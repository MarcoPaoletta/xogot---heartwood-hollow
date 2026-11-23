class_name CastNPC
extends StaticBody3D

## Reusable interactable story character (Mayor Hollis, Mother Clove, Bramble,
## Captain Rook, Pip, Moss, Chief Bumble). Turns toward Wren within 3 m and
## emits talked_to when Wren presses E within 2.5 m.

signal talked_to(npc_id: String, npc: CastNPC)

@export var npc_id: String = "mayor_hollis"
@export var display_name: String = "Mayor Hollis"
@export var interact_prompt: String = "E: Talk"
@export var interact_enabled: bool = true
@export var turn_radius: float = 3.5
@export var tint_color: Color = Color.WHITE

@onready var model_holder: Node3D = $ModelHolder
@onready var marker_label: Label3D = get_node_or_null("NameLabel") as Label3D

var _anim_player: AnimationPlayer = null
var _base_yaw: float = 0.0
var _current_yaw: float = 0.0


func _ready() -> void:
	add_to_group(&"npcs")
	if model_holder != null:
		_base_yaw = model_holder.rotation.y
		_current_yaw = _base_yaw
		_setup_model()
	if marker_label != null:
		marker_label.text = display_name


func _setup_model() -> void:
	var tint_cache: Dictionary = {}
	var stack: Array[Node] = [model_holder]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is AnimationPlayer and _anim_player == null:
			_anim_player = n as AnimationPlayer
		elif n is MeshInstance3D:
			var mi: MeshInstance3D = n as MeshInstance3D
			var low: String = mi.name.to_lower()
			# Hide pack weapons/shields/helpers per GDD Section 1.9
			if low.contains("icosphere") or low.contains("sword") or low.contains("dagger") or low.contains("staff") or low.contains("bow") or low.contains("shield") or low.contains("weapon"):
				mi.visible = false
				continue
			if tint_color != Color.WHITE and mi.mesh != null:
				for s: int in range(mi.mesh.get_surface_count()):
					var orig: Material = mi.get_active_material(s)
					if orig is StandardMaterial3D:
						var key: int = orig.get_instance_id()
						if not tint_cache.has(key):
							var dup: StandardMaterial3D = (orig as StandardMaterial3D).duplicate() as StandardMaterial3D
							dup.albedo_color = dup.albedo_color.lerp(tint_color, 0.55)
							tint_cache[key] = dup
						mi.set_surface_override_material(s, tint_cache[key] as Material)
		for c: Node in n.get_children():
			stack.append(c)

	if _anim_player != null:
		for nm: StringName in _anim_player.get_animation_list():
			var s_nm: String = String(nm)
			if s_nm.contains("Idle") or s_nm.contains("Dance"):
				_anim_player.get_animation(nm).loop_mode = Animation.LOOP_LINEAR
		play_gesture("Idle")


func _process(delta: float) -> void:
	var player: Node3D = get_tree().get_first_node_in_group(&"player") as Node3D
	var target_yaw: float = _base_yaw
	if player != null and visible:
		var to_p: Vector3 = player.global_position - global_position
		to_p.y = 0.0
		if to_p.length() <= turn_radius and to_p.length() > 0.15:
			target_yaw = atan2(to_p.x, to_p.z) - rotation.y
	_current_yaw = lerp_angle(_current_yaw, target_yaw, 1.0 - exp(-6.5 * delta))
	if model_holder != null:
		model_holder.rotation = Vector3(0.0, _current_yaw, 0.0)


func can_interact() -> bool:
	return visible and interact_enabled


func get_interact_label() -> String:
	return "%s (%s)" % [interact_prompt, display_name]


func interact(_wren: Node3D) -> void:
	play_gesture("Wave")
	talked_to.emit(npc_id, self)


func play_gesture(pref: String) -> void:
	if _anim_player == null:
		return
	var fallbacks: Array[String] = [pref, "Wave", "Yes", "PickUp", "Idle"]
	for c: String in fallbacks:
		if _anim_player.has_animation(c):
			_anim_player.play(c, 0.35)
			return
