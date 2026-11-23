class_name WrenController
extends CharacterBody3D

## Wren: third-person courier protagonist with camera-relative ground movement,
## M02 Brass Lantern calm cone (signature mechanic), M01 Wooden Sword 3-hit combo,
## M05 Capelet, 5 hearts with invulnerability blink, and campfire respawn.

signal hearts_changed(current: float, max_hearts: float)
signal hurt_flash_requested
signal fainted
signal lantern_state_changed(raised: bool)
signal interact_prompt_changed(prompt_text: String, world_pos: Vector3)
signal attack_performed(combo_step: int)

@export var walk_speed: float = 2.2
@export var run_speed: float = 5.0
@export var accel_time: float = 0.08
@export var turn_rate: float = 16.0
@export var gravity: float = 22.0
@export var max_hearts: float = 5.0
@export var combo_swing_duration: float = 0.35
@export var combo_reset_window: float = 0.65
@export var lantern_blend_time: float = 0.25
@export var anim_blend_locomotion: float = 0.45
@export var anim_blend_contact: float = 0.22

@onready var visual_root: Node3D = $VisualRoot
@onready var model_instance: Node3D = $VisualRoot/WrenModel
@onready var camera_pivot: PlayerCamera = $CameraPivot
@onready var capelet_mount: GearMount = $VisualRoot/CapeletMount
@onready var sword_mount: GearMount = $VisualRoot/SwordMount
@onready var lantern_hip_mount: GearMount = $VisualRoot/LanternHipMount
@onready var lantern_raised_anchor: Node3D = $VisualRoot/LanternRaisedAnchor
@onready var lantern_node: Node3D = $VisualRoot/LanternHipMount/M02Lantern
@onready var lantern_cone_root: Node3D = $VisualRoot/LanternConeRoot
@onready var lantern_cone_mesh: MeshInstance3D = $VisualRoot/LanternConeRoot/ConeMesh
@onready var lantern_cone_area: Area3D = $VisualRoot/LanternConeRoot/LanternConeArea
@onready var lantern_motes: GPUParticles3D = $VisualRoot/LanternConeRoot/LanternMotes
@onready var sword_hitbox: Area3D = $VisualRoot/SwordHitbox
@onready var sword_slash_mesh: MeshInstance3D = $VisualRoot/SwordSlashMesh
@onready var interact_area: Area3D = $VisualRoot/InteractArea
@onready var shield_back_indicator: MeshInstance3D = get_node_or_null("VisualRoot/ShieldBackBadge") as MeshInstance3D

var hearts: float = 5.0
var controls_enabled: bool = true
var walk_toggled: bool = false
var is_lantern_raised: bool = false
var _forced_lantern: bool = false
var is_fainting: bool = false

var _model_yaw: float = PI # Facing -Z (north along forest path)
var _last_wish: Vector3 = Vector3.ZERO
var _anim_player: AnimationPlayer = null
var _skeleton: Skeleton3D = null
var _upper_arm_l_idx: int = -1
var _lower_arm_l_idx: int = -1
var _lantern_blend: float = 0.0
var _lantern_light: OmniLight3D = null
var _cone_shader_mat: ShaderMaterial = null
var _slash_shader_mat: ShaderMaterial = null

# 3-hit sword combo state
var _combo_step: int = 0
var _swing_timer: float = 0.0
var _combo_window_timer: float = 0.0
var _hit_accepted_ids: Dictionary = {}
var _queued_attack: bool = false

# Damage / invulnerability / knockback
var _invuln_timer: float = 0.0
var _knockback_vel: Vector3 = Vector3.ZERO
var _step_accum: float = 0.0
var _current_clip: String = ""
var _current_interactable: Node3D = null
var _campfire_spawn: Vector3 = Vector3(0.0, 0.1, 40.0)
var _hitstop_active: bool = false


