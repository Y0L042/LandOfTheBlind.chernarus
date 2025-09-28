this addAction [   
    "Take Starter Pistol", 
    {   
        params ["_target", "_caller"];   
        g_StarterPistolTaken = ["g_StarterPistolTaken", true] call UTIL_fnc_setVar;
[player, "gm_pm_blk", 8] call BIS_fnc_addWeapon;
deleteVehicle this;
    },   
    nil,   
    1.5,   
    true,   
    true,   
    "",   
    "player distance _target < 3 && isNull objectParent player ",   
    3   
]