/*
    initPlayerLocal.sqf
    Runs when the player is initialized locally (both initial spawn and JIP)
    This is the proper place to set up player-specific initialization
*/

["initPlayerLocal.sqf started", "INIT"] call LOTB_fnc_debugPrint;

// Wait for player to be properly initialized
waitUntil { player == player }; 
waitUntil { time > 10 };

["Player fully initialized, setting up loadout system", "INIT"] call LOTB_fnc_debugPrint;

if (g_MissionStartedNow) then {
    ["Setting default loadout for new player", "LOADOUT"] call LOTB_fnc_debugPrint;
    [player] call UTIL_setDefaultLoadout;
};

// Check if this is the first time playing or if we have a saved loadout
private _hasSavedLoadout = !([["playerLoadout", []] call UTIL_fnc_getVar] isEqualTo []);

if (_hasSavedLoadout) then {
    // Load saved loadout
    ["Loading saved player loadout", "LOADOUT"] call LOTB_fnc_debugPrint;
    [] call UTIL_fnc_loadPlayerLoadout;
} else {
    // Apply default starting gear for first time
    ["No saved loadout found, applying default gear", "LOADOUT"] call LOTB_fnc_debugPrint;
    [player] call UTIL_fnc_setDefaultLoadout;
};

// Save the current loadout (either loaded or default) for respawns
["Saving current loadout for respawns", "LOADOUT"] call LOTB_fnc_debugPrint;
[] call UTIL_fnc_savePlayerLoadout;

// Start inventory monitoring to detect weapon pickups
["Starting inventory monitoring for weapon pickups", "INIT"] call LOTB_fnc_debugPrint;
[] call UTIL_fnc_startInventoryMonitoring;

["initPlayerLocal.sqf complete", "INIT"] call LOTB_fnc_debugPrint;