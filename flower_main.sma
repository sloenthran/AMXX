#include <amxmodx>
#include <cstrike>
#include <fun>
#include <fakemeta>
#include <hamsandwich>
#include <engine>
#include <colorchat>

#define GIB_ALWAYS							2
#define message_begin_f(%1,%2,%3,%4)		engfunc( EngFunc_MessageBegin, %1, %2, %3, %4 )
#define write_coord_f(%1)					engfunc( EngFunc_WriteCoord, %1 )

#define TASK_EXPLODE						1000
#define TASK_SCREENFADE						2000
#define TASK_CTS_MSG						3000
#define TASK_TS_MSG							4000
#define TASK_SHOOP							5000

enum _: FlowersCvars
{
	CVAR_FW_TIMECANTATTACK = 0,
	CVAR_FW_DAMAGEEXPLOSION,
	CVAR_FW_RADIUSEXPLOSION,
	CVAR_FW_SPEEDEXPLOSION,
	CVAR_FW_GRAVITYEXPLOSION,
	CVAR_FW_MONEYEXPLOSION,
	CVAR_FW_FRAGSEXPLOSION,
	CVAR_FW_CANBUYSHOOP,
	CVAR_FW_PRICESHOOP,
	CVAR_FW_SPEEDSHOOP,
	CVAR_FW_GRAVITYSHOOP,
	CVAR_GD_TIMESCREENFADE,
	CVAR_GD_COLORSCREENFADE,
	CVAR_GD_CANBUYKNIFE,
	CVAR_GD_PRICEKNIFE,
	CVAR_GD_CANBUYAMMOS,
	CVAR_GD_PRICEAMMOS,
	CVAR_MAX
}

new const FLOWERS_TAG[ ]					= "[ Flowers ]";

new const FLOWER_MOTD[ ]					= "flower_help.txt";
new const GARDENER_MOTD[ ]					= "gardener_help.txt";

new const SOUND_EXPL[ ] 	 				= "flower/yalala.wav";
new const SOUND_PROV[ ]  	 				= "flower/provocation.wav";
new const SOUND_SHOOP_BEGIN[ ]				= "flower/iamfiringmahlaser.wav";
new const SOUND_SHOOP_LAZER[ ]				= "flower/blahhhhh.wav";

new const FLOWER_ONEMODEL[]		= "models/player/flower_one/flower_one.mdl";
new const FLOWER_TWOMODEL[]		= "models/player/flower_two/flower_two.mdl";
new const FLOWER_THREEMODEL[]	= "models/player/flower_mod/splant.mdl";
new const PLAYER_MODEL[]		= "models/player/flower_mod/flower_mod.mdl";

new CsTeams:PlayerTeam[ 33 ];
new bool:g_bGibbed[ 33 ];
new bool:IsAlive[ 33 ];
new bool:NewPlayer[ 33 ];
new bool:g_bGoToExplode[ 33 ];
new bool:HasLaser[ 33 ];
new bool:g_bActivatedShoopDaWhoop[ 33 ];

new g_pCvars[ CVAR_MAX ];

new g_MaxPlayers;
new g_ExploSprite;
new g_LastTime[ 33 ];
new g_Beam;
new g_RoundTime;

new g_DeathMsg;

new ScreenFadeMsg; 

new bool:LastRoundCT[33] = false;
new bool:FirstRound = true;

/*==========================================================================================*/

