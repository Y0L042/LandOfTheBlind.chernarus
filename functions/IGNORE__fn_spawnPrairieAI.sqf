/*
    Function: PF_fnc_spawnPrairieAI
    
    Description:
        Spawns a group of soldiers with configurable faction, side, and position
    
    Parameters:
        _side - Side to spawn for (default: OPFOR) - can be BLUFOR, OPFOR, INDEPENDENT, CIVILIAN
        _faction - Faction classname (default: "vn_o_men_nva") - see faction examples below
        _squadType - Type of squad to spawn (default: "rifle") - options: "rifle", "mg", "at", "sniper", "demo"
        _amount - Number of soldiers to spawn (default: 6)
        _spawnLocation - Where to spawn (default: player) - can be:
                        - "player" - at player position
                        - [x,y,z] - exact coordinates
                        - "markerName" - at marker position
                        - object - at object position
        _offsetRadius - Radius around spawn point to spread soldiers (default: 10)
        _skill - AI skill level 0-1 (default: 0.7)
    
    Returns:
        Group - The spawned group
    
    Examples:
        // Spawn default PAVN rifle squad at player
        _group = [] call PF_fnc_spawnPrairieAI;
        
        // Spawn US forces at marker
        _group = [BLUFOR, "vn_b_men_army", "rifle", 8, "spawnMarker"] call PF_fnc_spawnPrairieAI;
        
        // Spawn PAVN MG team at coordinates
        _group = [OPFOR, "vn_o_men_nva", "mg", 4, [1000, 2000, 0], 15, 0.8] call PF_fnc_spawnPrairieAI;
        
        // Add waypoints after spawning:
        _group = [] call PF_fnc_spawnPrairieAI;
        _wp1 = _group addWaypoint [[1000, 1000, 0], 0];
        _wp1 setWaypointType "MOVE";
        _wp2 = _group addWaypoint [[1500, 1500, 0], 0];
        _wp2 setWaypointType "DESTROY";
        _wp2 setWaypointTarget someBuilding;
        
        // Replace group with waypoints (uses group position automatically):
        _group = [OPFOR, "vn_o_men_nva", "rifle", 6, "", 10, 0.7, "templateGroup"] call PF_fnc_spawnPrairieAI;
    
    Supported Factions:
        OPFOR:
            "vn_o_men_nva" - PAVN (North Vietnamese Army)
            "vn_o_men_vc" - Viet Cong
            "vn_o_men_pl" - Pathet Lao
        BLUFOR:
            "vn_b_men_army" - US Army
            "vn_b_men_marines" - US Marines
            "vn_b_men_navy" - US Navy
            "vn_b_men_sf" - US Special Forces
            "vn_b_men_aus_army" - Australian Army
        INDEPENDENT:
            "vn_i_men_army" - ARVN (South Vietnamese Army)
*/

params [
    ["_side", OPFOR, [OPFOR]],
    ["_faction", "vn_o_men_nva", [""]],
    ["_squadType", "rifle", [""]],
    ["_amount", 6, [0]],
    ["_spawnLocation", "player", ["", [], objNull]],
    ["_offsetRadius", 10, [0]],
    ["_skill", 0.7, [0]],
    ["_replaceGroup", "", [""]]  // Name of existing group to replace with waypoints
];

// Function to get spawn position based on input
private _fnc_getSpawnPos = {
    params ["_location"];
    private _pos = [0, 0, 0];
    
    // Debug output
    systemChat format ["DEBUG: Spawn location input: %1 (type: %2)", _location, typeName _location];
    
    switch (typeName _location) do {
        case "STRING": {
            if (_location == "player") then {
                _pos = getPos player;
                systemChat format ["DEBUG: Using player position: %1", _pos];
            } else {
                // Assume it's a marker name
                private _markerPos = getMarkerPos _location;
                systemChat format ["DEBUG: Marker '%1' position: %2", _location, _markerPos];
                
                if (_markerPos isNotEqualTo [0, 0, 0]) then {
                    _pos = _markerPos;
                    systemChat format ["DEBUG: Successfully using marker position: %1", _pos];
                } else {
                    systemChat format ["Warning: Marker '%1' not found, using player position", _location];
                    _pos = getPos player;
                };
            };
        };
        case "ARRAY": {
            _pos = _location;
            systemChat format ["DEBUG: Using coordinate array: %1", _pos];
        };
        case "OBJECT": {
            _pos = getPos _location;
            systemChat format ["DEBUG: Using object position: %1", _pos];
        };
        default {
            systemChat "Warning: Invalid spawn location, using player position";
            _pos = getPos player;
        };
    };
    
    _pos
};

