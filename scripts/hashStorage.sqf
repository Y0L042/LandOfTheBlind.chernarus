// Put hashmap into profileNamespace
LOTB_fnc_PutHashMap = {
    params ["_hashMap", "_varName"];
    profileNamespace setVariable [_varName, _hashMap];
};

// Get hashmap from profileNamespace
LOTB_fnc_GetHashMap = {
    params ["_hashMap", "_varName"];
    private _loaded = profileNamespace getVariable [_varName, []];
    if (typeName _loaded == "ARRAY") then {
        _hashMap = createHashMapFromArray _loaded;
    } else {
        _hashMap = createHashMap;
    };
};

// Save hashmap to profileNamespace
LOTB_fnc_SaveHashMap = {
    params ["_hashMap", "_varName"];
    profileNamespace setVariable [_varName, _hashMap];
    saveProfileNamespace;
};