public plugin_init( )
{
	register_plugin( "flower main", "2.8", "Micapat & Sloenthran" );
	register_dictionary( "flower_main.txt" );
	
	register_touch( "weaponbox", "player", "Weapons_Block" );
	register_touch( "armoury_entity", "player", "Weapons_Block" );
	
	RegisterHam( Ham_Spawn, "player", "SpawnPlayer", 1 );
	RegisterHam( Ham_Killed, "player", "Player_Killed" );
	
	register_clcmd("say /cut", "Cut");
	register_clcmd("say_team /cut", "Cut");
	register_clcmd("say /noz", "Cut");
	register_clcmd("say_team /noz", "Cut");
	register_clcmd("say /knife", "Cut");
	register_clcmd("say_team /knife", "Cut");
	register_clcmd("say /ammo", "Ammo");
	register_clcmd("say_team /ammo", "Ammo");
	register_clcmd("say /amunicja", "Ammo");
	register_clcmd("say_team /amunicja", "Ammo");
	register_clcmd("say /laser", "Laser");
	register_clcmd("say_team /laser", "Laser");
	register_clcmd("say /help", "Help_Command");
	register_clcmd("say_team /help", "Help_Command");
	register_clcmd("say /pomoc", "Help_Command");
	register_clcmd("say_team /pomoc", "Help_Command");
	
	register_forward( FM_PlayerPreThink, "Player_PreThink" );
	register_event( "HLTV", "Event_HLTV_New_Round", "a", "1=0", "2=0" );
	register_message( get_user_msgid("ClCorpse"), "Message_ClCorpse" );
	
	register_logevent("EndRound", 2, "1=Round_End");
	
	g_pCvars[ CVAR_FW_TIMECANTATTACK ] = 	register_cvar( "Fw_TimeCantAttack", "15" );
	g_pCvars[ CVAR_FW_DAMAGEEXPLOSION ] = 	register_cvar( "Fw_DamageExplosion", "60000.0" );
	g_pCvars[ CVAR_FW_RADIUSEXPLOSION ] = 	register_cvar( "Fw_RadiusExplosion", "250" );
	g_pCvars[ CVAR_FW_SPEEDEXPLOSION ] = 	register_cvar( "Fw_SpeedExplosion", "480.0" );
	g_pCvars[ CVAR_FW_GRAVITYEXPLOSION ] =	register_cvar( "Fw_GravityExplosion", "0.75" );
	g_pCvars[ CVAR_FW_MONEYEXPLOSION ] = 	register_cvar( "Fw_MoneyExplosion", "1000" );
	g_pCvars[ CVAR_FW_FRAGSEXPLOSION ] = 	register_cvar( "Fw_FragsExplosion", "2" );
	g_pCvars[ CVAR_FW_CANBUYSHOOP ] = 		register_cvar( "Fw_CanBuyShoop", "1" );
	g_pCvars[ CVAR_FW_PRICESHOOP ] = 		register_cvar( "Fw_PriceShoop", "500" );
	g_pCvars[ CVAR_FW_SPEEDSHOOP ] = 		register_cvar( "Fw_SpeedShoop", "120.0" );
	g_pCvars[ CVAR_FW_GRAVITYSHOOP ] = 		register_cvar( "Fw_GravityShoop", "2.5" );
	g_pCvars[ CVAR_GD_TIMESCREENFADE ] = 	register_cvar( "Gd_TimeScreenFade", "7" );
	g_pCvars[ CVAR_GD_COLORSCREENFADE ] = 	register_cvar( "Gd_ColorScreenFade", "000000000" );
	g_pCvars[ CVAR_GD_CANBUYKNIFE ] = 		register_cvar( "Gd_CanBuyKnife", "1" );
	g_pCvars[ CVAR_GD_PRICEKNIFE ] = 		register_cvar( "Gd_PriceKnife", "10000" );
	g_pCvars[ CVAR_GD_CANBUYAMMOS ] = 		register_cvar( "Gd_CanBuyAmmos", "1" );
	g_pCvars[ CVAR_GD_PRICEAMMOS ] = 		register_cvar( "Gd_PriceAmmos", "12000" );
	
	g_MaxPlayers = get_maxplayers( );
	g_DeathMsg = get_user_msgid( "DeathMsg" );
	ScreenFadeMsg = get_user_msgid( "ScreenFade" );
	
	set_cvar_string( "mp_freezetime", "0" );
	set_cvar_string( "mp_playerid", "2" );
	set_cvar_string( "sv_maxspeed", "999" );
	
	SpawnFlowerEnt();
	
}

