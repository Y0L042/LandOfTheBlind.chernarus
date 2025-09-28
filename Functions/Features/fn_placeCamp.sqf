/*
    Author: Y0L042
    
    Description:
        Places a player camp with tent, campfire, and respawn point
        Can only be used every 10 minutes. Old camp is deleted when new one is placed.
    
    Parameter(s):
        0: Array (Optional) - Position [x,y,z] where to place camp. If not provided, uses player position + direction
        1: Boolean (Optional) - Skip cooldown check (default: false). Used for startup restoration
    
    Returns:
        Boolean - True if camp was placed successfully, false if on cooldown
    
    Examples:
        [] call LOTB_fnc_placeCamp; // Place at player position
        [[1000,2000,0]] call LOTB_fnc_placeCamp; // Place at specific position
        [[1000,2000,0], true] call LOTB_fnc_placeCamp; // Place at position, skip cooldown
*/

// Parse parameters
params [["_targetPos", []], ["_skipCooldown", false]];


// Check cooldown using global variable
private _lastCampTime = s_SpawnCampPlaceTime;
private _currentTime = time;
private _cooldownDuration = 60;
private _campRespawnHandle = nil;
private _timeSinceLastCamp = _currentTime - _lastCampTime;

// Check if still on cooldown (unless skipped)
if ((!_skipCooldown) && (_timeSinceLastCamp < _cooldownDuration)) exitWith {
    private _remainingTime = _cooldownDuration - _timeSinceLastCamp;
    private _remainingMinutes = floor(_remainingTime / 60);
    private _remainingSeconds = floor(_remainingTime mod 60);
    
    hint format ["Camp placement on cooldown. %1:%02 remaining.", _remainingMinutes, _remainingSeconds];
    ["Camp placement denied - still on cooldown", "CAMP"] call LOTB_fnc_debugPrint;
};

// Determine camp position
private _tentPos = [];
private _campfirePos = [];

if (count _targetPos == 0) then {
    // Use player position and direction
    private _playerPos = getPos player;
    private _playerDir = getDir player;
    
    // Calculate positions (tent in front, campfire slightly to the side)
    _tentPos = _playerPos vectorAdd [3 * sin(_playerDir), 3 * cos(_playerDir), 0];
    _campfirePos = _playerPos vectorAdd [1.5 * sin(_playerDir + 45), 1.5 * cos(_playerDir + 45), 0];
} else {
    // Use provided position
    _tentPos = _targetPos;
    _campfirePos = _targetPos vectorAdd [2, 2, 0]; // Offset campfire slightly
};

["Placing camp at position: " + str _tentPos, "CAMP"] call LOTB_fnc_debugPrint;

// Remove old camp if it exists
private _oldCampObjects = player getVariable ["campObjects", []];
if (count _oldCampObjects > 0) then {
    ["Removing old camp objects", "CAMP"] call LOTB_fnc_debugPrint;
    {
        if (!isNull _x) then {
            deleteVehicle _x;
        };
    } forEach _oldCampObjects;
};

// Remove old respawn point
private _oldRespawnPos = player getVariable ["campRespawnPos", ""];
if (!(isNil "_campRespawnHandle")) then {
    ["Removing old respawn point: " + _oldRespawnPos, "CAMP"] call LOTB_fnc_debugPrint;
    [independent, _campRespawnHandle] call BIS_fnc_removeRespawnPosition;
};

// Create tent
private _tent = "Land_TentA_F" createVehicle _tentPos;
private _tentDir = if (count _targetPos == 0) then {getDir player + 180} else {0}; // Face tent opening towards player or default
_tent setDir _tentDir;
["Tent placed", "CAMP"] call LOTB_fnc_debugPrint;

// Create campfire
private _campfire = "Campfire_burning_F" createVehicle _campfirePos;
["Campfire placed", "CAMP"] call LOTB_fnc_debugPrint;

// Create respawn position
private _respawnPosId = format ["camp_respawn_%1", round(time)];
private _respawnPos = [independent, _tentPos, "Camp Respawn"] call BIS_fnc_addRespawnPosition;
_campRespawnHandle = _respawnPos;
["Respawn point created: " + str _respawnPos, "CAMP"] call LOTB_fnc_debugPrint;

// Store camp objects and respawn position (keep using player variables for runtime data)
player setVariable ["campObjects", [_tent, _campfire]];
player setVariable ["campRespawnPos", _respawnPos];

// Update the global camp placement time (per-session only)
s_SpawnCampPlaceTime = _currentTime;
["DEBUG: Updated global camp time: " + str s_SpawnCampPlaceTime, "DEBUG"] call LOTB_fnc_debugPrint;

// Add actions to tent
_tent addAction [
    "<t color='#00FF00'>Rest at Camp</t>",
    {
        params ["_target", "_caller"];
        ["Player resting at camp", "CAMP"] call LOTB_fnc_debugPrint;
        hint "You rest at your camp, feeling refreshed.";
        
        // Heal player
        _caller setDamage 0;
        
        // Save game progress
        [] call UTIL_fnc_savePlayerLoadout;
        ["Game progress saved at camp", "CAMP"] call LOTB_fnc_debugPrint;
    },
    nil,
    1.5,
    true,
    true,
    "",
    "player distance _target < 3 && alive player",
    5
];

_tent addAction [
    "<t color='#FF6600'>Pack Up Camp</t>",
    {
        params ["_target", "_caller"];
        ["Player packing up camp", "CAMP"] call LOTB_fnc_debugPrint;
        
        // Remove camp objects
        private _campObjects = _caller getVariable ["campObjects", []];
        {
            if (!isNull _x) then {
                deleteVehicle _x;
            };
        } forEach _campObjects;
        
        // Remove respawn point
        private _respawnPos = _caller getVariable ["campRespawnPos", ""];
        if (isNil "_campRespawnHandle") then {
            [independent, _campRespawnHandle] call BIS_fnc_removeRespawnPosition;
        };
        
        // Clear variables
        _caller setVariable ["campObjects", []];
        _caller setVariable ["campRespawnPos", ""];
        
        // Clear saved camp position (persistent) and reset cooldown (session)
        ["g_SpawnCampLocation", []] call UTIL_fnc_setVar;  // This stays persistent
        s_SpawnCampPlaceTime = -1;  // This resets for current session
        
        hint "Camp packed up successfully. Cooldown reset.";
        ["Camp packed up and cooldown reset", "CAMP"] call LOTB_fnc_debugPrint;
    },
    nil,
    1.5,
    true,
    true,
    "",
    "player distance _target < 3 && alive player",
    5
];

g_SpawnCampLocation = ["g_SpawnCampLocation", _tentPos] call UTIL_fnc_setVar;

// Success message
hint "Camp placed successfully! You can now respawn here and rest to heal.";
["Camp placement successful", "CAMP"] call LOTB_fnc_debugPrint;

true;