func _ready() -> void:
	add_to_group(&"player")
	rotation = Vector3.ZERO
	hearts = max_hearts
	_setup_model_rig()
	_setup_materials_and_lights()
	if sword_hitbox != null:
		sword_hitbox.monitoring = false
	if lantern_cone_area != null:
		lantern_cone_area.monitoring = false
	if lantern_motes != null:
		lantern_motes.emitting = false
	if shield_back_indicator != null:
		shield_back_indicator.visible = Story.has_shield
	# Defensive guard: disable any StaticBody3D colliders on mounted gear under VisualRoot
	if visual_root != null:
		var q: Array[Node] = [visual_root]
		while not q.is_empty():
			var node: Node = q.pop_back()
			if node is StaticBody3D:
				(node as StaticBody3D).collision_layer = 0
				(node as StaticBody3D).collision_mask = 0
			for ch: Node in node.get_children():
				q.append(ch)
	if Story != null:
		Story.flags_changed.connect(_on_story_flags_changed)
	hearts_changed.emit(hearts, max_hearts)


func _setup_model_rig() -> void:
	if model_instance == null:
		return
	var stack: Array[Node] = [model_instance]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is AnimationPlayer and _anim_player == null:
			_anim_player = n as AnimationPlayer
		elif n is Skeleton3D and _skeleton == null:
			_skeleton = n as Skeleton3D
		elif n is MeshInstance3D:
			var mi: MeshInstance3D = n as MeshInstance3D
			# Hide pack weapon so ONLY M01 Wooden Sword appears (GDD Section 1.9)
			if mi.name.contains("Dagger") or mi.name.contains("Weapon"):
				mi.visible = false
		for c: Node in n.get_children():
			stack.append(c)

	if _skeleton != null:
		_upper_arm_l_idx = _skeleton.find_bone("UpperArm.L")
		_lower_arm_l_idx = _skeleton.find_bone("LowerArm.L")
		# Bind GearMounts to external skeleton cleanly
		for gm: GearMount in [capelet_mount, sword_mount, lantern_hip_mount]:
			if gm != null:
				gm.use_external_skeleton = true
				gm.external_skeleton = gm.get_path_to(_skeleton)
				gm._apply.call_deferred()

	if _anim_player != null:
		for clip: String in ["Idle", "Walk", "Run"]:
			if _anim_player.has_animation(clip):
				_anim_player.get_animation(clip).loop_mode = Animation.LOOP_LINEAR
		_play_clip("Idle", 0.0)


func _setup_materials_and_lights() -> void:
	if lantern_node != null:
		_lantern_light = lantern_node.get_node_or_null("OmniLight3D") as OmniLight3D
	if lantern_cone_mesh != null:
		_cone_shader_mat = lantern_cone_mesh.get_active_material(0) as ShaderMaterial
		if _cone_shader_mat == null:
			_cone_shader_mat = lantern_cone_mesh.material_override as ShaderMaterial
		if _cone_shader_mat != null:
			_cone_shader_mat = _cone_shader_mat.duplicate() as ShaderMaterial
			lantern_cone_mesh.material_override = _cone_shader_mat
			_cone_shader_mat.set_shader_parameter("intensity", 0.0)
	if sword_slash_mesh != null:
		_slash_shader_mat = sword_slash_mesh.material_override as ShaderMaterial
		if _slash_shader_mat != null:
			_slash_shader_mat = _slash_shader_mat.duplicate() as ShaderMaterial
			sword_slash_mesh.material_override = _slash_shader_mat
			_slash_shader_mat.set_shader_parameter("opacity", 0.0)
		sword_slash_mesh.visible = false


func _on_story_flags_changed() -> void:
	if shield_back_indicator != null:
		shield_back_indicator.visible = Story.has_shield


func set_campfire_spawn(pos: Vector3) -> void:
	_campfire_spawn = pos


func teleport_to(pos: Vector3, facing_yaw_rad: float = PI) -> void:
	global_position = pos
	rotation = Vector3.ZERO
	velocity = Vector3.ZERO
	_knockback_vel = Vector3.ZERO
	_model_yaw = facing_yaw_rad
	if visual_root != null:
		visual_root.rotation = Vector3(0.0, _model_yaw, 0.0)
	if camera_pivot != null:
		# Camera looks toward facing_yaw: in Godot -Z is forward for Camera3D, while Rogue faces +Z!
		# Rogue facing +Z with _model_yaw = PI faces world -Z (north). Camera with yaw=0 looks world -Z!
		camera_pivot.set_initial_yaw(facing_yaw_rad - PI)
	reset_physics_interpolation()


