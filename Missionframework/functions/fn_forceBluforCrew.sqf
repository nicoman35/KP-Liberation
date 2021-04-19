/*
    File: fn_forceBluforCrew.sqf
    Author: KP Liberation Dev Team - https://github.com/KillahPotatoes
    Date: 2019-11-25
    Last Update: 2019-12-04
    License: MIT License - http://www.opensource.org/licenses/MIT

    Description:
        Creates vehicle crew from vehicle config.
        If the crew isn't the same side as the players, it'll create a player side crew.

    Parameter(s):
        _veh - Vehicle to add the blufor crew to [OBJECT, defaults to objNull]
		_crew - vehicle's crew

    Returns:
        Function reached the end [BOOL]
*/

params [ "_veh", ["_crew", []]];

if (isNull _veh) exitWith {["Null object given"] call BIS_fnc_error; false};

// UAV units can only have AI units. Besides, the lower routine WILL not work for UAVs. The driver will not be able to be moved in for whatever reason.
if (unitIsUAV _veh) exitWith {
	createVehicleCrew _veh;
	(group ((crew _veh) select 0)) setBehaviour "SAFE";
	true
};

// If we have a crew given with sored roles and classes, rebuild and reassign crew to the vehicle
private _grp = createGroup [GRLIB_side_friendly, true];
{
	private _class = _x select 0;
	private _member = _grp createUnit [_class, getPos _veh, [], 0, "FORM"];
	_member addMPEventHandler ["MPKilled", {_this spawn kill_manager}];
	private _role = _x select 1;
	if (_role select 0 == "driver") then {_member moveInDriver _veh};
	if (_role select 0 == "cargo") then {_member moveInCargo _veh};
	if (_role select 0 == "Turret") then {_member moveinturret [_veh, _role select 1]};
} forEach _crew;
(group ((crew _veh) select 0)) setBehaviour "SAFE";

true