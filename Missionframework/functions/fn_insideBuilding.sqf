/*
    File: fn_insideBuilding.sqf
    Author: Nicoman35
    Date: 2020-11-19
    Last Update: 2020-11-19
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
		Checks, wether given reference position is inside of a building.

    Parameter(s):
		_refPos		- Given reference position	[ARRAY, defaults to []]

    Returns:
		Building, if the reference position lies inside a buildig. ObjNull, if reference position does not lie inside a building. [OBJECT]
*/

params [
    ["_refPos", []]
];

diag_log formatText ["%1%2%3", time, "s  (fn_insideBuilding)		_refPos: ", _refPos];

if (count _refPos == 0) exitWith {false};

lineIntersectsSurfaces [_refPos, _refPos vectorAdd [0, 0, 50], objNull, objNull, false, 1, "GEOM", "FIRE"] select 0 params ["","","","_building"];
diag_log formatText ["%1%2%3", time, "s  (fn_insideBuilding)		_building: ", _building];
if (isNil {_building}) exitWith {objNull};
if (_building isKindOf "House")  exitWith {_building};
private _wallScore = 0;
private _directionsToCheck = [[2,0,1],[0,2,1],[-2,0,1],[0,-2,1],[2,2,1],[-2,2,1],[-2,-2,1],[-2,2,1]];
{
	lineIntersectsSurfaces [_refPos, _refPos vectorAdd _x, objNull, objNull, false, 1, "GEOM", "FIRE"] select 0 params ["","","","_building"];
	if (!isNil {_building} && _building isKindOf "House")  then {
		_wallScore = _wallScore + 1;
	}
} foreach _directionsToCheck;
if (_wallScore > 7) exitWith {_building}; // found at least 4 walls nearby
diag_log formatText ["%1%2", time, "s  (fn_insideBuilding)		returns objNull!!"];

objNull
