class_name ForestMonster
extends CharacterBody3D

## Cozy forest monster (5 archetypes + Chief Bumble boss).
## Calmed by Wren's M02 Brass Lantern (1.2 s beam -> pop of hearts & happy hop),
## or bonked by Wren's M01 Wooden Sword (3 hits, Bumble 6 -> poof into sparkles & runs off).

signal calmed(monster: ForestMonster)
signal poofed(monster: ForestMonster)
signal defeated_boss(monster: ForestMonster)

enum Archetype { BLOB, WINGED, MUSHROOM, FURBALL, ROLLER, CHIEF_BUMBLE }
enum State { IDLE, ALERT, ATTACK, STUNNED, CALM, POOFED, DANCE }

@export var archetype: Archetype = Archetype.BLOB
@export var max_hp: int = 3
@export var calm_duration: float = 1.2
@export var notice_radius: float = 8.0
@export var move_speed: float = 2.6
@export var start_grumpy: bool = true
@export var is_camp_monster: bool = false
@export var is_boss: bool = false
@export var body_tint: Color = Color.WHITE

@onready var model_holder: Node3D = $ModelHolder
@onready var calm_ring: MeshInstance3D = $CalmRing
@onready var anger_mark: Node3D = $AngerMark
@onready var heart_particles: GPUParticles3D = $HeartParticles
@onready var sparkle_particles: GPUParticles3D = $SparkleParticles
@onready var spore_ring: MeshInstance3D = get_node_or_null("SporeRing") as MeshInstance3D

static var _cached_flash_mat: StandardMaterial3D = null

var state: State = State.IDLE
var hp: int = 3
var calm_progress: float = 0.0
var is_active_hostile: bool = true

var _home_pos: Vector3 = Vector3.ZERO
var _anim_player: AnimationPlayer = null
var _model_meshes: Array[MeshInstance3D] = []
var _orig_overrides: Array[Material] = []
var _calm_mat: ShaderMaterial = null
var _knockback_vel: Vector3 = Vector3.ZERO
var _state_timer: float = 0.0
var _attack_cooldown: float = 0.0
var _windup_timer: float = 0.0
var _charge_dir: Vector3 = Vector3.ZERO
var _lantern_touched_this_frame: bool = false
var _wander_dir: Vector3 = Vector3.FORWARD
var _base_model_scale: Vector3 = Vector3.ONE
var _current_clip: String = ""
var _flash_timer: float = 0.0
var _dance_angle: float = 0.0
var _dance_center: Vector3 = Vector3.ZERO
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	add_to_group(&"monsters")
	_rng.randomize()
	_home_pos = global_position
	hp = max_hp
	is_active_hostile = start_grumpy
	if _cached_flash_mat == null:
		_cached_flash_mat = StandardMaterial3D.new()
		_cached_flash_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		_cached_flash_mat.albedo_color = Color.WHITE
		_cached_flash_mat.emission_enabled = true
		_cached_flash_mat.emission = Color.WHITE
		_cached_flash_mat.emission_energy_multiplier = 1.6

	_setup_model()
	_setup_vfx()
	_update_anger_mark()


