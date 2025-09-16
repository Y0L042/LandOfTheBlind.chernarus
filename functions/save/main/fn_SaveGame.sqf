/*
Performs a persistent save on given _slot.
*/

params ["_slot"];

PSave_SaveInProgress = true;

{
	[_x, [_slot]] call skhpersist_fnc_CallFunctionFromFileOrCode;
} forEach PSave_BeforeSaveEH;

[format ["Saving data on slot %1", _slot]] call skhpersist_fnc_LogToRPT;

[_slot] call skhpersist_fnc_ClearSave;

[_slot] call skhpersist_fnc_SaveMetadata;
[_slot] call skhpersist_fnc_SavePlayer;
[_slot] call skhpersist_fnc_SaveCustomContainers;
[_slot] call skhpersist_fnc_SaveCustomUnits;
[_slot] call skhpersist_fnc_SaveCustomVariables;
[_slot] call skhpersist_fnc_SaveCustomVehicles;
[_slot] call skhpersist_fnc_SaveEnvironmentInfo;
[_slot] call skhpersist_fnc_SaveMapMarkers;

{
	[_x, [_slot]] call skhpersist_fnc_CallFunctionFromFileOrCode;
} forEach PSave_AfterSaveEH;

saveProfileNamespace;

PSave_SaveInProgress = false;

hint format ["Persistent save done on slot %1.", _slot];
[format ["Saving data to slot %1 done.", _slot]] call skhpersist_fnc_LogToRPT;