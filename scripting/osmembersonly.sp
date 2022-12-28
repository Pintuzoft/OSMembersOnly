#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <string>

char error[255];
Handle membersonly = null;

public Plugin myinfo = {
	name = "OSMembersOnly",
	author = "Pintuz",
	description = "OldSwedes Members Only plugin",
	version = "0.01",
	url = "https://github.com/Pintuzoft/OSMembersOnly"
}

public void OnPluginStart() {
    databaseConnect();
    HookEvent("player_connect", Event_PlayerConnect);
}

/* EVENTS */
public Action Event_PlayerConnect(Handle event, const char[] name, bool dontBroadcast) {
    int player = GetEventInt ( event, "userid" );
    char steamid[32];
    GetClientAuthId ( player, AuthId_Steam2, steamid, sizeof(steamid) );
    if ( ! IsMember ( steamid ) ) {
        KickClient ( player, "You are not recognized as a member of OldSwedes!, make sure you are registered and have a valid steamid set on your profile." );
    }
    return Plugin_Continue;
}

/* FUNCTIONS */
public bool IsMember ( char steamid[32] ) {
    ReplaceString ( steamid, sizeof(steamid), "STEAM_0:", "" );
    ReplaceString ( steamid, sizeof(steamid), "STEAM_1:", "" );
    PrintToConsoleAll ( "steamid: %s", steamid );
    return true;
}

public void databaseConnect ( ) {
    if ( ( membersonly = SQL_Connect ( "membersonly", true, error, sizeof(error) ) ) != null ) {
        PrintToServer ( "[OSMembersOnly]: Connected to knivhelg database!" );
    } else {
        PrintToServer ( "[OSMembersOnly]: Failed to connect to members database! (error: %s)", error );
    }
}
public bool stringContains ( char string[32], char match[32] ) {
    return ( StrContains ( string, match, false ) != -1 );
}
