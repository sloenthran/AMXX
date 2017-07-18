#include <amxmodx>
#include <amxmisc>
#include <codmod>
#include <hamsandwich>
#include <fun>

#define DMG_BULLET (1<<1)

new GiveClass[33];

public plugin_init()
{
	
	register_plugin("COD [Lowca]", "1.0", "Sloenthran");

	cod_register_class("Lowca", "Ma 1/1 z noza(PPM) oraz Pompe z której ma 1/15", (1<<CSW_P228)|(1<<CSW_HEGRENADE)|(1<<CSW_XM1014), 40, 50, 20, 30);
	
	RegisterHam(Ham_TakeDamage, "player", "TakeDamage");
	
}

public cod_class_enabled(User)
{
	
	give_item(User, "weapon_hegrenade");
	
	GiveClass[User] = true;

}

public cod_class_disabled(User)
{
	GiveClass[User] = false;

}

public TakeDamage(User, Inflictor, Attacker, Float:Damage, DamageBits)
{

	if(!is_user_connected(Attacker) && !GiveClass[Attacker])
	{
		
		return HAM_IGNORED;
		
	}

	if(get_user_team(User) != get_user_team(Attacker) && get_user_weapon(Attacker) == CSW_XM1014 && DamageBits & DMG_BULLET && random_num(1, 15) == 1)
	{

		cod_inflict_damage(Attacker, User, float(get_user_health(User)) - Damage + 1.0, 0.0, Inflictor, DamageBits);
		
	}
	
	else if(get_user_weapon(Attacker) == CSW_KNIFE && DamageBits & DMG_BULLET && Damage > 20.0)
	{
		
		cod_inflict_damage(Attacker, User, float(get_user_health(User)) - Damage + 1.0, 0.0, Inflictor, DamageBits);
		
	}

	

	return HAM_IGNORED;

}