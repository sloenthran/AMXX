#include <amxmodx>
#include <colorchat>
#include <core>

native cod_get_perk_name(User, Perk[], Length);
native cod_set_user_perk(User, Item);
native cod_get_user_class(User);
native cod_get_user_perk(User);

new bool:BlockPerk[33];
new SendPerk[33];

public plugin_init() 
{
	
	register_plugin("Exchange Perk", "1.4.1", "Sloenthran");
	
	register_clcmd("say /wymien", "OpenMenu");
	register_clcmd("say /zamien", "OpenMenu");
	
	register_clcmd("say_team /wymien", "OpenMenu");
	register_clcmd("say_team /zamien", "OpenMenu");

}

public client_authorized(User)
{
	
	BlockPerk[User] = false;
	
}

public OpenMenu(User)
{
	
	new Menu = menu_create("Menu Wymiany", "MenuHandle");
	
	menu_additem(Menu, "Wymien Perk");
	
	if(!BlockPerk[User])
	{
		
		menu_additem(Menu,"\wMozliwosc wymiany \d[\rOdblokowana\d]");
	
	}
	
	else 
	{
	
		menu_additem(Menu,"\wMozliwosc wymiany \d[\rZablokowana\d]");
	
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
	
	switch(Item)
	{
		
		case 0:
		{
			
			menu_destroy(Menu);
			
			ChangePerk(User);
			
			return PLUGIN_HANDLED;
			
		}
		
		case 1:
		{
			
			if(!BlockPerk[User])
			{
				
				BlockPerk[User] = true;
				
			}
			
			else
			{
				
				BlockPerk[User] = false;
				
			}
			
			menu_destroy(Menu);
			
			OpenMenu(User);
			
			return PLUGIN_HANDLED;
			
		}
		
	}
	
	menu_destroy(Menu);
	
	return PLUGIN_HANDLED;
	
}

public ChangePerk(User)
{
	
	new Text[128], Perk[33], PerkNumber;
	
	new Menu = menu_create("Zamien sie perkiem", "HandleChangePerk");
	
	new Name[64];
	
	new CallBack = menu_makecallback("MenuCallBack");
	
	for(new Number = 0; Number <= 32; Number++)
	{
		
		if(!is_user_connected(Number) || BlockPerk[Number])
		{
			
			continue;
			
		}
		
		SendPerk[PerkNumber++] = Number;
		
		get_user_name(Number, Name, 63);
		
		cod_get_perk_name(cod_get_user_perk(Number), Perk, 32);
		
		format(Text, 127, "%s \d[\y%s\d]", Name, Perk); 
		
		menu_additem(Menu, Text, .callback=CallBack);
		
    }
	
	menu_setprop(Menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(Menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(Menu, MPROP_EXITNAME, "Wyjscie");
	
	menu_display(User, Menu);
	
}

public HandleChangePerk(User, Menu, Item)
{
	
	if(Item == MENU_EXIT) 
	{
		
		menu_destroy(Menu);
		
		return PLUGIN_HANDLED;
		
	}
	
	if(!is_user_connected(SendPerk[Item]))
	{
		
		ColorChat(User, GREEN, "[~]^x01 Nie odnaleziono zadanego gracza.");
		
		menu_destroy(Menu);
		
		return PLUGIN_HANDLED;
	
	}
	
	if(!cod_get_user_perk(SendPerk[Item]))
	{
		
		ColorChat(User, GREEN, "[~]^x01 Wybrany gracz nie ma zadnego perku.");

		menu_destroy(Menu);
		
		return PLUGIN_HANDLED;
		
	}
	
	if(!cod_get_user_perk(User))
	{
		
		ColorChat(User, GREEN, "[~]^x01 Nie masz zadnego perku.");
		
		menu_destroy(Menu);
		
		return PLUGIN_HANDLED;
		
	}

	new MenuName[128], Name[64];
	
	get_user_name(User, Name, 63);
	
	formatex(MenuName, 127, "\y[\rProjektSpark.PL\y] \wWymien sie perkiem z\r %s\w:", Name);
	
	new MenuTwo = menu_create(MenuName, "SendPerkHandle");

	menu_additem(MenuTwo, "Tak", Name);
	menu_additem(MenuTwo, "Nie", Name);
	
	menu_setprop(MenuTwo, MPROP_BACKNAME, "Wroc");
	menu_setprop(MenuTwo, MPROP_NEXTNAME, "Dalej");
	menu_setprop(MenuTwo, MPROP_EXITNAME, "Wyjscie");
	
	menu_display(SendPerk[Item], MenuTwo);
	
	return PLUGIN_HANDLED;
	
}

public SendPerkHandle(User, Menu, Item)
{
	
	if(Item == MENU_EXIT) 
	{
		
		menu_destroy(Menu);
		
		return PLUGIN_HANDLED;
		
	}
	
	new Access, CallBack, Data[64];
	
	menu_item_getinfo(Menu, Item, Access, Data, 63, _, _, CallBack);
	
	new Player = get_user_index(Data);
	
	switch(Item)
	{
		
		case 0: 
		{ 
		
			new PerkPlayer = cod_get_user_perk(Player);
			new PerkUser = cod_get_user_perk(User);
			
			cod_set_user_perk(Player, PerkUser);
			cod_set_user_perk(User, PerkPlayer);
			
			new Name[64];
			
			get_user_name(User, Name, 63);
		
			ColorChat(User, GREEN, "[COD]^x03 Wymieniles sie perkiem z %s.", Data);
			ColorChat(Player, GREEN, "[COD]^x03 Wymieniles sie perkiem z %s.", Name);
			
		}
		
		case 1: ColorChat(Player, GREEN, "[COD]^x03 Wybrany gracz nie zgodzil sie na wymiane perka.");
	
	}
	
	menu_destroy(Menu);
	
	return PLUGIN_HANDLED;
	
}

public MenuCallBack(User, Menu, Item)
{
	
	if(SendPerk[Item] == User || !cod_get_user_class(SendPerk[Item]) || !cod_get_user_perk(SendPerk[Item]))
	{
		
		return ITEM_DISABLED;
		
	}
	
	return ITEM_ENABLED;
	
}