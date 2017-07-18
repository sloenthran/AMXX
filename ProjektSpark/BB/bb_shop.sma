#include <amxmodx>
#include <nvault>
#include <colorchat>
#include <fun>
#include <cstrike>

new nVault;

new UserData[33];

new CvarCT, CvarTT, CvarHS, ValueCT, ValueTT, ValueHS;

public plugin_init()
{
	
	register_plugin("[BB] Shop", "1.0", "Sloenthran");
	
	nVault = nvault_open("BBShop");
	
	register_clcmd("say /sklep", "OpenMenu");
	register_clcmd("say_team /sklep", "OpenMenu");
	register_clcmd("say /ulepsz", "OpenMenu");
	register_clcmd("say_team /ulepsz", "OpenMenu");
	
	register_event("DeathMsg", "DeathMsg", "a");
	
	CvarCT = register_cvar("bb_shop_ct", "1", FCVAR_PROTECTED|FCVAR_SPONLY);
	CvarTT = register_cvar("bb_shop_tt", "1", FCVAR_PROTECTED|FCVAR_SPONLY);
	CvarHS = register_cvar("bb_shop_hs", "1", FCVAR_PROTECTED|FCVAR_SPONLY)
	
}

public plugin_cfg()
{
	
	ValueCT = get_pcvar_num(CvarCT);
	ValueTT = get_pcvar_num(CvarTT);
	ValueHS = get_pcvar_num(CvarHS);
	
	nvault_prune(nVault, 0, get_systime()- 5184000);
	
}

public plugin_natives()
{
	
	register_native("bb_shop_get_points", "NativeReturn", 1);
	register_native("bb_shop_set_points", "NativeSet", 1);
	register_native("bb_shop_add_points", "NativeAdd", 1);
	
	set_native_filter("NativeFilter");
	
}

public NativeReturn(User)
{
	
	return UserData[User];
	
}

public NativeSet(User, Number)
{
	
	UserData[User] = Number;
	
}

public NativeAdd(User, Number)
{
	
	UserData[User] += Number;
	
}


public NativeFilter()
{
	
	return PLUGIN_HANDLED;
	
}

public client_authorized(User)
{
	
	UserData[User] = 0;
	
	if(!is_user_hltv(User) && !is_user_bot(User))
	{
		
		LoadData(User);
		
	}
	
}

public client_disconnect(User)
{
	
	if(!is_user_hltv(User) && !is_user_bot(User))
	{

		SaveData(User);
		
	}

}

public plugin_end()
{

	nvault_close(nVault);

}

public LoadData(User)
{

	new Key[128], Data[256], Name[64];
	
	get_user_name(User, Name, 63);

	format(Key, 127, "%s-ChangeModel", Name);
	format(Data, 255, "%i", UserData[User]);

	nvault_get(nVault, Key, Data, 255);
	
	UserData[User] = str_to_num(Data);
	
	nvault_touch(nVault, Key);

}

public SaveData(User)
{

	new Key[128], Data[256], Name[64];
	
	get_user_name(User, Name, 63);
	
	format(Key, 127, "%s-ChangeModel", Name);
	format(Data, 255, "%i", UserData[User]);
	
	nvault_set(nVault, Key, Data);
	
}

public OpenMenu(User)
{
	
	new Format[64];
	
	formatex(Format, 63,"\wSklep BB by \rLvB^n\rIlosc Punktow: \w%i", UserData[User]);
	
	new Menu = menu_create(Format, "HandleMenu");
	
	menu_additem(Menu, "\wSklep \r[Tylko CT]");
	menu_additem(Menu, "\wUlepsz klase \r[Tylko TT]");
	
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
	
	switch(Item)
	{
		
		case 0:
		{
			
			menu_destroy(Menu);
			
			ShopMenu(User);
			
		}
		
		case 1:
		{
			
			menu_destroy(Menu);
			
			UpgradeMenu(User);
			
		}
		
	}
	
	return PLUGIN_HANDLED;
	
}

