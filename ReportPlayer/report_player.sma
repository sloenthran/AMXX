#include <amxmodx>
#include <sqlx>
#include <tutor>
#include <core>

new Handle:MySQL, ServerName[32];
new MaxPlayers, Players[32][32];
new ReportName[32][32], ReportReason[32][50];
new PlayerTimeBlock[32], PlayerNameBlock[32][32];
new Host, User, Pass, Base, NumberUser, NumberShout, CheckAdmin, CheckServerName, CvarServerName;
new GetHost[32], GetUser[32], GetPass[32], GetBase[32], GetNumberUser, GetNumberShout, GetCheckAdmin, GetCheckServerName;

public plugin_init() 
{

	register_plugin("Report Player", "6.0", "Sloenthran");
	
	tutorInit();
	
	Host = register_cvar("report_host", "", FCVAR_PROTECTED|FCVAR_SPONLY);
	User = register_cvar("report_user", "", FCVAR_PROTECTED|FCVAR_SPONLY);
	Pass = register_cvar("report_pass", "", FCVAR_PROTECTED|FCVAR_SPONLY);
	Base = register_cvar("report_base", "", FCVAR_PROTECTED|FCVAR_SPONLY);
	
	NumberUser  = register_cvar("report_number_user", "1", FCVAR_PROTECTED|FCVAR_SPONLY);
	NumberShout = register_cvar("report_number_shout", "3", FCVAR_PROTECTED|FCVAR_SPONLY);
	CheckAdmin  = register_cvar("report_check_admin", "1", FCVAR_PROTECTED|FCVAR_SPONLY);
	CheckServerName = register_cvar("report_check_server_name", "1", FCVAR_PROTECTED|FCVAR_SPONLY);
	CvarServerName = register_cvar("report_server_name", "", FCVAR_PROTECTED|FCVAR_SPONLY);
	
	register_clcmd("say /zglos", "PlayerMenu");
	register_clcmd("say_team /zglos", "PlayerMenu");
	
}

public plugin_precache()
{

	tutorPrecache();

}

public plugin_cfg()
{

	get_pcvar_string(Host, GetHost, 31);
	get_pcvar_string(User, GetUser, 31);
	get_pcvar_string(Pass, GetPass, 31);
	get_pcvar_string(Base, GetBase, 31);
	
	GetCheckAdmin  = get_pcvar_num(CheckAdmin);
	GetNumberUser  = get_pcvar_num(NumberUser);
	GetNumberShout = get_pcvar_num(NumberShout);
	GetCheckServerName = get_pcvar_num(CheckServerName);

	MaxPlayers = get_maxplayers();

	MySQL = SQL_MakeDbTuple(GetHost, GetUser, GetPass, GetBase);
	
	if(GetCheckServerName == 1)
	{
	
		set_task(1.0, "GetServerName");
		
	}
	
	else
	{
	
		get_pcvar_string(CvarServerName, ServerName, 31);
	
	}

}

public GetServerName()
{

	new OutPut[2][32];

	get_user_name(0, ServerName, 31);
	
	explode(ServerName, '@', OutPut, 2, 31);
	
	ServerName = OutPut[0];

}

