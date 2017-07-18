#include <amxmodx>
#include <amxmisc>
#include <colorchat>

new Players[33][64];
new MaxPlayers;

public plugin_init()
{

	register_plugin("amx_ss", "2.7", "Sloenthran");

	register_concmd("amx_ss", "CreateSS", ADMIN_BAN, "<nick>");
	
	register_clcmd("say /ss", "MenuSS");
	register_clcmd("say_team /ss", "MenuSS");

}

public plugin_cfg()
{

	MaxPlayers = get_maxplayers();

}

public CreateSS(User , Access , Number)
{

	if(!cmd_access(User , Access , Number, 2))
	{
	
		ColorChat(User, GREEN, "[AMX SS]^x03 Nie masz dostepu do robienia SS!");
	
		return PLUGIN_HANDLED; 
		
	}
	
	new Name[64], Target;
	
	read_argv(1, Name, 63);
	
	remove_quotes(Name);
	
	Target	= find_player("bjh" , Name);
	
	if(!is_user_connected(Target))
	{
	
		ColorChat(User, GREEN, "[AMX SS]^x03 Nie znaleziono takiego gracza online!");
		
		return PLUGIN_HANDLED;
		
	}
	
	new Data[2];
	
	Data[1] = Target;
	Data[0] = 1;
	
	set_task(2.0, "Snapshot", .parameter=Data, .len=2);
	
	Data[0] = 2;
	
	set_task(4.0, "Snapshot", .parameter=Data, .len=2);
	
	Data[0] = 3;
	
	set_task(6.0, "Snapshot", .parameter=Data, .len=2);
	
	Data[0] = 4;
	
	set_task(8.0, "Snapshot", .parameter=Data, .len=2);
	
	Data[0] = 5;
	
	set_task(10.0, "Snapshot", .parameter=Data, .len=2);
	
	Data[0] = User;
	
	set_task(12.0, "BanPlayer", .parameter=Data, .len=2);
	
	return PLUGIN_HANDLED;
 	
}

public Snapshot(const Data[])
{

	new Target = Data[1];
	
	client_cmd(Target, ";net_graph 3");
	client_cmd(Target, ";r_norefresh 1");
	client_cmd(Target, ";fps_max 1");
	client_cmd(Target, ";snapshot");
	client_cmd(Target, ";r_norefresh 0");
	client_cmd(Target, ";fps_max 101");
	
	return PLUGIN_HANDLED;

}

public BanPlayer(const Data[])
{

	new User = Data[0];
	new Target = Data[1];
	
	new UserName[64];
	
	get_user_name(Target, UserName, 63);

	ColorChat(User, GREEN, "[AMX SS]^x03 SS-y zostaly poprawnie zrobione graczowi %s!", UserName);
	
	client_cmd(User, ";amx_ban 0 ^"%s^" ^"Wstaw foty na Murzyny.pl!^"", UserName);
	
	return PLUGIN_HANDLED;

}

public MenuSS(User)
{

	if(!(get_user_flags(User) & ADMIN_BAN))
	{
	
		ColorChat(User, GREEN, "[AMX SS]^x03 Nie masz dostepu do robienia SS!");
	
		return PLUGIN_HANDLED; 
	
	}
	
	new Name[64];
	
	new PlayersNumber = 0;
	
	new Menu = menu_create("Wybierz gracza", "MenuHandle");
	
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

public MenuHandle(User, Menu, Item)
{
	
	if(Item == MENU_EXIT) 
	{
	
		menu_destroy(Menu);
	
		return PLUGIN_HANDLED;
	
	}
 
	menu_destroy(Menu);
	
	client_cmd(User, ";amx_ss ^"%s^"", Players[Item]);
	
	return PLUGIN_HANDLED;
	
}