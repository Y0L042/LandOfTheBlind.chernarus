/*
Task:
02 - The professor's notebook mentions some warehouses. Go investigate.
a. Search the warehouses

*/


systemChat "Running Story_02.sqf";
if (g_Story02Status >= COMPLETED) exitWith {};

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



if (g_Story02AStatus < COMPLETED) then 
{
    _marker_02_a = createMarker ["mSearchArea", [10278,1853.6,0]];
    _marker_02_a setMarkerShape "ELLIPSE";
    _marker_02_a setMarkerSize [100,100];
    _marker_02_a setMarkerColor "ColorYellow";
    _marker_02_a setMarkerAlpha 0.5;

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


}
