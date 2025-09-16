/*
===============================================================================
MISSION MANAGER - LAND OF THE BLIND
Controls mission sequence, completion, and persistence
===============================================================================
*/

// Initialize mission manager variables
if (isNil "LOTB_MissionManager") then {
    LOTB_MissionManager = createHashMap;
};

// Mission states
#define MISSION_STATE_NOT_STARTED 0
#define MISSION_STATE_ACTIVE 1
#define MISSION_STATE_COMPLETED 2
#define MISSION_STATE_FAILED 3

// Initialize mission data structure
LOTB_MissionManager set ["currentMissionIndex", 0];
LOTB_MissionManager set ["missionStates", createHashMap];
LOTB_MissionManager set ["isInitialized", false];

// Mission definitions - add more missions here
LOTB_MissionManager set ["missions", [
    ["Story_01", "missions\Story_01.sqf", "First Mission - Find the Notebook"],
    ["Story_02", "missions\Story_02.sqf", "Second Mission - Investigate the Warehouses"]
    // Add more missions as needed
]];

/*
===============================================================================
MISSION MANAGER FUNCTIONS
===============================================================================
*/

// Function to initialize mission states
LOTB_fnc_InitializeMissionStates = {
    private _missions = LOTB_MissionManager get "missions";
    private _states = createHashMap;
    
    {
        private _missionId = _x # 0;
        _states set [_missionId, MISSION_STATE_NOT_STARTED];
    } forEach _missions;
    
    LOTB_MissionManager set ["missionStates", _states];
    ["Mission states initialized"] call skhpersist_fnc_LogToRPT;
};

