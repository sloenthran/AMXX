#include <amxmodx>
#include <sqlx>
#include <cstrike>
#include <core>

new Handle:MySQL;
new CvarName, CvarValue[32];

enum StatsData {
	StatsNick[64],
	StatsKill,
	StatsDeath,
	StatsSuicide,
	StatsHeadShot,
	StatsTime
};

new PlayerStats[33][StatsData];

public plugin_init()
{
	
	register_plugin("WebStats", "2.1", "Sloenthran");
	
	set_task(0.5, "PrepareSQL");
	
	register_event("DeathMsg", "DeathMsg", "a");
	
	CvarName = register_cvar("stats_table", "", FCVAR_PROTECTED|FCVAR_SPONLY);
	
}

public client_authorized(User)
{
	
	PlayerStats[User][StatsKill] = 0;
	PlayerStats[User][StatsDeath] = 0;
	PlayerStats[User][StatsSuicide] = 0;
	PlayerStats[User][StatsHeadShot] = 0;
	PlayerStats[User][StatsTime] = 0;
	
	get_user_name(User, PlayerStats[User][StatsNick], 63);
	
	SQL_PrepareString(PlayerStats[User][StatsNick], PlayerStats[User][StatsNick], 63);
	
}

public client_disconnect(User) 
{
	
	if(is_user_hltv(User) || is_user_bot(User))
	{
		
		return PLUGIN_HANDLED;
		
	}
	
	PlayerStats[User][StatsTime] = get_user_time(User, 1);
	
	SaveStats(User);
	
	PlayerStats[User][StatsKill] = 0;
	PlayerStats[User][StatsDeath] = 0;
	PlayerStats[User][StatsSuicide] = 0;
	PlayerStats[User][StatsHeadShot] = 0;
	PlayerStats[User][StatsTime] = 0;
	
	return PLUGIN_HANDLED;
	
}

public PrepareSQL()
{
	
	get_pcvar_string(CvarName, CvarValue, 31);
	
	MySQL = SQL_MakeDbTuple(", "", "", "");
	
	static Query[512];
	
	formatex(Query, 511, "CREATE TABLE IF NOT EXISTS `%s` (`id` int(11) NOT NULL AUTO_INCREMENT, `nick` varchar(64) NOT NULL, `kill` int(32) NOT NULL, `death` int(32) NOT NULL, `suicide` int(32) NOT NULL, `headshot` int(32) NOT NULL, `first` int(16) NOT NULL, `last` int(16) NOT NULL, `time` int(16) NOT NULL, PRIMARY KEY (`id`), UNIQUE KEY (`nick`));", CvarValue);
	
	SQL_ThreadQuery(MySQL, "Query", Query);	
	
}

public DeathMsg()
{
	
	new Killer = read_data(1);
	new Killed = read_data(2);
	new HS = read_data(3);
	
	if(Killer == Killed)
	{
		
		PlayerStats[Killer][StatsSuicide] += 1;
		
	}
	
	else
	{
		
		if(HS)
		{
			
			PlayerStats[Killer][StatsHeadShot] += 1;
			
		}
		
		PlayerStats[Killer][StatsKill] += 1;
		PlayerStats[Killed][StatsDeath] += 1;
		
	}
	
}

public SaveStats(User) 
{
	
	static Query[2048], Length = 0, Max = sizeof(Query) - 1;
	
	Length += formatex(Query[Length], Max-Length, "INSERT IGNORE INTO `%s` (`nick`, `kill`, `death`, `suicide`, `headshot`, `first`, `last`, `time`) ", CvarValue);
	Length += formatex(Query[Length], Max-Length, "VALUES('%s', %i, %i, %i, %i, UNIX_TIMESTAMP(NOW()), UNIX_TIMESTAMP(NOW()), %i) ", PlayerStats[User][StatsNick], PlayerStats[User][StatsKill], PlayerStats[User][StatsDeath], PlayerStats[User][StatsSuicide], PlayerStats[User][StatsHeadShot], PlayerStats[User][StatsTime]);
	Length += formatex(Query[Length], Max-Length, "ON DUPLICATE KEY UPDATE `kill`=`kill`+%i, `death`=`death`+%i, `suicide`=`suicide`+%i, `headshot`=`headshot`+%i, `time`=`time`+%i, `last`=UNIX_TIMESTAMP(NOW());", PlayerStats[User][StatsKill], PlayerStats[User][StatsDeath], PlayerStats[User][StatsSuicide], PlayerStats[User][StatsHeadShot], PlayerStats[User][StatsTime]);
	
	SQL_ThreadQuery(MySQL, "Query", Query);
	
}

public Query(FailState, Handle:Query, Error[])
{
	
	if(FailState != TQUERY_SUCCESS)
	{
		
		log_amx("[WebStats SQL Error] %s", Error);
		
		return PLUGIN_HANDLED;
		
	}
	
	return PLUGIN_HANDLED;
	
}

stock SQL_PrepareString(const Data[], Out[], Size)
{
	
	copy(Out, Size, Data);
	
	replace_all(Out, Size, "'", "\'");
	replace_all(Out, Size, "`", "\`");    
	replace_all(Out, Size, "\\", "\\\\");
	replace_all(Out, Size, "^0", "\0");
	replace_all(Out, Size, "^n", "\n");
	replace_all(Out, Size, "^r", "\r");
	replace_all(Out, Size, "^x1a", "\Z");
	
}