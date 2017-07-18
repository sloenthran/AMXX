#include <amxmodx>
#include <fun>
#include <cstrike>
#include <hamsandwich>
#include <fakemeta>
#include <engine>
#include <colorchat>

#define IsPlayer(%1) (1 <= %1 <= MaxPlayers && is_user_connected(%1))
#define JumpTask 1111

new Round = 0;
new CvarHP, ValueHP;
new CvarAP, ValueAP;
new MaxPlayers;

new bool:IsTerminator[32];
new bool:Jump[32];
new bool:IsUse = false;

new const TerminatorModel[] = "models/player/terminator/terminator.mdl";

public plugin_init()
{
	
	register_plugin("Terminator", "5.0", "Sloenthran");
	
	register_logevent("NewRound", 2, "1=Round_Start");
	register_logevent("ResetRound", 2, "1=Game_Commencing")
	
	register_logevent("EndRound", 2, "1=Round_End");
	
	register_event("TextMsg", "ResetRound", "a", "2&Game_will_restart_in");
	register_event("DeathMsg", "DeathMsg", "a");
	
	CvarHP = register_cvar("terminator_hp", "40000", FCVAR_PROTECTED|FCVAR_SPONLY);
	CvarAP = register_cvar("terminator_ap", "10", FCVAR_PROTECTED|FCVAR_SPONLY);
	
	RegisterHam(Ham_TakeDamage, "player", "KillKnife");
	RegisterHam(Ham_Touch, "weaponbox", "BlockWeapon", 0);
	RegisterHam(Ham_Touch, "armoury_entity", "BlockWeapon", 0);
	
	register_forward(FM_CmdStart, "DoubleJump");
	
}

public plugin_precache()
{
	
	precache_model(TerminatorModel);
	
}

public plugin_natives()
{
	
	set_native_filter("NativeFilter");
	
}

public plugin_cfg()
{
	
	ValueHP = get_pcvar_num(CvarHP);
	ValueAP = get_pcvar_num(CvarAP);
	
	MaxPlayers = get_maxplayers();
	
}

public client_authorized(User)
{
	
	IsTerminator[User] = false;
	Jump[User] = false;
	
	if(Round == 2)
	{
		
		set_task(2.5, "SetCT", User);
		
	}
	
}

public client_disconnect(User)
{
	
	if(IsTerminator[User])
	{
		
		set_lights("#OFF");
		
		IsTerminator[User] = false;
		
		server_cmd("amx_pausecfg on");
		
	}
	
	Jump[User] = false;
	
}

public NativeFilter()
{
	
	return PLUGIN_HANDLED;
	
}

public EndRound()
{
	
	if(Round == 2)
	{
	
		for(new Number = 0; Number < 32; Number++)
		{
		
			if(IsPlayer(Number))
			{
			
				if(IsTerminator[Number])
				{
				
					IsTerminator[Number] = false;
				
					cs_reset_user_model(Number);
				
					server_cmd("amx_pausecfg on");
				
					IsUse = true;
				
				}
			
			}
			
		}
		
	}
	
}

public ResetRound()
{
	
	Round = 0;
	
}

public NewRound()
{
	
	Round += 1;
	
	if(Round == 2)
	{
		
		if(get_playersnum(0) > 4)
		{
			
			Draw();
			
		}
		
	}
	
	else if(Round == 3 && IsUse)
	{
		
		DrawTwo();
		
	}
	
}

public Draw()
{
	
	new bool:Lose, ID;
	
	Lose = false;
	
	for(new Number = 1; Number < MaxPlayers; Number++)
	{
		
		if(is_user_alive(Number) && is_user_connected(Number))
		{
			
			if(Lose)
			{
				
				cs_set_user_team(Number, CS_TEAM_CT);
				
				ExecuteHamB(Ham_CS_RoundRespawn, Number);
				
				ColorChat(Number, GREEN, "[Terminator] Wylosowano terminatora! Kryjcie sie!");
				
				give_item(Number, "weapon_m4a1");
				
				cs_set_user_bpammo(Number, CSW_M4A1, 90);
				
				give_item(Number, "weapon_ak47");
				
				cs_set_user_bpammo(Number, CSW_AK47, 90);
				
				
				
			}
			
			else
			{
				
				ID = random_num(1, 2);
				
				if(ID == 2 || Number == MaxPlayers)
				{
					
					cs_set_user_team(Number, CS_TEAM_T);
					
					ExecuteHamB(Ham_CS_RoundRespawn, Number);
					
					CreateTerminator(Number);
					
					strip_user_weapons(Number);
					
					give_item(Number, "weapon_knife");
					
					set_user_health(Number, ValueHP);
					
					Lose = true;
					
				}
				
				else
				{
					
					cs_set_user_team(Number, CS_TEAM_CT);
					
					ExecuteHamB(Ham_CS_RoundRespawn, Number);
					
					ColorChat(Number, GREEN, "[Terminator] Wylosowano terminatora! Kryjcie sie!");

					give_item(Number, "weapon_m4a1");
					
					cs_set_user_bpammo(Number, CSW_M4A1, 90);
					
					give_item(Number, "weapon_ak47");
				
					cs_set_user_bpammo(Number, CSW_AK47, 90);
					
				}
				
			}
			
		}
		
	}
	
	if(!Lose)
	{
		
		Draw();
		
	}
	
}

