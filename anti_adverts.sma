#include <amxmodx>
#include <regex>

#define PATTERN	"([0-9].*[qwertyuiopasdfghjklzxcvbnm`,./;'-= ].*[0-9].*[qwertyuiopasdfghjklzxcvbnm`,./;'-= ].*[0-9].*[qwertyuiopasdfghjklzxcvbnm`,./;'-= ].*[0-9])"

public plugin_init()
{
	
	register_plugin("Anti Adverts", "3.1", "Sloenthran");
	
	register_clcmd("say", "CheckSay");
	register_clcmd("say_team", "CheckSay");
	
}

public client_infochanged(User)
{
	
	CheckName(User);

}	

public client_authorized(User)
{
	
	set_task(5.0, "CheckName", User);
	
}

public CheckSay(User) 
{
	
	new Args[1024], Regex:Result, Error[64], ReturnValue;
	
	read_args(Args, 1023);
	
	Result = regex_match(Args, PATTERN, ReturnValue, Error, 63);
	
	switch(Result)
	{
		
		case REGEX_MATCH_FAIL: return PLUGIN_CONTINUE;
		case REGEX_PATTERN_FAIL: return PLUGIN_CONTINUE;
		case REGEX_NO_MATCH: return PLUGIN_CONTINUE;

		default: 
		{
	
			BanPlayer(User);
			
			regex_free(Result);
			
			return PLUGIN_HANDLED;
			
		}
		
	}
	
	return PLUGIN_CONTINUE;
	
}

public CheckName(User)
{
	
	new UserName[64], Regex:Result, Error[64], ReturnValue;
	
	get_user_name(User, UserName, 63);
	
	Result = regex_match(UserName, PATTERN, ReturnValue, Error, 63);
	
	switch(Result)
	{
		
		case REGEX_MATCH_FAIL: return PLUGIN_CONTINUE;
		case REGEX_PATTERN_FAIL: return PLUGIN_CONTINUE;
		case REGEX_NO_MATCH: return PLUGIN_CONTINUE;

		default: 
		{
	
			BanPlayer(User);
			
			regex_free(Result);
			
			return PLUGIN_HANDLED;
			
		}
		
	}
	
	return PLUGIN_CONTINUE;
	
}

public BanPlayer(User)
{
	
	new UserName[64];
	
	get_user_name(User, UserName, 63);
	
	server_cmd("amx_ban 60 ^"%s^" ^"Reklama!^"", UserName);
	
	return PLUGIN_HANDLED;
	
}