// Get spawn position
private _spawnPos = [_spawnLocation] call _fnc_getSpawnPos;

// Check if we should replace an existing group with waypoints
private _targetGroup = grpNull;
private _existingWaypoints = [];
private _useGroupPosition = false;

if (_replaceGroup != "") then {
    // Try to find the existing group by variable name
    private _foundObject = missionNamespace getVariable [_replaceGroup, objNull];
    
    if (!isNull _foundObject) then {
        private _sourceGroup = grpNull;
        private _groupLeader = objNull;
        
        // Check if it's a unit (group leader) or actual group
        if (typeName _foundObject == "OBJECT") then {
            _sourceGroup = group _foundObject;  // Get group from unit
            _groupLeader = _foundObject;        // Store the leader
            systemChat format ["DEBUG: Found unit '%1', using its group", _replaceGroup];
        } else {
            _sourceGroup = _foundObject;  // It's already a group
            _groupLeader = leader _sourceGroup;  // Get the leader
            systemChat format ["DEBUG: Found group '%1' directly", _replaceGroup];
        };
        
        if (!isNull _sourceGroup && !isNull _groupLeader) then {
            // Use the group leader's position as spawn position
            _spawnPos = getPos _groupLeader;
            _useGroupPosition = true;
            systemChat format ["DEBUG: Using group position as spawn location: %1", _spawnPos];
            
            // Store existing waypoints for copying
            _existingWaypoints = waypoints _sourceGroup;
            systemChat format ["DEBUG: Found %1 waypoints to copy", count _existingWaypoints];
            
            // Create new group (don't reuse the old one)
            _targetGroup = createGroup [_side, true];
            
            // Delete the old group's units
            {
                deleteVehicle _x;
            } forEach (units _sourceGroup);
            
            systemChat format ["DEBUG: Will spawn at group position and copy %1 waypoints", count _existingWaypoints];
        } else {
            systemChat format ["WARNING: Could not get group from '%1', creating new group", _replaceGroup];
            _targetGroup = createGroup [_side, true];
        };
    } else {
        systemChat format ["WARNING: Object '%1' not found, creating new group", _replaceGroup];
        _targetGroup = createGroup [_side, true];
    };
} else {
    // Create new group as normal
    _targetGroup = createGroup [_side, true];
};

private _group = _targetGroup;

// Add debug to verify group type
systemChat format ["DEBUG: Group variable type: %1, Group: %2", typeName _group, _group];

// Add debug to verify group type
systemChat format ["DEBUG: Group variable type: %1, Group: %2", typeName _group, _group];

// Define squad compositions with correct unit classnames
private _squadCompositions = createHashMap;

// Vietnam DLC PAVN/NVA Units (OPFOR)
if (_faction == "vn_o_men_nva") then {
    _squadCompositions set ["rifle", [
        "vn_o_men_nva_65_01",      // Squad Leader
        "vn_o_men_nva_65_02",      // Rifleman
        "vn_o_men_nva_65_02",      // Rifleman
        "vn_o_men_nva_65_03",      // Grenadier
        "vn_o_men_nva_65_04",      // Machine Gunner
        "vn_o_men_nva_65_05"       // Marksman
    ]];
    _squadCompositions set ["mg", [
        "vn_o_men_nva_65_01",      // Squad Leader
        "vn_o_men_nva_65_04",      // Machine Gunner
        "vn_o_men_nva_65_04",      // Machine Gunner
        "vn_o_men_nva_65_02",      // Rifleman (Support)
        "vn_o_men_nva_65_02"       // Rifleman (Support)
    ]];
    _squadCompositions set ["at", [
        "vn_o_men_nva_65_01",      // Squad Leader
        "vn_o_men_nva_65_06",      // AT Specialist
        "vn_o_men_nva_65_06",      // AT Specialist
        "vn_o_men_nva_65_02",      // Rifleman (Support)
        "vn_o_men_nva_65_03"       // Grenadier
    ]];
    _squadCompositions set ["sniper", [
        "vn_o_men_nva_65_01",      // Squad Leader
        "vn_o_men_nva_65_05",      // Marksman/Sniper
        "vn_o_men_nva_65_05",      // Marksman/Sniper
        "vn_o_men_nva_65_02"       // Rifleman (Security)
    ]];
    _squadCompositions set ["demo", [
        "vn_o_men_nva_65_01",      // Squad Leader
        "vn_o_men_nva_65_07",      // Demo Specialist
        "vn_o_men_nva_65_03",      // Grenadier
        "vn_o_men_nva_65_02",      // Rifleman
        "vn_o_men_nva_65_02"       // Rifleman
    ]];
};

