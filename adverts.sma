#include <amxmodx>
#include <colorchat>

public plugin_init()
{

	register_plugin("Adverts", "1.0", "Sloenthran");
	
	set_task(300.0, "Adverts", .flags="b");
	
}

public Adverts()
{
	
	ColorChat(0, GREEN, "[HPK]^x03 Rekrutacja na admina jest otwarta! Czujesz sie na silach? Skladaj podanie!");
	
}