#include <amxmodx>
#include <fakemeta>
#include <engine>
#include <colorchat>
#include <cstrike>

new Time = 0;
new MaxPlayers;

new UserRash[33];

new Float:CoordsCT[][] = 
{
	{ -495.0, 640.0, 0.0 },
	{ -144.0, 640.0, 250.0 },
	{ 528.0, 566.0, 0.0 },
	{ 751.0, 566.0, 250.0 },
	{ -2031.0, 387.0, 0.0 },
	{ -1424.0, 387.0, 250.0 }
};

public plugin_init()
{
	
	register_plugin("DD2 Anty Rush", "3.0", "Sloenthran");
	
	register_touch("OneWall", "player", "TouchWall");
	register_touch("TwoWall", "player", "TouchWall");
	register_touch("ThreeWall", "player", "TouchWall");
	
	register_logevent("NewRound", 2, "1=Round_Start");
	
	set_task(1.0, "AddTime", .flags="b");

}

public plugin_precache()
{
	
	CreateWallOne();
	CreateWallTwo();
	CreateWallThree();
	
}

public plugin_cfg()
{

	MaxPlayers = get_maxplayers();
	
}

public client_authorized(User)
{
	
	UserRash[User] = 0;
	
}

public NewRound()
{
	
	Time = 0;
	
	ColorChat(0, GREEN, "[AntyRush]^x03 Przez pierwsze 30 sekund CT nie raszuje!");
	
	for(new Number = 0; Number < MaxPlayers; Number++)
	{
	
		if(is_user_connected(Number) && !is_user_hltv(Number))
		{
			
			UserRash[Number] = 0;
			
		}
		
	}
	
}

public AddTime()
{
	
	Time += 1;
	
	if(Time == 30)
	{
		
		ColorChat(0, GREEN, "[AntyRush]^x03 CT moze juz raszowac!");
		
	}
	
}

public CreateWallOne()
{
	
	new CreateEnt = create_entity("info_target");

	set_pev(CreateEnt, pev_classname, "OneWall");
	
	dllfunc(DLLFunc_Spawn, CreateEnt); 
	
	set_pev(CreateEnt, pev_solid, SOLID_TRIGGER); 
	set_pev(CreateEnt, pev_movetype, MOVETYPE_FLY);
	
	engfunc(EngFunc_SetSize, CreateEnt, CoordsCT[0], CoordsCT[1]);
	
	engfunc(EngFunc_DropToFloor, CreateEnt);
	
}

public CreateWallTwo()
{
	
	new CreateEnt = create_entity("info_target");

	set_pev(CreateEnt, pev_classname, "TwoWall");
	
	dllfunc(DLLFunc_Spawn, CreateEnt); 
	
	set_pev(CreateEnt, pev_solid, SOLID_TRIGGER); 
	set_pev(CreateEnt, pev_movetype, MOVETYPE_FLY);
	
	engfunc(EngFunc_SetSize, CreateEnt, CoordsCT[2], CoordsCT[3]);
	
	engfunc(EngFunc_DropToFloor, CreateEnt);
	
}

public CreateWallThree()
{
	
	new CreateEnt = create_entity("info_target");

	set_pev(CreateEnt, pev_classname, "ThreeWall");
	
	dllfunc(DLLFunc_Spawn, CreateEnt); 
	
	set_pev(CreateEnt, pev_solid, SOLID_TRIGGER); 
	set_pev(CreateEnt, pev_movetype, MOVETYPE_FLY);
	
	engfunc(EngFunc_SetSize, CreateEnt, CoordsCT[4], CoordsCT[5]);
	
	engfunc(EngFunc_DropToFloor, CreateEnt);
	
}

public TouchWall(Ent, User)
{
	
	if(Time < 30)
	{
		
		if(cs_get_user_team(User) == CS_TEAM_CT)
		{
			
			if(UserRash[User] == 3)
			{
				
				ColorChat(User, GREEN, "[AntyRush]^x03 Nie raszujemy przez 30 sekund! Moze teraz to do Ciebie dotrze...");
				
				user_silentkill(User);
				
			}
			
			else
			{
			
				new Float:Velocity[3], Float:Length;
			
				entity_get_vector(User, EV_VEC_velocity, Velocity);
			
				Length = vector_length(Velocity) + 0.0001;
			
				Velocity[0] = (Velocity[0] / Length) * (-500.0);
				Velocity[1] = (Velocity[1] / Length) * (-500.0);
			
				if(Velocity[2] < 0)
				{
				
					Velocity[2] = Velocity[2] * (-1.0) + 15.0;
				
				}
			
				entity_set_vector(User, EV_VEC_velocity, Velocity);
		
				ColorChat(User, GREEN, "[AntyRush]^x03 Nie raszuj!");
				
				UserRash[User] += 1;
				
			}
			
		}
		
	}
	
	return FMRES_IGNORED; 
	
}