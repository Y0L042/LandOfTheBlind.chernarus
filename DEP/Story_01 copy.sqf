/*
Task:
01 - You find yourself on an island. You need to find out what is going on.
a. Investigate town
b. Get notebook from lighthouse
c. Leave for mainland
*/

// Main mission task
_task_01 = player createSimpleTask ["task_investigateIsland"];
_task_01 setSimpleTaskDescription ["Find out what's happening on the island", "Investigate Island", "Investigate Island"];
_task_01 setTaskState "Assigned";

// Initialize mission variables
LOTB_Story01_PhotoFound = false;
LOTB_Story01_NotebookFound = false;
LOTB_Story01_TasksCompleted = [];

// Function to check and update mission progress
LOTB_fnc_CheckStory01Progress = {
    // If notebook is found, complete the main mission
    if (LOTB_Story01_NotebookFound) then {
        ["task_investigateIsland", "Succeeded"] call BIS_fnc_taskSetState;
        // ["Story_01"] call LOTB_fnc_CompleteMission;
        
        // Clean up any remaining markers
        deleteMarker "mSearchArea";
        deleteMarker "hd_objective";
    };
};

/* Task 01 A: Investigate Town (Optional) */
["task_investigateTown", true,
 ["Investigate the town for clues.", "Investigate town", "Investigate town"],
 getMarkerPos "mSearchArea", "ASSIGNED", 1, true, "task_investigateIsland"
] call BIS_fnc_taskCreate;

// Create search area marker
_marker_01_a = createMarker ["mSearchArea", [13422.2,2801.48]];
_marker_01_a setMarkerShape "ELLIPSE";
_marker_01_a setMarkerSize [100,100];
_marker_01_a setMarkerColor "ColorYellow";
_marker_01_a setMarkerAlpha 0.5;
_marker_01_a setMarkerBrush "Forward diagonal";

// Photo interaction
photo_01_a addAction [
    "Look at photo",
    {
        params ["_target", "_caller"];
        
        // Only process if not already found
        if (!LOTB_Story01_PhotoFound) then {
            LOTB_Story01_PhotoFound = true;
            LOTB_Story01_TasksCompleted pushBack "photo";
            
            // Remove the object
            deleteVehicle _target;
            
            // Notify the player
            hint "You found a photo of a lighthouse. Go investigate it.";
            
            // Complete the town investigation task
            ["task_investigateTown", "Succeeded"] call BIS_fnc_taskSetState;
            deleteMarker "mSearchArea";
            
            // Create lighthouse task and marker (only after photo is found)
            if (!LOTB_Story01_NotebookFound) then {
                ["task_pickupNotebook", true,
                ["Find the notebook left in the lighthouse", "Find notebook", "Find notebook"],
                getMarkerPos "hd_objective", "CREATED", 1, true, "task_investigateIsland"
                ] call BIS_fnc_taskCreate;
                
                // Create lighthouse marker
                _marker_01_b = createMarker ["hd_objective", [13312.6,2729.3,0]];
                _marker_01_b setMarkerColor "ColorYellow";
                _marker_01_b setMarkerType "hd_objective";
                
                hint "New objective: Investigate the lighthouse shown in the photo.";
            };
            
            // Check overall progress
            [] call LOTB_fnc_CheckStory01Progress;
        };
    }
];

// Notebook interaction (no task or marker created initially)
notebook_01_b addAction [
    "Pick up Notebook",
    {
        params ["_target", "_caller"];
        
        // Only process if not already found
        if (!LOTB_Story01_NotebookFound) then {
            LOTB_Story01_NotebookFound = true;
            LOTB_Story01_TasksCompleted pushBack "notebook";
            
            // Remove the object
            deleteVehicle _target;
            
            // Different responses based on how they found it
            if (LOTB_Story01_PhotoFound) then {
                hint "You found the notebook mentioned in the photo. It contains coordinates to the next objective.";
                // Complete the notebook task that was created after photo
                ["task_pickupNotebook", "Succeeded"] call BIS_fnc_taskSetState;
            } else {
                hint "You found a notebook. It contains coordinates to the next objective.";
                // If they skipped the photo, auto-complete the town task
                ["task_investigateTown", "Succeeded"] call BIS_fnc_taskSetState;
                deleteMarker "mSearchArea";
                
                // Create and immediately complete the notebook task for progression tracking
                ["task_pickupNotebook", true,
                ["Find the notebook left in the lighthouse", "Find notebook", "Find notebook"],
                getMarkerPos "hd_objective", "CREATED", 1, true, "task_investigateIsland"
                ] call BIS_fnc_taskCreate;
                _task_01_b setTaskState "Succeeded";
            };
            
            // Clean up lighthouse marker if it exists
            deleteMarker "hd_objective";
            
            // Check overall progress (this will complete the mission)
            [] call LOTB_fnc_CheckStory01Progress;
        };
    }
];

// Optional: Add a trigger zone around the lighthouse for early discovery hint
_lighthouseTrigger = createTrigger ["EmptyDetector", [13312.6,2729.3,0]];
_lighthouseTrigger setTriggerArea [50, 50, 0, false];
_lighthouseTrigger setTriggerActivation ["WEST", "PRESENT", false];
_lighthouseTrigger setTriggerStatements [
    "this && !LOTB_Story01_PhotoFound && player in thisList",
    "
        hint 'You discovered a lighthouse. Maybe there are clues inside.';
        if (getMarkerColor 'hd_objective' == '') then {
            _marker = createMarker ['hd_objective', [13312.6,2729.3,0]];
            _marker setMarkerColor 'ColorYellow';
            _marker setMarkerType 'hd_objective';
        };
    ",
    ""
];