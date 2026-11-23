@tool
class_name MenuCameraDirector
extends Node3D

## Loops through child MenuCameraShot nodes with hard cuts between shots and smooth
## movement inside each shot over the live forest world (GDD Section 8.3).

@export var active: bool = false:
	set(value):
		active = value
		if active:
			_shot_index = -1
			_advance()
@export var preview_shot: int = 0:
	set(value):
		preview_shot = value
		if Engine.is_editor_hint():
			_apply_preview()
@export_range(0.0, 1.0) var preview_t: float = 0.0:
	set(value):
		preview_t = value
		if Engine.is_editor_hint():
			_apply_preview()

@onready var cam: Camera3D = $Camera3D

var _shot_index: int = -1
var _elapsed: float = 0.0
var _current_shot: MenuCameraShot = null


func make_current() -> void:
	if cam != null:
		cam.current = true


func _process(delta: float) -> void:
	if Engine.is_editor_hint() or not active:
		return
	if _current_shot == null:
		_advance()
		return
	_elapsed += delta
	var dur: float = maxf(0.5, _current_shot.duration)
	if _elapsed >= dur:
		_advance()
		return
	if cam != null:
		cam.global_transform = _current_shot.sample(_elapsed / dur)


func _get_shots() -> Array[MenuCameraShot]:
	var out: Array[MenuCameraShot] = []
	for c: Node in get_children():
		if c is MenuCameraShot and (c as MenuCameraShot).enabled:
			out.append(c as MenuCameraShot)
	return out


func _advance() -> void:
	var shots: Array[MenuCameraShot] = _get_shots()
	if shots.is_empty():
		_current_shot = null
		return
	_shot_index = (_shot_index + 1) % shots.size()
	_current_shot = shots[_shot_index]
	_elapsed = 0.0
	if cam != null:
		cam.fov = _current_shot.fov
		cam.global_transform = _current_shot.sample(0.0)
		cam.reset_physics_interpolation()


func _apply_preview() -> void:
	var shots: Array[MenuCameraShot] = _get_shots()
	if shots.is_empty() or cam == null:
		return
	var idx: int = clampi(preview_shot, 0, shots.size() - 1)
	cam.fov = shots[idx].fov
	cam.global_transform = shots[idx].sample(preview_t)
