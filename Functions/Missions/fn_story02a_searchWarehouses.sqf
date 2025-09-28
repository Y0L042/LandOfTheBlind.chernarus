/*
    Author: Y0L042
    
    Description:
        Story 02A - Search Warehouses Mission
    
    Parameter(s):
        None
    
    Returns:
        Nothing
    
    Examples:
        [] call LOTB_fnc_story02a_searchWarehouses;
*/

["Setting up Story 02A - Search Warehouses", "MISSION"] call LOTB_fnc_debugPrint;

// Create search area marker
private _marker_02_a = createMarker ["mSearchArea", [10278,1853.6,0]];
_marker_02_a setMarkerShape "ELLIPSE";
_marker_02_a setMarkerSize [100,100];
_marker_02_a setMarkerColor "ColorYellow";
_marker_02_a setMarkerAlpha 0.5;

// Create warehouse search task
[player,
    ["task_02_a_searchWarehouses", "task_02_investigateWarehouses"],
    ["Search the warehouses the professor mentioned", "Search Warehouses", "Search Warehouses"],
    [10278,1853.6,0],
    "ASSIGNED",
    1,
    false,
    "",
    false
] call BIS_fnc_taskCreate;

["Story 02A warehouse search set up complete", "MISSION"] call LOTB_fnc_debugPrint;