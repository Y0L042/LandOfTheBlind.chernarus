/*
===============================================================================
ARMA 3 MULTIPLAYER SCENARIO - LAND OF THE BLIND
Main Script - Initializes save system and loads existing data
===============================================================================
*/

// Wait for mission to be fully initialized
waitUntil {!isNull player && time > 0};

// Structure that will hold all saved data
LOTB_SavedVars_Key = "LOTB_SavedVars";
LOTB_SavedVars = createHashMap;
call LOTB_fnc_SetSavedVarsKeys; // Initialize hashmap key refs

// Log mission start
["Mission 'Land of the Blind' starting..."] call skhpersist_fnc_LogToRPT;

// Wait a moment for the save system to be fully initialized
sleep 1;
// Load saved hashmap BEFORE anything else
[LOTB_SavedVars, LOTB_SavedVars_Key] call LOTB_fnc_GetHashMap;
[LOTB_SavedVars, false] call LOTB_fnc_EnsureSavedVars; // Ensure all keys exist

// Initialize the persistent save system
["Calling save system initialization..."] call skhpersist_fnc_LogToRPT;
[] call skhpersist_fnc_InitializeSaveSystem;


// // Check for existing save data and auto-load if available BEFORE mission manager
// private _autoLoadSlot = 0; // Default auto-load slot

// // Fix the save data check format to match your save system
// private _metadataKey = format ["%1.%2.%3", PSave_SaveGamePrefix, _autoLoadSlot, "metadata"];
// private _saveExists = profileNamespace getVariable [_metadataKey, nil];

// if (!isNil "_saveExists") then {
//     ["Found existing save data in slot " + str _autoLoadSlot + ", loading variables before mission initialization..."] call skhpersist_fnc_LogToRPT;
    
//     // Load the game state IMMEDIATELY - not in a spawn
//     [_autoLoadSlot] call skhpersist_fnc_LoadGame;
    
//     // Notify players that the game was loaded
//     if (hasInterface) then {
//         systemChat format ["Game state loaded from save slot %1", _autoLoadSlot];
//     };
    
//     ["Game state successfully loaded from slot " + str _autoLoadSlot] call skhpersist_fnc_LogToRPT;
// } else {
//     ["No existing save data found, starting fresh mission"] call skhpersist_fnc_LogToRPT;
    
//     // Optional: Initialize fresh mission state here
//     if (hasInterface) then {
//         systemChat "Starting new mission - Land of the Blind";
//     };
// };

// NOW initialize mission manager - after variables are loaded
[] execVM "scripts\missionManager.sqf";

// Set up periodic auto-save (every 5 minutes)
[] spawn {
    while {false} do { // Disable
        sleep 300; // 5 minutes
        
        // Only auto-save if no save/load operation is in progress
        if (!PSave_SaveInProgress && !PSave_LoadInProgress) then {
            ["Performing automatic save..."] call skhpersist_fnc_LogToRPT;
            [_autoLoadSlot] call skhpersist_fnc_SaveGame;
            
            if (hasInterface) then {
                systemChat "Game automatically saved";
            };
        };
    };
};

// Add scroll-wheel save action for all players
if (hasInterface) then {
    [] spawn {
        // Wait for player to be fully initialized
        waitUntil {!isNull player && alive player && time > 1};
        sleep 2; // Additional delay to ensure everything is ready
        
        systemChat "Adding scroll-wheel actions..."; // Debug message
        
        player addAction [
            "<t color='#000000ff' font='PuristaBold' underline='1' size='1.2'>Mission Actions</t>", // Action text
            "",
            [], // Arguments
            -1.1, // Priority (higher = appears higher in menu)
            true, // Show window
            true, // Hide on use
            "", // Shortcut
            "alive _this", // Condition (only show when player is alive)
            5 // Distance (show action within 5 meters of self)
        ];

        player addAction [
            "Save Game", // Action text
            "scripts\saveMission.sqf", // External script file
            [], // Arguments
            -1.1, // Priority (higher = appears higher in menu)
            true, // Show window
            true, // Hide on use
            "", // Shortcut
            "alive _this", // Condition (only show when player is alive)
            5 // Distance (show action within 5 meters of self)
        ];
        
        // Optional: Add a load action as well
        player addAction [
            "Load Game",
            "scripts\loadMission.sqf", // External script file
            [],
            -1.2, // Slightly lower priority than save
            true,
            true,
            "",
            "alive _this",
            5
        ];

        // Add clear save action
        player addAction [
            "Clear Save Data",
            {
                params ["_target", "_caller", "_actionId", "_arguments"];
                
                // Confirmation dialog
                private _confirm = ["Clear Save Data", "Are you sure you want to delete all saved data? This cannot be undone!", "Yes", "Cancel"] call BIS_fnc_guiMessage;
                
                if (_confirm) then {
                    // Clear the save data
                    private _slot = 0; // Default slot
                    [_slot] call skhpersist_fnc_ClearSave;
                    LOTB_SavedVars = createHashMap; // Reset local saved vars
                    [LOTB_SavedVars, true] call LOTB_fnc_EnsureSavedVars; // Re-initialize keys
                    [LOTB_SavedVars, LOTB_SavedVars_Key] call LOTB_fnc_PutHashMap;
                    
                    // Also clear mission progress
                    profileNamespace setVariable ["LOTB_MissionProgress", nil];
                    profileNamespace setVariable ["LandOfTheBlind_LastSaveTime", nil];
                    saveProfileNamespace;
                    
                    systemChat "Save data cleared successfully!";
                    ["Save data cleared by user"] call skhpersist_fnc_LogToRPT;
                    
                    hint "Save data has been cleared. You can restart the mission fresh.";
                } else {
                    systemChat "Save data clear cancelled.";
                };
            },
            [],
            -1.3, // Lower priority than load
            true,
            true,
            "",
            "alive _this",
            5
        ];
        
        systemChat "Scroll-wheel actions added successfully!"; // Debug message
    };
};

// Initialize custom mission-specific content
[] spawn {
    // Wait for save system to be fully ready
    waitUntil {!isNil "PSave_SaveGamePrefix"};
    
    // Add any mission-specific initialization here
    ["Initializing mission-specific content..."] call skhpersist_fnc_LogToRPT;

    systemChat "Starting mission...";
    [LOTB_SavedVars, LOTB_SavedVars_Key] call LOTB_fnc_GetHashMap;
    [LOTB_SavedVars, false] call LOTB_fnc_EnsureSavedVars; // Ensure all keys exist

    // if (isServer && PSave_CurrentlyLoadedSlot == -1) then {
    //     systemChat format ["Fresh Save"];
    // } else {
    //     systemChat format ["Old Save"];
    // };

    ["Mission initialization complete"] call skhpersist_fnc_LogToRPT;
};

["Main script execution completed"] call skhpersist_fnc_LogToRPT;