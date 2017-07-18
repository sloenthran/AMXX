#include <amxmodx>
#include <cstrike>
#include <fakemeta>
#include <colorchat>
#include <fun>

new Float:Coords[][] = 
{
    { -1736.3, 2348.1, -59.9 },
    { -1356.3, 2900.1, 160.0 }
};

public plugin_init()
{

	register_plugin("DD2 Block B", "1.3", "Sloenthran");
	
	register_event("BarTime", "CheckPlant", "be", "1=3");
	
}

public CheckPlant(User)
{

	new Players[32], Count, CT;
	
	get_players(Players, Count);
	
	for(new Number; Number < Count; Number++)
	{
	
		if(cs_get_user_team(Players[Number]) == CS_TEAM_CT)
		{
		
			CT++;
			
		}
	
	}
	
	if(CT < 5)
	{
	
		new Float:Data[3];
	
		pev(User, pev_origin, Data);
	
		if(Coords[0][0] < Data[0] && Coords[0][1] < Data[1] && Coords[0][2] < Data[2] && Coords[1][0] > Data[0] && Coords[1][1] > Data[1] && Coords[1][2] > Data[2])
		{
		
			if(cs_get_user_team(User) == CS_TEAM_T)
			{
				
				cs_set_user_plant(User, 0);
				
				new Origin[3];
				
				get_user_origin(User, Origin);
				
				Origin[2] += 25;
				
				set_user_origin(User, Origin);
			
				client_cmd(User, "; drop weapon_c4");
	
				ColorChat(User, GREEN, "[BS Limit]^x03 Jest ponizej 5 CT. W zwiazku z tym gramy tylko na A!");
				
				cs_set_user_plant(User, 1);
				
			}
	
		}
		
	}

}