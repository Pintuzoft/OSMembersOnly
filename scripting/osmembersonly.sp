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
    int player_id = GetEventInt ( event, "userid" );
    if ( player_id == 0 ) {
        return Plugin_Continue;
    }
    PrintToConsoleAll ( "player_id: %i", player_id );
    int player = GetClientOfUserId ( player_id );
    if ( ! playerIsReal ( player ) ) {
        return Plugin_Continue;
    }
    
    PrintToConsoleAll ( "player: %i", player );
    char player_authid[32];
    GetClientAuthId ( player, AuthId_Steam2, player_authid, sizeof(player_authid) );
    PrintToConsoleAll ( "player_authid: %s", player_authid );
  //  if ( ! IsMember ( player_authid ) ) {
  //      KickClient ( player, "You are not recognized as a member of OldSwedes!, make sure you are registered and have a valid steamid set on your profile." );
  //  }
    return Plugin_Handled;
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
public bool playerIsReal ( int player ) {
    return ( IsClientInGame ( player ) &&
             ! IsClientSourceTV ( player ) );
}
public bool stringContains ( char string[32], char match[32] ) {
    return ( StrContains ( string, match, false ) != -1 );
}
