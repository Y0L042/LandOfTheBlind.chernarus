/*
Lists all variables stored by this mission in profileNamespace
on given save _slot.

Returns array with persisted data.
*/

// _slot is optional - if not specified, all data persisted by
// this system will be returned (i.e. only with prefix = PSave_SaveGamePrefix).
params ["_slot"];

private _variables = allVariables profileNamespace;
private _result = [];

if (isNil { _slot }) then
{
    ["Listing variables for all saves."] call skhpersist_fnc_LogToRPT;
}
else
{
    [format ["Listing variables for save slot %1.", _slot]] call skhpersist_fnc_LogToRPT;
};

{
    private _splittedVariable = _x splitString ".";
    
    if (_splittedVariable # 0 == PSave_SaveGamePrefix) then
    {
        if (isNil { _slot }) then
        {
            _result pushBack _x;
        }
        else
        {
            if (count _splittedVariable >= 2 && (parseNumber (_splittedVariable # 1)) == _slot) then
            {
                _result pushBack _x;
            };
        }
    };
} forEach _variables;

_result;