public plugin_precache( )
{
	precache_model( "models/rpgrocket.mdl" ); // Necessary for 3D View
	precache_model( FLOWER_ONEMODEL );
	precache_model( PLAYER_MODEL );
	precache_model( FLOWER_TWOMODEL );
	precache_model( FLOWER_THREEMODEL );
	
	g_Beam = 			precache_model( "sprites/xbeam3.spr" );
	g_ExploSprite = 	precache_model( "sprites/zerogxplode.spr" );
	
	precache_sound( SOUND_EXPL );
	precache_sound( SOUND_PROV );
	precache_sound( SOUND_SHOOP_BEGIN );
	precache_sound( SOUND_SHOOP_LAZER );
}

public SpawnFlowerEnt()
{
	
	new Ent = -1, Float:Temp[3];
	
	while((Ent = find_ent_by_class( Ent, "info_target" )) > 0)
	{

		entity_get_vector(Ent, EV_VEC_origin, Temp);
		
		Temp[2] += 28.0;
		
		entity_set_origin(Ent, Temp);
		
		Temp[0] = Temp[2] = 0.0;
		Temp[1] = random_float(0.0, 360.0);
		
		entity_set_vector(Ent, EV_VEC_angles, Temp);
		
		switch(random_num(1, 7))
		{
			
			case 1, 4, 6:
			{
				
				entity_set_model(Ent, FLOWER_ONEMODEL); 
				engfunc(EngFunc_DropToFloor, Ent);
			
			}
			
			case 2, 5, 7: entity_set_model(Ent, FLOWER_TWOMODEL);
			
			case 3:
			{	
			
				entity_set_model(Ent, FLOWER_THREEMODEL);
				engfunc(EngFunc_DropToFloor, Ent);
				
			}
			
		}
		
	}
	
}

/*==========================================================================================*/

public client_connect( id )
{
	NewPlayer[ id ] = true;
	g_bGoToExplode[ id ] = false;
	HasLaser[ id ] = false;
	g_bActivatedShoopDaWhoop[ id ] = false;
	IsAlive[ id ] = false;
	LastRoundCT[id] = false;
	
}

public client_disconnect( id )
{
	remove_task( id + TASK_EXPLODE );
	remove_task( id + TASK_SCREENFADE );
	remove_task( id + TASK_CTS_MSG );
	remove_task( id + TASK_TS_MSG );
	remove_task( id + TASK_SHOOP );
	
	NewPlayer[ id ] = true;
	g_bGoToExplode[ id ] = false;
	HasLaser[ id ] = false;
	g_bActivatedShoopDaWhoop[ id ] = false;
	IsAlive[ id ] = false;
	LastRoundCT[id] = false;
}