func heal_full() -> void:
	hearts = max_hearts
	is_fainting = false
	hearts_changed.emit(hearts, max_hearts)


func set_controls_enabled(enabled: bool) -> void:
	controls_enabled = enabled
	if camera_pivot != null:
		camera_pivot.set_input_enabled(enabled)
	if not enabled:
		is_lantern_raised = false
		_last_wish = Vector3.ZERO
		velocity.x = 0.0
		velocity.z = 0.0
		lantern_state_changed.emit(false)


func _unhandled_input(event: InputEvent) -> void:
	if not controls_enabled or is_fainting or get_tree().paused:
		return
	if event.is_action_pressed(&"walk_toggle"):
		walk_toggled = not walk_toggled
	elif event.is_action_pressed(&"attack"):
		_request_sword_attack()
	elif event.is_action_pressed(&"interact"):
		_try_interact()


func set_lantern_forced(raised: bool) -> void:
	_forced_lantern = raised
	is_lantern_raised = raised
	if raised:
		_lantern_blend = 1.0
	else:
		_lantern_blend = 0.0
	lantern_state_changed.emit(raised)


func _physics_process(delta: float) -> void:
	# CharacterBody3D NEVER rotates (player-controller.md Bug C fix)
	rotation = Vector3.ZERO

	# Invulnerability blink timer
	if _invuln_timer > 0.0:
		_invuln_timer = maxf(0.0, _invuln_timer - delta)
		if model_instance != null:
			model_instance.visible = _invuln_timer <= 0.0 or (int(_invuln_timer * 18.0) % 2 == 0)
	elif model_instance != null and not model_instance.visible:
		model_instance.visible = true

	if is_fainting:
		velocity.x = lerpf(velocity.x, 0.0, 1.0 - exp(-10.0 * delta))
		velocity.z = lerpf(velocity.z, 0.0, 1.0 - exp(-10.0 * delta))
		if not is_on_floor():
			velocity.y -= gravity * delta
		move_and_slide()
		return

	# Lantern hold state (Right Mouse Button or scripted story pose)
	var want_lantern: bool = _forced_lantern or (controls_enabled and Input.is_action_pressed(&"lantern") and _swing_timer <= 0.0)
	if want_lantern != is_lantern_raised:
		is_lantern_raised = want_lantern
		lantern_state_changed.emit(is_lantern_raised)
		if camera_pivot != null:
			camera_pivot.set_lantern_active(is_lantern_raised)
		if Audio != null:
			Audio.play_sfx(&"lantern_raise" if is_lantern_raised else &"lantern_lower", 0.94, 1.06, -6.0)
			Audio.set_lantern_hum(is_lantern_raised)

	# Camera-relative movement on ground plane
	var move_input: Vector2 = Vector2.ZERO
	if controls_enabled:
		move_input = Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	var wish: Vector3 = Vector3.ZERO
	if move_input.length_squared() > 0.001 and camera_pivot != null:
		var cam_b: Basis = camera_pivot.yaw_basis()
		wish = cam_b * Vector3(move_input.x, 0.0, move_input.y)
		wish.y = 0.0
		wish = wish.normalized() * minf(1.0, move_input.length())
	_last_wish = wish

	var speed: float = walk_speed if (walk_toggled or is_lantern_raised) else run_speed
	if _swing_timer > 0.0:
		speed *= 0.45
	var target_vel: Vector3 = wish * speed + _knockback_vel
	var accel_rate: float = 1.0 / maxf(0.01, accel_time)
	var k_vel: float = 1.0 - exp(-accel_rate * 3.0 * delta)
	velocity.x = lerpf(velocity.x, target_vel.x, k_vel)
	velocity.z = lerpf(velocity.z, target_vel.z, k_vel)
	_knockback_vel = _knockback_vel.lerp(Vector3.ZERO, 1.0 - exp(-10.0 * delta))

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = -0.2
	move_and_slide()

	# Model faces INPUT wish direction (never velocity!), yaw in own variable written as full triple euler
	if _last_wish.length_squared() > 0.002:
		var target_yaw: float = atan2(_last_wish.x, _last_wish.z)
		_model_yaw = lerp_angle(_model_yaw, target_yaw, 1.0 - exp(-turn_rate * delta))
	if visual_root != null:
		visual_root.rotation = Vector3(0.0, _model_yaw, 0.0)

	# Footstep cadence synced to movement
	var horiz_speed: float = Vector2(velocity.x, velocity.z).length()
	if is_on_floor() and horiz_speed > 0.6:
		_step_accum += horiz_speed * delta
		var stride: float = 1.45 if horiz_speed > 3.2 else 1.05
		if _step_accum >= stride:
			_step_accum = 0.0
			_play_footstep()

	# Update sword combo, lantern cone calm beam, and nearby interactables
	_update_sword_combo(delta)
	_update_lantern(delta)
	_update_locomotion_anim(horiz_speed)
	_update_interactables()


