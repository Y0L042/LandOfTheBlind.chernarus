// Put hashmap into profileNamespace
LOTB_fnc_PutHashMap = {
    params ["_hashMap", "_varName"];
    _hashMapArray = _hashMap toArray true;
    profileNamespace setVariable [_varName, _hashMapArray];
};

// Get hashmap from profileNamespace
LOTB_fnc_GetHashMap = {
    params ["_hashMap", "_varName"];

    private _loadedArr = profileNamespace getVariable _varName;

    if (typeName _loadedArr == "HASHMAP") then {
        _loadedArr = [];
        profileNamespace setVariable [_varName, []];
        saveProfileNamespace;
    };

    private _arrSize = count _loadedArr;
    if (_arrSize >= 2) then {
        systemChat "Hashmap found";
        private _keys = _loadedArr select 0;
        private _values = _loadedArr select 1;
        _hashMap = _keys createHashMapFromArray _values;
    } else {
        systemChat "Hashmap not found";
        _hashMap = createHashMap;
    };
    [_hashMap] call LOTB_fnc_PrintHashMap;
    _hashMap
};

// Save hashmap to profileNamespace
LOTB_fnc_SaveHashMap = {
    params ["_hashMap", "_varName"];
    [_hashMap] call LOTB_fnc_PrintHashMap;
    profileNamespace setVariable [_varName, _hashMap toArray true];
    saveProfileNamespace;
};

LOTB_fnc_PrintHashMap = {
    params ["_hashMap"];
    systemChat "Printing hashmap:";
    if (typeName _hashMap == "HASHMAP") then {
        { systemChat str [_x, _y] } forEach _hashMap;
    };
};