public ShopMenu(User)
{
	
	new Format[64];
	
	formatex(Format, 63,"\wSklep BB by \rLvB^n\rIlosc Punktow: \w%i", UserData[User]);
	
	new Menu = menu_create(Format, "HandleShopMenu");
	
	menu_additem(Menu, "\wGranat Frost \r[2 punkty]");
	menu_additem(Menu, "\wGranat Napalm \r[3 punkty]");
	menu_additem(Menu, "\wMinigun \r[15 punktow]]");
	menu_additem(Menu, "\wBazooka \r[8 punktow]");
	menu_additem(Menu, "\wGrawitacja \r[6 punktow]");
	
	menu_setprop(Menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(Menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(Menu, MPROP_EXITNAME, "Wyjscie");
	
	menu_display(User, Menu);
	
	return PLUGIN_HANDLED;
	
}

public HandleShopMenu(User, Menu, Item)
{
	
	if(Item == MENU_EXIT || !is_user_alive(User) || !(cs_get_user_team(User) == CS_TEAM_CT))
	{
		
		menu_destroy(Menu);
		
		return PLUGIN_HANDLED;
		
	}
	
	switch(Item)
	{
		
		case 0:
		{
			
			if(UserData[User] >= 2)
			{
				
				UserData[User] -= 2;
				
				give_item(User, "weapon_smokegrenade");
				
				ColorChat(User, GREEN, "[SKLEP] ^x01 Kupiles granat zamrazajacy");
				
			}
			
			else
			{
				
				ColorChat(User, GREEN, "[SKLEP] ^x01 Nie stac Cie na to!");
				
			}
			
		}
		
		case 1:
		{
			
			if(UserData[User] >= 3)
			{
				
				UserData[User] -= 3;
				
				give_item(User, "weapon_hegrenade");
				
				ColorChat(User, GREEN, "[SKLEP] ^x01 Kupiles napalm");
				
			}
			
			else
			{
				
				ColorChat(User, GREEN, "[SKLEP] ^x01 Nie stac Cie na to!");
				
			}
			
		}
		
		case 2:
		{
			
			if(UserData[User] >= 15)
			{
				
				UserData[User] -= 15;
				
				new Name[64];
				
				get_user_name(User, Name, 63);
				
				server_cmd("amx_minigun_daj ^"%s^"", Name);
				
				ColorChat(User, GREEN, "[SKLEP] ^x01 Kupiles miniguna");
				
			}
			
			else
			{
				
				ColorChat(User, GREEN, "[SKLEP] ^x01 Nie stac Cie na to!");
				
			}
			
		}
		
		case 3:
		{
			
			if(UserData[User] >= 8)
			{
				
				UserData[User] -= 8;
				
				new Name[64];
				
				get_user_name(User, Name, 63);
				
				server_cmd("amx_bazooka_give ^"%s^"", Name);
				
				ColorChat(User, GREEN, "[SKLEP] ^x01 Kupiles bazooke");
				
			}
			
			else
			{
				
				ColorChat(User, GREEN, "[SKLEP] ^x01 Nie stac Cie na to!");
				
			}
			
		}
		
		case 4:
		{
			
			if(UserData[User] >= 6)
			{
				
				UserData[User] -= 6;
				
				set_user_gravity(User, 0.45)
				
				ColorChat(User, GREEN, "[SKLEP] ^x01 Zmniejszyles swoja grawitacje");
				
			}
			
			else
			{
				
				ColorChat(User, GREEN, "[SKLEP] ^x01 Nie stac Cie na to!");
				
			}
			
		}
		
	}
	
	menu_destroy(Menu);
	
	return PLUGIN_HANDLED;
	
}

public UpgradeMenu(User)
{
	
	new Format[64];
	
	formatex(Format, 63,"\wSklep BB by \rLvB^n\rIlosc Punktow: \w%i", UserData[User]);
	
	new Menu = menu_create(Format, "HandleUpgradeMenu");
	
	menu_additem(Menu, "\w500 HP \r[8 punktow]");
	menu_additem(Menu, "\w1000 HP \r[12 punktow]");
	menu_additem(Menu, "\w1500 HP \r[16 punktow]]");
	
	menu_setprop(Menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(Menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(Menu, MPROP_EXITNAME, "Wyjscie");
	
	menu_display(User, Menu);
	
	return PLUGIN_HANDLED;
	
}

public HandleUpgradeMenu(User, Menu, Item)
{
	
	if(Item == MENU_EXIT || !is_user_alive(User) || !(cs_get_user_team(User) == CS_TEAM_T)) 
	{
		
		menu_destroy(Menu);
		
		return PLUGIN_HANDLED;
		
	}
	
	switch(Item)
	{
		
		case 0:
		{
			
			if(UserData[User] >= 8)
			{
				
				UserData[User] -= 8;
				
				set_user_health(User, get_user_health(User) + 500);
				
				ColorChat(User, GREEN, "[SKLEP] ^x01 Kupiles 500 HP");
				
			}
			
			else
			{
				
				ColorChat(User, GREEN, "[SKLEP] ^x01 Nie stac Cie na to!");
				
			}
			
		}
		
		case 1:
		{
			
			if(UserData[User] >= 12)
			{
				
				UserData[User] -= 12;
				
				set_user_health(User, get_user_health(User) + 1000);
				
				ColorChat(User, GREEN, "[SKLEP] ^x01 Kupiles 1000 HP");
				
			}
			
			else
			{
				
				ColorChat(User, GREEN, "[SKLEP] ^x01 Nie stac Cie na to!");
				
			}
			
		}
		
		case 2:
		{
			
			if(UserData[User] >= 16)
			{
				
				UserData[User] -= 16;
				
				set_user_health(User, get_user_health(User) + 1500);
				
				ColorChat(User, GREEN, "[SKLEP] ^x01 Kupiles 1500 HP");
				
			}
			
			else
			{
				
				ColorChat(User, GREEN, "[SKLEP] ^x01 Nie stac Cie na to!");
				
			}
			
		}
		
	}
	
	return PLUGIN_HANDLED;
	
}

public DeathMsg()
{

	new Killer = read_data(1);
	new Killed = read_data(2);
	new HS = read_data(3);
	
	if(Killer != Killed && Killer)
	{
		
		if(get_user_flags(Killer) & ADMIN_LEVEL_H)
		{
			
			UserData[Killer] += 1;
			
		}
		
		if(cs_get_user_team(Killer) == CS_TEAM_CT)
		{
			
			UserData[Killer] += ValueCT;
			
			ColorChat(Killer, GREEN, "[SKLEP] ^x01 Dostales ^x04+%i ^x01punkty za zabojstwo!", ValueCT);
			
		}
		
		else
		{
			
			UserData[Killer] += ValueTT;
			
			ColorChat(Killer, GREEN, "[SKLEP] ^x01 Dostales ^x04+%i ^x01punkty za zabojstwo!", ValueTT);
			
		}
		
		if(HS)
		{
			
			UserData[Killer] += ValueHS;
			
			ColorChat(Killer, GREEN, "[SKLEP] ^x01 Dostales bonus za HS ^x04+%i ^x01punkty!", ValueHS);
			
		}
		
	}
	
}