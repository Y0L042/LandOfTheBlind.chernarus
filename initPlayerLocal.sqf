/*
    initPlayerLocal.sqf
    Runs when the player is initialized locally (both initial spawn and JIP)
    This is the proper place to set up player-specific initialization
*/

["initPlayerLocal.sqf started", "INIT"] call LOTB_fnc_debugPrint;

// Wait for player to be properly initialized
waitUntil { player == player }; 
waitUntil { time > 10 };

// Initialize camp cooldown global variable if not set
if (isNil "g_LastCampPlacedTime") then {
    g_LastCampPlacedTime = -1;
    ["Initialized global camp timer variable", "INIT"] call LOTB_fnc_debugPrint;
};

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

// Add place camp action to player
["Adding place camp action to player", "INIT"] call LOTB_fnc_debugPrint;
player addAction [
    "<t color='#00AA00'>📍 Place Camp</t>",
    {
        params ["_target", "_caller"];
        [] call LOTB_fnc_placeCamp;
    },
    nil,
    -1.5,
    false,  // Don't show in action menu by default
    true,   // Hide on use = false, so it stays available
    "",     // No shortcut key
    "alive player", // Only when player is alive
    10      // Max distance (not used for self-actions)
];

// Add camp status action
player addAction [
    "<t color='#AAAAAA'>🏕️ Camp Status</t>",
    {
        params ["_target", "_caller"];
        
        // Use global variable instead of player variable or database
        private _lastCampTime = s_SpawnCampPlaceTime;
        private _currentTime = time;
        private _cooldownDuration = 60;
        
        if (_lastCampTime == -1) then {
            hint "No camp cooldown active. You can place a camp anytime.";
        } else {
            private _timeSinceLastCamp = _currentTime - _lastCampTime;
            if (_timeSinceLastCamp >= _cooldownDuration) then {
                hint "Camp cooldown finished. You can place a new camp.";
            } else {
                private _remainingTime = _cooldownDuration - _timeSinceLastCamp;
                private _remainingMinutes = floor(_remainingTime / 60);
                private _remainingSeconds = floor(_remainingTime mod 60);
                hint format ["Camp cooldown: %1:%02 remaining", _remainingMinutes, _remainingSeconds];
            };
        };
        
        // Show current camp info
        private _campObjects = _caller getVariable ["campObjects", []];
        if (count _campObjects > 0 && !isNull (_campObjects select 0)) then {
            private _campPos = getPos (_campObjects select 0);
            private _distance = _caller distance _campPos;
            systemChat format ["Current camp is %1m away at %2", round(_distance), mapGridPosition _campPos];
        } else {
            systemChat "No active camp placed.";
        };
    },
    nil,
    -1.4,
    false,
    true,
    "",
    "alive player",
    10
];

["initPlayerLocal.sqf complete", "INIT"] call LOTB_fnc_debugPrint;