func _setup_model() -> void:
	if model_holder == null:
		return
	_base_model_scale = model_holder.scale
	var tint_mat_cache: Dictionary = {}
	var stack: Array[Node] = [model_holder]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is AnimationPlayer and _anim_player == null:
			_anim_player = n as AnimationPlayer
		elif n is MeshInstance3D:
			var mi: MeshInstance3D = n as MeshInstance3D
			# Hide loose Icosphere helper mesh present in Quaternius monster GLTFs (MEASUREMENTS.md trap!)
			if mi.name.to_lower().contains("icosphere"):
				mi.visible = false
				continue
			if body_tint != Color.WHITE and mi.mesh != null:
				for s: int in range(mi.mesh.get_surface_count()):
					var orig: Material = mi.get_active_material(s)
					if orig is StandardMaterial3D:
						var key: int = orig.get_instance_id()
						if not tint_mat_cache.has(key):
							var dup: StandardMaterial3D = (orig as StandardMaterial3D).duplicate() as StandardMaterial3D
							dup.albedo_color = dup.albedo_color.lerp(body_tint, 0.72)
							tint_mat_cache[key] = dup
						mi.set_surface_override_material(s, tint_mat_cache[key] as Material)
			_model_meshes.append(mi)
			_orig_overrides.append(mi.material_override)
		for c: Node in n.get_children():
			stack.append(c)

	if _anim_player != null:
		for nm: StringName in _anim_player.get_animation_list():
			var s_nm: String = String(nm)
			if s_nm.contains("Idle") or s_nm.contains("Walk") or s_nm.contains("Run") or s_nm.contains("Flying") or s_nm.contains("Dance"):
				_anim_player.get_animation(nm).loop_mode = Animation.LOOP_LINEAR
		_play_best_clip(["Idle", "Flying_Idle", "Flying"])


func _setup_vfx() -> void:
	if calm_ring != null:
		var m: Material = calm_ring.material_override
		if m is ShaderMaterial:
			_calm_mat = (m as ShaderMaterial).duplicate() as ShaderMaterial
			calm_ring.material_override = _calm_mat
			_calm_mat.set_shader_parameter("progress", 0.0)
		calm_ring.visible = false
	if spore_ring != null:
		spore_ring.visible = false


func set_hostile_mode(hostile: bool, force_reset: bool = false) -> void:
	if force_reset and hostile:
		state = State.ALERT
		hp = max_hp
		visible = true
		collision_layer = 8
		collision_mask = 11
		set_physics_process(true)
	elif state == State.CALM or state == State.POOFED or state == State.DANCE:
		return
	is_active_hostile = hostile
	_update_anger_mark()


func start_camp_dance(center: Vector3, angle_offset: float) -> void:
	state = State.DANCE
	is_active_hostile = false
	_dance_center = center
	_dance_angle = angle_offset
	_update_anger_mark()
	if calm_ring != null:
		calm_ring.visible = false
	_play_best_clip(["Dance", "Jump", "Yes", "Wave", "Idle"])


func start_calm_idle() -> void:
	state = State.CALM
	is_active_hostile = false
	_update_anger_mark()
	if calm_ring != null:
		calm_ring.visible = false
	_play_best_clip(["Idle", "Flying_Idle", "Flying"])


func receive_lantern_light(delta: float, _source_pos: Vector3) -> void:
	if state == State.CALM or state == State.POOFED or state == State.DANCE:
		return
	_lantern_touched_this_frame = true
	if is_boss:
		# Lantern stuns Chief Bumble for 1s, cannot calm him (GDD Section 4.4)
		if state != State.STUNNED and _attack_cooldown <= 0.0:
			state = State.STUNNED
			_state_timer = 1.0
			_attack_cooldown = 2.6
			_trigger_flash(0.14)
			_play_best_clip(["HitReact", "HitRecieve", "No", "Idle"])
			if Audio != null:
				Audio.play_sfx(&"monster_grumpy", 1.15, 1.30, -5.0)
		return

	calm_progress = clampf(calm_progress + delta / maxf(0.15, calm_duration), 0.0, 1.0)
	if calm_ring != null:
		calm_ring.visible = true
		if _calm_mat != null:
			_calm_mat.set_shader_parameter("progress", calm_progress)
	if calm_progress >= 1.0:
		_become_calm()


func receive_sword_hit(dmg: int, knockback_dir: Vector3, _combo_step: int) -> bool:
	if state == State.CALM or state == State.POOFED or state == State.DANCE:
		return false
	if not is_active_hostile:
		return false
	hp -= dmg
	_knockback_vel = knockback_dir.normalized() * (3.0 if is_boss else 6.8)
	_trigger_flash(0.09)
	_squash_pop()
	_play_best_clip(["HitRecieve", "HitReact", "No"])
	if hp <= 0:
		_poof_away()
	return true


