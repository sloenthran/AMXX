#include <amxmodx>
#include <amxmisc>
#include <colorchat>
	
new MaxPlayers;
	
public plugin_init()
{
	
	register_plugin("amx_ip", "1.3", "Sloenthran");
	register_concmd("amx_ip", "ShowIP");
	
	set_task(140.0, "Adverts", .flags="b");
	
}

public plugin_cfg()
{

	MaxPlayers = get_maxplayers();
	
}

public ShowIP(User)
{

	new PlayerIP[16] , PlayerName[64], PlayerSID[36];
	new Number, NumberTwo;
	
	NumberTwo = 1;
	
	console_print(User, "--------------------------------------------------------------");
	console_print(User, "------------------------- [Lista IP] -------------------------");
	console_print(User, "--------------------------------------------------------------");
	
	for(Number = 0; Number < MaxPlayers; Number++)
	{
	
		if(is_user_connected(Number) && !is_user_hltv(Number))
		{
	
			get_user_ip(Number, PlayerIP , 15 , 1);
			get_user_name(Number, PlayerName , 63);
			get_user_authid(Number, PlayerSID, 35); 
		
			console_print(User , "%d) %s - %s - %s", NumberTwo++, PlayerName , PlayerIP, PlayerSID);
			
		}
		
	}
	
	console_print(User, "--------------------------------------------------------------");
	
	return PLUGIN_HANDLED;
	
}

public Adverts()
{

	ColorChat(0, GREEN, "[IP]^x03 Aby zobaczyć IP graczy wpisz w konsoli amx_ip!");

}