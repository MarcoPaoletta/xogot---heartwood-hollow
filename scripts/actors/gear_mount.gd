@tool
class_name GearMount
extends BoneAttachment3D

## Socket for mounting Xogot Modeler hero props (M01 sword, M02 lantern, M05 capelet)
## rigidly onto an animated Skeleton3D with saved WeaponMountProfile calibration.

@export var mount_profile: WeaponMountProfile:
	set(value):
		mount_profile = value
		_load_from_profile()
		_apply()
@export var offset_position: Vector3 = Vector3.ZERO:
	set(value):
		offset_position = value
		_write_profile()
		_apply()
@export var offset_rotation_degrees: Vector3 = Vector3.ZERO:
	set(value):
		offset_rotation_degrees = value
		_write_profile()
		_apply()
@export var offset_scale: Vector3 = Vector3.ONE:
	set(value):
		offset_scale = value
		_write_profile()
		_apply()

@export_group("Capture (editor only)")
@export var capture_from_gear: bool = false:
	set(value):
		if value and Engine.is_editor_hint():
			_capture()

@export_group("Preview (editor only)")
@export var preview_player_path: NodePath
@export var preview_animation: String = "":
	set(value):
		preview_animation = value
		_scrub()
@export_range(0.0, 1.0) var preview_time: float = 0.0:
	set(value):
		preview_time = value
		_scrub()

var _loading: bool = false


func _ready() -> void:
	_load_from_profile()
	_apply()
	_apply.call_deferred()


func _load_from_profile() -> void:
	if mount_profile == null:
		return
	_loading = true
	offset_position = mount_profile.position_offset
	offset_rotation_degrees = mount_profile.rotation_degrees_offset
	offset_scale = mount_profile.scale_factor
	_loading = false


func _apply() -> void:
	if not is_inside_tree() or get_child_count() == 0:
		return
	var gear: Node3D = get_child(0) as Node3D
	if gear == null:
		return
	var parent_scale: Vector3 = _skeleton_scale()
	var inv: Vector3 = Vector3(1.0 / parent_scale.x, 1.0 / parent_scale.y, 1.0 / parent_scale.z)
	gear.position = offset_position * inv
	gear.rotation_degrees = offset_rotation_degrees
	gear.scale = offset_scale * inv


func _skeleton_scale() -> Vector3:
	var s: Vector3 = global_basis.get_scale()
	if use_external_skeleton:
		var sk: Node3D = get_node_or_null(get_external_skeleton()) as Node3D
		if sk != null:
			s = sk.global_basis.get_scale()
	if s.x < 0.0001 or s.y < 0.0001 or s.z < 0.0001:
		return Vector3.ONE
	return s


func _write_profile() -> void:
	if mount_profile == null or _loading or not Engine.is_editor_hint() or not is_node_ready():
		return
	mount_profile.position_offset = offset_position
	mount_profile.rotation_degrees_offset = offset_rotation_degrees
	mount_profile.scale_factor = offset_scale


func _capture() -> void:
	if get_child_count() == 0:
		return
	var gear: Node3D = get_child(0) as Node3D
	if gear == null:
		return
	var parent_scale: Vector3 = _skeleton_scale()
	offset_position = gear.position * parent_scale
	offset_rotation_degrees = gear.rotation_degrees
	offset_scale = gear.scale * parent_scale


func _scrub() -> void:
	if not Engine.is_editor_hint():
		return
	var sk: Skeleton3D = get_node_or_null(get_external_skeleton()) as Skeleton3D
	var ap: AnimationPlayer = get_node_or_null(preview_player_path) as AnimationPlayer
	if sk == null or ap == null:
		return
	if preview_animation.is_empty():
		sk.reset_bone_poses()
		return
	if not ap.has_animation(preview_animation):
		return
	var anim: Animation = ap.get_animation(preview_animation)
	var t: float = clampf(preview_time, 0.0, 1.0) * anim.length
	for i: int in range(anim.get_track_count()):
		var bone: String = String(anim.track_get_path(i)).get_slice(":", 1)
		var bi: int = sk.find_bone(bone)
		if bi == -1:
			continue
		match anim.track_get_type(i):
			Animation.TYPE_ROTATION_3D:
				sk.set_bone_pose_rotation(bi, anim.rotation_track_interpolate(i, t))
			Animation.TYPE_POSITION_3D:
				sk.set_bone_pose_position(bi, anim.position_track_interpolate(i, t))
			Animation.TYPE_SCALE_3D:
				sk.set_bone_pose_scale(bi, anim.scale_track_interpolate(i, t))