func _become_calm() -> void:
	state = State.CALM
	is_active_hostile = false
	calm_progress = 1.0
	_update_anger_mark()
	if calm_ring != null:
		calm_ring.visible = false
	if heart_particles != null:
		heart_particles.restart()
		heart_particles.emitting = true
	_squash_pop(Vector3(1.22, 1.25, 1.22))
	_play_best_clip(["Jump", "Dance", "Yes", "Wave", "Idle"])
	if Audio != null:
		Audio.play_sfx(&"calm_chime", 0.94, 1.12, -4.0)
		Audio.play_sfx(&"monster_happy", 0.95, 1.15, -6.0)
	if Story != null:
		Story.record_monster_calmed()
	# Pick happy wander direction away from the path center
	var angle: float = _rng.randf_range(0.0, TAU)
	_wander_dir = Vector3(cos(angle), 0.0, sin(angle))
	_state_timer = 4.0
	calmed.emit(self)


func _poof_away() -> void:
	state = State.POOFED
	is_active_hostile = false
	_update_anger_mark()
	if calm_ring != null:
		calm_ring.visible = false
	if sparkle_particles != null:
		sparkle_particles.restart()
		sparkle_particles.emitting = true
	if Audio != null:
		Audio.play_sfx(&"sparkle_poof", 0.95, 1.12, -3.0)
	if Story != null:
		Story.record_monster_bonked()
	if is_boss:
		defeated_boss.emit(self)
		# Chief Bumble stomps off toward east woods rather than vanishing instantly
		_state_timer = 2.6
		poofed.emit(self)
		return
	# Cozy poof: run/hop away and fade out (never death/blood!)
	var tw: Tween = create_tween()
	tw.tween_property(model_holder, "scale", Vector3(0.05, 0.05, 0.05), 0.55).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tw.tween_callback(func() -> void:
		visible = false
		collision_layer = 0
		collision_mask = 0
		set_physics_process(false)
	)
	poofed.emit(self)


func _physics_process(delta: float) -> void:
	# Stay peaceful idle during Title Screen and open Dialogue so monsters never cheap-shot Wren!
	if Story != null and (not Story.run_active or Story.dialogue_open):
		velocity.x = 0.0
		velocity.z = 0.0
		if not is_on_floor():
			velocity.y -= 20.0 * delta
		move_and_slide()
		return

	if _flash_timer > 0.0:
		_flash_timer -= delta
		if _flash_timer <= 0.0:
			_clear_flash()

	if _attack_cooldown > 0.0:
		_attack_cooldown = maxf(0.0, _attack_cooldown - delta)

	# Decay lantern progress gently when beam moves away
	if not _lantern_touched_this_frame and calm_progress > 0.0 and state != State.CALM:
		calm_progress = maxf(0.0, calm_progress - delta * 0.45)
		if _calm_mat != null:
			_calm_mat.set_shader_parameter("progress", calm_progress)
		if calm_progress <= 0.01 and calm_ring != null:
			calm_ring.visible = false
	_lantern_touched_this_frame = false

	var player: Node3D = get_tree().get_first_node_in_group(&"player") as Node3D

	match state:
		State.IDLE, State.ALERT:
			_process_hostile_ai(delta, player)
		State.ATTACK:
			_process_attack(delta, player)
		State.STUNNED:
			_state_timer -= delta
			velocity.x = lerpf(velocity.x, _knockback_vel.x, 1.0 - exp(-8.0 * delta))
			velocity.z = lerpf(velocity.z, _knockback_vel.z, 1.0 - exp(-8.0 * delta))
			if _state_timer <= 0.0:
				state = State.ALERT
		State.CALM:
			_state_timer -= delta
			if _state_timer > 0.0:
				velocity.x = _wander_dir.x * 1.45
				velocity.z = _wander_dir.z * 1.45
				_face_dir(_wander_dir, delta)
			else:
				velocity.x = lerpf(velocity.x, 0.0, 1.0 - exp(-6.0 * delta))
				velocity.z = lerpf(velocity.z, 0.0, 1.0 - exp(-6.0 * delta))
				_play_best_clip(["Idle", "Flying_Idle", "Flying"])
		State.DANCE:
			_dance_angle += delta * 1.35
			var r: float = 3.2
			var tgt: Vector3 = _dance_center + Vector3(cos(_dance_angle) * r, 0.0, sin(_dance_angle) * r)
			var to_t: Vector3 = tgt - global_position
			to_t.y = 0.0
			velocity.x = to_t.x * 2.5
			velocity.z = to_t.z * 2.5
			_face_dir(to_t, delta)
		State.POOFED:
			if is_boss and _state_timer > 0.0:
				_state_timer -= delta
				var flee: Vector3 = Vector3(1.0, 0.0, -0.3).normalized()
				velocity.x = flee.x * 4.2
				velocity.z = flee.z * 4.2
				_face_dir(flee, delta)
				_play_best_clip(["Run", "Walk"])
				if _state_timer <= 0.0:
					visible = false
					collision_layer = 0
					set_physics_process(false)
			else:
				velocity = Vector3.ZERO

	_knockback_vel = _knockback_vel.lerp(Vector3.ZERO, 1.0 - exp(-9.0 * delta))
	if not is_on_floor():
		velocity.y -= 20.0 * delta
	else:
		velocity.y = -0.2
	move_and_slide()


