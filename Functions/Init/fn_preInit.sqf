/*
    PreInit function - Runs before Init.sqf
    Initializes INIDBI and loads all global variables
*/

systemChat "Running preInit...";

UTIL_initializePlayerLoadout = {
    private _hasSavedLoadout = !([["playerLoadout", []] call UTIL_fnc_getVar] isEqualTo []);
    
    if (_hasSavedLoadout) then {
        ["Loading saved player loadout", "LOADOUT"] call LOTB_fnc_debugPrint;
        [] call UTIL_fnc_loadPlayerLoadout;
    } else {
        ["No saved loadout found, applying default gear", "LOADOUT"] call LOTB_fnc_debugPrint;
        [player] call UTIL_setDefaultLoadout;
        // Save this default loadout for future respawns
        [] call UTIL_fnc_savePlayerLoadout;
    };
};

_handle = ["new", "LandOfTheBlind"] call OO_INIDBI;
LOTB_Database = _handle;
systemChat "INIDBI initialized in preInit";

// Define inline functions
UTIL_getVar = {
    params ["_varName", "_defaultValue"];
    
    if (isNil "_varName") exitWith { 
        nil;
    };
    
    private _hasDefault = !isNil "_defaultValue";
    private _result = ["read", ["GameState", _varName]] call LOTB_Database;
    
    if (_result isNotEqualTo false) then {
        _result;
    } else {
        if (_hasDefault) then {
            ["write", ["GameState", _varName, _defaultValue]] call LOTB_Database;
            _defaultValue;
        } else {
            "__UNDEFINED__";
        };
    };
};

UTIL_setVar = {
    params ["_varName", "_newValue"];
    
    if (isNil "_varName" || isNil "_newValue") exitWith { 
        false;
    };
    
    ["write", ["GameState", _varName, _newValue]] call LOTB_Database;
    _newValue;
};

// Create function aliases
UTIL_fnc_getVar = UTIL_getVar;
UTIL_fnc_setVar = UTIL_setVar;

// Define constants
NOT_STARTED = 0;
ASSIGNED = 1;
COMPLETED = 2;
FAILED = 3;




// Load all global variables
g_MissionStartedNow = ["g_MissionStartedNow", true] call UTIL_fnc_getVar;

g_Story01Status = ["g_Story01Status", ASSIGNED] call UTIL_fnc_getVar;
g_Story01AStatus = ["g_Story01AStatus", ASSIGNED] call UTIL_fnc_getVar;
g_Story01BStatus = ["g_Story01BStatus", NOT_STARTED] call UTIL_fnc_getVar;

g_Story02Status = ["g_Story02Status", NOT_STARTED] call UTIL_fnc_getVar;
g_Story02AStatus = ["g_Story02AStatus", NOT_STARTED] call UTIL_fnc_getVar;

g_Story01APictureTaken = ["g_Story01APictureTaken", false] call UTIL_fnc_getVar;
g_Story01BNotebookTaken = ["g_Story01BNotebookTaken", false] call UTIL_fnc_getVar;

g_StarterPistolTaken = ["g_StarterPistolTaken", false] call UTIL_fnc_getVar;
g_StarterPistolAmmoTaken = ["g_StarterPistolAmmoTaken", false] call UTIL_fnc_getVar;
g_SkalistyBoatKeyTaken = ["g_SkalistyBoatKeyTaken", false] call UTIL_fnc_getVar;
g_SkalistyBoatTaken = ["g_SkalistyBoatTaken", false] call UTIL_fnc_getVar;




// ["g_Story01Status: " + str g_Story01Status, "VARIABLE"] call LOTB_fnc_debugPrint;
// ["g_Story01AStatus: " + str g_Story01AStatus, "VARIABLE"] call LOTB_fnc_debugPrint;
// ["g_Story01BStatus: " + str g_Story01BStatus, "VARIABLE"] call LOTB_fnc_debugPrint;
// ["g_Story02Status: " + str g_Story02Status, "VARIABLE"] call LOTB_fnc_debugPrint;
// ["g_Story02AStatus: " + str g_Story02AStatus, "VARIABLE"] call LOTB_fnc_debugPrint;
// ["g_Story01APictureTaken: " + str g_Story01APictureTaken, "VARIABLE"] call LOTB_fnc_debugPrint;
// ["g_Story01BNotebookTaken: " + str g_Story01BNotebookTaken, "VARIABLE"] call LOTB_fnc_debugPrint;
// ["g_StarterPistolTaken: " + str g_StarterPistolTaken, "VARIABLE"] call LOTB_fnc_debugPrint;
// ["g_StarterPistolAmmoTaken: " + str g_StarterPistolAmmoTaken, "VARIABLE"] call LOTB_fnc_debugPrint;
// ["g_SkalistyBoatKeyTaken: " + str g_SkalistyBoatKeyTaken, "VARIABLE"] call LOTB_fnc_debugPrint;
// ["g_SkalistyBoatTaken: " + str g_SkalistyBoatTaken, "VARIABLE"] call LOTB_fnc_debugPrint;




// Define inventory management functions
UTIL_savePlayerLoadout = {
    private _loadout = getUnitLoadout player;
    ["playerLoadout", _loadout] call UTIL_fnc_setVar;
    ["Player loadout saved", "INVENTORY"] call LOTB_fnc_debugPrint;
};

UTIL_loadPlayerLoadout = {
    private _loadout = ["playerLoadout", []] call UTIL_fnc_getVar;
    
    if (_loadout isEqualTo []) exitWith {
        ["No saved loadout found", "INVENTORY"] call LOTB_fnc_debugPrint;
    };
    
    player setUnitLoadout _loadout;
    ["Player loadout loaded", "INVENTORY"] call LOTB_fnc_debugPrint;
};