public Player_PreThink( id )
{
	
	if( IsAlive[ id ] && PlayerTeam[ id ] == CS_TEAM_T )
	{
		if( !g_bGoToExplode[ id ] )
		{
			new button = entity_get_int( id, EV_INT_button );
			new oldButton = entity_get_int( id, EV_INT_oldbuttons );
			
			if( button & IN_ATTACK2 && !( oldButton & IN_ATTACK2 ))
			{
				if ( g_RoundTime - get_timeleft( ) > get_pcvar_num( g_pCvars[ CVAR_FW_TIMECANTATTACK ] ))
				{
					g_bGoToExplode[ id ] = true;
					
					if( !HasLaser[ id ] ) /* Explode */
					{
						set_user_maxspeed( id, get_pcvar_float( g_pCvars[ CVAR_FW_SPEEDEXPLOSION ] ) );
						set_user_gravity( id, get_pcvar_float( g_pCvars[ CVAR_FW_GRAVITYEXPLOSION ] ) );
						
						emit_sound( id, CHAN_STATIC, SOUND_EXPL, 0.5, ATTN_NORM, 0, PITCH_NORM );
						
						client_print( id, print_chat, "%s %L", FLOWERS_TAG, id, "LAUNCH_EXPLODE" );
						client_print( id, print_chat, "%s %L", FLOWERS_TAG, id, "LAUNCH_EXPLODE_2" );
						
						set_task ( 3.0, "Explode", id + TASK_EXPLODE );
					}
					else /* Shoop Da Whoop  0_0 */
					{
						emit_sound( id, CHAN_STATIC, SOUND_SHOOP_BEGIN, 1.0, ATTN_NORM, 0, PITCH_NORM );
						
						client_print( id, print_chat, "%s %L", FLOWERS_TAG, id, "LAUNCH_SHOOP" );
						
						set_hudmessage ( 12, 109, 190, -1.0, 0.45, 0, 0.1, 2.0, 0.1, 1.0, -1 );
						show_hudmessage ( 0 , "WTFFFFFFFFFFFFFFFFFF ???" );
						
						set_task ( 2.5,  "ShoopdaWhoop", id + TASK_SHOOP );
						set_task ( 12.5, "Explode", id + TASK_EXPLODE );
					}
				}
				else
				{
					ColorChat(id, GREEN, "[KWIATKI]^x03 Jesteś zbyt mało zirytowany aby eksplodować!");
				}
			}
			else if( button & IN_ATTACK && !( oldButton & IN_ATTACK ) && ( g_LastTime[ id ] - get_timeleft( ) > 2 ))
			{
				g_LastTime[ id ] = get_timeleft( );
				emit_sound( id, CHAN_STATIC, SOUND_PROV, 0.5, ATTN_NORM, 0, PITCH_NORM );
			}
		}
		else if( g_bActivatedShoopDaWhoop[ id ] )
		{
			new origin[ 3 ], aim[ 3 ], target, body;
			
			get_user_origin( id, origin);
			get_user_origin( id, aim, 3 );
			
			// Lazeeeeeeeeeeeeeeeer
			message_begin( MSG_PVS, SVC_TEMPENTITY, origin );
			write_byte( TE_BEAMPOINTS )
			write_coord( origin[ 0 ] );
			write_coord( origin[ 1 ] );
			write_coord( origin[ 2 ] );
			write_coord( aim[ 0 ] );
			write_coord( aim[ 1 ] );
			write_coord( aim[ 2 ] );
			write_short( g_Beam );
			write_byte( 1 );
			write_byte( 1 );
			write_byte( 1 );
			write_byte( 210 );
			write_byte( 1 );
			write_byte( 12 );
			write_byte( 109 );
			write_byte( 190 );
			write_byte( 255 );
			write_byte( 50 );
			message_end( );
			
			get_user_aiming( id, target, body );
			
			if( 1 <= target <= g_MaxPlayers && PlayerTeam[ target ] == CS_TEAM_CT && IsAlive[ target ] )
			{
				ExecuteHamB( Ham_TakeDamage, target, id, id, 200.0, DMG_BLAST | DMG_ALWAYSGIB );
				
				if( !IsAlive[ target ] ) 
				{
					cs_set_user_deaths( target, get_user_deaths( target ) + 1 );
					set_user_frags( id, get_user_frags( id ) + 1 );
					
					message_begin( MSG_ALL, g_DeathMsg );
					write_byte( id );
					write_byte( target );
					write_byte( 0 );
					write_string( "" );
					message_end( );
				}
			}
		}
	}
}

/*==========================================================================================*/

public Cts_Beginning( User )
{
	User -= TASK_CTS_MSG;

	if( IsAlive[ User ] )
	{
		switch( PlayerTeam[ User ] )
		{
			case CS_TEAM_T:
			{
				
				ColorChat(User, GREEN, "[KWIATKI]^x03 Ogrodnicy już widzą!");
				
			}
			case CS_TEAM_CT:
			{
				
				ColorChat(User, GREEN, "[KWIATKI]^x03 Wyplenianie chwastów czas zacząć!");
				
				give_item( User, "weapon_usp" );
			}
		}
	}
}

public Ts_Beginning( id )
{
	id -= TASK_TS_MSG;

	if( IsAlive[ id ] )
	{
		switch( PlayerTeam[ id ] )
		{
			case CS_TEAM_T:
			{
				set_hudmessage ( 0, 255, 0, -1.0, 0.35, 0, 0.1, 2.5, 0.1, 1.0, -1 );
				show_hudmessage ( id , "%L", id, "HUD_ANGRY" );
			}
			case CS_TEAM_CT:
			{
				set_hudmessage ( 255, 0, 0, -1.0, 0.40, 0, 0.1, 2.5, 0.1, 1.0, -1 );
				show_hudmessage ( id , "%L", id, "HUD_AGRESSIVE" );
			}
		}
	}
}