func _process_hostile_ai(delta: float, player: Node3D) -> void:
	if not is_active_hostile or player == null or (Story != null and Story.dialogue_open):
		velocity.x = lerpf(velocity.x, _knockback_vel.x, 1.0 - exp(-8.0 * delta))
		velocity.z = lerpf(velocity.z, _knockback_vel.z, 1.0 - exp(-8.0 * delta))
		_play_best_clip(["Idle", "Flying_Idle", "Flying"])
		return

	var to_p: Vector3 = player.global_position - global_position
	to_p.y = 0.0
	var dist: float = to_p.length()

	if dist > notice_radius and global_position.distance_to(_home_pos) > 1.0:
		var back: Vector3 = _home_pos - global_position
		back.y = 0.0
		if back.length() > 0.5:
			var bd: Vector3 = back.normalized()
			velocity.x = bd.x * move_speed * 0.65 + _knockback_vel.x
			velocity.z = bd.z * move_speed * 0.65 + _knockback_vel.z
			_face_dir(bd, delta)
			_play_best_clip(["Walk", "Flying", "Idle"])
		return

	if dist > notice_radius:
		velocity.x = lerpf(velocity.x, _knockback_vel.x, 1.0 - exp(-8.0 * delta))
		velocity.z = lerpf(velocity.z, _knockback_vel.z, 1.0 - exp(-8.0 * delta))
		_play_best_clip(["Idle", "Flying_Idle", "Flying"])
		return

	state = State.ALERT
	var dir: Vector3 = to_p.normalized() if dist > 0.01 else Vector3.FORWARD
	_face_dir(dir, delta)

	match archetype:
		Archetype.MUSHROOM:
			# Stays put and puffs a spore cloud when player comes near (< 4.2m)
			velocity.x = _knockback_vel.x
			velocity.z = _knockback_vel.z
			if dist < 4.2 and _attack_cooldown <= 0.0:
				_start_spore_puff(player)
			else:
				_play_best_clip(["Idle", "Bite_InPlace"])
		Archetype.FURBALL:
			# 0.8 s windup then fast charge!
			if dist < 6.5 and _attack_cooldown <= 0.0:
				state = State.ATTACK
				_windup_timer = 0.8
				_state_timer = 0.65
				_charge_dir = dir
				_play_best_clip(["Bite_InPlace", "No", "Idle"])
			else:
				velocity.x = dir.x * move_speed * 0.85 + _knockback_vel.x
				velocity.z = dir.z * move_speed * 0.85 + _knockback_vel.z
				_play_best_clip(["Walk", "Jump"])
		_:
			# BLOB (hops), WINGED (swoops), ROLLER (rolls), CHIEF_BUMBLE (stomps)
			velocity.x = dir.x * move_speed + _knockback_vel.x
			velocity.z = dir.z * move_speed + _knockback_vel.z
			_play_best_clip(["Walk", "Run", "Flying", "Jump"])
			var hit_dist: float = 1.95 if is_boss else 1.25
			if dist < hit_dist and _attack_cooldown <= 0.0:
				_attack_cooldown = 1.25
				_play_best_clip(["Bite_Front", "Punch", "Headbutt"])
				if player.has_method("take_damage"):
					player.take_damage(1.0, dir)


