/*
Task:
02 - The professor's notebook mentions some warehouses. Go investigate.
a. Search the warehouses

*/

// Main mission task
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


// Function to check and update mission progress
LOTB_fnc_CheckStory02Progress = {
    if (LOTB_SavedVars get LOTB_Story02_WarehousesInvestigated_Key) then {
        ["task_02_investigateWarehouses", "Succeeded"] call BIS_fnc_taskSetState;
        ["Story_02"] call LOTB_fnc_CompleteMission;  // Enabled for proper mission flow
        
        // Clean up any remaining markers
        deleteMarker "mSearchArea";
        deleteMarker "hd_objective";
    };
};

/* Task 02 A: Investigate Warehouses */
_marker_02_a = createMarker ["mSearchArea", [10278,1853.6,0]];
_marker_02_a setMarkerShape "ELLIPSE";
_marker_02_a setMarkerSize [100,100];
_marker_02_a setMarkerColor "ColorYellow";
_marker_02_a setMarkerAlpha 0.5;

[
    player, 
    ["task_02_a_searchWarehouses", "task_02_investigateWarehouses"], 
    [
        "Search the warehouses the professor mentioned", 
        "Search Warehouses", 
        "Search Warehouses"
    ],
    getMarkerPos "mSearchArea",
    "ASSIGNED", 
    1, 
    false,
    "",
    false
] call BIS_fnc_taskCreate;

