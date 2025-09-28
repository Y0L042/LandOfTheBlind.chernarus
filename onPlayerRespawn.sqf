/*
    onPlayerRespawn.sqf
    Runs when the player respawns
    This is the proper place to restore player loadout after death
*/

["onPlayerRespawn.sqf started", "RESPAWN"] call LOTB_fnc_debugPrint;

// Wait for player to be properly respawned
waitUntil { player == player }; 
waitUntil { time > 5 };

["Player respawned, restoring saved loadout", "RESPAWN"] call LOTB_fnc_debugPrint;

// Load the saved loadout
[] call UTIL_fnc_loadPlayerLoadout;

["onPlayerRespawn.sqf complete", "RESPAWN"] call LOTB_fnc_debugPrint;