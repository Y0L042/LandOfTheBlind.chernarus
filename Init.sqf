// Initialize the main mission script
systemChat "Running Init.sqf";

// PreInit function has already loaded all global variables and INIDBI




systemChat "Starting story scripts...";


/*
Task:
01 - You find yourself on an island. You need to find out what is going on.
a. Investigate town
b. Get notebook from lighthouse
-> Story 02
*/


systemChat "Running Story_01.sqf";

if (g_Story01Status < COMPLETED) then 
{
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
};





if (g_Story01AStatus < COMPLETED) then 
{
    // Town investigation task
    [player,
        ["task_01_a_investigateTown", "task_01_investigateIsland"],
        ["Investigate the town for clues.", "Investigate town", "Investigate town"],
        [13422.2,2801.48],
        "ASSIGNED",
        1,
        false,
        "",
        false
    ] call BIS_fnc_taskCreate;

    _marker_01_a = createMarker ["mSearchArea", [13422.2,2801.48]];
    _marker_01_a setMarkerShape "ELLIPSE";
    _marker_01_a setMarkerSize [100,100];
    _marker_01_a setMarkerColor "ColorYellow";
    _marker_01_a setMarkerAlpha 0.5;

    photo_01_a addAction [
        "<t color='#FFFF00'>Look at Photo</t>",
        {
            params ["_target", "_caller"];

            // Remove the object
            deleteVehicle _target;

            // Notify the player
            hint "You found a photo of a lighthouse. Go investigate it.";
            deleteMarker "mSearchArea";

            // Complete the town investigation task
            ["task_01_a_investigateTown", "Succeeded"] call BIS_fnc_taskSetState;
            g_Story01AStatus = ["g_Story01AStatus", COMPLETED] call UTIL_fnc_setVar;

            // Create the next task
            [player,
                ["task_01_b_pickupNotebook", "task_01_investigateIsland"],
                ["Find the notebook left in the lighthouse", "Find notebook", "Find notebook"],
                [13312.6,2729.3,0],
                "ASSIGNED",
                1,
                false,
                "",
                false
            ] call BIS_fnc_taskCreate;

            // Create marker for lighthouse
            _marker_01_b = createMarker ["hd_objective", [13312.6,2729.3,0]];
            _marker_01_b setMarkerColor "ColorYellow";
            _marker_01_b setMarkerType "hd_objective";
            systemChat "New objective: Investigate the lighthouse shown in the photo.";
        }
    ];
};




if (g_Story01BStatus == ASSIGNED) then 
{
    notebook_01_b addAction [
        "<t color='#FFFF00'>Pick up Notebook</t>",
        {
            params ["_target", "_caller"];

            // Remove the object
            deleteVehicle _target;
            hint "You found the notebook mentioned in the photo. It contains coordinates to the next objective.";
            deleteMarker "hd_objective";

            ["task_01_b_pickupNotebook", "Succeeded"] call BIS_fnc_taskSetState;
            g_Story01BStatus = ["g_Story01BStatus", COMPLETED] call UTIL_fnc_setVar;

            g_Story01Status = ["g_Story01Status", COMPLETED] call UTIL_fnc_setVar;

            g_Story02Status = ["g_Story02Status", ASSIGNED] call UTIL_fnc_setVar;
            g_Story02AStatus = ["g_Story02AStatus", ASSIGNED] call UTIL_fnc_setVar;
            systemChat "New main objective: Investigate the professor's warehouses.";
        }
    ];
};

/*
Task:
02 - The professor's notebook mentions some warehouses. Go investigate.
a. Search the warehouses

*/


systemChat "Running Story_02.sqf";
if (g_Story02Status >= COMPLETED) then
{
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
};




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
};
