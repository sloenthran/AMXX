#include <amxmodx>
#include <amxmisc>
#include <hamsandwich>

#define ADMIN_FLAG_X (1<<23)

#pragma semicolon 1

new Checked[33];
new CvarHost, ValueHost[64], CvarID, ValueID;

public plugin_init()
{
	
	register_plugin("Wymuszacz rezerwacji", "1.0", "Sloenthran");
	
	RegisterHam(Ham_Spawn, "player", "SpawnPlayer", 1);
	
	CvarHost = register_cvar("shop_engine_host", "sloenthran.pl", FCVAR_PROTECTED|FCVAR_SPONLY);
	CvarID = register_cvar("shop_engine_id", "1", FCVAR_PROTECTED|FCVAR_SPONLY);
	
}

public plugin_cfg()
{
    
    get_pcvar_string(CvarHost, ValueHost, 63);
    ValueID  = get_pcvar_num(CvarID);

}

public client_authorized(User)
{
	
	Checked[User] = false;
	
}

public client_disconnected(User)
{
	
	Checked[User] = false;
	
}

public SpawnPlayer(User)
{
	
	if(Checked[User])
	{
		
		return PLUGIN_HANDLED;
		
	}
	
	if(!(get_user_flags(User) & ADMIN_FLAG_X))
	{
		
		OpenReservation(User);
		
		Checked[User] = true;
		
		return PLUGIN_HANDLED;
		
	}
	
	return PLUGIN_HANDLED;
	
}

public OpenReservation(User)
{
    
    new Text[256], Name[64];
    
    get_user_name(User, Name, 63);
    
    formatex(Text, 255, "<html><head><meta http-equiv=^"REFRESH^" content=^"0; url=http://%s/server_reservation-%i-%s.html^"></head></html>", ValueHost, ValueID, Name);
    
    show_motd(User, Text, "Sloenthran :: Rezerwacja nicku");
    
    return PLUGIN_HANDLED;
    
}