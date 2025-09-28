systemChat "Running SavedVars.sqf";

NOT_STARTED = 0;
ASSIGNED = 1;
COMPLETED = 2;
FAILED = 3;

// Story Status
g_Story01Status = ["g_Story01Status", ASSIGNED] call UTIL_fnc_getVar;
g_Story01AStatus = ["g_Story01AStatus", ASSIGNED] call UTIL_fnc_getVar;
g_Story01BStatus = ["g_Story01BStatus", NOT_STARTED] call UTIL_fnc_getVar;

g_Story02Status = ["g_Story02Status", NOT_STARTED] call UTIL_fnc_getVar;
g_Story02AStatus = ["g_Story02AStatus", NOT_STARTED] call UTIL_fnc_getVar;

// Story Item Status
g_Story01APictureTaken = ["g_Story01APictureTaken", false] call UTIL_fnc_getVar;
g_Story01BNotebookTaken = ["g_Story01BNotebookTaken", false] call UTIL_fnc_getVar;


// Misc Status
g_StarterPistolTaken = ["g_StarterPistolTaken", false] call UTIL_fnc_getVar;
g_StarterPistolAmmoTaken = ["g_StarterPistolAmmoTaken", false] call UTIL_fnc_getVar;
g_SkalistyBoatKeyTaken = ["g_SkalistyBoatKeyTaken", false] call UTIL_fnc_getVar;
g_SkalistyBoatTaken = ["g_SkalistyBoatTaken", false] call UTIL_fnc_getVar;

