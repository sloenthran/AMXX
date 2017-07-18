#include <amxmodx>
#include <colorchat>

#define EndTask 666

new bool:LastRound = false;

public plugin_init() 
{ 
    register_plugin("Round Finish", "1.2" ,"Sloenthran") 
    
    register_event("SendAudio", "EndRound", "a","2=%!MRAD_terwin", "2=%!MRAD_ctwin", "2=%!MRAD_rounddraw");
	
    set_task(11.0,"EndMap", EndTask, .flags="d");
} 

public EndMap() 
{ 
	
	LastRound = true;
	server_cmd("mp_timelimit 0");
	
	ColorChat(0, GREEN, "[CheckMap]^x03 Mapa zmieni sie w nastepnej rundzie");
	
} 
public EndRound() 
{
	
    if(LastRound) 
    { 
		
		ColorChat(0, GREEN, "[CheckMap]^x03 Mapa zmieni sie w ciagu 3 sekund");
        
		set_task(3.0, "ChangeMap"); 

	}
	
}

public server_changelevel(MapName[]) 
{ 
    if(LastRound)
	{			
		
		ChangeMap();
		
	}
	
}

public ChangeMap() 
{
	
	LastRound = false; 
	server_cmd("mp_timelimit 25");
	server_cmd("changelevel de_dust2");
	
}