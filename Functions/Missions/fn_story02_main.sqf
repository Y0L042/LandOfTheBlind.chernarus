/*
    Author: Y0L042
    
    Description:
        Story 02 Main Mission - Creates the warehouse investigation task
    
    Parameter(s):
        None
    
    Returns:
        Nothing
    
    Examples:
        [] call LOTB_fnc_story02_main;
*/

["Creating Story 02 main task", "MISSION"] call LOTB_fnc_debugPrint;

// Main warehouse investigation task
[
    player,
    "task_02_investigateWarehouses",
    [  
        "Investigate the professor's warehouses.", 
        "Investigate Warehouses", 
        "Investigate Warehouses"
    ],
    objNull, 
    "ASSIGNED", 
    2, 
    true
] call BIS_fnc_taskCreate;

["Story 02 main task created", "MISSION"] call LOTB_fnc_debugPrint;

// Create Story 02A (warehouse search) if assigned
if (g_Story02AStatus == ASSIGNED) then {
    ["Initializing Story 02A - Warehouse Search", "MISSION"] call LOTB_fnc_debugPrint;
    [] call LOTB_fnc_story02a_searchWarehouses;
};