// Default starting gear function
UTIL_setDefaultLoadout = {
    params ["_unit"];
    
    ["Setting default starting gear", "LOADOUT"] call LOTB_fnc_debugPrint;
    
    // Remove existing items
    removeAllWeapons _unit;
    removeAllItems _unit;
    removeAllAssignedItems _unit;
    removeUniform _unit;
    removeVest _unit;
    removeBackpack _unit;
    removeHeadgear _unit;
    removeGoggles _unit;
    
    // Add containers
    _unit forceAddUniform "U_C_Journalist";
    
    // Add binoculars
    _unit addWeapon "gm_df7x40_blk";
    
    // Add items to containers
    _unit addItemToUniform "gm_30Rnd_762x39mm_B_M43_ak47_blk";
    
    // Add items
    _unit linkItem "ItemMap";
    _unit linkItem "gm_watch_kosei_80_slv";
    
    // Set identity
    [_unit,"WhiteHead_19","gm_voice_male_deu_07"] call BIS_fnc_setIdentity;
    
    ["Default starting gear applied", "LOADOUT"] call LOTB_fnc_debugPrint;
};

// Initialize player loadout (first time or respawn)
UTIL_initializePlayerLoadout = {
    private _hasSavedLoadout = !([["playerLoadout", []] call UTIL_fnc_getVar] isEqualTo []);
    
    if (_hasSavedLoadout) then {
        ["Loading saved player loadout", "LOADOUT"] call LOTB_fnc_debugPrint;
        [] call UTIL_fnc_loadPlayerLoadout;
    } else {
        ["No saved loadout found, applying default gear", "LOADOUT"] call LOTB_fnc_debugPrint;
        [player] call UTIL_setDefaultLoadout;
        // Save this default loadout for future respawns
        [] call UTIL_fnc_savePlayerLoadout;
    };
};

// Note: Respawn handling is now done via onPlayerRespawn.sqf

// Inventory monitoring system for weapon pickups
UTIL_startInventoryMonitoring = {
    ["Starting inventory monitoring system", "INVENTORY"] call LOTB_fnc_debugPrint;
    
    // Store initial inventory state
    player setVariable ["lastKnownWeapons", weapons player];
    player setVariable ["lastKnownItems", items player];
    player setVariable ["lastKnownMagazines", magazines player];
    
    // Start monitoring loop
    [] spawn {
        while {alive player} do {
            private _currentWeapons = weapons player;
            private _currentItems = items player;
            private _currentMagazines = magazines player;
            
            private _lastWeapons = player getVariable ["lastKnownWeapons", []];
            private _lastItems = player getVariable ["lastKnownItems", []];
            private _lastMagazines = player getVariable ["lastKnownMagazines", []];
            
            // Check for new weapons
            {
                if (!(_x in _lastWeapons)) then {
                    ["Player picked up weapon: " + _x, "PICKUP"] call LOTB_fnc_debugPrint;
                    [_x, "weapon"] call UTIL_fnc_onItemPickup;
                };
            } forEach _currentWeapons;
            
            // Check for new items
            {
                if (!(_x in _lastItems)) then {
                    ["Player picked up item: " + _x, "PICKUP"] call LOTB_fnc_debugPrint; 
                    [_x, "item"] call UTIL_fnc_onItemPickup;
                };
            } forEach _currentItems;
            
            // Check for new magazines
            {
                if (!(_x in _lastMagazines)) then {
                    ["Player picked up magazine: " + _x, "PICKUP"] call LOTB_fnc_debugPrint;
                    [_x, "magazine"] call UTIL_fnc_onItemPickup;
                };
            } forEach _currentMagazines;
            
            // Update stored inventory
            player setVariable ["lastKnownWeapons", _currentWeapons];
            player setVariable ["lastKnownItems", _currentItems];
            player setVariable ["lastKnownMagazines", _currentMagazines];
            
            sleep 0.5; // Check every 0.5 seconds
        };
    };
};

// Handle item pickup events
UTIL_onItemPickup = {
    params ["_itemClass", "_itemType"];

    [] call UTIL_savePlayerLoadout;
    
    // Check for specific story items
    // switch (_itemClass) do {
    //     case "gm_p1_blk": {
    //         ["Starter pistol picked up!", "STORY"] call LOTB_fnc_debugPrint;
    //         g_StarterPistolTaken = ["g_StarterPistolTaken", true] call UTIL_fnc_setVar;
    //         // Auto-save loadout when important items are picked up
    //         [] call UTIL_fnc_savePlayerLoadout;
    //     };
    //     case "gm_30Rnd_762x39mm_B_M43_ak47_blk": {
    //         ["Starter pistol ammo picked up!", "STORY"] call LOTB_fnc_debugPrint;
    //         g_StarterPistolAmmoTaken = ["g_StarterPistolAmmoTaken", true] call UTIL_fnc_setVar;
    //         [] call UTIL_fnc_savePlayerLoadout;
    //     };
    //     // Add more cases for other story items
    //     default {
    //         ["Generic item picked up: " + _itemClass, "PICKUP"] call LOTB_fnc_debugPrint;
    //     };
    // };
};

// Create function aliases
UTIL_fnc_savePlayerLoadout = UTIL_savePlayerLoadout;
UTIL_fnc_loadPlayerLoadout = UTIL_loadPlayerLoadout;
UTIL_fnc_setDefaultLoadout = UTIL_setDefaultLoadout;
UTIL_fnc_initializePlayerLoadout = UTIL_initializePlayerLoadout;
UTIL_fnc_startInventoryMonitoring = UTIL_startInventoryMonitoring;
UTIL_fnc_onItemPickup = UTIL_onItemPickup;

systemChat "PreInit complete - all global variables loaded!";