/*
    Author: Y0L042
    
    Description:
        Story 01 Main Mission - Creates the main investigation task
    
    Parameter(s):
        None
    
    Returns:
        Nothing
    
    Examples:
        [] call LOTB_fnc_story01_main;
*/

["Creating Story 01 main task", "MISSION"] call LOTB_fnc_debugPrint;

// Main mission task
[
    player,
    "task_01_investigateIsland",
    ["Find out what's happening on the island", "Investigate Island", "Investigate Island"],
    objNull,
    "ASSIGNED",
    2,
    true
] call BIS_fnc_taskCreate;

["Story 01 main task created", "MISSION"] call LOTB_fnc_debugPrint;



// Create Story 01A (town investigation) if not completed

if (g_Story01AStatus < COMPLETED) then {
    ["Initializing Story 01A - Town Investigation", "MISSION"] call LOTB_fnc_debugPrint;
    [] call LOTB_fnc_story01a_investigateTown;
};

// Create Story 01B (notebook pickup) if Story 01A is completed but 01B is still assigned
if (g_Story01BStatus > NOT_STARTED) then {
    ["Initializing Story 01B - Notebook Pickup", "MISSION"] call LOTB_fnc_debugPrint;
    [] call LOTB_fnc_story01b_pickupNotebook;
};