func _process(_delta: float) -> void:
	# Raise left arm cleanly when lantern is aloft (upper-body procedural pose over locomotion!)
	if _skeleton != null and _lantern_blend > 0.01:
		if _upper_arm_l_idx != -1:
			var rest_rot: Quaternion = _skeleton.get_bone_pose_rotation(_upper_arm_l_idx)
			var raised_rot: Quaternion = Quaternion.from_euler(Vector3(deg_to_rad(-115.0), deg_to_rad(15.0), deg_to_rad(25.0)))
			_skeleton.set_bone_pose_rotation(_upper_arm_l_idx, rest_rot.slerp(raised_rot, _lantern_blend))
		if _lower_arm_l_idx != -1:
			var l_rest: Quaternion = _skeleton.get_bone_pose_rotation(_lower_arm_l_idx)
			var l_raised: Quaternion = Quaternion.from_euler(Vector3(deg_to_rad(-30.0), 0.0, 0.0))
			_skeleton.set_bone_pose_rotation(_lower_arm_l_idx, l_rest.slerp(l_raised, _lantern_blend))


func _update_lantern(delta: float) -> void:
	var target_b: float = 1.0 if is_lantern_raised else 0.0
	var rate: float = 1.0 / maxf(0.05, lantern_blend_time)
	_lantern_blend = move_toward(_lantern_blend, target_b, rate * delta)
	var eased: float = _lantern_blend * _lantern_blend * (3.0 - 2.0 * _lantern_blend)

	# Smoothly move M02 Brass Lantern between Hip mount and Raised Left Hand anchor!
	if lantern_node != null and lantern_hip_mount != null and lantern_raised_anchor != null:
		if eased > 0.01:
			lantern_node.top_level = true
			var hip_xf: Transform3D = lantern_hip_mount.global_transform
			# Offset hanging straight down at hip
			var hip_pose: Transform3D = Transform3D(Basis.IDENTITY, hip_xf.origin + Vector3(0.0, 0.0, 0.0))
			var raised_pose: Transform3D = Transform3D(Basis.IDENTITY, lantern_raised_anchor.global_position)
			lantern_node.global_transform = hip_pose.interpolate_with(raised_pose, eased)
		else:
			if lantern_node.top_level:
				lantern_node.top_level = false
				lantern_hip_mount._apply()

	if _lantern_light != null:
		_lantern_light.light_energy = lerpf(1.4, 2.8, eased)
		_lantern_light.omni_range = lerpf(5.0, 9.0, eased)

	if _cone_shader_mat != null:
		_cone_shader_mat.set_shader_parameter("intensity", eased)
	if lantern_cone_mesh != null:
		lantern_cone_mesh.visible = eased > 0.02
	if lantern_motes != null:
		lantern_motes.emitting = eased > 0.35
	if lantern_cone_area != null:
		lantern_cone_area.monitoring = eased > 0.35

	# Apply calm beam to every monster & lantern trigger (Heartseed!) inside the 6m 60-deg cone!
	if eased > 0.35 and lantern_cone_area != null:
		for body: Node3D in lantern_cone_area.get_overlapping_bodies():
			if body.has_method("receive_lantern_light"):
				body.receive_lantern_light(delta, global_position)
		for area: Area3D in lantern_cone_area.get_overlapping_areas():
			if area.has_method("receive_lantern_light"):
				area.receive_lantern_light(delta, global_position)
			elif area.get_parent() != null and area.get_parent().has_method("receive_lantern_light"):
				area.get_parent().receive_lantern_light(delta, global_position)