// Vietnam DLC Viet Cong Units (OPFOR)
if (_faction == "vn_o_men_vc") then {
    _squadCompositions set ["rifle", [
        "vn_o_men_vc_local_01",    // Squad Leader
        "vn_o_men_vc_local_02",    // Rifleman
        "vn_o_men_vc_local_02",    // Rifleman
        "vn_o_men_vc_local_03",    // Grenadier
        "vn_o_men_vc_local_04",    // Machine Gunner
        "vn_o_men_vc_local_05"     // Marksman
    ]];
    _squadCompositions set ["mg", [
        "vn_o_men_vc_local_01",    // Squad Leader
        "vn_o_men_vc_local_04",    // Machine Gunner
        "vn_o_men_vc_local_04",    // Machine Gunner
        "vn_o_men_vc_local_02",    // Rifleman
        "vn_o_men_vc_local_02"     // Rifleman
    ]];
    _squadCompositions set ["at", [
        "vn_o_men_vc_local_01",    // Squad Leader
        "vn_o_men_vc_local_06",    // AT Specialist
        "vn_o_men_vc_local_06",    // AT Specialist
        "vn_o_men_vc_local_02",    // Rifleman
        "vn_o_men_vc_local_03"     // Grenadier
    ]];
    _squadCompositions set ["sniper", [
        "vn_o_men_vc_local_01",    // Squad Leader
        "vn_o_men_vc_local_05",    // Marksman
        "vn_o_men_vc_local_05",    // Marksman
        "vn_o_men_vc_local_02"     // Rifleman
    ]];
    _squadCompositions set ["demo", [
        "vn_o_men_vc_local_01",    // Squad Leader
        "vn_o_men_vc_local_07",    // Demo Specialist
        "vn_o_men_vc_local_03",    // Grenadier
        "vn_o_men_vc_local_02",    // Rifleman
        "vn_o_men_vc_local_02"     // Rifleman
    ]];
};

// Vietnam DLC US Army Units (BLUFOR)
if (_faction == "vn_b_men_army") then {
    _squadCompositions set ["rifle", [
        "vn_b_men_army_01",        // Squad Leader
        "vn_b_men_army_02",        // Rifleman
        "vn_b_men_army_02",        // Rifleman
        "vn_b_men_army_03",        // Grenadier
        "vn_b_men_army_04",        // Machine Gunner
        "vn_b_men_army_05"         // Marksman
    ]];
    _squadCompositions set ["mg", [
        "vn_b_men_army_01",        // Squad Leader
        "vn_b_men_army_04",        // Machine Gunner
        "vn_b_men_army_04",        // Machine Gunner
        "vn_b_men_army_02",        // Rifleman
        "vn_b_men_army_02"         // Rifleman
    ]];
    _squadCompositions set ["at", [
        "vn_b_men_army_01",        // Squad Leader
        "vn_b_men_army_06",        // AT Specialist
        "vn_b_men_army_06",        // AT Specialist
        "vn_b_men_army_02",        // Rifleman
        "vn_b_men_army_03"         // Grenadier
    ]];
    _squadCompositions set ["sniper", [
        "vn_b_men_army_01",        // Squad Leader
        "vn_b_men_army_05",        // Marksman
        "vn_b_men_army_05",        // Marksman
        "vn_b_men_army_02"         // Rifleman
    ]];
    _squadCompositions set ["demo", [
        "vn_b_men_army_01",        // Squad Leader
        "vn_b_men_army_07",        // Demo Specialist
        "vn_b_men_army_03",        // Grenadier
        "vn_b_men_army_02",        // Rifleman
        "vn_b_men_army_02"         // Rifleman
    ]];
};

// Fallback to vanilla units if Vietnam faction not recognized
private _useVanillaFallback = false;
if (_faction != "vn_o_men_nva" && _faction != "vn_o_men_vc" && _faction != "vn_b_men_army") then {
    _useVanillaFallback = true;
    systemChat format ["WARNING: Faction '%1' not recognized, using vanilla units", _faction];
    
    // Vanilla OPFOR units
    if (_side == OPFOR) then {
        _squadCompositions set ["rifle", [
            "O_Soldier_SL_F",          // Squad Leader
            "O_Soldier_F",             // Rifleman
            "O_Soldier_F",             // Rifleman
            "O_Soldier_GL_F",          // Grenadier
            "O_Soldier_AR_F",          // Autorifleman
            "O_soldier_M_F"            // Marksman
        ]];
    };
    
    // Vanilla BLUFOR units
    if (_side == BLUFOR) then {
        _squadCompositions set ["rifle", [
            "B_Soldier_SL_F",          // Squad Leader
            "B_Soldier_F",             // Rifleman
            "B_Soldier_F",             // Rifleman
            "B_Soldier_GL_F",          // Grenadier
            "B_Soldier_AR_F",          // Autorifleman
            "B_soldier_M_F"            // Marksman
        ]];
    };
    
    // Copy rifle composition to other squad types for simplicity
    _squadCompositions set ["mg", (_squadCompositions get "rifle")];
    _squadCompositions set ["at", (_squadCompositions get "rifle")];
    _squadCompositions set ["sniper", (_squadCompositions get "rifle")];
    _squadCompositions set ["demo", (_squadCompositions get "rifle")];
};

