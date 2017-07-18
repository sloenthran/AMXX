#include <amxmodx>
#include <amxmisc>
#include <colorchat>

new Players[33][64];
new MaxPlayers;

public plugin_init() 
{
    
	register_plugin("CFG Ban", "1.0", "Sloenthran");
    
	register_concmd("amx_bancfg", "BanCFG", ADMIN_BAN, "<nick>");
	
	register_clcmd("say /cfg", "MenuCFG");
	register_clcmd("say_team /cfg", "MenuCFG");
	
}

public plugin_cfg()
{

	MaxPlayers = get_maxplayers();

}

public client_authorized(User)
{
	
    new Info[32];
	
    get_user_info(User, "_cfgban", Info, 31);
    
    if(strlen(Info) > 0)
    {
		
        if(get_systime() < str_to_num(Info))
        {
			
            server_cmd("kick #%d ^"Jestes zbanowany!^"", get_user_userid(User));
			
        }
		
    }
	
}

public BanCFG(User , Access , Number)
{

	if(!cmd_access(User , Access , Number, 2))
	{
	
		ColorChat(User, GREEN, "[AMX CFG]^x03 Nie masz dostepu do tej komendy!");
	
		return PLUGIN_HANDLED; 
		
	}
	
	new Name[64], Target;
	
	read_argv(1, Name, 63);
	
	remove_quotes(Name);
	
	Target	= find_player("bjh" , Name);
	
	if(!is_user_connected(Target))
	{
	
		ColorChat(User, GREEN, "[AMX CFG]^x03 Nie znaleziono takiego gracza online!");
		
		return PLUGIN_HANDLED;
		
	}
	
	new UserName[64];
	
	get_user_name(Target, UserName, 63);
	
	client_cmd(Target, ";developer 1");
	client_cmd(Target, ";setinfo _cfgban %i", get_systime() + 3600);
	client_cmd(Target, ";developer 0");
	client_cmd(Target, ";disconnect");
	
	ColorChat(User, GREEN, "[AMX CFG]^x03 Ban na CFG zostal dodany graczowi %s!", UserName);
	
	return PLUGIN_HANDLED;
	
}

public MenuCFG(User)
{

	if(!(get_user_flags(User) & ADMIN_BAN))
	{
	
		ColorChat(User, GREEN, "[AMX CFG]^x03 Nie masz dostepu do tej komendy!");
	
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
	
	client_cmd(User, ";amx_bancfg ^"%s^"", Players[Item]);
	
	return PLUGIN_HANDLED;
	
}