func _request_sword_attack() -> void:
	if is_lantern_raised:
		return
	if _swing_timer > 0.0:
		if _swing_timer < combo_swing_duration * 0.55:
			_queued_attack = true
		return
	_start_combo_swing()


func _start_combo_swing() -> void:
	_combo_step = (_combo_step % 3) + 1
	_swing_timer = combo_swing_duration
	_combo_window_timer = combo_reset_window
	_queued_attack = false
	_hit_accepted_ids.clear()

	# Pick distinct animation clip per combo hit (horizontal, backhand, overhead)
	var clip: String = "Dagger_Attack"
	if _combo_step == 2:
		clip = "Dagger_Attack2"
	elif _combo_step == 3:
		clip = "Punch"
	_play_clip(clip, anim_blend_contact, true)

	if Audio != null:
		Audio.play_sfx(&"sword_swing", 0.90 + _combo_step * 0.06, 1.05 + _combo_step * 0.06, -4.0)
	if sword_slash_mesh != null:
		sword_slash_mesh.visible = true
		sword_slash_mesh.rotation = Vector3(
			deg_to_rad(-10.0 if _combo_step == 1 else (12.0 if _combo_step == 2 else 75.0)),
			0.0,
			deg_to_rad(0.0 if _combo_step == 1 else (180.0 if _combo_step == 2 else 90.0))
		)
	attack_performed.emit(_combo_step)


func _update_sword_combo(delta: float) -> void:
	if _swing_timer > 0.0:
		_swing_timer -= delta
		var t: float = 1.0 - clampf(_swing_timer / combo_swing_duration, 0.0, 1.0)
		var active_window: bool = t >= 0.20 and t <= 0.72
		if sword_hitbox != null:
			sword_hitbox.monitoring = active_window
			if active_window:
				_query_sword_hits()
		if _slash_shader_mat != null:
			_slash_shader_mat.set_shader_parameter("progress", clampf(t * 1.25, 0.0, 1.0))
			_slash_shader_mat.set_shader_parameter("opacity", sin(t * PI))
		if _swing_timer <= 0.0:
			if sword_hitbox != null:
				sword_hitbox.monitoring = false
			if sword_slash_mesh != null:
				sword_slash_mesh.visible = false
			if _queued_attack:
				_start_combo_swing()
	elif _combo_window_timer > 0.0:
		_combo_window_timer -= delta
		if _combo_window_timer <= 0.0:
			_combo_step = 0


func _query_sword_hits() -> void:
	if sword_hitbox == null:
		return
	var forward: Vector3 = Vector3(sin(_model_yaw), 0.0, cos(_model_yaw)).normalized()
	for body: Node3D in sword_hitbox.get_overlapping_bodies():
		var bid: int = body.get_instance_id()
		if _hit_accepted_ids.has(bid):
			continue
		if body.has_method("receive_sword_hit"):
			var accepted: bool = bool(body.receive_sword_hit(1, forward, _combo_step))
			if accepted:
				_hit_accepted_ids[bid] = true
				if Audio != null:
					Audio.play_sfx(&"sword_bonk", 0.88, 1.14, -2.0)
				if camera_pivot != null:
					camera_pivot.add_trauma(0.24 if _combo_step < 3 else 0.36)
				_trigger_hitstop()


