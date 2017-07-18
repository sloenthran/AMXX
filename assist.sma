#include <amxmodx>
#include <fakemeta>
#include <hamsandwich>
#include <fun>
#include <colorchat>

#define MAX 32
#define IsPlayer(%1) (1 <= %1 <= MAX && is_user_connected(%1))

new g_bAsysta[MAX+1][MAX+1];

public plugin_init() {
	register_plugin("Assist", "1.1", "DarkGL")
	
	register_event("DeathMsg", "eventDeath", "a");
	register_event("HLTV", "newRound", "a", "1=0", "2=0") 
	
	RegisterHam(Ham_TakeDamage, "player", "fwDamage", 1);
}

public newRound()
{
	for(new i = 0;i <= MAX;i++){
		for(new j = 0;j <= MAX;j++)
			g_bAsysta[i][j] = 0;
	}
}

public client_connect(id){
	for(new j = 0;j <= MAX;j++)	g_bAsysta[id][j] = 0;
}

public fwDamage(iVictim, iInflicter, iAttacker, Float:fDamage, iBitDamage){
	if( (IsPlayer(iAttacker) && IsPlayer(iVictim)) && get_user_team(iVictim) != get_user_team(iAttacker) && iVictim != iAttacker)
		g_bAsysta[iAttacker][iVictim] += floatround(fDamage);
	
	return HAM_IGNORED;
}

public eventDeath(){
	new iKiller = read_data(1);
	new iVictim = read_data(2);
	
	if(IsPlayer(iKiller) && IsPlayer(iVictim) && iKiller != iVictim)
	{
		new sName[64];
		get_user_name(iVictim, sName, sizeof sName - 1);
		
		for(new i = 0 ; i <= MAX; i ++){
			
			if(IsPlayer(i))
			{
			
				if(i == iKiller)	continue;
			
				if(g_bAsysta[i][iVictim] >= 50){		
				
					ColorChat(i, GREEN, "[Assist]^x03 Pomogles w zabiciu gracza %s! Dostajesz fraga!", sName);
				
					set_user_frags(i, get_user_frags(i)+1)
				}
				
			}
			
			g_bAsysta[i][iVictim] = 0;
			
		}
	}
}