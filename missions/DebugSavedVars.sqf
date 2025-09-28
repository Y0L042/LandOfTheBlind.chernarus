systemChat "--- DebugSavedVars.sqf ---";

private _vars = [
    "g_Story01Status",
    "g_Story01AStatus",
    "g_Story01BStatus",
    "g_Story02Status",
    "g_Story02AStatus",
    "g_Story01APictureTaken",
    "g_Story01BNotebookTaken",
    "g_StarterPistolTaken",
    "g_StarterPistolAmmoTaken",
    "g_SkalistyBoatKeyTaken",
    "g_SkalistyBoatTaken"
];

{
    private _name = _x;
    private _inidbiVal = ["read", ["GameState", _name]] call LOTB_Database;
    if (_inidbiVal isEqualTo false) then { _inidbiVal = "<NOT_FOUND>"; };
    private _utilVal = [_name, "<DEFAULT>"] call UTIL_getVar;
    
    systemChat format ["INIDBI: %1 = %2", _name, str _inidbiVal];
    systemChat format ["UTIL_GET: %1 = %2", _name, str _utilVal];
    systemChat "---";
} forEach _vars;

systemChat "--- End DebugSavedVars.sqf ---";