public DrawTwo()
{
	
	new ID;
	
	for(new Number = 1; Number < MaxPlayers; Number++)
	{
		
		if(is_user_alive(Number) && is_user_connected(Number))
		{
			
			ID = random_num(1, 2);
		
			if(ID == 2)
			{

				cs_set_user_team(Number, CS_TEAM_T);
		
				ExecuteHamB(Ham_CS_RoundRespawn, Number);
				
				strip_user_weapons(Number);
			
				give_item(Number, "weapon_knife");
		
			}

			else
			{
		
				cs_set_user_team(Number, CS_TEAM_CT);
		
				ExecuteHamB(Ham_CS_RoundRespawn, Number);
				
			}
			
		}
		
	}
	
}

public CreateTerminator(User)
{
	
	IsTerminator[User] = true;
	Jump[User] = true;
	
	server_cmd("bb_startround");
	
	server_cmd("amx_pausecfg pause basebuilder65.amxx");
	
	cs_set_user_model(User, "terminator");
	
	set_lights("c");
	
}

public KillKnife(User, Ent, Attacker)
{
	
	if(is_user_alive(Attacker) && IsTerminator[Attacker] && get_user_weapon(Attacker) == CSW_KNIFE)
	{
		
		cs_set_user_armor(User, 0, CS_ARMOR_NONE);
		
		SetHamParamFloat(4, float(get_user_health(User) + 1));
		
		return HAM_HANDLED;
		
	}
	
	return HAM_IGNORED;
	
}

public DeathMsg()
{
	
	new Killer = read_data(1);
	new Killed = read_data(2);
	
	if(Killer != Killed && Killer)
	{
		
		if(IsTerminator[Killed])
		{
			
			GiveAP();
			
			IsTerminator[Killed] = false;
			
			cs_reset_user_model(Killed);
			
			set_lights("#OFF");
			
			
		}
		
	}
	
}

public BlockWeapon(Weapon, User)
{
	
	if(!pev_valid(Weapon) || !is_user_alive(User) || !IsTerminator[User])
	{
		
		return HAM_IGNORED;
		
	}
	
	return HAM_SUPERCEDE;
	
}

public DoubleJump(User, Buttons)
{
	
	if(IsTerminator[User] && Jump[User])
	{
		
		new Flags = pev(User, pev_flags);
		
		if((get_uc(Buttons, UC_Buttons) & IN_JUMP) && !(Flags & FL_ONGROUND) && !(pev(User, pev_oldbuttons) & IN_JUMP))
		{
			
			new Float:VeloCity[3];
			
			pev(User, pev_velocity,VeloCity);
			VeloCity[2] = random_float(265.0,285.0);
			set_pev(User,pev_velocity,VeloCity);
			
			Jump[User] = false;
			
			set_task(1.0, "GiveJump", User + JumpTask);
			
		}
		
	}
	
}

public GiveJump(User)
{
	
	User -= JumpTask;
	
	Jump[User] = true;
	
}

public GiveAP()
{
	
	for(new Number = 1; Number < MaxPlayers; Number++)
	{
		
		if(cs_get_user_team(Number) == CS_TEAM_CT)
		{
			
			cs_set_user_money(Number , cs_get_user_money(Number) + ValueAP, 1);
			
		}
		
	}
	
}

public SetCT(User)
{
	
	if(is_user_connected(User))
	{		
	
		cs_set_user_team(User, CS_TEAM_CT);
		
	}
	
}