public Player_Killed( id, iKiller, iGib )
{
	IsAlive[ id ] = false;
	
	if( iGib == GIB_ALWAYS )
	{
		g_bGibbed[ id ] = true;
	}	
	
	if( HasLaser[ id ] )
	{
		HasLaser[ id ] = false;
		
		set_hudmessage ( 255, 0, 0, -1.0, 0.35, 0, 0.1, 2.5, 0.1, 1.0, -1 );
		show_hudmessage ( id , "%L", id, "HUD_MADNESS" );
		
		remove_task( id + TASK_EXPLODE );
		
		Explode( id + TASK_EXPLODE );
		
		emit_sound( id, CHAN_STATIC, SOUND_SHOOP_BEGIN, 1.0, ATTN_NORM, SND_STOP, PITCH_NORM );
		emit_sound( id, CHAN_STATIC, SOUND_SHOOP_LAZER, 1.0, ATTN_NORM, SND_STOP, PITCH_NORM );
	}
}

/*==========================================================================================*/

public Event_HLTV_New_Round( )
{
	g_RoundTime = get_timeleft( );
	arrayset( g_bGibbed, false, sizeof( g_bGibbed ));
}

public Message_ClCorpse( msgId, msgDest, msgEnt )
{
	return ( g_bGibbed[ get_msg_arg_int( 12 ) ] ) ? PLUGIN_HANDLED : PLUGIN_CONTINUE;
}

public Weapons_Block( weapon, player )
{
	return ( PlayerTeam[ player ] == CS_TEAM_CT ) ? PLUGIN_CONTINUE : PLUGIN_HANDLED;
}

public Explode( id )
{
	id -= TASK_EXPLODE;
	
	if( is_user_connected( id ))
    {
		HasLaser[ id ] = false;
		
		new enemy, Float:origin[ 3 ], Float:origin_enemy[ 3 ], Float:real_damage;
		entity_get_vector( id, EV_VEC_origin, origin );
		
		new Float:damage = get_pcvar_float( g_pCvars[ CVAR_FW_DAMAGEEXPLOSION ] );
		new Float:radius = get_pcvar_float( g_pCvars[ CVAR_FW_RADIUSEXPLOSION ] );
		
		new money_bonus = get_pcvar_num( g_pCvars[ CVAR_FW_MONEYEXPLOSION ] );
		new frags_bonus = get_pcvar_num( g_pCvars[ CVAR_FW_FRAGSEXPLOSION ] );
		
		new money = cs_get_user_money( id );
		new frags = get_user_frags( id );
		
		// Explosion !
		message_begin_f( MSG_BROADCAST, SVC_TEMPENTITY, origin, 0 );
		write_byte( TE_EXPLOSION );
		write_coord_f( origin[ 0 ] );
		write_coord_f( origin[ 1 ] );
		write_coord_f( origin[ 2 ] );
		write_short( g_ExploSprite );
		write_byte( clamp( floatround( damage ), 0, 255 ));
		write_byte( 15 );
		write_byte( 0 );
		message_end( );
		
		// Kill players around
		while( 1 <= ( enemy = find_ent_in_sphere( enemy, origin, radius )) <= g_MaxPlayers )
		{
			if(( PlayerTeam[ enemy ] == CS_TEAM_CT ) && ( IsAlive[ enemy ] ))
			{
				entity_get_vector( enemy, EV_VEC_origin, origin_enemy );
				
				if(( real_damage = damage / get_distance_f( origin, origin_enemy )) > 1.0 )
				{
					ExecuteHamB( Ham_TakeDamage, enemy, id, id, real_damage, DMG_BLAST|DMG_ALWAYSGIB );
					
					if( !IsAlive[ enemy ] )
					{
						cs_set_user_deaths( enemy, get_user_deaths( enemy ) + 1 );
						money = ( money + money_bonus > 16000 ) ? 16000 : money + money_bonus;
						frags += frags_bonus;
						
						message_begin( MSG_ALL, g_DeathMsg );
						write_byte( id );
						write_byte( enemy );
						write_byte( 0 );
						write_string( "" );
						message_end( );
					}
				}
			}
		}
		
		cs_set_user_money( id, money );
		set_user_frags( id, frags + 1 );
		cs_set_user_deaths( id, get_user_deaths( id ) - 1 );
		
		ExecuteHamB( Ham_Killed, id, id, GIB_ALWAYS );
	}
}

