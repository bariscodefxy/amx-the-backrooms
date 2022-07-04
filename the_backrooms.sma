#include <amxmodx>
#include <amxmisc>
#include <fakemeta_util>
#include <cstrike>
#include <hamsandwich>
#include <fun>
#include <engine>

#define PLUGIN_NAME "The Backrooms"
#define PLUGIN_VERSION "1.0.0"
#define PLUGIN_AUTHOR "bariscodefx"

new g_forwardspeed[32][64], g_gamma[32][64];

public plugin_init()
{

    // registers
    register_plugin( PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR ) ;
    register_logevent( "logevent_round_start", 2, "1=Round_Start" );
    register_logevent( "logevent_round_end", 2, "1=Round_End" );
    RegisterHam(Ham_Touch, "weaponbox", "fw_TouchWeapon")
    RegisterHam(Ham_Touch, "armoury_entity", "fw_TouchWeapon")
    RegisterHam(Ham_Touch, "weapon_shield", "fw_TouchWeapon")
    register_event("DeathMsg", "Event_DeathMsg", "a")
    register_cvar("tb_enabled", "1")
    register_cvar("tb_autojump", "1")
    register_cvar("tb_obunga_health", "100")
    register_cvar("tb_player_health", "1")
    register_cvar("tb_obunga_speed", "500")
    register_cvar("tb_player_speed", "300")

    // tasks
    set_task( 1.0, "initHud", 1000, _, _, "b" ) ;
    set_task( 1.0, "speedChecks", 1100, _, _, "b" ) ;
    set_task( 1.0, "healandimmunityChecks", 1200, _, _, "b" ) ;
    set_task( 1.0, "infiniteAmmo", 1300, _, _, "b" ) ;
    set_task( 1.0, "prepareCvars", 1300, _, _, "b" ) ;
}

public prepareCvars()
{
    if( !get_cvar_num("tb_enabled") ) return PLUGIN_HANDLED;
    
    if ( get_cvar_num( "mp_buytime" ) ) server_cmd( "mp_buytime 0" );
    if ( get_cvar_num( "mp_timelimit" ) ) server_cmd( "mp_timelimit 0" );
    if ( get_cvar_num( "sv_airaccelerate" ) != 999 ) server_cmd( "sv_airaccelerate 999" );
    if ( get_cvar_num( "sv_gravity" ) != 650 ) server_cmd( "sv_gravity 650" );
    if ( get_cvar_num( "mp_autoteambalance" ) ) server_cmd( "mp_autoteambalance 0" );
    if ( !get_cvar_num( "mp_roundover" ) ) server_cmd( "mp_roundover 1" );
    if ( get_cvar_num( "mp_roundrespawn_time" ) ) server_cmd( "mp_roundrespawn_time 0" );
    if ( !get_cvar_num( "mp_auto_join_team" ) ) server_cmd( "mp_auto_join_team 1" );
    if ( !get_cvar_num( "mp_respawn_immunitytime" ) ) server_cmd( "mp_respawn_immunitytime 7" );
    if ( get_cvar_num( "mp_limitteams" ) ) server_cmd( "mp_limitteams 0" );
    if ( get_cvar_num( "mp_roundtime" ) > 2 ) server_cmd( "mp_roundtime 2" );
    
    new players[32], playerCount;
    get_players(players, playerCount, "ach");
    
    for ( new i = 0; i < playerCount; i++ )
    {
        if( !is_user_alive( players[i] ) ) break;
        query_client_cvar( players[i], "cl_forwardspeed", "cvarQuery" );
        query_client_cvar( players[i], "gamma", "cvarQuery" );
    }
    
    return PLUGIN_CONTINUE;
}

public client_disconnected( id )
{
    if ( g_forwardspeed[id][0] ) client_cmd( id, "cl_forwardspeed %s", g_forwardspeed[id] );
    if ( g_gamma[id][0] ) client_cmd( id, "gamma %s", g_gamma[id] );
    
    return PLUGIN_CONTINUE;
}

public cvarQuery( id, cvar[], value[] )
{
    new nVal[64];
    add(nVal, 64, value, 64);
    
    if ( equal( cvar, "cl_forwardspeed" ) )
    {
        if ( !equal( value, "999" ) )
        {
            g_forwardspeed[id] = nVal;
            client_cmd( id, "cl_forwardspeed 999" );
        }
    }else if ( equal( cvar, "gamma" ) )
    {
        if ( !equal( value, "1.0" ) )
        {
            g_gamma[id] = nVal;
            client_cmd( id, "gamma 1.0" );
        }
    }
    
    return PLUGIN_CONTINUE;
}

public healandimmunityChecks()
{
    if( !get_cvar_num("tb_enabled") ) return PLUGIN_HANDLED;
    
    new players[32], playerCount;
    get_players(players, playerCount, "ach");
    
    for ( new i = 0; i < playerCount; i++ )
    {
        if( !is_user_alive( players[i] ) ) break;
        if( cs_get_user_team( players[i] ) == CS_TEAM_CT ) 
        {
            if( get_user_godmode( players[i] ) ) set_user_godmode( players[i], 0 );
            set_user_health( players[i], get_cvar_num("tb_player_health") );
        } else if( cs_get_user_team( players[i] ) == CS_TEAM_T )
        {
            if( !get_user_godmode( players[i] ) ) set_user_godmode( players[i], 1 );
            set_user_health( players[i], get_cvar_num("tb_obunga_health") );
        }
    }

    return PLUGIN_CONTINUE;
}

public initHud()
{
    if( !get_cvar_num("tb_enabled") ) return PLUGIN_HANDLED;

    set_hudmessage( 255, 255, 255, -1.0, 0.75, 2 ) ;
    show_hudmessage( 0, "[ The Backrooms Mod by bariscodefx ]" );

    return PLUGIN_CONTINUE;
}

