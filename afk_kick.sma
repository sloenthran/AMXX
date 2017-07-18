#include <amxmodx>
#include <amxmisc>
#include <cstrike>
#include <engine>
#include <colorchat>
#include <hamsandwich>

new UserTimeAFK[33];
new UserOldPosition[33][3], UserSpawnPosition[33][3];
new NumberCT, NumberTT;

new bool:UserSpawn[33] = {true, ...}

public plugin_init() 
{
	
	register_plugin("AFK Kick", "2.3", "Sloenthran");
	
	RegisterHam(Ham_Spawn, "player", "PlayerSpawn", 1);
	
	set_task(5.0, "CheckPlayers", .flags="b");
	
}

public client_authorized(User) 
{
	
	UserTimeAFK[User] = 0;

}

public CheckPlayers() 
{
	
	new Players[32], Count;
	
	get_players(Players, Count, "ac");
	
	GetAlivePlayer();

	for(new Number = 0; Number < Count; Number++)
	{

        if(is_user_connected(Players[Number]) && !is_user_bot(Players[Number]) && !is_user_hltv(Players[Number]) && is_user_alive(Players[Number]) && UserSpawn[Players[Number]]) 
		{
			
			new Position[3];

			get_user_origin(Players[Number], Position)
			
			if(Position[0] == UserSpawnPosition[Players[Number]][0] && Position[1] == UserSpawnPosition[Players[Number]][1] && Position[2] == UserSpawnPosition[Players[Number]][2]) 
			{
				
				UserTimeAFK[Players[Number]] += 5;
				CheckTimeAFK(Players[Number]);
				CheckTeam(Players[Number]);
			
			} 
			
			else 
			{
				
				get_user_origin(Players[Number], Position, 3);
				
				if(Position[0] == UserOldPosition[Players[Number]][0] && Position[1] == UserOldPosition[Players[Number]][1] && Position[2] == UserOldPosition[Players[Number]][2])
				{
					
					UserTimeAFK[Players[Number]] += 5;
					CheckTimeAFK(Players[Number]);
					CheckTeam(Players[Number]);
				
				} 
				
				else 
				{
					
					UserOldPosition[Players[Number]][0] = Position[0];
					UserOldPosition[Players[Number]][1] = Position[1];
					UserOldPosition[Players[Number]][2] = Position[2];
					UserTimeAFK[Players[Number]] = 0;
				
				}
			
			}
			
			if(UserTimeAFK[Players[Number]] > 15 && user_has_weapon(Players[Number], CSW_C4)) 
			{
				
				client_cmd(Players[Number], "; drop weapon_c4");
				
				ColorChat(0, GREEN, "[AFK]^x03 Bomba zostala wyrzucona!");
			
			} 
        
		}
		
	}
	
	return PLUGIN_HANDLED;
	
}

public CheckTeam(User) 
{
	
	if(UserTimeAFK[User] >= 45) 
	{
		
		new Name[64];
	
		get_user_name(User, Name, 63);
	
		user_silentkill(User);
	
		ColorChat(0, GREEN, "[AFK]^x03 %s jest AFK od 45 sekund wiec zostal zabity!", Name);
		
	}
}

public CheckTimeAFK(User) 
{
	
	if(get_playersnum(0) >= 6) 
	{
		
		if(75 <= UserTimeAFK[User] < 90)
		{

			ColorChat(User, GREEN, "[AFK]^x03 Za %i sekund zostaniesz wykopany jako AFK!", 90 - UserTimeAFK[User]);
			
		} 
		
		else if(UserTimeAFK[User] > 90) 
		{
			
			new Name[64];
		
			get_user_name(User, Name, 63);
			
			ColorChat(0, GREEN, "[AFK]^x03 %s byl AFK przez 90 sekund i zostal wykopany!", Name);

			server_cmd("kick #%d ^"Zostales wyrzucony za bycie AFK!^"", get_user_userid(User));
		
		}
	
	}
	
}

public PlayerSpawn(User)
{
	
	UserSpawn[User] = true;
	
	get_user_origin(User, UserOldPosition[User], 3);
	get_user_origin(User, UserSpawnPosition[User]);
	
}

public GetAlivePlayer() 
{
	
	new Players[32], Count;
	
	get_players(Players, Count, "ac")
	
	NumberCT = 0;
	NumberTT = 0;

	for(new Number = 0; Number < Count; Number++) 
	{
		
		if(UserTimeAFK[Players[Number]] < 25)
		{
			
			switch(get_user_team(Players[Number]))
			{
				
				case 1: NumberTT++;
				case 2: NumberCT++;
				
			}
			
		}
		
	}
	
}