func _process_attack(delta: float, player: Node3D) -> void:
	if _windup_timer > 0.0:
		_windup_timer -= delta
		velocity.x = _knockback_vel.x
		velocity.z = _knockback_vel.z
		# Telegraph shake during 0.8s windup
		if model_holder != null:
			model_holder.position.x = sin(_windup_timer * 48.0) * 0.08
		return
	if model_holder != null:
		model_holder.position.x = 0.0
	_state_timer -= delta
	velocity.x = _charge_dir.x * (move_speed * 2.35) + _knockback_vel.x
	velocity.z = _charge_dir.z * (move_speed * 2.35) + _knockback_vel.z
	_play_best_clip(["Jump", "Walk"])
	if player != null and global_position.distance_to(player.global_position) < 1.35:
		if player.has_method("take_damage"):
			player.take_damage(1.0, _charge_dir)
		_state_timer = 0.0
	if _state_timer <= 0.0:
		_attack_cooldown = 1.8
		state = State.ALERT


func _start_spore_puff(player: Node3D) -> void:
	_attack_cooldown = 2.6
	_play_best_clip(["Bite_InPlace", "Jump"])
	if spore_ring != null:
		spore_ring.visible = true
		spore_ring.scale = Vector3(0.2, 0.2, 0.2)
		var tw: Tween = create_tween()
		tw.tween_property(spore_ring, "scale", Vector3(2.8, 0.5, 2.8), 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		tw.tween_callback(func() -> void:
			if is_instance_valid(player) and global_position.distance_to(player.global_position) < 2.85:
				if player.has_method("take_damage"):
					player.take_damage(1.0, (player.global_position - global_position).normalized())
		)
		tw.tween_interval(0.35)
		tw.tween_callback(func() -> void: spore_ring.visible = false)


func _face_dir(dir: Vector3, delta: float) -> void:
	if dir.length_squared() < 0.001 or model_holder == null:
		return
	var target_yaw: float = atan2(dir.x, dir.z)
	model_holder.rotation.y = lerp_angle(model_holder.rotation.y, target_yaw, 1.0 - exp(-10.0 * delta))


func _update_anger_mark() -> void:
	if anger_mark != null:
		anger_mark.visible = is_active_hostile and state != State.CALM and state != State.POOFED and state != State.DANCE


func _trigger_flash(duration: float) -> void:
	_flash_timer = duration
	for mi: MeshInstance3D in _model_meshes:
		mi.material_override = _cached_flash_mat


func _clear_flash() -> void:
	for i: int in range(_model_meshes.size()):
		_model_meshes[i].material_override = _orig_overrides[i]


func _squash_pop(peak: Vector3 = Vector3(1.26, 0.74, 1.26)) -> void:
	if model_holder == null:
		return
	var tw: Tween = create_tween()
	tw.tween_property(model_holder, "scale", _base_model_scale * peak, 0.08).set_trans(Tween.TRANS_QUAD)
	tw.tween_property(model_holder, "scale", _base_model_scale, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func _play_best_clip(candidates: Array[String]) -> void:
	if _anim_player == null:
		return
	for c: String in candidates:
		if _anim_player.has_animation(c):
			if _current_clip != c or not _anim_player.is_playing():
				_current_clip = c
				_anim_player.play(c, 0.25)
			return