public speedChecks()
{
    if( !get_cvar_num("tb_enabled") ) return PLUGIN_HANDLED;
    
    new players[32], playerCount;
    get_players(players, playerCount, "ach");
    
    for ( new i = 0; i < playerCount; i++ )
    {
        if( !is_user_alive( players[i] ) ) break;
        if( cs_get_user_team( players[i] ) == CS_TEAM_CT ) fm_set_user_maxspeed( players[i], get_cvar_float("tb_player_speed") );
        else if( cs_get_user_team( players[i] ) == CS_TEAM_T ) fm_set_user_maxspeed( players[i], get_cvar_float("tb_obunga_speed") );
    }
    
    return PLUGIN_CONTINUE;
}

public weaponChecks()
{
    if( !get_cvar_num("tb_enabled") ) return PLUGIN_HANDLED;

    new players[32], playerCount;
    get_players(players, playerCount, "ach") ;
    
    for ( new i = 0; i < playerCount; i++ )
    {
        if ( !is_user_alive(players[i]) ) break;
        fm_strip_user_weapons( players[i] );
        give_item( players[i], "weapon_knife" );
        if( cs_get_user_team( players[i] ) == CS_TEAM_CT )
        {
            give_item( players[i], "weapon_m4a1" );
            give_item( players[i], "weapon_deagle" );
        }
    }

    return PLUGIN_CONTINUE;
}

public infiniteAmmo()
{
    if( !get_cvar_num("tb_enabled") ) return PLUGIN_HANDLED;

    new players[32], playerCount;
    get_players(players, playerCount, "ach") ;
    
    for ( new i = 0; i < playerCount; i++ )
    {
        if ( !is_user_alive(players[i]) ) break;
        if( get_user_weapon( players[i] ) ) cs_set_weapon_ammo( cs_get_user_weapon_entity( players[i] ), 999 );
    }
    
    return PLUGIN_CONTINUE;
}

public fw_TouchWeapon(weapon,id)
{
    if( !get_cvar_num("tb_enabled") ) return PLUGIN_HANDLED;

    if (!is_user_connected(id))
        return HAM_IGNORED;
        
    if ( cs_get_user_team( id ) == CS_TEAM_CT )
        return HAM_IGNORED

    return HAM_SUPERCEDE;
}

public client_PreThink(id) {
	if (!get_cvar_num("tb_enabled"))
		return PLUGIN_CONTINUE
	if (cs_get_user_team(id) == CS_TEAM_T)
	    return PLUGIN_CONTINUE;

	entity_set_float(id, EV_FL_fuser2, 0.0)		// Disable slow down after jumping

	if (!get_cvar_num("tb_autojump"))
		return PLUGIN_CONTINUE

// Code from CBasePlayer::Jump (player.cpp)		Make a player jump automatically
	if (entity_get_int(id, EV_INT_button) & 2) {	// If holding jump
		new flags = entity_get_int(id, EV_INT_flags)

		if (flags & FL_WATERJUMP)
			return PLUGIN_CONTINUE
		if ( entity_get_int(id, EV_INT_waterlevel) >= 2 )
			return PLUGIN_CONTINUE
		if ( !(flags & FL_ONGROUND) )
			return PLUGIN_CONTINUE

		new Float:velocity[3]
		entity_get_vector(id, EV_VEC_velocity, velocity)
		velocity[2] += 250.0
		entity_set_vector(id, EV_VEC_velocity, velocity)

		entity_set_int(id, EV_INT_gaitsequence, 6)	// Play the Jump Animation
	}
	return PLUGIN_CONTINUE
}

public selectRandomObunga()
{
    if( !get_cvar_num("tb_enabled") ) return PLUGIN_HANDLED;
    if( get_playersnum() < 2 ) return PLUGIN_HANDLED;

    new players[32], playerCount, selectedPlayer;
    get_players(players, playerCount, "che", "CT") ;
    
    selectedPlayer = random_num( 0, playerCount - 1 );
    
    new tPlayers[32], tPlayerCount;
    get_players(tPlayers, tPlayerCount, "che", "TERRORIST") ;
    
    cs_set_user_team( players[selectedPlayer], CS_TEAM_T, CS_T_LEET );
    
    for ( new i = 0; i < tPlayerCount; i++ )
    {
        cs_set_user_team( tPlayers[i], CS_TEAM_CT, CS_CT_GIGN );
    }

    return PLUGIN_CONTINUE;
}

public Event_DeathMsg()
{
    if( !get_cvar_num("tb_enabled") ) return PLUGIN_HANDLED;
    new attacker = read_data( 1 );
    server_cmd("say test");
    if(attacker) return PLUGIN_HANDLED;
    new victim = read_data( 2 );
    if( !cs_get_user_team( victim ) != CS_TEAM_CT )
        return PLUGIN_HANDLED;
    
    spawn( victim );
    
    if( !is_user_alive( victim ) ) return PLUGIN_HANDLED;
    
    fm_strip_user_weapons( victim );
    give_item( victim, "weapon_knife" );
    give_item( victim, "weapon_m4a1" );
    give_item( victim, "weapon_deagle" );
    
    return PLUGIN_CONTINUE
}

public logevent_round_start()
{
    if( !get_cvar_num("tb_enabled") ) return PLUGIN_HANDLED;

    set_task( 0.2, "weaponChecks", 990, _, _, "a", 1 ) ;
    
    return PLUGIN_CONTINUE;
}

public logevent_round_end()
{
    if( !get_cvar_num("tb_enabled") ) return PLUGIN_HANDLED;

    set_task( 0.2, "selectRandomObunga", 980, _, _, "a", 1 );
    
    return PLUGIN_CONTINUE;
}