// Function to start a specific mission
LOTB_fnc_StartMission = {
    params ["_missionId"];
    
    private _missions = LOTB_MissionManager get "missions";
    private _missionData = [];
    
    // Find the mission data
    {
        if ((_x # 0) == _missionId) then {
            _missionData = _x;
            break;
        };
    } forEach _missions;
    
    if (count _missionData == 0) then {
        [format ["Mission '%1' not found!", _missionId]] call skhpersist_fnc_LogToRPT;
        false
    } else {
        private _missionFile = _missionData # 1;
        private _missionName = _missionData # 2;
        
        // Set mission state to active
        private _states = LOTB_MissionManager get "missionStates";
        _states set [_missionId, MISSION_STATE_ACTIVE];
        
        // Execute the mission script
        [] execVM _missionFile;
        
        [format ["Started mission: %1 (%2)", _missionName, _missionId]] call skhpersist_fnc_LogToRPT;
        
        if (hasInterface) then {
            systemChat format ["Mission Started: %1", _missionName];
        };
        
        // Save progress
        [] call LOTB_fnc_SaveMissionProgress;
        
        true
    };
};

// Function to complete a mission
LOTB_fnc_CompleteMission = {
    params ["_missionId"];
    
    private _states = LOTB_MissionManager get "missionStates";
    _states set [_missionId, MISSION_STATE_COMPLETED];
    
    [format ["Mission completed: %1", _missionId]] call skhpersist_fnc_LogToRPT;
    
    if (hasInterface) then {
        systemChat format ["Mission Completed: %1", _missionId];
    };
    
    // Save progress
    // [] call LOTB_fnc_SaveMissionProgress; Disable for testing
    
    // Check if we should start the next mission
    [] call LOTB_fnc_CheckForNextMission;
};

// Function to fail a mission
LOTB_fnc_FailMission = {
    params ["_missionId"];
    
    private _states = LOTB_MissionManager get "missionStates";
    _states set [_missionId, MISSION_STATE_FAILED];
    
    [format ["Mission failed: %1", _missionId]] call skhpersist_fnc_LogToRPT;
    
    if (hasInterface) then {
        systemChat format ["Mission Failed: %1", _missionId];
    };
    
    // Save progress
    [] call LOTB_fnc_SaveMissionProgress;
};

// Function to check and start next mission
LOTB_fnc_CheckForNextMission = {
    private _missions = LOTB_MissionManager get "missions";
    private _currentIndex = LOTB_MissionManager get "currentMissionIndex";
    private _states = LOTB_MissionManager get "missionStates";
    
    // Check if current mission is completed
    private _currentMissionId = (_missions # _currentIndex) # 0;
    private _currentState = _states get _currentMissionId;
    
    if (_currentState == MISSION_STATE_COMPLETED) then {
        // Move to next mission
        _currentIndex = _currentIndex + 1;
        LOTB_MissionManager set ["currentMissionIndex", _currentIndex];
        
        // Check if there are more missions
        if (_currentIndex < count _missions) then {
            private _nextMissionId = (_missions # _currentIndex) # 0;
            [format ["Auto-starting next mission: %1", _nextMissionId]] call skhpersist_fnc_LogToRPT;
            
            // Small delay before starting next mission
            [_nextMissionId] spawn {
                params ["_missionId"];
                sleep 3; // 3 second delay
                [_missionId] call LOTB_fnc_StartMission;
            };
        } else {
            [format ["All missions completed!"]] call skhpersist_fnc_LogToRPT;
            if (hasInterface) then {
                systemChat "Congratulations! All missions completed!";
            };
        };
    };
};

// Function to get current mission
LOTB_fnc_GetCurrentMission = {
    private _missions = LOTB_MissionManager get "missions";
    private _currentIndex = LOTB_MissionManager get "currentMissionIndex";
    
    if (_currentIndex < count _missions) then {
        _missions # _currentIndex
    } else {
        []
    };
};

// Function to get mission state
LOTB_fnc_GetMissionState = {
    params ["_missionId"];
    
    private _states = LOTB_MissionManager get "missionStates";
    _states getOrDefault [_missionId, MISSION_STATE_NOT_STARTED]
};

// Function to save mission progress
LOTB_fnc_SaveMissionProgress = {
    private _progressData = createHashMap;
    _progressData set ["currentMissionIndex", LOTB_MissionManager get "currentMissionIndex"];
    _progressData set ["missionStates", LOTB_MissionManager get "missionStates"];
    
    // Save to profile namespace
    profileNamespace setVariable ["LOTB_MissionProgress", _progressData];
    saveProfileNamespace;
    
    ["Mission progress saved"] call skhpersist_fnc_LogToRPT;
};

// Function to load mission progress
LOTB_fnc_LoadMissionProgress = {
    private _progressData = profileNamespace getVariable ["LOTB_MissionProgress", createHashMap];
    
    if (count _progressData > 0) then {
        LOTB_MissionManager set ["currentMissionIndex", _progressData getOrDefault ["currentMissionIndex", 0]];
        LOTB_MissionManager set ["missionStates", _progressData getOrDefault ["missionStates", createHashMap]];
        
        ["Mission progress loaded"] call skhpersist_fnc_LogToRPT;
        true
    } else {
        ["No mission progress found, starting fresh"] call skhpersist_fnc_LogToRPT;
        false
    };
};

/*
===============================================================================
MISSION MANAGER INITIALIZATION
===============================================================================
*/

// Initialize mission manager
[] spawn {
    ["Initializing Mission Manager..."] call skhpersist_fnc_LogToRPT;
    
    // Initialize mission states
    [] call LOTB_fnc_InitializeMissionStates;
    
    // Try to load existing progress
    private _progressLoaded = [] call LOTB_fnc_LoadMissionProgress;
    
    if (!_progressLoaded) then {
        // Fresh start - begin with first mission
        private _missions = LOTB_MissionManager get "missions";
        if (count _missions > 0) then {
            private _firstMissionId = (_missions # 0) # 0;
            ["Starting first mission for fresh game"] call skhpersist_fnc_LogToRPT;
            [_firstMissionId] call LOTB_fnc_StartMission;
        };
    } else {
        // Resume from saved progress
        ["Resuming from saved progress"] call skhpersist_fnc_LogToRPT;
        private _currentMission = [] call LOTB_fnc_GetCurrentMission;
        
        if (count _currentMission > 0) then {
            private _currentMissionId = _currentMission # 0;
            private _currentState = [_currentMissionId] call LOTB_fnc_GetMissionState;
            
            // If current mission is active, restart it
            if (_currentState == MISSION_STATE_ACTIVE) then {
                [format ["Restarting active mission: %1", _currentMissionId]] call skhpersist_fnc_LogToRPT;
                [_currentMissionId] call LOTB_fnc_StartMission;
            };
        };
    };
    
    LOTB_MissionManager set ["isInitialized", true];
    ["Mission Manager initialized successfully"] call skhpersist_fnc_LogToRPT;
};

/*
===============================================================================
MISSION MANAGER ACTIONS (Scroll wheel menu)
===============================================================================
*/

if (hasInterface) then {
        player addAction [
            "<t color='#000000ff' font='PuristaBold' underline='0' size='0.9'>Debug Actions</t>", // Action text
            "",
            [], // Arguments
            -2.0, // Priority (higher = appears higher in menu)
            true, // Show window
            true, // Hide on use
            "", // Shortcut
            "alive _this", // Condition (only show when player is alive)
            5 // Distance (show action within 5 meters of self)
        ];

    // Add debug actions for mission management
    player addAction [
        "Show Mission Status",
        {
            private _currentMission = [] call LOTB_fnc_GetCurrentMission;
            if (count _currentMission > 0) then {
                private _missionName = _currentMission # 2;
                private _missionId = _currentMission # 0;
                private _state = [_missionId] call LOTB_fnc_GetMissionState;
                
                private _stateText = switch (_state) do {
                    case MISSION_STATE_NOT_STARTED: { "Not Started" };
                    case MISSION_STATE_ACTIVE: { "Active" };
                    case MISSION_STATE_COMPLETED: { "Completed" };
                    case MISSION_STATE_FAILED: { "Failed" };
                    default { "Unknown" };
                };
                
                systemChat format ["Current Mission: %1 (%2)", _missionName, _stateText];
            } else {
                systemChat "No current mission";
            };
        },
        [],
        -2.1,
        true,
        true,
        "",
        "alive _this",
        5
    ];
};