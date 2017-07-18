#include <amxmodx>

public plugin_init()
{

	register_plugin("Change Map", "1.0", "Sloenthran");
	
	set_task(0.1, "ChangeMap", .flags="d");
	
}

public ChangeMap()
{
	
	server_cmd("changelevel de_dust2");
	
}