/*
Allows cleaning up saved files.
// _dryRun is optional - default is true.
*/
params ["_dryRun"];

if (isNil { _dryRun }) then
{
	_dryRun = true;
};

fncCleanupVehicles = {
	params ["_array"];

	private _indexesToRemove = [];

	{
		private _damage;
		_class =  [_x, "class"] call skhpersist_fnc_GetByKey;
		_damage =  [_x, "generalDamage"] call skhpersist_fnc_GetByKey;

		if (_damage == 1) then
		{
			[format ["Destroyed vehicle found (%1), index %2 added for removal.", _class, _forEachIndex]] call skhpersist_fnc_LogToRPT;
			_indexesToRemove pushBack _forEachIndex;
		};
	} forEach _array;

	{
		_array deleteAt _x;
	} forEachReversed _indexesToRemove;

	(count _indexesToRemove) != 0
};

if (PSave_CurrentlyLoadedSlot == -1) then
{
	hint "Please load the game first.";
	[format ["Cleanup was called but no game has been loaded."]] call skhpersist_fnc_LogToRPT;
}
else
{
	private _slot = PSave_CurrentlyLoadedSlot;
	[format ["Cleanup started for slot %1, dry run = %2.", _slot, _dryRun]] call skhpersist_fnc_LogToRPT;

	_variables = [_slot] call skhpersist_fnc_ListExistingVariables;

	{
		private _modified = false;

		[format ["Cleaning %1...", _x]] call skhpersist_fnc_LogToRPT;

		private _splitName = _x splitString ".";
		private _data = profileNamespace getVariable _x;

		if ((_splitName # 2) == "vehicles") then
		{
			[format ["Cleaning vehicles (initial count: %1)...", count _data]] call skhpersist_fnc_LogToRPT;
			_modified = [_data] call fncCleanupVehicles;
		};

		if (!_dryRun && _modified) then
		{
			[_x, _data, _slot] call skhpersist_fnc_SaveData;
		}
		else
		{
			if (dryRun) then
			{
				[format ["[DRY-RUN] Saving data (post-cleanup count %1) to %2.", count _data, _x]] call skhpersist_fnc_LogToRPT;
			}
			else
			{
				[format ["No changes in %1.", _x]] call skhpersist_fnc_LogToRPT;
			};
		};
	} forEach _variables;
};