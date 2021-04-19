/*
    File: fn_insideBuilding.sqf
    Author: Nicoman35
    Date: 2020-11-19
    Last Update: 2021-03-02
    License: MIT License - http://www.opensource.org/licenses/MIT

    Examples: 
		_building = [player] call fn_insideBuilding;
		_building = [getPosWorld player] call fn_insideBuildingDev;
		
	Description:
		Checks, wether given reference position is inside of a building.

    Parameter(s):
		_position		- Position given by 'getPosWorld', or oject	[ARRAY or OBJECT, defaults to []]

    Returns:
		Building, if the reference position lies inside a buildig. ObjNull, if reference position does not lie inside a building. [OBJECT]
*/

// fn_insideBuildingDev = {
params [
   ["_position", []]
];

if (typeName _position == "OBJECT") then {_position = getPosWorld _position};

// diag_log formatText ["%1%2%3", time, "s  (fn_insideBuilding)		_position: ", _position];

if (count _position == 0) exitWith {objNull};

lineIntersectsSurfaces [_position, _position vectorAdd [0, 0, 20], objNull, objNull, false, 1, "GEOM", "FIRE"] select 0 params ["","","","_building"];
// diag_log formatText ["%1%2%3", time, "s  (fn_insideBuilding)		_building: ", _building];
// if (isNil {_building}) exitWith {objNull};

if (_building isKindOf "House")  exitWith {_building};
private _wallScore = 0;
private _directionsToCheck = [[2, 0, 1], [0, 2, 1], [-2, 0, 1], [0, -2, 1], [2, 2, 1], [-2, 2, 1], [-2, -2, 1], [-2, 2, 1]];
{
	lineIntersectsSurfaces [_position, _position vectorAdd _x, objNull, objNull, false, 1, "GEOM", "FIRE"] select 0 params ["","","","_building"];
	if (!isNil {_building} && _building isKindOf "House")  then {
		_wallScore = _wallScore + 1;
	}
} foreach _directionsToCheck;
if (_wallScore > 7) exitWith {_building}; // found at least 4 walls nearby
// diag_log formatText ["%1%2", time, "s  (fn_insideBuilding)		returns objNull!!"];

objNull
// };
// _building = [player] call fn_insideBuildingDev;
// diag_log formatText ["%1%2%3", time, "s  (fn_insideBuildingDev)		_building: ", _building];