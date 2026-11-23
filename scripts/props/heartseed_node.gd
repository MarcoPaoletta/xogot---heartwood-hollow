class_name HeartseedController
extends Node3D

## The Heartseed resting in M06 The Heartwood's diamond socket.
## Starts dim violet (#52597B); when Wren raises her M02 Brass Lantern within 6 m
## it awakens over 1.5 s to radiant gold (#FDC10C), rises out of the socket, floats
## to the center of the Heart Chamber with orbiting light rings, and triggers the final choice.

signal awakened

@export var socket_pos: Vector3 = Vector3(0.0, 10.0, -222.8)
@export var chamber_float_pos: Vector3 = Vector3(0.0, 3.8, -206.0)

@onready var crystal_mesh: MeshInstance3D = $CrystalMesh
@onready var orbit_ring_a: MeshInstance3D = $OrbitRingA
@onready var orbit_ring_b: MeshInstance3D = $OrbitRingB
@onready var glow_light: OmniLight3D = $GlowLight
@onready var sparkles: GPUParticles3D = $Sparkles

var is_lit: bool = false
var _awakening: bool = false
var _bob_time: float = 0.0
var _base_pos: Vector3 = Vector3.ZERO
var _dim_mat: StandardMaterial3D = null
var _lit_mat: StandardMaterial3D = null


func _ready() -> void:
	_dim_mat = load("res://assets/modeler/_materials/seed_dim.tres") as StandardMaterial3D
	_lit_mat = load("res://assets/modeler/_materials/seed_lit.tres") as StandardMaterial3D
	reset_dim()


func reset_dim() -> void:
	is_lit = false
	_awakening = false
	global_position = socket_pos
	_base_pos = socket_pos
	if crystal_mesh != null and _dim_mat != null:
		crystal_mesh.material_override = _dim_mat
	if orbit_ring_a != null:
		orbit_ring_a.visible = false
	if orbit_ring_b != null:
		orbit_ring_b.visible = false
	if glow_light != null:
		glow_light.light_energy = 0.25
		glow_light.light_color = Color("#6B6F96")
		glow_light.omni_range = 6.0
	if sparkles != null:
		sparkles.emitting = false


func receive_lantern_light(_delta: float, source_pos: Vector3) -> void:
	if is_lit or _awakening:
		return
	var dist_xz: float = Vector2(source_pos.x - global_position.x, source_pos.z - global_position.z).length()
	if dist_xz <= 18.0:
		trigger_awaken()


func trigger_awaken() -> void:
	if is_lit or _awakening:
		return
	_awakening = true
	if Audio != null:
		Audio.play_sfx(&"seed_awaken", 1.0, 1.0, -2.0)
	if crystal_mesh != null and _lit_mat != null:
		var blend_mat: StandardMaterial3D = _dim_mat.duplicate() as StandardMaterial3D
		blend_mat.emission_enabled = true
		blend_mat.emission = Color("#FDC10C")
		blend_mat.emission_energy_multiplier = 0.0
		crystal_mesh.material_override = blend_mat
		var tw: Tween = create_tween()
		tw.set_parallel(true)
		tw.tween_property(blend_mat, "albedo_color", Color("#FDC10C"), 1.5).set_trans(Tween.TRANS_SINE)
		tw.tween_property(blend_mat, "emission_energy_multiplier", 2.6, 1.5).set_trans(Tween.TRANS_SINE)
		tw.tween_property(self, "global_position", chamber_float_pos, 1.65).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
		if glow_light != null:
			tw.tween_property(glow_light, "light_color", Color("#FFE070"), 1.5)
			tw.tween_property(glow_light, "light_energy", 4.2, 1.5)
			tw.tween_property(glow_light, "omni_range", 24.0, 1.5)
		tw.chain().tween_callback(func() -> void:
			is_lit = true
			_awakening = false
			_base_pos = chamber_float_pos
			if orbit_ring_a != null: orbit_ring_a.visible = true
			if orbit_ring_b != null: orbit_ring_b.visible = true
			if sparkles != null: sparkles.emitting = true
			if Story != null: Story.awaken_seed()
			awakened.emit()
		)


func set_lit_instant() -> void:
	is_lit = true
	_awakening = false
	global_position = chamber_float_pos
	_base_pos = chamber_float_pos
	if crystal_mesh != null and _lit_mat != null:
		crystal_mesh.material_override = _lit_mat
	if orbit_ring_a != null: orbit_ring_a.visible = true
	if orbit_ring_b != null: orbit_ring_b.visible = true
	if glow_light != null:
		glow_light.light_color = Color("#FFE070")
		glow_light.light_energy = 4.2
		glow_light.omni_range = 24.0
	if sparkles != null:
		sparkles.emitting = true


func _process(delta: float) -> void:
	_bob_time += delta
	if crystal_mesh != null:
		crystal_mesh.rotate_y(delta * (0.95 if is_lit else 0.18))
	if is_lit:
		global_position.y = _base_pos.y + sin(_bob_time * 1.8) * 0.25
		if orbit_ring_a != null:
			orbit_ring_a.rotate_y(delta * 1.1)
			orbit_ring_a.rotate_z(delta * 0.4)
		if orbit_ring_b != null:
			orbit_ring_b.rotate_y(-delta * 0.9)
			orbit_ring_b.rotate_x(delta * 0.5)