/*==========================================================================================*/

public ShoopdaWhoop( id )
{
	id -= TASK_SHOOP;
	
	if( IsAlive[ id ] )
	{
		set_user_maxspeed( id, get_pcvar_float( g_pCvars[ CVAR_FW_SPEEDSHOOP ] ) );
		set_user_gravity( id, get_pcvar_float( g_pCvars[ CVAR_FW_GRAVITYSHOOP ] ) );
		g_bActivatedShoopDaWhoop[ id ] = true;
		
		client_print( id, print_chat, "%s %L", FLOWERS_TAG, id, "LAUNCH_SHOOP_2" );
		
		emit_sound( id, CHAN_STATIC, SOUND_SHOOP_LAZER, 1.0, ATTN_NORM, 0, PITCH_NORM );
	}
}

// Main

public SpawnPlayer(User)
{
	
	if(is_user_alive(User))
	{
		
		if(NewPlayer[User])
		{
			
			NewPlayer[User] = false;
			
			ColorChat(User, GREEN, "[KWIATKI]^x03 Nie wiesz o co w tym modzie chodzi? Nie martw się wpisz /pomoc lub spytaj innych graczy!");
			
			query_client_cvar(User, "cl_minmodels", "QueryCvar");
			
		}
		
		else
		{
			
			remove_task( User + TASK_EXPLODE );
			remove_task( User + TASK_SCREENFADE );
			remove_task( User + TASK_CTS_MSG );
			remove_task( User + TASK_TS_MSG );
			remove_task( User + TASK_SHOOP );
			
			g_bGoToExplode[ User ] = false;
			HasLaser[User] = false;
			g_bActivatedShoopDaWhoop[ User ] = false;
			
		}
		
		strip_user_weapons( User );
		PlayerTeam[ User ] = cs_get_user_team( User );
		IsAlive[ User ] = true;
		
		switch( PlayerTeam[ User ] )
		{
			case CS_TEAM_T:
			{
				
				LastRoundCT[User] = false;
				
				set_view( User, CAMERA_3RDPERSON );
				set_user_footsteps( User, 1 );
				set_user_health( User, 1 );
			}
			case CS_TEAM_CT:
			{
				
				LastRoundCT[User] = true;
				
				set_view( User, CAMERA_NONE );
				set_user_footsteps( User, 0 );
				
				ScreenFade(User);
			}
		}
		
		set_task( float( get_pcvar_num( g_pCvars[ CVAR_GD_TIMESCREENFADE ] )), "Cts_Beginning", User + TASK_CTS_MSG );
		set_task( float( get_pcvar_num( g_pCvars[ CVAR_FW_TIMECANTATTACK ] )), "Ts_Beginning", User + TASK_TS_MSG );
		
		g_LastTime[ User ] = get_timeleft( );
	
	}
	
	return PLUGIN_CONTINUE;
}

public ScreenFade(User)
{

	message_begin(MSG_ONE, ScreenFadeMsg, {0, 0, 0}, User);
	write_short((1<<12) * 1);
	write_short((1<<12) * 7);
	write_short(0x0002);
	write_byte(0);
	write_byte(0);
	write_byte(0);
	write_byte(255);
	message_end();

}

public EndRound()
{
	
	if(FirstRound)
	{
		
		FirstRound = false;
		
		return PLUGIN_HANDLED;
		
	}
	
	set_task(3.0, "ChangeTeam");
	
	return PLUGIN_CONTINUE;
	
}

