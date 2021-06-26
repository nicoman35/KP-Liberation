waitUntil {!isNil "save_is_loaded"};
waitUntil {!isNil "GRLIB_vehicle_to_military_base_links"};
waitUntil {!isNil "blufor_sectors"};
waitUntil {save_is_loaded};

if (GRLIB_difficulty_modifier == 0) exitWith {};											// no AA turrets on easiest difficulty level
if (isNil "opfor_AA_Turrets") exitWith {};													// leave, if there are no AA turrets defined in currently played preset
private _AA_Killed_Turrets = 0;																// counter of killed AA turrets
if (isNil "KPLIB_AA_used_positions") then {KPLIB_AA_used_positions = []};								// define array containing all currently used positions
if (isNil "KPLIB_AA_opfor_turrets") then {KPLIB_AA_opfor_turrets = []};						// define array containing all turrets corresponding to a used position
if (isNil "KPLIB_AA_opfor_turret_types") then {KPLIB_AA_opfor_turret_types = []};			// define array containing all spawned turret types

// In case anything goes wrong within the save, and some inconsistent data occurs, reset all arrays and make a fresh start
if (count KPLIB_AA_used_positions != count KPLIB_AA_opfor_turret_types || count KPLIB_AA_used_positions != count KPLIB_AA_opfor_turrets) then {
	KPLIB_AA_used_positions = [];
	KPLIB_AA_opfor_turrets = [];
	KPLIB_AA_opfor_turret_types = [];
};

// diag_log formatText ["%1%2", time, "s  (KPLIB_AA_opfor_turrets) started!"]; 

