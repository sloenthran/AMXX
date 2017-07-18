#include <amxmodx>
#include <amxmisc>
#include <colorchat>

new UserPlay[33];

public plugin_init()
{
	
	register_plugin("Round Sound", "1.6.1", "Sloenthran");
	
	register_event("SendAudio", "Play", "a", "2&%!MRAD_terwin");
	register_event("SendAudio", "Play", "a", "2&%!MRAD_ctwin");
	
	register_clcmd("say /roundsound", "Change");
	register_clcmd("say_team /roundsound", "Change");
	
	set_task(120.0, "Adverts", .flags="b");
	
}

public plugin_precache()
{
	
	precache_generic("sound/Murzyny4FUN/2015/Sierpien/1.mp3");
	precache_generic("sound/Murzyny4FUN/2015/Sierpien/2.mp3");
	precache_generic("sound/Murzyny4FUN/2015/Sierpien/3.mp3");
	precache_generic("sound/Murzyny4FUN/2015/Sierpien/4.mp3");
	precache_generic("sound/Murzyny4FUN/2015/Sierpien/5.mp3");
	precache_generic("sound/Murzyny4FUN/2015/Sierpien/6.mp3");
	precache_generic("sound/Murzyny4FUN/2015/Sierpien/7.mp3");
	precache_generic("sound/Murzyny4FUN/2015/Sierpien/8.mp3");
	precache_generic("sound/Murzyny4FUN/2015/Sierpien/9.mp3");
	precache_generic("sound/Murzyny4FUN/2015/Sierpien/10.mp3");
	precache_generic("sound/Murzyny4FUN/2015/Sierpien/11.mp3");
	precache_generic("sound/Murzyny4FUN/2015/Sierpien/12.mp3");
	
}

public client_authorized(User)
{
	
	UserPlay[User] = 666;
	
}

public Play()
{
	
	new Music = random_num(1, 12);

	for(new Number = 0; Number < 32; Number++)
	{
		
		if(is_user_connected(Number) && UserPlay[Number] == 666)
		{
			
			client_cmd(Number, ";mp3 play /sound/Murzyny4FUN/2015/Sierpien/%i.mp3", Music);
			
		}
		
	}
	
}

public Change(User)
{
	
	if(UserPlay[User] == 666)
	{
		
		UserPlay[User] = 111;
		
		ColorChat(User, GREEN, "[RS]^x03 RS-y zostaly wylaczone do konca mapy!");
		
	}
	
	else
	{
		
		UserPlay[User] = 666;
		
		ColorChat(User, GREEN, "[RS]^x03 RS-y zostaly wlaczone!");
		
	}
	
	return PLUGIN_HANDLED;
	
}

public Adverts()
{

	ColorChat(0, GREEN, "[RS]^x03 Aby wlaczyc lub wylaczyc RS-y uzyj komendy /roundsound!");

}