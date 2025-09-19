// Var keys
LOTB_fnc_SetSavedVarsKeys = {
    systemChat "SavedVars keys created";

    // Mission states
    LOTB_NOTSTARTED = "_NOTSTARTED_"; // Mission not created yet

    // These missions must be created, and their status set.
    LOTB_ASSIGNED = "ASSIGNED"; // Mission created and assigned
    LOTB_UNASSIGNED = "UNASSIGNED"; // Mission created, but unassigned
    LOTB_SUCCESS = "COMPLETED"; // Mission completed, success
    LOTB_FAILED = "FAILED"; // Mission completed, failed

    // Story_01
    LOTB_Story_01_TasksCompleted_Key = "LOTB_Story_01_TasksCompleted";
    LOTB_Story_01_Status_Key = "LOTB_Story_01_Completed";
    LOTB_Story_01_a_PhotoFound_Key = "LOTB_Story_01_a_PhotoFound";
    LOTB_Story_01_b_NotebookFound_Key = "LOTB_Story_01_b_NotebookFound";
    LOTB_SkalistyBoatFound_Key = "LOTB_SkalistyBoatFound";
    LOTB_SkalistyGunFound_Key = "LOTB_SkalistyGunFound";

    // Story_02
    LOTB_Story02_TasksCompleted_Key = "LOTB_Story02_TasksCompleted";
    LOTB_Story02_WarehousesInvestigated_Key = "LOTB_Story02_WarehousesInvestigated";

    [
        LOTB_Story_01_TasksCompleted_Key,
        LOTB_Story_01_Status_Key,
        LOTB_Story_01_a_PhotoFound_Key,
        LOTB_Story_01_b_NotebookFound_Key,
        LOTB_SkalistyBoatFound_Key,
        LOTB_SkalistyGunFound_Key,


        LOTB_Story02_TasksCompleted_Key,
        LOTB_Story02_WarehousesInvestigated_Key
    ]
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
    if (isNil { _hashMap get LOTB_Story_01_Status_Key }) then {
        _hashMap set [LOTB_Story_01_Status_Key, LOTB_NOTSTARTED];
    };
    if (isNil { _hashMap get LOTB_Story_01_a_PhotoFound_Key }) then {
        _hashMap set [LOTB_Story_01_a_PhotoFound_Key, LOTB_NOTSTARTED];
    };
    if (isNil { _hashMap get LOTB_Story_01_b_NotebookFound_Key }) then {
        _hashMap set [LOTB_Story_01_b_NotebookFound_Key, LOTB_NOTSTARTED];
    };
    if (isNil { _hashMap get LOTB_SkalistyBoatFound_Key }) then {
        _hashMap set [LOTB_SkalistyBoatFound_Key, LOTB_NOTSTARTED];
    };
    if (isNil { _hashMap get LOTB_SkalistyGunFound_Key }) then {
        _hashMap set [LOTB_SkalistyGunFound_Key, LOTB_NOTSTARTED];
    };

    // Story_02
    if (isNil { _hashMap get LOTB_Story02_TasksCompleted_Key }) then {
        _hashMap set [LOTB_Story02_TasksCompleted_Key, []];
    };
    if (isNil { _hashMap get LOTB_Story02_WarehousesInvestigated_Key }) then {
        _hashMap set [LOTB_Story02_WarehousesInvestigated_Key, LOTB_NOTSTARTED];
    };
};