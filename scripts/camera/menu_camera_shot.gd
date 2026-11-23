@tool
class_name MenuCameraShot
extends Node3D

## Single moving camera shot for the Title Menu Camera Director (menu-camera-cuts).

enum Movement { STATIC, MOVE, ORBIT }

@export var enabled: bool = true
@export var duration: float = 4.5
@export var fov: float = 48.0
@export var movement: Movement = Movement.MOVE
@export var end_offset: Vector3 = Vector3(0.0, 0.0, -3.0)
@export var end_rotation_offset_degrees: Vector3 = Vector3.ZERO
@export var orbit_target: Vector3 = Vector3.ZERO
@export var orbit_degrees: float = 38.0
@export var look_at_target: bool = true
@export var look_target: Vector3 = Vector3.ZERO
@export var ease_ends: bool = true


func sample(t_norm: float) -> Transform3D:
	var t: float = clampf(t_norm, 0.0, 1.0)
	if ease_ends:
		t = t * t * (3.0 - 2.0 * t)
	var start_xf: Transform3D = global_transform
	var pos: Vector3 = start_xf.origin
	var rot_basis: Basis = start_xf.basis
	match movement:
		Movement.MOVE:
			pos = start_xf.origin + end_offset * t
			var extra: Basis = Basis.from_euler(Vector3(
				deg_to_rad(end_rotation_offset_degrees.x * t),
				deg_to_rad(end_rotation_offset_degrees.y * t),
				deg_to_rad(end_rotation_offset_degrees.z * t)
			))
			rot_basis = start_xf.basis * extra
		Movement.ORBIT:
			var offset: Vector3 = start_xf.origin - orbit_target
			var rotated: Vector3 = offset.rotated(Vector3.UP, deg_to_rad(orbit_degrees * t))
			pos = orbit_target + rotated
	var xf: Transform3D = Transform3D(rot_basis, pos)
	if look_at_target:
		var aim: Vector3 = look_target if movement != Movement.ORBIT else orbit_target
		if pos.distance_to(aim) > 0.05:
			xf = xf.looking_at(aim, Vector3.UP)
	return xf
