/*
===============================================================================
Save Game Action Implementation
===============================================================================
*/

params ["_target", "_caller", "_actionId", "_arguments"];

systemChat "Saving game...";

// [0] call skhpersist_fnc_SaveGame; // Save to slot 0
[LOTB_SavedVars, LOTB_SavedVars_Key] call LOTB_fnc_SaveHashMap;

// Save timestamp using BIS_fnc_timeToString
private _currentTime = time;
private _timeString = [_currentTime, "HH:MM:SS"] call BIS_fnc_timeToString;
// Save the timestamp to profile namespace
profileNamespace setVariable ["LandOfTheBlind_LastSaveTime", _timeString];

saveProfileNamespace;

systemChat format ["Game saved successfully at: %1", _timeString];
