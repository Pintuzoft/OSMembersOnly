#include <sourcemod>
#include <sdktools>
#include <cstrike>


public Plugin myinfo = {
	name = "OSMembersOnly",
	author = "Pintuz",
	description = "OldSwedes Members Only plugin",
	version = "0.01",
	url = "https://github.com/Pintuzoft/OSMembersOnly"
}


public void OnPluginStart() {
    HookEvent("player_connect", Event_OnPlayerConnect);
}

/* EVENTS */
public Action Event_OnPlayerConnect(Handle event, const String[] &eventname, bool dontBroadcast) {
    int client = GetClientOfUserId ( GetEventInt ( event, "userid" ) );
    char steamid[32];
    GetClientAuthId ( client, steamid, sizeof(steamid) );
    if ( ! IsMember ( steamid ) ) {
        KickClient ( client, "You are not recognized as a member of OldSwedes!, make sure you are registered and have a valid steamid set on your profile." );
    }
    return Plugin_Continue;
}

/* FUNCTIONS */
public bool IsMember ( char steamid[32] ) {
    char url[256];
    steamid = StrReplace ( steamid, "STEAM_0:", "" );
    steamid = StrReplace ( steamid, "STEAM_1:", "" );
    Format ( url, sizeof(url), "http://oldswedes.com/serverapi/index.php?request=ismember&steamid=%s", steamid );
    char response[256];
    HTTPGet ( url, response, sizeof(response) );
    if ( stringContains ( response, "TRUE" ) ) ) {
        return true;
    }
    return false;
}


public bool stringContains ( char string[32], char match[32] ) {
    return ( StrContains ( string, match, false ) != -1 );
}
