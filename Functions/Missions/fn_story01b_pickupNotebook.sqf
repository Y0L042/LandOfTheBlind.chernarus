/*
    Author: Y0L042
    
    Description:
        Story 01B - Pickup Notebook Mission
    
    Parameter(s):
        None
    
    Returns:
        Nothing
    
    Examples:
        [] call LOTB_fnc_story01b_pickupNotebook;
*/

["Setting up Story 01B - Pickup Notebook", "MISSION"] call LOTB_fnc_debugPrint;

// Create the notebook pickup task
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
private _marker_01_b = createMarker ["hd_objective", [13312.6,2729.3,0]];
_marker_01_b setMarkerColor "ColorYellow";
_marker_01_b setMarkerType "hd_objective";

// Add action to notebook object
notebook_01_b addAction [
    "<t color='#FFFF00'>Pick up Notebook</t>",
    {
        params ["_target", "_caller"];

        ["Notebook picked up, completing Story 01", "STORY"] call LOTB_fnc_debugPrint;

        // Remove the object
        deleteVehicle _target;
        hint "You found the notebook mentioned in the photo. It contains coordinates to the next objective.";
        deleteMarker "hd_objective";

        // Complete this task and Story 01
        ["task_01_b_pickupNotebook", "Succeeded"] call BIS_fnc_taskSetState;
        g_Story01BStatus = ["g_Story01BStatus", COMPLETED] call UTIL_fnc_setVar;
        g_Story01Status = ["g_Story01Status", COMPLETED] call UTIL_fnc_setVar;
        g_Story01BNotebookTaken = ["g_Story01BNotebookTaken", true] call UTIL_fnc_setVar;

        // Start Story 02
        g_Story02Status = ["g_Story02Status", ASSIGNED] call UTIL_fnc_setVar;
        g_Story02AStatus = ["g_Story02AStatus", ASSIGNED] call UTIL_fnc_setVar;
        
        // Initialize Story 02 missions
        [] call LOTB_fnc_story02_main;

        systemChat "New main objective: Investigate the professor's warehouses.";
    }
];

["Story 01B notebook pickup set up complete", "MISSION"] call LOTB_fnc_debugPrint;