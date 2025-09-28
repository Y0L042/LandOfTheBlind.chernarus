/*
    Author: Y0L042

    Description:
        Attempts to get a variable from INIDBI database, if it doesn't exist, sets it to a default value and returns that.

    Parameter(s):
        0: String - Variable name to get from INIDBI database
        1: Any (Optional) - Default value to set and return if variable doesn't exist

    Returns:
        Any - Value of the variable from INIDBI database, the default value if provided, or "__UNDEFINED__" if no default provided

    Examples:
        // Gets "myVarName" from INIDBI, returns "__UNDEFINED__" if doesn't exist and no default
        _myVar = ["myVarName"] call UTIL_fnc_getVar; 
        // Gets "myVarName" from INIDBI, if it doesn't exist, sets it to 10 and returns 10
        _myVar = ["myVarName", 10] call UTIL_fnc_getVar; 
*/

params ["_varName", "_value"];

if (isNil "_varName") exitWith { 
    systemChat "UTIL_fnc_getVar: VarName is NIL!";
    nil;
};

// Check if default value was provided
private _hasDefault = !isNil "_value";

if (!_hasDefault) exitWith { 
    systemChat format ["GETVAR: Reading %1 from INIDBI (no default)", _varName];
    private _myStringValue = ["read", ["GameState", _varName]] call LOTB_Database;
    systemChat format ["GETVAR: Read result for %1: %2", _varName, str _myStringValue];
    if (!isNil "_myStringValue" && {_myStringValue isNotEqualTo ""}) then {
        systemChat format ["GETVAR: Returning saved value: %1", str _myStringValue];
        _myStringValue;
    } else {
        systemChat format ["UTIL_fnc_getVar: Value for variable '%1' not found and no default provided!", _varName];
        "__UNDEFINED__";
    };
};

private _out = _value;
systemChat format ["GETVAR: Reading %1 from INIDBI (with default)", _varName];

// Try to read from INIDBI with error handling
private _myStringValue = "";
try {
    _myStringValue = ["read", ["GameState", _varName]] call LOTB_Database;
    systemChat format ["GETVAR: Read result for %1: %2", _varName, str _myStringValue];
} catch {
    systemChat format ["GETVAR: Error reading %1 from INIDBI: %2", _varName, str _exception];
    _myStringValue = "";
};

if (!isNil "_myStringValue" && _myStringValue != "") then {
    _out = _myStringValue;
    systemChat format ["GETVAR: Using saved value for %1: %2", _varName, str _out];
} else {
    systemChat format ["GETVAR: Writing default value for %1: %2", _varName, str _value];
    try {
        ["write", ["GameState", _varName, _value]] call LOTB_Database;
    } catch {
        systemChat format ["GETVAR: Error writing %1 to INIDBI: %2", _varName, str _exception];
    };
    _out = _value;
};

_out;   