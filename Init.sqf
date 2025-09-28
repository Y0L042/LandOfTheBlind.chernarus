// Initialize the main mission script
systemChat "Running Init.sqf";

// PreInit function has already loaded all global variables and INIDBI
// Player loadout handling is now done via initPlayerLocal.sqf and onPlayerRespawn.sqf

// Restore saved camp before player spawns to make it available as respawn option
["Restoring saved camp before player spawn", "INIT"] call LOTB_fnc_debugPrint;
[] call UTIL_fnc_restoreSavedCamp;

systemChat "Starting story scripts...";

["Initializing mission system", "INIT"] call LOTB_fnc_debugPrint;

// Story 01 - Island Investigation
["Checking Story 01 status", "MISSION"] call LOTB_fnc_debugPrint;


// Create main Story 01 task if not completed
if (g_Story01Status < COMPLETED) then {
    ["Initializing Story 01 main mission", "MISSION"] call LOTB_fnc_debugPrint;
    [] call LOTB_fnc_story01_main;
};

// Story 02 - Warehouse Investigation
["Checking Story 02 status", "MISSION"] call LOTB_fnc_debugPrint;

// Create Story 02 main task if assigned but not completed
if (g_Story02Status == ASSIGNED) then {
    ["Initializing Story 02 main mission", "MISSION"] call LOTB_fnc_debugPrint;
    [] call LOTB_fnc_story02_main;
};

["Mission system initialization complete", "INIT"] call LOTB_fnc_debugPrint;
