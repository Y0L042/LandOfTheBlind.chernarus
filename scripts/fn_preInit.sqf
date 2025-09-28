/*
    PreInit function - Runs before Init.sqf
    Initializes INIDBI and loads all global variables
*/

systemChat "Running preInit...";

// Initialize INIDBI
_handle = ["new", "LandOfTheBlind"] call OO_INIDBI;
LOTB_Database = _handle;
systemChat "INIDBI initialized in preInit";

// Define inline functions
UTIL_getVar = {
    params ["_varName", "_defaultValue"];
    
    if (isNil "_varName") exitWith { 
        nil;
    };
    
    private _hasDefault = !isNil "_defaultValue";
    private _result = ["read", ["GameState", _varName]] call LOTB_Database;
    
    if (_result isNotEqualTo false) then {
        _result;
    } else {
        if (_hasDefault) then {
            ["write", ["GameState", _varName, _defaultValue]] call LOTB_Database;
            _defaultValue;
        } else {
            "__UNDEFINED__";
        };
    };
};

UTIL_setVar = {
    params ["_varName", "_newValue"];
    
    if (isNil "_varName" || isNil "_newValue") exitWith { 
        false;
    };
    
    ["write", ["GameState", _varName, _newValue]] call LOTB_Database;
    _newValue;
};

// Create function aliases
UTIL_fnc_getVar = UTIL_getVar;
UTIL_fnc_setVar = UTIL_setVar;

// Define constants
NOT_STARTED = 0;
ASSIGNED = 1;
COMPLETED = 2;
FAILED = 3;

// Load all global variables
g_Story01Status = ["g_Story01Status", ASSIGNED] call UTIL_fnc_getVar;
g_Story01AStatus = ["g_Story01AStatus", ASSIGNED] call UTIL_fnc_getVar;
g_Story01BStatus = ["g_Story01BStatus", NOT_STARTED] call UTIL_fnc_getVar;

g_Story02Status = ["g_Story02Status", NOT_STARTED] call UTIL_fnc_getVar;
g_Story02AStatus = ["g_Story02AStatus", NOT_STARTED] call UTIL_fnc_getVar;

g_Story01APictureTaken = ["g_Story01APictureTaken", false] call UTIL_fnc_getVar;
g_Story01BNotebookTaken = ["g_Story01BNotebookTaken", false] call UTIL_fnc_getVar;

g_StarterPistolTaken = ["g_StarterPistolTaken", false] call UTIL_fnc_getVar;
g_StarterPistolAmmoTaken = ["g_StarterPistolAmmoTaken", false] call UTIL_fnc_getVar;
g_SkalistyBoatKeyTaken = ["g_SkalistyBoatKeyTaken", false] call UTIL_fnc_getVar;
g_SkalistyBoatTaken = ["g_SkalistyBoatTaken", false] call UTIL_fnc_getVar;

systemChat "PreInit complete - all global variables loaded!";