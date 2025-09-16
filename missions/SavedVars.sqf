// Var keys
LOTB_fnc_SetSavedVarsKeys = {
    systemChat "SavedVars keys created";

    // Story_01
    LOTB_Story_01_TasksCompleted_Key = "LOTB_Story_01_TasksCompleted";
    LOTB_Story_01_Completed_Key = "LOTB_Story_01_Completed";
    LOTB_Story_01_a_PhotoFound_Key = "LOTB_Story_01_a_PhotoFound";
    LOTB_Story_01_b_NotebookFound_Key = "LOTB_Story_01_b_NotebookFound";

    // Story_02
    LOTB_Story02_TasksCompleted_Key = "LOTB_Story02_TasksCompleted";
    LOTB_Story02_WarehousesInvestigated_Key = "LOTB_Story02_WarehousesInvestigated";
};

LOTB_fnc_EnsureSavedVars = {
    params ["_hashMap", ["_reset", false]];

    systemChat "EnsureSavedVars()";
    [format ["EnsureSavedVars() called on %1", if (hasInterface) then {"client"} else {"server"}]] call skhpersist_fnc_LogToRPT;

    if (_reset) then {
        systemChat "Resetting SavedVars!";
        [format ["Resetting SavedVars! called on %1", if (hasInterface) then {"client"} else {"server"}]] call skhpersist_fnc_LogToRPT;
        _hashMap = createHashMap;
    };

    // Story_01
    if (isNil { _hashMap get LOTB_Story_01_TasksCompleted_Key }) then {
        _hashMap set [LOTB_Story_01_TasksCompleted_Key, []];
    };
    if (isNil { _hashMap get LOTB_Story_01_Completed_Key }) then {
        _hashMap set [LOTB_Story_01_Completed_Key, false];
    };
    if (isNil { _hashMap get LOTB_Story_01_a_PhotoFound_Key }) then {
        _hashMap set [LOTB_Story_01_a_PhotoFound_Key, false];
    };
    if (isNil { _hashMap get LOTB_Story_01_b_NotebookFound_Key }) then {
        _hashMap set [LOTB_Story_01_b_NotebookFound_Key, false];
    };

    // Story_02
    if (isNil { _hashMap get LOTB_Story02_TasksCompleted_Key }) then {
        _hashMap set [LOTB_Story02_TasksCompleted_Key, []];
    };
    if (isNil { _hashMap get LOTB_Story02_WarehousesInvestigated_Key }) then {
        _hashMap set [LOTB_Story02_WarehousesInvestigated_Key, false];
    };
};