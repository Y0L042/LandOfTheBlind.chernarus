/*
===============================================================================
Load Game Action Implementation
===============================================================================
*/

params ["_target", "_caller", "_actionId", "_arguments"];

if (PSave_SaveInProgress || PSave_LoadInProgress) then {
    systemChat "Save/Load operation already in progress, please wait...";
} else {
    systemChat "Loading game...";
    
    // [0] call skhpersist_fnc_LoadGame;
    [LOTB_SavedVars, LOTB_SavedVars_Key] call LOTB_fnc_GetHashMap;
    [LOTB_SavedVars, false] call LOTB_fnc_EnsureSavedVars; // Ensure all keys exist

    // Load and display the saved timestamp
    private _lastSaveTime = profileNamespace getVariable ["LandOfTheBlind_LastSaveTime", ""];
    if (_lastSaveTime != "") then {
        systemChat format ["Game loaded successfully! Last saved at: %1", _lastSaveTime];
    } else {
        systemChat "Game loaded successfully!";
    };
};