while {GRLIB_endgame == 0} do {
    private _sleeptime =  (1800 + (random 1800)) / (([] call KPLIB_fnc_getOpforFactor) * GRLIB_csat_aggressivity);

    if (combat_readiness >= 80) then {_sleeptime = _sleeptime * 0.75};
    if (combat_readiness >= 90) then {_sleeptime = _sleeptime * 0.75};
    if (combat_readiness >= 95) then {_sleeptime = _sleeptime * 0.75};
	
	// diag_log formatText ["%1%2%3%4%5%6%7%8%9", time, "s  (KPLIB_AA_opfor_turrets) getOpforFactor: ", [] call KPLIB_fnc_getOpforFactor, ", combat_readiness: ", combat_readiness, ", GRLIB_csat_aggressivity: ", GRLIB_csat_aggressivity, ", _sleeptime: ", _sleeptime];
	sleep _sleeptime;
	// diag_log formatText ["%1%2%3%4%5%6%7%8%9", time, "s  (KPLIB_AA_opfor_turrets) getOpforFactor: ", [] call KPLIB_fnc_getOpforFactor, ", combat_readiness: ", combat_readiness, ", GRLIB_csat_aggressivity: ", GRLIB_csat_aggressivity, ", _sleeptime: ", _sleeptime];   
	// sleep 60;
	// diag_log formatText ["%1%2%3%4%5", time, "s  (KPLIB_AA_opfor_turrets) after sleep, KPLIB_AA_opfor_turrets: ", KPLIB_AA_opfor_turrets, ", KPLIB_AA_used_positions: ", KPLIB_AA_used_positions]; 
	
	// Check and clear turret array for any destroyed or unmanned units
	private _turret = objNull;
	{		
		if (typeName _x  == "ARRAY") then {			
			_turret = _x select 0;															// in case turret is an array, choose first element of array as turret
		} else {
			_turret = _x;
		};
		if (!alive _turret || !alive gunner _turret) then {
			// diag_log formatText ["%1%2%3%4%5", time, "s  (KPLIB_AA_opfor_turrets) turret ", _turret, " not alive, _x is an ARRAY: ", typeName _x  == "ARRAY"]; 
			if (typeName _x  == "ARRAY") then {			
				// diag_log formatText ["%1%2%3", time, "s  (KPLIB_AA_opfor_turrets) units group _x: ", units group _x]; 
				{
					if (alive _x) then {_x setDamage 1};
				} forEach _x;
			};
			KPLIB_AA_opfor_turrets deleteAt _forEachIndex;										// delete any destroyed or unmanned AA turret from turret array
			KPLIB_AA_used_positions deleteAt _forEachIndex;										// delete corresponding position from used positions array
			KPLIB_AA_opfor_turret_types deleteAt _forEachIndex;									// delete corresponding turret type from used turret types array
			
			_AA_Killed_Turrets = _AA_Killed_Turrets + 1;										// raise kill counter
		};
	} forEach KPLIB_AA_opfor_turrets;
	
	// diag_log formatText ["%1%2%3%4%5%6%7", time, "s  (KPLIB_AA_opfor_turrets) KPLIB_AA_opfor_turrets after clearing: ", KPLIB_AA_opfor_turrets, ", KPLIB_AA_used_positions: ", KPLIB_AA_used_positions, ", _AA_Killed_Turrets: ", _AA_Killed_Turrets]; 
	
	// If AA turrets were destroyed, add a 'punishment' time for the enemy. This extra time is ment to be a dampening of the production of AA turrets
	if (_AA_Killed_Turrets > 0) then {
		_sleeptime = _sleeptime * _AA_Killed_Turrets;
		// diag_log formatText ["%1%2%3", time, "s  (KPLIB_AA_opfor_turrets) extra sleeptime on account of killed turrets: ", _sleeptime]; 
		// sleep 10;
		sleep _sleeptime;																	// killing AA turrets 'damps' placement of further turrets
		_AA_Killed_Turrets = 0;																// reset kill counter after performing 'damp' sleep
	};
	
	// Calculate maximum amount of AA turrets
	private _maxAAnumber = round (GRLIB_difficulty_modifier * 2);
	if (_maxAAnumber > 12) then {_maxAAnumber = 12};
	if (combat_readiness > 0 && _maxAAnumber > 0) then {
		_maxAAnumber = _maxAAnumber * round (combat_readiness / 30);		
		if (_maxAAnumber > 20) then {_maxAAnumber = 20};
		if (_maxAAnumber > (count sectors_allSectors - count blufor_sectors)) then {_maxAAnumber = count sectors_allSectors - count blufor_sectors};	// maximum amount of AA turrets should not exceed number of opfor sectors
	};
	
	// diag_log formatText ["%1%2%3%4%5%6%7%8%9", time, "s  (KPLIB_AA_opfor_turrets) GRLIB_difficulty_modifier: ", GRLIB_difficulty_modifier, ", combat_readiness: ", combat_readiness, ", number opfor sectors: ", count sectors_allSectors - count blufor_sectors, ", _maxAAnumber: ", _maxAAnumber]; 
	
	// If maximum amount of AA turrets has not been reached yet, add one to the map
	if (count KPLIB_AA_opfor_turrets < _maxAAnumber) then {
		private _spawn_marker = [] call KPLIB_fnc_getOpforAASpawnPoint;						// get a sector for spawning an AA turret
		if (_spawn_marker == "") exitWith {diag_log formatText ["%1%2", time, "s  (KPLIB_AA_opfor_turrets) _spawn_marker: Could not find AA position"];};		
		private _rndTurret = selectRandom opfor_AA_Turrets;									// choose an opfor turret to be spawned
		
		// The lower the difficulty level is, the less it is likely to have 'heavy' AA defenses
		if (GRLIB_difficulty_modifier < 4 && typeName _rndTurret == "ARRAY") then {
			private _i = 4 - GRLIB_difficulty_modifier;
			while {typeName _rndTurret == "ARRAY" && _i > 0} do { 
				_rndTurret = selectRandom opfor_AA_Turrets;
				_i = _i - 1; 
			};
		};
		
		// diag_log formatText ["%1%2%3%4%5%6%7%8%9", time, "s  (KPLIB_AA_opfor_turrets) turrets count: ", count KPLIB_AA_opfor_turrets, ", _spawn_marker: ", _spawn_marker, ", markerpos _spawn_marker: ", markerpos _spawn_marker, ", _rndTurret: ", _rndTurret]; 
		private ["_vehicle", "_group", "_groupVehicles"];
		KPLIB_AA_used_positions pushBack _spawn_marker;	
		KPLIB_AA_opfor_turret_types pushBack _rndTurret;	
		if (typeName _rndTurret == "ARRAY") exitWith {
			_group = createGroup [GRLIB_side_enemy, true];
			_groupVehicles = [];
			{
				_vehicle = [markerpos _spawn_marker, _x] call KPLIB_fnc_spawnVehicle;
				_groupVehicles pushBack _vehicle;
				[_vehicle] joinSilent _group;
			} forEach _rndTurret;
			KPLIB_AA_opfor_turrets pushBack _groupVehicles;
			_group setBehaviour "AWARE";
		};
		_vehicle = [markerpos _spawn_marker, _rndTurret] call KPLIB_fnc_spawnVehicle;
		KPLIB_AA_opfor_turrets pushBack _vehicle;
		_vehicle setBehaviour "AWARE";
	};
};