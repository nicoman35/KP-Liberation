/*
    File: fn_insideRock.sqf
    Author: Nicoman35
    Date: 2020-11-19
    Last Update: 2020-11-19
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
        Checks, wether given reference position is inside of a rock.

    Parameter(s):
        _refPos		- Given reference position	[ARRAY, defaults to []]

    Returns:
        Bool
*/

params [
   ["_refPos", []]
];

diag_log formatText ["%1%2%3", time, "s  (fn_insideRock)		_refPos: ", _refPos];

if (count _refPos == 0) exitWith {false};

lineIntersectsSurfaces [_refPos, _refPos vectorAdd [0, 0, 30], objNull, objNull, false, 1, "GEOM", "FIRE"] select 0 params ["","","","_rock"];
diag_log formatText ["%1%2%3", time, "s  (fn_insideRock)		_rock: ", _rock];
if (isNil {_rock}) exitWith {false};
if (isnull _rock || _rock isKindOf "House") exitWith {false};

true
