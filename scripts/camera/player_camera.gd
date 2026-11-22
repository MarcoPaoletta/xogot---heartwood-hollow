class_name PlayerCamera
extends Node3D

## Rigid zero-lag third-person camera (skills/game-dev/references/third-person-camera/).
## Position follow is 100% rigid on interpolated body transform; smoothing applies ONLY
## to rotation overrides, FOV, spring length, and trauma shake.

@export var follow_height: float = 1.32
@export var default_distance: float = 3.50
@export var lantern_distance: float = 3.15
@export var default_fov: float = 50.0
@export var lantern_fov: float = 47.0
@export var mouse_sensitivity_deg_per_px: float = 0.1375
@export var pitch_min_deg: float = -35.0
@export var pitch_max_deg: float = -5.0
@export var initial_pitch_deg: float = -16.0
@export var shake_max_offset: float = 0.14
@export var shake_decay: float = 2.6

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var arm_end: Node3D = $SpringArm3D/ArmEnd
@onready var cam: Camera3D = $SpringArm3D/ArmEnd/Camera3D

var yaw: float = 0.0
var pitch_deg: float = -16.0
var _player: Node3D = null
var _trauma: float = 0.0
var _shake_time: float = 0.0
var _lantern_active: bool = false
var _input_enabled: bool = true
var _override_active: bool = false
var _override_target_xf: Transform3D = Transform3D.IDENTITY
var _override_fov: float = 50.0
var _override_blend: float = 0.0


func _ready() -> void:
	top_level = true
	pitch_deg = initial_pitch_deg
	_player = get_parent() as Node3D
	if spring_arm != null:
		spring_arm.spring_length = default_distance
	if cam != null:
		cam.fov = default_fov


func set_initial_yaw(yaw_rad: float) -> void:
	yaw = yaw_rad
	pitch_deg = initial_pitch_deg
	_apply_rig_transform()
	reset_physics_interpolation()


func set_input_enabled(enabled: bool) -> void:
	_input_enabled = enabled


func set_lantern_active(active: bool) -> void:
	_lantern_active = active


func add_trauma(amount: float) -> void:
	_trauma = clampf(_trauma + amount, 0.0, 1.0)


func set_camera_override(target_xf: Transform3D, target_fov: float = 50.0) -> void:
	_override_active = true
	_override_target_xf = target_xf
	_override_fov = target_fov


func clear_camera_override() -> void:
	_override_active = false


func yaw_basis() -> Basis:
	return Basis(Vector3.UP, yaw)


func get_camera() -> Camera3D:
	return cam


func _unhandled_input(event: InputEvent) -> void:
	if not _input_enabled or _override_active or get_tree().paused:
		return
	if event is InputEventMouseMotion:
		var mm: InputEventMouseMotion = event as InputEventMouseMotion
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED or Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
			var rel: Vector2 = mm.screen_relative if mm.screen_relative.length_squared() > 0.0001 else mm.relative
			yaw -= deg_to_rad(rel.x * mouse_sensitivity_deg_per_px)
			pitch_deg = clampf(pitch_deg - rel.y * mouse_sensitivity_deg_per_px, pitch_min_deg, pitch_max_deg)


func _process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	# Rigid follow on interpolated physics transform (zero lag, zero jitter)
	var body_pos: Vector3 = _player.get_global_transform_interpolated().origin
	global_position = body_pos + Vector3(0.0, follow_height, 0.0)
	rotation = Vector3(deg_to_rad(pitch_deg), yaw, 0.0)

	# Smooth spring length & FOV only (never follow position)
	var k: float = 1.0 - exp(-8.0 * delta)
	if spring_arm != null:
		var target_len: float = lantern_distance if _lantern_active else default_distance
		spring_arm.spring_length = lerpf(spring_arm.spring_length, target_len, k)
	if cam != null:
		var target_fov: float = _override_fov if _override_active else (lantern_fov if _lantern_active else default_fov)
		cam.fov = lerpf(cam.fov, target_fov, k)

		# Trauma-squared camera shake on Camera3D local offset (inside ArmEnd so SpringArm never overwrites it)
		if _trauma > 0.001:
			_trauma = maxf(0.0, _trauma - shake_decay * delta)
			_shake_time += delta * 42.0
			var shake: float = _trauma * _trauma * shake_max_offset
			cam.position = Vector3(
				sin(_shake_time * 1.13) * shake,
				cos(_shake_time * 1.71) * shake * 0.85,
				0.0
			)
		else:
			cam.position = cam.position.lerp(Vector3.ZERO, 1.0 - exp(-16.0 * delta))

		# Smooth blend to dialogue/decision override transform when active
		if _override_active:
			_override_blend = minf(1.0, _override_blend + delta * 2.5)
			cam.top_level = true
			var eased: float = _override_blend * _override_blend * (3.0 - 2.0 * _override_blend)
			cam.global_transform = arm_end.global_transform.interpolate_with(_override_target_xf, eased)
		elif _override_blend > 0.001:
			_override_blend = maxf(0.0, _override_blend - delta * 2.8)
			var eased: float = _override_blend * _override_blend * (3.0 - 2.0 * _override_blend)
			cam.global_transform = arm_end.global_transform.interpolate_with(_override_target_xf, eased)
			if _override_blend <= 0.001:
				cam.top_level = false
				cam.transform = Transform3D.IDENTITY


func _apply_rig_transform() -> void:
	if _player != null:
		global_position = _player.global_position + Vector3(0.0, follow_height, 0.0)
	rotation = Vector3(deg_to_rad(pitch_deg), yaw, 0.0)
