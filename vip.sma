#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <fun>
#include <hamsandwich>
#include <colorchat>
#include <core>

#define SCOREATTRIB_NONE	0
#define SCOREATTRIB_DEAD	(1<<0)
#define SCOREATTRIB_BOMB	(1<<1)
#define SCOREATTRIB_VIP		(1<<2)

new Round = 0;

public plugin_init()
{

	register_plugin("VIP", "1.9", "Sloenthran");
	
	register_logevent("NewRound", 2, "1=Round_Start");
	register_logevent("ResetRound", 2, "1=Game_Commencing")
	
	register_event("TextMsg", "ResetRound", "a", "2&Game_will_restart_in");
	register_event("DeathMsg", "DeathMsg", "a");
	
	RegisterHam(Ham_Spawn, "player", "PlayerSpawn", 1);
	
	register_clcmd("say /shop", "ShowShop");
	register_clcmd("say_team /shop", "ShowShop");
	
	register_clcmd("say /vip", "ShowVIP");
	register_clcmd("say_team /vip", "ShowVIP");
	
	register_message(get_user_msgid("ScoreAttrib"), "ChangeAttrib");
	
	set_task(130.0, "Adverts", .flags="b");
	
}

public ChangeAttrib()
{
	
	new Player = get_msg_arg_int(1);
	
	if(is_user_connected(Player) && (get_user_flags(Player) & ADMIN_LEVEL_H))
	{

		set_msg_arg_int(2, ARG_BYTE, is_user_alive(Player) ? SCOREATTRIB_VIP : SCOREATTRIB_DEAD);    
	
	}
	
}

public NewRound()
{
	
	Round += 1;
	
}

public ResetRound()
{
	
	Round = 0;
	
}

public PlayerSpawn(User)
{
	
	if(!is_user_alive(User))
	{
		
		return PLUGIN_HANDLED;
		
	}
	
	if(get_user_flags(User) & ADMIN_LEVEL_H)
	{
		
		if(Round >= 3)
		{
			
			MenuVIP(User);
			
		}
		
		else
		{
			
			GiveOthers(User);
			
		}
		
	}
	
	return PLUGIN_HANDLED;
	
}

public MenuVIP(User)
{
	
	if(!is_user_alive(User))
	{
		
		return PLUGIN_HANDLED;
		
	}
	
	new Menu = menu_create("[VIP] Wybierz bron", "MenuHandle");
	
	menu_additem(Menu, "M4A1 + Deagle");
	menu_additem(Menu, "AK47 + Deagle");
	menu_additem(Menu, "AWP + Deagle");
	menu_additem(Menu, "M249 + Deagle");
	menu_additem(Menu, "XM1014 + Deagle");
	
	menu_setprop(Menu, MPROP_BACKNAME, "Wroc");
	menu_setprop(Menu, MPROP_NEXTNAME, "Dalej");
	menu_setprop(Menu, MPROP_EXITNAME, "Wyjscie");
	
	menu_display(User, Menu);
	
	return PLUGIN_HANDLED;
	
}

public MenuHandle(User, Menu, Item)
{
	
	if(!is_user_alive(User))
	{
		
		menu_destroy(Menu);
		
		return PLUGIN_HANDLED;
		
	}
	
	if(Item == MENU_EXIT) 
	{
		
		menu_destroy(Menu);
		
		return PLUGIN_HANDLED;
		
	}
	
	new bool:C4 = false;
	
	if(user_has_weapon(User, CSW_C4))
	{
		
		C4 = true;
		
	}
	
	strip_user_weapons(User);
	give_item(User, "weapon_knife");
	
	if(C4)
	{
		
		give_item(User, "weapon_c4");
		
		cs_set_user_plant(User);
		
	}
	
	switch(Item)
	{
		
		case 0:
		{
			
			give_item(User, "weapon_m4a1");
			
			cs_set_user_bpammo(User, CSW_M4A1, 90);

		}

		case 1:
		{
			
			give_item(User, "weapon_ak47");
			
			cs_set_user_bpammo(User, CSW_AK47, 90);
			
		}
		
		case 2:
		{
			
			give_item(User, "weapon_awp");
			
			cs_set_user_bpammo(User, CSW_AWP, 30);
			
		}
		
		case 3:
		{
			
			give_item(User, "weapon_m249");
			
			cs_set_user_bpammo(User, CSW_M249, 200);
			
		}
		
		case 4:
		{
			
			give_item(User, "weapon_xm1014");
			
			cs_set_user_bpammo(User, CSW_XM1014, 32);
			
		}
		
	}
	
	give_item(User, "weapon_deagle");
	
	cs_set_user_bpammo(User, CSW_DEAGLE, 35);
	
	GiveOthers(User);
	
	menu_destroy(Menu);

	return PLUGIN_HANDLED;
	
}

public GiveOthers(User)
{
	
	if(!is_user_alive(User))
	{
		
		return PLUGIN_HANDLED;
		
	}

	give_item(User, "weapon_hegrenade");
	give_item(User, "weapon_flashbang");
	give_item(User, "weapon_flashbang");
	give_item(User, "weapon_smokegrenade");
	give_item(User, "item_assaultsuit");
	
	if(get_user_team(User) ==  2)
	{
	
		give_item(User, "item_thighpack");
		
	}
	
	return PLUGIN_HANDLED;
	
}

public DeathMsg()
{

	new Killer = read_data(1);
	new Killed = read_data(2);
	new HS = read_data(3);
	
	if(!(get_user_flags(Killer) & ADMIN_LEVEL_H))
	{
		
		return PLUGIN_HANDLED;
		
	}
	
	if(Killer != Killed && Killer)
	{
		
		new HP = get_user_health(Killer);
		
		if(HS)
		{
		
			if(100 < HP + 30)
			{
			
				set_user_health(Killer, 100);
			
			}
			
			else
			{
			
				set_user_health(Killer, HP + 30);
			
			}
		
		}
		
		else
		{
		
			if(100 < HP + 15)
			{
			
				set_user_health(Killer, 100);
			
			}
			
			else
			{
			
				set_user_health(Killer, HP + 15);
			
			}
		
		}
		
	}
	
	return PLUGIN_HANDLED;
	
}

public ShowShop(User)
{
	
	show_motd(User, "ShowShop.txt");

}

public ShowVIP(User)
{
	
	show_motd(User, "ShowVIP.txt");

}

public Adverts()
{

	ColorChat(0, GREEN, "[VIP]^x03 Aby przejsc do naszego sklepu uzyj komendy /shop!");
	ColorChat(0, GREEN, "[VIP]^x03 Aby sprawdzic co daje VIP uzyj komendy /vip!");

}