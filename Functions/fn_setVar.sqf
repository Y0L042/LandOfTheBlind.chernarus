/*
    Author: Y0L042

    Description:
        Stores variable name in namespace

    Parameter(s):
        0: String - Variable name to set in missionNamespace
        1: Any - Value to set the variable to

    Returns:
        Any - The value that was set

    Examples:
        // Sets "g_myVar" in missionNamespace to 10
        g_myVar = ["g_myVar", 10] call SOGR_fnc_setVar;
*/


params ["_varName", "_newValue"];

if (isNil "_varName" || isNil "_newValue") exitWith { 
    if (isNil "_varName") then {
        systemChat "UTIL_fnc_setVar: VarName is NIL!";
    };
    if (isNil "_newValue") then {
        systemChat "UTIL_fnc_setVar: NewValue is NIL!";
    };
    false; // Return false to indicate failure
};

systemChat format ["SETVAR: Writing %1 = %2 to INIDBI", _varName, str _newValue];
try {
    ["write", ["GameState", _varName, _newValue]] call LOTB_Database;
    systemChat format ["SETVAR: Write complete for %1", _varName];
} catch {
    systemChat format ["SETVAR: Error writing %1 to INIDBI: %2", _varName, str _exception];
};

_newValue;