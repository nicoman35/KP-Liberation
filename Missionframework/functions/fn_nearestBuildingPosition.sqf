/*
    File: fn_nearestBuildingPosition.sqf
    Author: Nicoman35
    Date: 2020-11-19
    Last Update: 2020-11-19
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
        Finds closest building position from a given reference position.

    Parameter(s):
        _refPos		- Given reference position	[ARRAY, defaults to []]
        _building	- Building to search		[OBJECT, defaults to objNull]

    Returns:
        Closest buliding position from reference position [ARRAY]
*/

params [
    ["_refPos", []],
    ["_building", objNull]
];

diag_log formatText ["%1%2%3%4%5", time, "s  (fn_nearestBuildingPosition)		_refPos: ", _refPos, ", _building: ", _building];

if (isNull _building) exitWith {[]};

private _allPositions = _building buildingPos -1;
private _closestPos = _allPositions select 0;
if (count _refPos > 0) then {
	_allPositions = _allPositions apply {[_x distance _refPos, _x]};
	_allPositions sort true;
	private _closestPos = _allPositions select 0 select 1;
};

diag_log formatText ["%1%2%3", time, "s  (fn_nearestBuildingPosition)		_closestPos: ", _closestPos];

_closestPos
