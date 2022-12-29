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
    CreateTimer ( 1.0, handleNewPlayer, player_id );    
    return Plugin_Handled;
}

/* FUNCTIONS */

public Action handleNewPlayer ( Handle timer, int player_id ) {
    char kickReason[255];
    int player = GetClientOfUserId ( player_id );

    if ( ! playerIsReal ( player ) ) {
        return Plugin_Continue;
    }
    
    char name[64];
    char steamid[32];
    GetClientName ( player, name, sizeof(name) );
    GetClientAuthId ( player, AuthId_Steam2, steamid, sizeof(steamid) );

    if ( isBot ( steamid ) ) {
        return Plugin_Continue;
    }

    if( invalidSteamID ( steamid ) ) {
        Format ( kickReason, sizeof(kickReason), "You are not recognized as a member of OldSwedes!\nMake sure you are registered on oldswedes.se and have a valid SteamID set on your profile\n\nInvalid SteamID found:\n%s\n\n./OldSwedes", steamid );
        KickClient ( player, kickReason );
    }

    if ( ! IsMember ( name, steamid ) ) {
        Format ( kickReason, sizeof(kickReason), "You are not recognized as a member of OldSwedes!\nMake sure you are registered on oldswedes.se and have a valid SteamID set on your profile\n\nSteamID found:\n%s\n\n./OldSwedes", steamid );
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

public bool IsMember ( char name[64], char steamid[32] ) {
    char buf[32];
    char username[64];
    
    Handle stmt = null;

    buf = steamid;
    ReplaceString ( buf, sizeof(buf), "STEAM_0:", "%" );
    ReplaceString ( buf, sizeof(buf), "STEAM_1:", "%" );

    databaseConnect ( );

    if ( ( stmt = SQL_PrepareQuery ( membersonly, "SELECT name FROM user WHERE steamid like ?", error, sizeof(error) ) ) == null ) {
        SQL_GetError ( membersonly, error, sizeof(error) );
        PrintToServer("[OSMembersOnly]: Failed to query[0x01] (error: %s)", error);
        return false;
    }
    SQL_BindParamString ( stmt, 0, buf, false );
    if ( ! SQL_Execute ( stmt ) ) {
        SQL_GetError ( membersonly, error, sizeof(error) );
        PrintToServer("[OSMembersOnly]: Failed to execute[0x02] (error: %s)", error);
        return false;
    }
    if ( ! SQL_FetchRow ( stmt ) ) {
        SQL_GetError ( membersonly, error, sizeof(error) );
        PrintToServer ( "[OSMembersOnly]: Failed to fetch[0x03] (error: %s)", error );
        return false;
    }
    
    SQL_FetchString ( stmt, 0, username, sizeof(username) );
    
    if ( stmt != null ) {
        delete stmt;
    }

    char message[255];
    Format ( message, sizeof(message), "[OSMembersOnly]: player connected: %s (Member: %s)", name, username );
    PrintToChatAll ( message );
    PrintToServer ( message );
    return true;
}


public bool invalidSteamID ( char steamid[32] ) {
    if ( StrEqual( steamid, "" ) || StrEqual( steamid, "STEAM_ID_PENDING" ) || StrEqual( steamid, "STEAM_ID_STOP_IGNORING_RETVALS" ) ) {
        return true;
    }
    return false;
}

public void databaseConnect ( ) {
    if ( ( membersonly = SQL_Connect ( "membersonly", true, error, sizeof(error) ) ) != null ) {
        PrintToServer ( "[OSMembersOnly]: Connected to members database!" );
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