public ChangeTeam()
{
	
	new Players[32], Count;
	
	get_players(Players, Count, "h");
	
	for(new Number = 0; Number < Count; Number++)
	{
		
		new ID = Players[Number];
		
		if(is_user_connected(ID) && (cs_get_user_team(ID) != CS_TEAM_SPECTATOR))
		{
			
			cs_set_user_team(ID, CS_TEAM_T);
			
		}
		
	}
	
	if(Count > 15)
	{
		
		RandomCT(Players, Count);
		RandomCT(Players, Count);
		RandomCT(Players, Count);
		RandomCT(Players, Count);
		
	}
	
	else if(Count > 11)
	{
		
		RandomCT(Players, Count);
		RandomCT(Players, Count);
		RandomCT(Players, Count);
		
	}
	
	else if(Count > 5)
	{
		
		RandomCT(Players, Count);
		RandomCT(Players, Count);
		
	}
	
	else
	{
		
		RandomCT(Players, Count);
		
	}
	
}

public RandomCT(const Players[], Count)
{
	
	new One = Players[random(Count)];

	if(LastRoundCT[One])
	{
		
		RandomCT(Players, Count);
		
		return PLUGIN_HANDLED;
		
	}
	
	
	if(is_user_connected(One) && (cs_get_user_team(One) != CS_TEAM_SPECTATOR))
	{
	
		cs_set_user_team(One, CS_TEAM_CT);
		
	}
	
	return PLUGIN_HANDLED;
	
}

// End Main
// Shop

public Cut(User)
{
	
	if(PlayerTeam[User] == CS_TEAM_CT && IsAlive[User])
	{
		
		new Money = cs_get_user_money(User);
		
		if(Money >= 10000)
		{
			
			cs_set_user_money(User, Money - 10000);
			
			give_item(User, "weapon_knife");
			
			ColorChat(User, GREEN, "[KWIATKI]^x03 Uważaj jest ostry! W sam raz do cięcia kwiatków...");
		
		}
		
		else
		{
			
			ColorChat(User, GREEN, "[KWIATKI]^x03 Nie stać Cię. Nóż kosztuje 10000$!");
			
		}
	
	}
	
	return PLUGIN_HANDLED;
	
}

public Ammo(User)
{
	
	if(PlayerTeam[User] == CS_TEAM_CT && IsAlive[User])
	{
		
		new Money = cs_get_user_money(User);
		
		if(Money >= 6000)
		{
			
			cs_set_user_money(User, Money - 6000);
			
			cs_set_user_bpammo(User, CSW_USP, cs_get_user_bpammo(User, CSW_USP ) + 12);
			
			ColorChat(User, GREEN, "[KWIATKI]^x03 Przechandlowales dolary na amunicję... Dobry wybor!");
		
		}
		
		else
		{
			
			ColorChat(User, GREEN, "[KWIATKI]^x03 Nie stać Cię. Amunicja kosztuje 6000$!");
			
		}
	
	}
	
	return PLUGIN_HANDLED;
	
}

public Laser(User)
{
	
	if(PlayerTeam[User] == CS_TEAM_T && IsAlive[User])
	{
		
		new Money = cs_get_user_money(User);
		
		if(Money >= 16000)
		{
			
			cs_set_user_money(User, Money - 16000);
			
			HasLaser[User] = true;
			
			ColorChat(User, GREEN, "[KWIATKI]^x03 Masz teraz laser!");
			ColorChat(User, GREEN, "[KWIATKI]^x03 Zniszcz ich wszystkich!");
			
		}
		
		else
		{
			
			ColorChat(User, GREEN, "[KWIATKI]^x03 Nie stać Cię. Laser kosztuje 16000$!");
			
		}
	
	}
	
	return PLUGIN_HANDLED;
	
}

// End Shop
// Secure

public QueryCvar(User, const Cvar[ ], const Value[ ] )
{
	
	if(is_user_connected(User))
    {
		
		if(!strcmp(Value, "0", 1))
		{
		
			query_client_cvar(User, "cl_minmodels", "QueryCvar");
			
		}
		
		else
		{
			
			client_cmd(User, ";cl_minmodels 0");
			client_cmd(User, ";reconnect");
			
		}
		
	}
	
}

// End Secure

public Help_Command( id )
{
	switch( PlayerTeam[ id ] )
	{
		case CS_TEAM_T:  show_motd( id, FLOWER_MOTD );
		case CS_TEAM_CT: show_motd( id, GARDENER_MOTD );
	}
}