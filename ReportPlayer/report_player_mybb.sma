#include <amxmodx>
#include <sqlx>
#include <core>
#include <colorchat>

new Handle:MySQL;

new CvarHost, CvarUser, CvarPass, CvarBase, CvarNumberUser, CvarServerName, CvarCheckName, CvarCheckAdmin;
new ValueHost[32], ValueUser[32], ValuePass[32], ValueBase[32], ValueNumberUser, ValueServerName[64], ValueCheckName, ValueCheckAdmin;

new PlayerTimeBlock[33], PlayerNameBlock[33][64];
new MaxPlayers, Players[33][64];
new ReportName[33][64], ReportReason[33][64];

public plugin_init()
{
	
	register_plugin("Report Player [MyBB]", "1.4", "Sloenthran");
	
	set_task(0.5, "PrepareSQL");
	
	register_clcmd("say /zglos", "PlayerMenu");
	register_clcmd("say_team /zglos", "PlayerMenu");
	
	CvarHost = register_cvar("report_host", "", FCVAR_PROTECTED|FCVAR_SPONLY);
	CvarUser = register_cvar("report_user", "", FCVAR_PROTECTED|FCVAR_SPONLY);
	CvarPass = register_cvar("report_pass", "", FCVAR_PROTECTED|FCVAR_SPONLY);
	CvarBase = register_cvar("report_base", "", FCVAR_PROTECTED|FCVAR_SPONLY);
	
	CvarNumberUser = register_cvar("report_number_user", "1", FCVAR_PROTECTED|FCVAR_SPONLY);
	CvarServerName = register_cvar("report_server_name", "Sloenthran.pl", FCVAR_PROTECTED|FCVAR_SPONLY);
	CvarCheckName = register_cvar("report_check_name", "1", FCVAR_PROTECTED|FCVAR_SPONLY);
	CvarCheckAdmin = register_cvar("report_check_admin", "1", FCVAR_PROTECTED|FCVAR_SPONLY);
	
}

public plugin_cfg()
{
	
	MaxPlayers = get_maxplayers();
	
}

public PrepareSQL()
{
	
	get_pcvar_string(CvarHost, ValueHost, 31);
	get_pcvar_string(CvarUser, ValueUser, 31);
	get_pcvar_string(CvarPass, ValuePass, 31);
	get_pcvar_string(CvarBase, ValueBase, 31);
	
	ValueNumberUser = get_pcvar_num(CvarNumberUser);
	ValueCheckName = get_pcvar_num(CvarCheckName);
	ValueCheckAdmin = get_pcvar_num(CvarCheckAdmin);
	
	if(ValueCheckName == 1)
	{
		
		new OutPut[2][64];

		get_user_name(0, ValueServerName, 63);
	
		explode(ValueServerName, '@', OutPut, 2, 63);
	
		ValueServerName = OutPut[0];
		
	}
	
	else
	{
		
		get_pcvar_string(CvarServerName, ValueServerName, 63);
		
	}
	
	MySQL = SQL_MakeDbTuple(ValueHost, ValueUser, ValuePass, ValueBase);
	
}

public Query(FailState, Handle:Query, Error[])
{
	
	if(FailState != TQUERY_SUCCESS)
	{
		
		log_amx("[SQL Error] %s", Error);
		
		return PLUGIN_HANDLED;
		
	}
	
	return PLUGIN_HANDLED;
	
}

