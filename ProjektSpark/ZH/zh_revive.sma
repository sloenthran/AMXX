#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <cstrike>

new MaxPlayers, Players[33][33];

public plugin_init()
{
	
	register_plugin("[ZH] Revive Player", "1.0", "Sloenthran")
	
	register_clcmd("say /revive", "OpenMenu");
	register_clcmd("say_team /revive", "OpenMenu");
	
}

public plugin_cfg()
{
	
	MaxPlayers = get_maxplayers();
	
}

public OpenMenu(User)
{
	
	if(!(get_user_flags(User) & ADMIN_IMMUNITY))
	{
		
		return PLUGIN_HANDLED;
		
	}

	new Name[64], PlayersNumber = 0;
	
	new Menu = menu_create("Wybierz gracza", "HandleMenu");
	
	for(new Number = 1; Number <= MaxPlayers; Number++)
	{
		
		if(is_user_connected(Number) && !is_user_bot(Number) && !is_user_hltv(Number) && !is_user_alive(Number))
		{
		
			get_user_name(Number, Name, 63);
			
			Players[User][PlayersNumber] = Number;

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

public HandleMenu(User, Menu, Item)
{
	
	if(Item == MENU_EXIT) 
	{
		
		menu_destroy(Menu);
	
		return PLUGIN_HANDLED;
	
	}
	
	new ID = Players[User][Item];
 
	menu_destroy(Menu);
	
	ExecuteHamB(Ham_CS_RoundRespawn, ID);
	
	return PLUGIN_HANDLED;
	
}