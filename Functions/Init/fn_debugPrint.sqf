/*
    Author: Y0L042
    
    Description:
        Debug print function that outputs to both screen (systemChat) and RPT log file
    
    Parameter(s):
        0: String - Message to print
        1: String (Optional) - Category/Tag for the message (default: "DEBUG")
    
    Returns:
        Nothing
    
    Examples:
        ["Hello World"] call LOTB_fnc_debugPrint;
        ["Player spawned", "INIT"] call LOTB_fnc_debugPrint;
        ["Variable value: " + str _myVar, "VARIABLE"] call LOTB_fnc_debugPrint;
*/

params ["_message", "_category"];

// Default category if not provided
if (isNil "_category") then { _category = "DEBUG"; };

// Create formatted message with timestamp
private _timestamp = [daytime, "HH:MM:SS"] call BIS_fnc_timeToString;
private _formattedMessage = format ["[%1][%2] %3", _timestamp, _category, _message];

// Output to screen (visible to player)
systemChat _formattedMessage;

// Output to RPT log file (for debugging/logging)
diag_log _formattedMessage;