// Get squad composition or default to rifle
private _composition = _squadCompositions getOrDefault [_squadType, _squadCompositions get "rifle"];

// Build unit classnames - no need to modify since they're already complete
private _unitTypes = +_composition;

// Debug: Show unit types being used
systemChat format ["DEBUG: Unit types to spawn: %1", _unitTypes];

// Ensure we have enough unit types for the requested amount
while {count _unitTypes < _amount} do {
    _unitTypes append _composition;
};

private _spawnedUnits = [];

// Spawn soldiers
for "_i" from 0 to (_amount - 1) do {
    // Select unit type
    private _unitType = _unitTypes select (_i min (count _unitTypes - 1));
    
    // Debug: Show what unit type we're trying to spawn
    systemChat format ["DEBUG: Attempting to spawn unit %1 of type: %2", _i + 1, _unitType];
    
    // Calculate spawn position around spawn point
    private _angle = (_i / _amount) * 360;
    private _offset = [sin _angle, cos _angle, 0] vectorMultiply _offsetRadius;
    private _unitSpawnPos = _spawnPos vectorAdd _offset;
    
    // Find safe position on ground
    _unitSpawnPos = [_unitSpawnPos select 0, _unitSpawnPos select 1, 0];
    private _safePos = _unitSpawnPos findEmptyPosition [0, 20, _unitType];
    
    // If no empty position found, use calculated position
    if (count _safePos == 0) then {
        _safePos = _unitSpawnPos;
    };
    
    // Debug: Show spawn position
    systemChat format ["DEBUG: Spawn position for unit %1: %2", _i + 1, _safePos];
    
    // Create the unit
    private _unit = _group createUnit [_unitType, _safePos, [], 0, "NONE"];
    
    // Debug: Check if unit was created successfully
    if (isNull _unit) then {
        systemChat format ["ERROR: Failed to create unit of type: %1", _unitType];
    } else {
        systemChat format ["DEBUG: Successfully created unit: %1 at position %2", _unit, getPos _unit];
        
        // Set unit skill
        _unit setSkill _skill;
        
        // Add to spawned units array
        _spawnedUnits pushBack _unit;
        
        // Set first unit as group leader
        if (_i == 0) then {
            _group selectLeader _unit;
        };
    };
};

// Copy waypoints from the original group if any exist
if (count _existingWaypoints > 0) then {
    systemChat format ["DEBUG: Copying %1 waypoints to new group", count _existingWaypoints];
    
    {
        private _wpPos = waypointPosition _x;
        private _wpType = waypointType _x;
        private _wpSpeed = waypointSpeed _x;
        private _wpBehaviour = waypointBehaviour _x;
        private _wpCombatMode = waypointCombatMode _x;
        private _wpFormation = waypointFormation _x;
        
        private _newWp = _group addWaypoint [_wpPos, 0];
        _newWp setWaypointType _wpType;
        _newWp setWaypointSpeed _wpSpeed;
        _newWp setWaypointBehaviour _wpBehaviour;
        _newWp setWaypointCombatMode _wpCombatMode;
        _newWp setWaypointFormation _wpFormation;
        
        systemChat format ["DEBUG: Copied waypoint: %1 at %2", _wpType, _wpPos];
        
    } forEach _existingWaypoints;
} else {
    // Set default group behavior if no waypoints copied
    _group setBehaviour "AWARE";
    _group setFormation "WEDGE";
    _group setSpeedMode "NORMAL";
};

// Output information
private _sideText = switch (_side) do {
    case BLUFOR: {"BLUFOR"};
    case OPFOR: {"OPFOR"};
    case INDEPENDENT: {"INDEPENDENT"};
    case CIVILIAN: {"CIVILIAN"};
    default {"UNKNOWN"};
};

systemChat format ["Spawned %1 %2 %3 squad (%4 units) for %5", _amount, _faction, _squadType, count _spawnedUnits, _sideText];

// Return the group (caller can add custom waypoints)
_group
