/*
Task:
01 - You find yourself on an island. You need to find out what is going on.
a. Investigate town
b. Get notebook from lighthouse
-> Story 02
*/

// SAVED_VARS
// Use LOTB_SavedVars hashmap directly for all mission state

// Main mission task

if (LOTB_SavedVars get LOTB_Story_01_Completed_Key) exitWith {};
[
    player,
    "task_01_investigateIsland",
    [  
        "Find out what's happening on the island", 
        "Investigate Island", 
        "Investigate Island"
    ],
    objNull, 
    "ASSIGNED", 
    2, 
    true
] call BIS_fnc_taskCreate;

// Initialize mission variables

// Function to check and update mission progress
LOTB_fnc_CheckStory01Progress = {
    // If notebook is found, complete the main mission
    if (LOTB_SavedVars get LOTB_Story_01_b_NotebookFound_Key) then {
        ["task_01_investigateIsland", "Succeeded"] call BIS_fnc_taskSetState;
        ["Story_01"] call LOTB_fnc_CompleteMission;  // Enabled for proper mission flow
        // Clean up any remaining markers
        deleteMarker "mSearchArea";
        deleteMarker "hd_objective";
        systemChat "Mission Story_01 completed! Starting next mission...";
    };
};



// Photo interaction
if (!(LOTB_SavedVars get LOTB_Story_01_a_PhotoFound_Key)) then {

    /* Task 01 A: Investigate Town (Optional) */
    // Create search area marker FIRST
    _marker_01_a = createMarker ["mSearchArea", [13422.2,2801.48]];
    _marker_01_a setMarkerShape "ELLIPSE";
    _marker_01_a setMarkerSize [100,100];
    _marker_01_a setMarkerColor "ColorYellow";
    _marker_01_a setMarkerAlpha 0.5;
    // _marker_01_a setMarkerBrush "Forward diagonal";

    // Now create the task with the correct marker position
    [
        player, 
        ["task_01_a_investigateTown", "task_01_investigateIsland"], 
        [
            "Investigate the town for clues.", 
            "Investigate town", 
            "Investigate town"
        ],
        getMarkerPos "mSearchArea", 
        "ASSIGNED",
        1, 
        false,
        "",
        false
    ] call BIS_fnc_taskCreate;

    photo_01_a addAction [
        "<t color='#FFFF00'>Look at Photo</t>",
        {
            params ["_target", "_caller"];
            // Only process if not already found
            if (!(LOTB_SavedVars get LOTB_Story_01_a_PhotoFound_Key)) then {
                LOTB_SavedVars set [LOTB_Story_01_a_PhotoFound_Key, true];
                private _tasksCompleted = LOTB_SavedVars get LOTB_Story_01_TasksCompleted_Key;
                if (isNil "_tasksCompleted") then { _tasksCompleted = []; };
                _tasksCompleted pushBack "photo";
                LOTB_SavedVars set [LOTB_Story_01_TasksCompleted_Key, _tasksCompleted];
                // Remove the object
                deleteVehicle _target;
                // Notify the player
                hint "You found a photo of a lighthouse. Go investigate it.";
                // Complete the town investigation task
                ["task_01_a_investigateTown", "Succeeded"] call BIS_fnc_taskSetState;
                deleteMarker "mSearchArea";
                // NOW create lighthouse task and marker (only after photo is found)
                if (!(LOTB_SavedVars get LOTB_Story_01_b_NotebookFound_Key)) then {
                    [
                        player, 
                        ["task_01_b_pickupNotebook", "task_01_investigateIsland"], 
                        [
                            "Find the notebook left in the lighthouse", 
                            "Find notebook", 
                            "Find notebook"
                        ],
                        objNull,
                        "ASSIGNED", 
                        1, 
                        false,
                        "",
                        false
                    ] call BIS_fnc_taskCreate;
                    // Create lighthouse marker
                    _marker_01_b = createMarker ["hd_objective", [13312.6,2729.3,0]];
                    _marker_01_b setMarkerColor "ColorYellow";
                    _marker_01_b setMarkerType "hd_objective";
                    systemChat "New objective: Investigate the lighthouse shown in the photo.";
                };
                // Check overall progress
                [] call LOTB_fnc_CheckStory01Progress;
            };
        }
    ];
};

// Notebook interaction (no task or marker created initially - hidden until photo found)
notebook_01_b addAction [
    "<t color='#FFFF00'>Pick up Notebook</t>",
    {
        params ["_target", "_caller"];
        // Only process if not already found
        if (!(LOTB_SavedVars get LOTB_Story_01_b_NotebookFound_Key)) then {
            LOTB_SavedVars set [LOTB_Story_01_b_NotebookFound_Key, true];
            private _tasksCompleted = LOTB_SavedVars get LOTB_Story_01_TasksCompleted_Key;
            if (isNil "_tasksCompleted") then { _tasksCompleted = []; };
            _tasksCompleted pushBack "notebook";
            LOTB_SavedVars set [LOTB_Story_01_TasksCompleted_Key, _tasksCompleted];
            // Remove the object
            deleteVehicle _target;
            // Different responses based on how they found it
            if (LOTB_SavedVars get LOTB_Story_01_a_PhotoFound_Key) then {
                hint "You found the notebook mentioned in the photo. It contains coordinates to the next objective.";
                // Complete the notebook task that was created after photo
                ["task_01_b_pickupNotebook", "Succeeded"] call BIS_fnc_taskSetState;
            } else {
                hint "You found a notebook. It contains coordinates to the next objective.";
                // If they skipped the photo, auto-complete the town task
                ["task_01_a_investigateTown", "Succeeded"] call BIS_fnc_taskSetState;
                deleteMarker "mSearchArea";
                // Create and immediately complete the notebook task for progression tracking
                [
                    player, 
                    ["task_01_b_pickupNotebook", "task_01_investigateIsland"], 
                    [
                        "Find the notebook left in the lighthouse", 
                        "Find notebook", 
                        "Find notebook"
                    ],
                    [13312.6,2729.3,0], 
                    "CREATED", 
                    1, 
                    true
                ] call BIS_fnc_taskCreate;
                ["task_01_b_pickupNotebook", "Succeeded"] call BIS_fnc_taskSetState;
            };
            // Clean up lighthouse marker if it exists
            deleteMarker "hd_objective";
            // Check overall progress (this will complete the mission)
            [] call LOTB_fnc_CheckStory01Progress;
        };
    }
];
