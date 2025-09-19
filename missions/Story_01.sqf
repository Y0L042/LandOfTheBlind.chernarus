/*
Task:
01 - You find yourself on an island. You need to find out what is going on.
a. Investigate town
b. Get notebook from lighthouse
-> Story 02
*/



LOTB_fnc_Check_Task_01 = {
    if (LOTB_SavedVars get LOTB_Story_01_Status_Key != LOTB_NOTSTARTED) then {
        [
            player,
            "task_01_investigateIsland",
            [  
                "Find out what's happening on the island", 
                "Investigate Island", 
                "Investigate Island"
            ],
            objNull, 
            LOTB_SavedVars get LOTB_Story_01_Status_Key, 
            2, 
            true
        ] call BIS_fnc_taskCreate;
    };
};
call LOTB_fnc_Check_Task_01;



LOTB_fnc_Check_Task_01_A = {
    if (LOTB_SavedVars get LOTB_Story_01_a_PhotoFound_Key != LOTB_NOTSTARTED) then {
        [
            player, 
            ["task_01_a_investigateTown", "task_01_investigateIsland"], 
            [
                "Investigate the town for clues.", 
                "Investigate town", 
                "Investigate town"
            ],
            getMarkerPos "mSearchArea", 
            LOTB_SavedVars get LOTB_Story_01_a_PhotoFound_Key,
            1, 
            false,
            "",
            false
        ] call BIS_fnc_taskCreate;

        if (LOTB_SavedVars get LOTB_Story_01_a_PhotoFound_Key == [LOTB_ASSIGNED, LOTB_UNASSIGNED]) then {
            _marker_01_a = createMarker ["mSearchArea", [13422.2,2801.48]];
            _marker_01_a setMarkerShape "ELLIPSE";
            _marker_01_a setMarkerSize [100,100];
            _marker_01_a setMarkerColor "ColorYellow";
            _marker_01_a setMarkerAlpha 0.5;

            photo_01_a addAction [
                "<t color='#FFFF00'>Look at Photo</t>",
                {
                    params ["_target", "_caller"];

                    LOTB_SavedVars set [LOTB_Story_01_a_PhotoFound_Key, LOTB_SUCCESS];
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
                    
                    call LOTB_fnc_Check_Task_01_B;
                }
            ];
        }
    };
};
call LOTB_fnc_Check_Task_01_A;



LOTB_fnc_Check_Task_01_B = {
    if (LOTB_SavedVars get LOTB_Story_01_b_NotebookFound_Key != LOTB_NOTSTARTED) then {
        [
            player, 
            ["task_01_b_pickupNotebook", "task_01_investigateIsland"], 
            [
                "Find the notebook left in the lighthouse", 
                "Find notebook", 
                "Find notebook"
            ],
            objNull,
            LOTB_SavedVars get LOTB_Story_01_b_NotebookFound_Key, 
            1, 
            false,
            "",
            false
        ] call BIS_fnc_taskCreate;

        if (LOTB_SavedVars get LOTB_Story_01_b_NotebookFound_Key == [LOTB_UNASSIGNED, LOTB_ASSIGNED]) then {
            _marker_01_b = createMarker ["hd_objective", [13312.6,2729.3,0]];
            _marker_01_b setMarkerColor "ColorYellow";
            _marker_01_b setMarkerType "hd_objective";
            systemChat "New objective: Investigate the lighthouse shown in the photo.";

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
        };

    };
};
call LOTB_fnc_Check_Task_01_B;