func _trigger_hitstop() -> void:
	if _hitstop_active:
		return
	_hitstop_active = true
	var prev_scale: float = Engine.time_scale
	Engine.time_scale = 0.08
	await get_tree().create_timer(0.06, true, false, true).timeout
	if is_inside_tree():
		Engine.time_scale = prev_scale
	_hitstop_active = false


func take_damage(amount: float, knockback_dir: Vector3 = Vector3.ZERO) -> bool:
	if _invuln_timer > 0.0 or is_fainting or not controls_enabled:
		return false
	if Story != null and Story.god_mode:
		return false
	var dmg: float = amount * 0.5 if (Story != null and Story.has_shield) else amount
	hearts = maxf(0.0, hearts - dmg)
	_invuln_timer = 1.0
	if knockback_dir.length_squared() > 0.001:
		_knockback_vel = knockback_dir.normalized() * 5.2
	if Audio != null:
		Audio.play_sfx(&"player_hurt", 0.92, 1.08, -2.0)
	if camera_pivot != null:
		camera_pivot.add_trauma(0.42)
	hearts_changed.emit(hearts, max_hearts)
	hurt_flash_requested.emit()
	_play_clip("RecieveHit", 0.15, true)
	if hearts <= 0.0:
		_begin_faint()
	return true


func _begin_faint() -> void:
	is_fainting = true
	is_lantern_raised = false
	lantern_state_changed.emit(false)
	_play_clip("Death", 0.25, true)
	fainted.emit()


func _update_locomotion_anim(horiz_speed: float) -> void:
	if _swing_timer > 0.0 or is_fainting:
		return
	if horiz_speed > 3.1:
		_play_clip("Run", anim_blend_locomotion)
	elif horiz_speed > 0.35:
		_play_clip("Walk", anim_blend_locomotion)
	else:
		_play_clip("Idle", anim_blend_locomotion)


func _play_clip(clip_name: String, blend: float = 0.35, force_restart: bool = false) -> void:
	if _anim_player == null or not _anim_player.has_animation(clip_name):
		return
	if _current_clip == clip_name and _anim_player.is_playing() and not force_restart:
		return
	_current_clip = clip_name
	_anim_player.play(clip_name, blend)


func _play_footstep() -> void:
	if Audio == null:
		return
	var z: float = global_position.z
	if z < -72.0 and z > -88.0:
		Audio.play_sfx(&"step_wood", 0.90, 1.12, -10.0)
	elif z < -112.0 and z > -168.0:
		Audio.play_sfx(&"step_stone", 0.90, 1.12, -11.0)
	else:
		Audio.play_sfx(&"step_dirt", 0.88, 1.15, -10.0)


func _update_interactables() -> void:
	if interact_area == null or not controls_enabled:
		if _current_interactable != null:
			_current_interactable = null
			interact_prompt_changed.emit("", Vector3.ZERO)
		return
	var nearest: Node3D = null
	var best_d2: float = 999.0
	for body: Node3D in interact_area.get_overlapping_bodies():
		if body.has_method("can_interact") and body.can_interact():
			var d2: float = global_position.distance_squared_to(body.global_position)
			if d2 < best_d2:
				best_d2 = d2
				nearest = body
	for area: Area3D in interact_area.get_overlapping_areas():
		var owner_n: Node3D = area.get_parent() as Node3D
		if owner_n != null and owner_n.has_method("can_interact") and owner_n.can_interact():
			var d2: float = global_position.distance_squared_to(owner_n.global_position)
			if d2 < best_d2:
				best_d2 = d2
				nearest = owner_n
	_current_interactable = nearest
	if nearest != null:
		var lbl: String = String(nearest.get_interact_label()) if nearest.has_method("get_interact_label") else "E: Talk"
		interact_prompt_changed.emit(lbl, nearest.global_position + Vector3(0.0, 2.05, 0.0))
	else:
		interact_prompt_changed.emit("", Vector3.ZERO)


func _try_interact() -> void:
	if _current_interactable != null and _current_interactable.has_method("interact"):
		_current_interactable.interact(self)