public PlayerMenu(User)
{

	if(PlayerTimeBlock[User] > get_systime())
	{
	
		ColorChat(User, GREEN, "[ReportPlayer]^x03 Odczekaj minute przed ponownym zgloszeniem!");
	
		return PLUGIN_HANDLED;
	
	}

	new Name[64];
	
	new PlayersNumber = 0;
	
	new Menu = menu_create("Wybierz gracza", "PlayerMenuHandle");
	
	for(new Number = 1; Number <= MaxPlayers; Number++)
	{
		
		if(is_user_connected(Number) && !is_user_bot(Number) && !is_user_hltv(Number))
		{
		
			get_user_name(Number, Name, 63);
			
			Players[PlayersNumber] = Name;

			PlayersNumber++;
			
			menu_additem(Menu, Name);
		
		}
		
	}
	
	menu_setprop(Menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(Menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(Menu, MPROP_EXITNAME, "Wyjscie");
	
	menu_display(User, Menu);
	
	return PLUGIN_HANDLED;

}

public PlayerMenuHandle(User, Menu, Item)
{
	
	if(Item == MENU_EXIT) 
	{
		
		menu_destroy(Menu);
	
		return PLUGIN_HANDLED;
	
	}
	
	ReportName[User] = Players[Item];
 
	menu_destroy(Menu);
	
	if(equali(ReportName[User], PlayerNameBlock[Item]))
	{
	
		ColorChat(User, GREEN, "[ReportPlayer]^x03 Ten gracz przed chwila byl zglaszany!");
	
		return PLUGIN_HANDLED;
	
	}
	
	PlayerNameBlock[Item] = ReportName[User];
	
	set_task(300.0, "UnblockPlayerName", User);
	
	PlayerReasonMenu(User);

	return PLUGIN_HANDLED;

}

public PlayerReasonMenu(User)
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
	
	menu_display(User, Menu);
	
	return PLUGIN_HANDLED;

}

public PlayerReasonHandle(User, Menu, Item)
{
	
	if(Item == MENU_EXIT) 
	{
		
		menu_destroy(Menu);
	
		return PLUGIN_HANDLED;
	
	}
	
	switch(Item)
	{
	
		case 0: ReportReason[User] = "ma WH";
		case 1: ReportReason[User] = "ma SH";
		case 2: ReportReason[User] = "ma AIM-a";
		case 3: ReportReason[User] = "utrudnia gre";
		case 4: ReportReason[User] = "reklamuje";
		case 5: ReportReason[User] = "nie wykonuje celow mapy";
	
	}
	
	menu_destroy(Menu);
	
	switch(ValueCheckAdmin)
	{
	
		case 1: CheckAdmin(User);
		case 2: AddShouts(User);

	}
	
	return PLUGIN_HANDLED;
	
}

public CheckAdmin(User)
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
	
		static Query[512];
		
		formatex(Query, 511, "[Report Player] Gracz %s %s", ReportName[User], ReportReason[User]);
		
		client_cmd(User, "; say_team @ %s", Query);
		
		ColorChat(User, GREEN, "[ReportPlayer]^x03 Gracz zostal zgloszony!");
	
		PlayerTimeBlock[User] = get_systime() + 60;
	
	}
	
	else
	{
	
		AddShouts(User);
	
	}

}

public AddShouts(User)
{
	
	new IP[32], Name[64];
	
	static Query[512];
	
	get_user_name(User, Name, 63);
	get_user_ip(User, IP, 31, 1);
	
	formatex(Query, 511, "INSERT INTO mybb_dvz_shoutbox VALUES('', '%i', '[color=#93f710][b][ReportPlayer][/b][/color] Serwer: [b]%s[/b] | Zglaszajacy: [b]%s[/b] | Wiadomosc: Gracz [b]%s %s[/b]', UNIX_TIMESTAMP(NOW()), 'NULL', '%s');", ValueNumberUser, ValueServerName, Name, ReportName[User], ReportReason[User], IP);
	
	SQL_ThreadQuery(MySQL, "Query", Query);
	
	ColorChat(User, GREEN, "[ReportPlayer]^x03 Gracz zostal zgloszony!");
	
	PlayerTimeBlock[User] = get_systime() + 60;
	
}

public UnblockPlayerName(User)
{

	PlayerNameBlock[User] = "";

}

stock explode(const string[], const character, output[][], const maxs, const maxlen)
{

	new iDo = 0, len = strlen(string), oLen = 0;

	do
	{
	
		oLen += (1+copyc(output[iDo++],maxlen,string[oLen],character));
		
	} while(oLen < len && iDo < maxs);
	
}