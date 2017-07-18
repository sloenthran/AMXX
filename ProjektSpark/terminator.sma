#include <amxmodx>
#include <fun>
#include <cstrike>
#include <hamsandwich>
#include <colorchat>
#include <fakemeta>
#include <engine>

#define IsPlayer(%1) (1 <= %1 <= MaxPlayers && is_user_connected(%1))
#define JumpTask 1111

new Round = 0;
new CvarHP, ValueHP;
new MaxPlayers;
new PackNumber = 0;

new bool:CheckDraw = false;
new bool:IsTerminator[33];
new bool:Jump[33];

new const TerminatorModel[] = "models/player/terminator/terminator.mdl";
new const BonusPackModel[] = "models/gunxpmod/bonus_pack.mdl";

public plugin_init()
{
	
	register_plugin("Terminator", "2.1", "Sloenthran");
	
	register_logevent("NewRound", 2, "1=Round_Start");
	register_logevent("ResetRound", 2, "1=Game_Commencing");
	
	register_logevent("EndRound", 2, "1=Round_End");
	
	register_event("TextMsg", "ResetRound", "a", "2&Game_will_restart_in");
	register_event("DeathMsg", "DeathMsg", "a");
	
	CvarHP  = register_cvar("terminator_hp", "30000", FCVAR_PROTECTED|FCVAR_SPONLY);
	
	RegisterHam(Ham_TakeDamage, "player", "KillKnife");
	RegisterHam(Ham_Touch, "weaponbox", "BlockWeapon", 0);
	RegisterHam(Ham_Touch, "armoury_entity", "BlockWeapon", 0);
	
	register_forward(FM_Touch, "TouchBonusPack");
	
	register_forward(FM_CmdStart, "DoubleJump");
	
}

public plugin_precache()
{
	
	precache_model(TerminatorModel);
	precache_model(BonusPackModel);
	
}

public plugin_natives()
{
	
	set_native_filter("NativeFilter");
	
}

public plugin_cfg()
{
	
	ValueHP  = get_pcvar_num(CvarHP);
	
	MaxPlayers = get_maxplayers();
	
}

public client_authorized(User)
{
	
	IsTerminator[User] = false;
	Jump[User] = false;
	
}

public client_disconnect(User)
{
	
	IsTerminator[User] = false;
	Jump[User] = false;
	
}

public NativeFilter()
{
	
	return PLUGIN_HANDLED;
	
}

public EndRound()
{

    for(new Number = 0; Number < 32; Number++)
	{
	
        if(IsPlayer(Number))
		{
			
			if(IsTerminator[Number])
			{
		
				IsTerminator[Number] = false;
		
				cs_reset_user_model(Number);
		
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
	
	if(Round == 3)
	{
		
		if(get_playersnum(0) > 5)
		{
		
			CheckDraw = true;
		
		}
		
	}
	
	if(CheckDraw)
	{
		
		Draw();
		
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
				
			}
			
			else
			{
				
				ID = random_num(1, 2);
				
				if(ID == 2)
				{
					
					cs_set_user_team(Number, CS_TEAM_T);
					
					ExecuteHamB(Ham_CS_RoundRespawn, Number);
					
					CreateTerminator(Number);
					
					strip_user_weapons(Number);
					
					give_item(Number, "weapon_knife");
					
					Lose = true;
					
				}
				
				else
				{
					
					cs_set_user_team(Number, CS_TEAM_CT);
					
					ExecuteHamB(Ham_CS_RoundRespawn, Number);
					
				}
				
			}
			
		}
		
	}
	
}

public CreateTerminator(User)
{
	
	IsTerminator[User] = true;
	Jump[User] = true;
	
	cs_set_user_model(User, "terminator");
	set_user_health(User, ValueHP);
	
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

public TouchBonusPack(Ent, User)
{
	
	if(!is_user_alive(User) || !pev_valid(Ent))
	{	
		
		return FMRES_IGNORED;
		
	}
	
	static ClassName[32];
	
	pev(Ent, pev_classname, ClassName,31); 
	
	if(!equali(ClassName, "bonuspack"))
	{
		
		return FMRES_IGNORED;
		
	}
	
	if(pev(User, pev_button))
	{
		
		UseBonusPack(User);
		engfunc(EngFunc_RemoveEntity, Ent);
		
	}
	
	return FMRES_IGNORED; 
	
}

public UseBonusPack(User)
{
	
	if(is_user_connected(User) && is_user_alive(User))
	{
		
		PackNumber++;
		
		switch(PackNumber)
		{
			
			case 1:
			{
				new Name[32];
				
				get_user_name(User, Name, 31);
				
				server_cmd("bf2_set_points ^"%s^" 30", Name);
				
				ColorChat(User, GREEN, "[Terminator]^x03 Dostales 30 punktow do sklepiku.");
				
			}
			
			case 2:
			{
				
				new Name[32];
				
				get_user_name(User, Name, 31);
				
				server_cmd("bf2_set_points ^"%s^" 10", Name);
				
				ColorChat(User, GREEN, "[Terminator]^x03 Dostales 10 punktow do sklepiku.");
				
			}
			
			case 3:
			{
				
				new Name[32];
				
				get_user_name(User, Name, 31);
				
				server_cmd("bf2_addbadge ^"%s^" 1 3", Name);
				
				ColorChat(User, GREEN, "[Terminator]^x03 Dostales odznake Weteran z Pistoletow!");
				
			}
			
			case 4:
			{
				
				new Name[32];
				
				get_user_name(User, Name, 31);
				
				server_cmd("bf2addbage ^"%s^" 3 3", Name);
				
				ColorChat(User, GREEN, "[Terminator]^x03 Dostales odznake Weteran z Broni Snajperskiej.");
				
			}
			
			case 5:
			{
				
				new Name[32];
				
				get_user_name(User, Name, 31);
				
				server_cmd("bf2_set_points ^"%s^" 20", Name);
				
				ColorChat(User, GREEN, "[Terminator]^x03 Dostales 20 punktow do sklepiku.");
				
			}
			
		}
		
	}
	
}

public CreateBonusPack(User, Number)
{ 
	
	new Float:origins[3];
	
	pev(User, pev_origin, origins);
	
	origins[0] += 50.0 + Number;
	origins[1] += Number;
	origins[2] -= 32.0 - Number;
	
	new CreateEnt = create_entity("info_target")
	
	set_pev(CreateEnt, pev_origin, origins);
	entity_set_model(CreateEnt, BonusPackModel);
	set_pev(CreateEnt, pev_classname, "bonuspack");
	
	dllfunc(DLLFunc_Spawn, CreateEnt); 
	set_pev(CreateEnt, pev_solid, SOLID_TRIGGER); 
	set_pev(CreateEnt, pev_movetype, MOVETYPE_FLY);
	
	engfunc(EngFunc_SetSize, CreateEnt, {-1.1, -1.1, -1.1}, {1.1, 1.1, 1.1});
	
	engfunc(EngFunc_DropToFloor, CreateEnt);
	
}

public DeathMsg()
{
	
	new Killer = read_data(1);
	new Killed = read_data(2);
	
	if(Killer != Killed && Killer)
	{
		
		if(IsTerminator[Killed])
		{
			
			CreateBonusPack(Killed, 25);
			CreateBonusPack(Killed, 50);
			CreateBonusPack(Killed, 75);
			CreateBonusPack(Killed, 100);
			CreateBonusPack(Killed, 125);
			
			CheckDraw = false;
			
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