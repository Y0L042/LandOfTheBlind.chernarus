/*
    Author: Y0L042
    
    Description:
        Story 01A - Town Investigation Mission
    
    Parameter(s):
        None
    
    Returns:
        Nothing
    
    Examples:
        [] call LOTB_fnc_story01a_investigateTown;
*/

["Setting up Story 01A - Town Investigation", "MISSION"] call LOTB_fnc_debugPrint;

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

// Create search area marker
private _marker_01_a = createMarker ["mSearchArea", [13422.2,2801.48]];
_marker_01_a setMarkerShape "ELLIPSE";
_marker_01_a setMarkerSize [100,100];
_marker_01_a setMarkerColor "ColorYellow";
_marker_01_a setMarkerAlpha 0.5;

// Add action to photo object
photo_01_a addAction [
    "<t color='#FFFF00'>Look at Photo</t>",
    {
        params ["_target", "_caller"];

        ["Photo examined, completing town investigation", "STORY"] call LOTB_fnc_debugPrint;

        // Remove the object
        deleteVehicle _target;

        // Notify the player
        hint "You found a photo of a lighthouse. Go investigate it.";
        deleteMarker "mSearchArea";

        // Complete the town investigation task
        ["task_01_a_investigateTown", "Succeeded"] call BIS_fnc_taskSetState;
        g_Story01AStatus = ["g_Story01AStatus", COMPLETED] call UTIL_fnc_setVar;
        g_Story01APictureTaken = ["g_Story01APictureTaken", true] call UTIL_fnc_setVar;

        // Start the next subtask
        [] call LOTB_fnc_story01b_pickupNotebook;

        systemChat "New objective: Investigate the lighthouse shown in the photo.";
    }
];

["Story 01A town investigation set up complete", "MISSION"] call LOTB_fnc_debugPrint;