public PlayerMenu(id)
{

	if(PlayerTimeBlock[id] > get_systime())
	{
	
		tutorMake(id, TUTOR_RED, 5.0, "Odczekaj minute przed ponownym zgloszeniem!");
	
		return PLUGIN_HANDLED;
	
	}

	new Name[32];
	
	new PlayersNumber = 0;
	
	new Menu = menu_create("Wybierz gracza", "PlayerMenuHandle");
	
	for(new Number = 1; Number <= MaxPlayers; Number++)
	{
		
		if(is_user_connected(Number) && !is_user_bot(Number) && !is_user_hltv(Number))
		{
		
			get_user_name(Number, Name, 31);
			
			Players[PlayersNumber] = Name;

			PlayersNumber++;
			
			menu_additem(Menu, Name);
		
		}
		
	}
	
	menu_setprop(Menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(Menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(Menu, MPROP_EXITNAME, "Wyjscie");
	
	menu_display(id, Menu);
	
	return PLUGIN_HANDLED;

}

public PlayerMenuHandle(id, Menu, Item)
{
	
	if(Item == MENU_EXIT) 
	{
		
		menu_destroy(Menu);
	
		return PLUGIN_HANDLED;
	
	}
	
	ReportName[id] = Players[Item];
 
	menu_destroy(Menu);
	
	if(equali(ReportName[id], PlayerNameBlock[Item]))
	{
	
		tutorMake(id, TUTOR_RED, 5.0, "Ten gracz przed chwila byl zglaszany!");
	
		return PLUGIN_HANDLED;
	
	}
	
	PlayerNameBlock[Item] = ReportName[id];
	
	set_task(300.0, "UnblockPlayerName", id);
	
	PlayerReasonMenu(id);

	return PLUGIN_HANDLED;

}

public PlayerReasonMenu(id)
{

	new Menu = menu_create("Wybierz powod", "PlayerReasonHandle");
	
	menu_additem(Menu, "Gracz ma WH");
	menu_additem(Menu, "Gracz ma SH");
	menu_additem(Menu, "Gracz ma AIM-a");
	menu_additem(Menu, "Gracz utrudnia gre");
	menu_additem(Menu, "Gracz reklamuje");
	menu_additem(Menu, "Gracz nie wykonuje celow mapy");
	
	menu_setprop(Menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(Menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(Menu, MPROP_EXITNAME, "Wyjscie");
	
	menu_display(id, Menu);
	
	return PLUGIN_HANDLED;

}

public PlayerReasonHandle(id, Menu, Item)
{
	
	if(Item == MENU_EXIT) 
	{
		
		menu_destroy(Menu);
	
		return PLUGIN_HANDLED;
	
	}
	
	switch(Item)
	{
	
		case 0: ReportReason[id] = "ma WH";
		case 1: ReportReason[id] = "ma SH";
		case 2: ReportReason[id] = "ma AIM-a";
		case 3: ReportReason[id] = "utrudnia gre";
		case 4: ReportReason[id] = "reklamuje";
		case 5: ReportReason[id] = "nie wykonuje celow mapy";
	
	}
	
	menu_destroy(Menu);
	
	switch(GetCheckAdmin)
	{
	
		case 1: QueryCheckAdmin(id);
		case 2: AddShouts(id);

	}
	
	return PLUGIN_HANDLED;
	
}

public QueryCheckAdmin(id)
{

	new AdminNumber;

	for(new Number = 1; Number <= MaxPlayers; Number++)
	{
		
		if(is_user_connected(Number) && !is_user_bot(Number) && !is_user_hltv(Number) && get_user_flags(Number) & ADMIN_BAN)
		{
		
			AdminNumber++;
		
		}
		
	}
	
	if(AdminNumber > 0)
	{
	
		new Message[256];
		
		new Time = get_systime();
		
		formatex(Message, 255, "[Report Player] Gracz %s %s", ReportName[id], ReportReason[id]);
		
		client_cmd(id, "; say_team @ %s", Message);
		
		tutorMake(id, TUTOR_RED, 5.0, "Gracz zostal zgloszony!");
	
		PlayerTimeBlock[id] = Time + 60;
	
	}
	
	else
	{
	
		AddShouts(id);
	
	}

}

public AddShouts(id)
{

	switch(GetNumberShout)
	{
	
		case 1: AddShoutsIPB(id);
		case 2: AddShoutsPHPBB3(id);
		case 3: AddReportPlayerIframe(id);
		case 4: AddShoutsMyBB(id);
	
	}

}

public UnblockPlayerName(id)
{

	PlayerNameBlock[id] = "";

}

public AddShoutsIPB(id)
{

	static Query[512];
	
	new IP[32], Name[32];

	new Time = get_systime();

	get_user_name(id, Name, 31);
	get_user_ip(id, IP, 31, 1);
	
	formatex(Query, 511, "INSERT INTO shoutbox_shouts VALUES('', '%i', '%i', '[color=#93f710][b][ReportPlayer][/b][/color] Serwer: [b]%s[/b] | Zgłaszający: [b]%s[/b] | Wiadomość: Gracz [b]%s %s[/b]', '%s', 'NULL');", GetNumberUser, Time, ServerName, Name, ReportName[id], ReportReason[id], IP);
	
	tutorMake(id, TUTOR_RED, 5.0, "Gracz zostal zgloszony!");
	
	PlayerTimeBlock[id] = Time + 60;
	
	SQL_ThreadQuery(MySQL, "Query", Query);
	
}

public AddShoutsPHPBB3(id)
{

	static Query[512];
	
	new IP[32], Name[32];

	new Time = get_systime();

	get_user_name(id, Name, 31);
	get_user_ip(id, IP, 31, 1);
	
	formatex(Query, 511, "INSERT INTO phpbb3_mchat VALUES('', '%i', '%s', '[ReportPlayer] Serwer: %s | Zgłaszający: %s | Wiadomość: Gracz %s %s', '', '', '7', '%i', '0', '0');", GetNumberUser, IP, ServerName, Name, ReportName[id], ReportReason[id], Time);
	
	tutorMake(id, TUTOR_RED, 5.0, "Gracz zostal zgloszony!");
	
	PlayerTimeBlock[id] = Time + 60;
	
	SQL_ThreadQuery(MySQL, "Query", Query);	

}

public AddReportPlayerIframe(id)
{

	static Query[512];
	
	new IP[32], Name[32];

	new Time = get_systime();

	get_user_name(id, Name, 31);
	get_user_ip(id, IP, 31, 1);
	
	formatex(Query, 511, "INSERT INTO report_player VALUES('', '%s', '%i', '%s', '%s', '%s %s')", ServerName, Time, IP, Name, ReportName[id], ReportReason[id]);
	
	tutorMake(id, TUTOR_RED, 5.0, "Gracz zostal zgloszony!");
	
	PlayerTimeBlock[id] = Time + 60;
	
	SQL_ThreadQuery(MySQL, "Query", Query);
	
}

public AddShoutsMyBB(id)
{

	static Query[512];
	
	new IP[32], Name[32];

	new Time = get_systime();

	get_user_name(id, Name, 31);
	get_user_ip(id, IP, 31, 1);
	
	formatex(Query, 511, "INSERT INTO mybb_dvz_shoutbox VALUES('', '%i', '[color=#93f710][b][ReportPlayer][/b][/color] Serwer: [b]%s[/b] | Zgłaszający: [b]%s[/b] | Wiadomość: Gracz [b]%s %s[/b]', '%i', 'NULL', '%s');", GetNumberUser, ServerName, Name, ReportName[id], ReportReason[id], Time, IP);
	
	tutorMake(id, TUTOR_RED, 5.0, "Gracz zostal zgloszony!");
	
	PlayerTimeBlock[id] = Time + 60;
	
	SQL_ThreadQuery(MySQL, "Query", Query);	

}

public Query(iFailState, Handle:hQuery, szError[], iError, iData[], iDataSize, Float:fQueueTime) 
{ 

	if(iFailState == TQUERY_CONNECT_FAILED || iFailState == TQUERY_QUERY_FAILED) 
	{
	
		log_amx("%s", szError); 
		
		return;
		
	}
	
}

stock explode(const string[], const character, output[][], const maxs, const maxlen)
{

	new iDo = 0, len = strlen(string), oLen = 0;

	do
	{
	
		oLen += (1+copyc(output[iDo++],maxlen,string[oLen],character));
		
	} while(oLen < len && iDo < maxs);
	
}
