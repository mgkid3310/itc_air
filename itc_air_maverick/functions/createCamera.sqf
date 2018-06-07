
params ["_display"];
_plane = vehicle player;

private _cam = "camera" camCreate (getPos _plane);
_cam camSetFov 0.05;
//_cam attachTo [_plane, [2.7,2,-0.8]];
_cam cameraEffect ["internal", "BACK", "MAVERICK_FEED"];
_cam camCommit 0;
"MAVERICK_FEED" setPiPEffect [3,1,1,0.4,0,[0,0,0,0],[1,1,1,0],[1,1,1,1]];

ITC_AIR_MAVERICK_CAM = _cam;

[{
   _this select 0 params ["_plane","_display"];
   if (_display isEqualTo displayNull || (_display getVariable ["page",""]) != "ccdmav") exitWith {
       camDestroy ITC_AIR_MAVERICK_CAM;
       ITC_AIR_MAVERICK_CAM cameraEffect ["terminate", "back", "MAVERICK_FEED"];
       ITC_AIR_MAVERICK_CAM = nil;
       [_this select 1] call CBA_fnc_removePerFrameHandler;
   };
   //_cam camSetPos (getPos _plane);
   ITC_AIR_MAVERICK_CAM cameraEffect ["internal", "BACK", "MAVERICK_FEED"];
   private _forwardModifier = vectorMagnitude (velocity _plane) * 0.5;
   private _cameraPos = (_plane modelToWorld [ITC_AIR_MAVERICK_CAMSIDE * 2.7,2 + _forwardModifier,-0.8]);
   ITC_AIR_MAVERICK_CAM camSetPos _cameraPos;

   private _planeDir = vectorDir _plane;
   private _dirWorld = (getPosASL _plane) vectorFromTo ITC_AIR_MAVERICK_TRACK;
   private _ang = acos (_dirWorld vectorDotProduct _planeDir);

   private _targetVector = [5000,ITC_AIR_MAVERICK_DIR # 0, ITC_AIR_MAVERICK_DIR # 1] call CBA_fnc_polar2vect;
   private _cameraTarget = _plane modelToWorld _targetVector;
   if(ITC_AIR_MAVERICK_GSTAB && (_ang < 15)) then {
     _cameraTarget = ITC_AIR_MAVERICK_TRACK;
   };
   if((!isNull (ITC_AIR_MAVERICK_LOCK # 0)) && (_ang < 15)) then {
     _cameraTarget = (ITC_AIR_MAVERICK_LOCK # 0) modelToWorld (ITC_AIR_MAVERICK_LOCK # 1);
   };
   if(_ang > 15) then {
     ITC_AIR_MAVERICK_GSTAB = false;
   };
   ITC_AIR_MAVERICK_CAM camSetTarget _cameraTarget;
   ITC_AIR_MAVERICK_CAM camCommit 0;
   drawIcon3d ["itc_air_mfd\data\UI\wagonwheel.paa", [0,1,0,1], _cameraTarget, 0.7, 0.7, 0, "", 1, 0.05, "PuristaMedium", "center"];
}, 0, [_plane, _display]] call CBA_fnc_addPerFrameHandler;