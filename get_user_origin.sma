#include <amxmodx>
#include <colorchat>

public plugin_init()
{

	register_plugin("Player Position", "1.0", "Sloenthran");
	
	register_clcmd("say /position", "ShowPosition");
	
}

public ShowPosition(User)
{
	
	new Origin[3];
	
	get_user_origin(User, Origin);
	
	ColorChat(User, GREEN, "[Position]^x03 X: %i | Y: %i | Z: %i", Origin[0], Origin[1], Origin[2]);
	
	return PLUGIN_HANDLED;
	
}