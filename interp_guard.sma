#include <amxmodx>

public plugin_init()
{
	
	register_plugin("Interp Guard", "2.6", "Sloenthran");
	
}

public client_authorized(User)
{
	
	set_task(1.0, "SetInterp", User, .flags="b");
	
}

public SetInterp(User)
{
	
	client_cmd(User, "; rate 25000");
	client_cmd(User, "; cl_updaterate 101");
	client_cmd(User, "; ex_interp 0.01");
	
}