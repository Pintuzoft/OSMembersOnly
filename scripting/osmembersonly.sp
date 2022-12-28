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
    PrintToServer ( "player_id: %d", player_id );
    CreateTimer ( 0.5, handleNewPlayer, player_id );
    
    return Plugin_Handled;
}

/* FUNCTIONS */

public Action handleNewPlayer ( Handle timer, int player_id ) {
    char kickReason[255];
    int player = GetClientOfUserId ( player_id );
    PrintToServer ( "player: %d", player );
    if ( ! playerIsReal ( player ) ) {
        return Plugin_Continue;
    }
    
    char steamid[32];
    GetClientAuthId ( player, AuthId_Steam2, steamid, sizeof(steamid) );
    
    PrintToServer ( "steamid: %s", steamid );

    if ( isBot ( steamid ) ) {
        return Plugin_Continue;
    }

    if( invalidSteamID ( steamid ) ) {
        Format ( kickReason, sizeof(kickReason), "You are not recognized as a member of OldSwedes!\nMake sure you are registered on oldswedes.se and have a valid SteamID set on your profile\n\nInvalid SteamID found:\n%s", steamid );
        KickClient ( player, kickReason );
    }

    if ( ! IsMember ( steamid ) ) {
        Format ( kickReason, sizeof(kickReason), "You are not recognized as a member of OldSwedes!\nMake sure you are registered on oldswedes.se and have a valid SteamID set on your profile\n\nSteamID found:\n%s", steamid );
        KickClient ( player, kickReason );
    }
    
    return Plugin_Handled;
}

public bool isBot ( char steamid[32] ) {
    if ( stringContains ( steamid, "BOT" ) ) {
        return true;
    }
    return false;
}

public bool IsMember ( char steamid[32] ) {
    ReplaceString ( steamid, sizeof(steamid), "STEAM_0:", "" );
    ReplaceString ( steamid, sizeof(steamid), "STEAM_1:", "" );
    PrintToServer ( "steamid: %s", steamid );
    return false;
}

public bool invalidSteamID ( char steamid[32] ) {
    if ( StrEqual( steamid, "" ) || StrEqual( steamid, "STEAM_ID_PENDING" ) || StrEqual( steamid, "STEAM_ID_STOP_IGNORING_RETVALS" ) ) {
        return true;
    }
    return false;
}

public void databaseConnect ( ) {
    if ( ( membersonly = SQL_Connect ( "membersonly", true, error, sizeof(error) ) ) != null ) {
        PrintToServer ( "[OSMembersOnly]: Connected to knivhelg database!" );
    } else {
        PrintToServer ( "[OSMembersOnly]: Failed to connect to members database! (error: %s)", error );
    }
}
public bool playerIsReal ( int player ) {
    return ( player > 0 &&
             ! IsClientSourceTV ( player ) );
}
public bool stringContains ( char string[32], char match[32] ) {
    return ( StrContains ( string, match, false ) != -1 );
}
