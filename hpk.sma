#include <amxmodx>
#include <colorchat>

#define ADMIN_FLAG_X (1<<23)

new UserPing[33], NumberPukawkaFix;

public plugin_init()
{

	register_plugin("HPK", "2.0", "Sloenthran");
	
	NumberPukawkaFix = 0;
	
	set_task(150.0, "Adverts", .flags="b");
	
	set_task(7.0, "PukawkaFix", .flags="b");

}

public client_authorized(User)
{

	if(!is_user_bot(User) && !is_user_hltv(User))
	{
	
		if(!(get_user_flags(User) & ADMIN_FLAG_X))
		{
		
			set_task(7.0, "CheckPing", User, .flags="b");
		
		}
		
		else
		{
			
			set_task(7.0, "NoCheck", User);
			
		}
	
	}

}

public client_disconnect(User)
{

	if(!is_user_bot(User) && !is_user_hltv(User))
	{
	
		if(!(get_user_flags(User) & ADMIN_FLAG_X))
		{
		
			remove_task(User);			
		
		}
	
	}
	
}

public CheckPing(User)
{
	
	if(get_user_flags(User) & ADMIN_FLAG_X)
	{
		
		remove_task(User);
		
		return PLUGIN_HANDLED;
		
	}
	
	new Ping, Loss;
	
	get_user_ping(User, Ping, Loss);
	
	if(Ping > 90)
	{
	
		UserPing[User]++;
	
		ColorChat(User, GREEN, "[HPK]^x03 Masz zbyt wysoki ping! To %i z 3 ostrzezen!", UserPing[User]);
	
	}
	
	else
	{
	
		if(UserPing[User] != 0)
		{
		
			UserPing[User] -= 1;
		
		}
	
	}
	
	if(UserPing[User] == 3)
	{
	
		new Name[64], UserID;
		
		get_user_name(User, Name, 63);
	
		UserID = get_user_userid(User);
		
		server_cmd("banid 1 #%i", UserID);
		
		client_cmd(User, "; disconnect");
		
		ColorChat(0, GREEN, "[HPK]^x03 Gracz %s zostal wyrzucony za zbyt wysoki ping!", Name);
	
	}
	
	return PLUGIN_HANDLED;

}

public Adverts()
{

	ColorChat(0, GREEN, "[HPK]^x03 Gracze z pingiem 90+ beda wyrzucani!");

}

public NoCheck(User)
{
	
	ColorChat(User, GREEN, "[HPK]^x03 Twoj ping nie bedzie sprawdzany gdyz masz immunitet!");
	
}

public PukawkaFix()
{
	
	for(new Number = 0; Number < 32; Number++)
	{
		
		if(UserPing[Number] > 0)
		{
			
			NumberPukawkaFix++;
			
		}
		
	}
	
	if(NumberPukawkaFix > 5)
	{
	
		for(new Number = 0; Number < 32; Number++)
		{
			
			UserPing[Number] = 0;
			
		}
		
	}
	
}