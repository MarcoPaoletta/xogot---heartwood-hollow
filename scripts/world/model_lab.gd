class_name ModelLabController
extends Node3D

## Modeler workshop (GDD Section 1.3) and F4 Modeler Gallery (Section 12.4).
## Supports automated 6-camera + silhouette 1920x1080 review capture and
## interactive turntable gallery browsing of all 10 Xogot Modeler hero assets.

const GALLERY_ITEMS: Array[Dictionary] = [
	{"id": "m01_wooden_sword", "name": "Wren's Wooden Sword", "scene": "res://assets/modeler/m01_wooden_sword/m01_wooden_sword.tscn", "cam_dist": 1.35, "target_y": 0.25},
	{"id": "m02_brass_lantern", "name": "Wren's Brass Lantern", "scene": "res://assets/modeler/m02_brass_lantern/m02_brass_lantern.tscn", "cam_dist": 0.72, "target_y": -0.15},
	{"id": "m03_rock_small", "name": "Mossy Forest Rock (Small)", "scene": "res://assets/modeler/m03_mossy_rock/m03_rock_small.tscn", "cam_dist": 1.1, "target_y": 0.16},
	{"id": "m03_rock_medium", "name": "Mossy Forest Rock (Medium)", "scene": "res://assets/modeler/m03_mossy_rock/m03_rock_medium.tscn", "cam_dist": 2.2, "target_y": 0.36},
	{"id": "m03_rock_large", "name": "Mossy Forest Rock (Large)", "scene": "res://assets/modeler/m03_mossy_rock/m03_rock_large.tscn", "cam_dist": 4.2, "target_y": 0.72},
	{"id": "m04_tree_a", "name": "Old Forest Tree (Straight)", "scene": "res://assets/modeler/m04_forest_tree/m04_tree_a.tscn", "cam_dist": 18.0, "target_y": 6.5},
	{"id": "m04_tree_b", "name": "Old Forest Tree (Root Arch)", "scene": "res://assets/modeler/m04_forest_tree/m04_tree_b.tscn", "cam_dist": 18.5, "target_y": 6.5},
	{"id": "m05_capelet", "name": "Wren's Capelet", "scene": "res://assets/modeler/m05_capelet/m05_capelet.tscn", "cam_dist": 1.25, "target_y": -0.12},
	{"id": "m06_heartwood", "name": "The Heartwood", "scene": "res://assets/modeler/m06_heartwood/m06_heartwood.tscn", "cam_dist": 56.0, "target_y": 19.0},
	{"id": "m07_heartseed", "name": "The Heartseed", "scene": "res://assets/modeler/m07_heartseed/m07_heartseed.tscn", "cam_dist": 3.0, "target_y": 0.0},
	{"id": "m07_shard", "name": "Pip's Heartseed Shard", "scene": "res://assets/modeler/m07_heartseed/m07_shard.tscn", "cam_dist": 0.65, "target_y": 0.0},
	{"id": "m08_river_bridge", "name": "The River Bridge", "scene": "res://assets/modeler/m08_river_bridge/m08_river_bridge.tscn", "cam_dist": 16.0, "target_y": 0.6},
	{"id": "m09_honey_pot", "name": "The Honey Pot", "scene": "res://assets/modeler/m09_honey_pot/m09_honey_pot.tscn", "cam_dist": 0.55, "target_y": 0.09},
	{"id": "m10_guard_shield", "name": "The Old Guard's Shield", "scene": "res://assets/modeler/m10_guard_shield/m10_guard_shield.tscn", "cam_dist": 1.25, "target_y": 0.0},
]

@export var gallery_mode: bool = false
@export var turntable_speed_deg: float = 24.0
@export var return_scene_path: String = "res://scenes/main.tscn"

@onready var turntable: Node3D = $Turntable
@onready var specimen_slot: Node3D = $Turntable/SpecimenSlot
@onready var height_ruler: Node3D = $HeightRuler
@onready var wren_silhouette: Node3D = $WrenSilhouette
@onready var white_backdrop: MeshInstance3D = $WhiteBackdrop
@onready var backdrop: MeshInstance3D = $Backdrop
@onready var floor_mesh: MeshInstance3D = $Floor
@onready var plinth_mesh: MeshInstance3D = $Turntable/Plinth
@onready var world_env: WorldEnvironment = $WorldEnvironment
@onready var gallery_ui: CanvasLayer = $GalleryUI
@onready var title_label: Label = $GalleryUI/Card/VBox/TitleLabel
@onready var subtitle_label: Label = $GalleryUI/Card/VBox/SubtitleLabel
@onready var counter_label: Label = $GalleryUI/Card/VBox/CounterLabel

var _current_index: int = 0
var _current_specimen: Node3D = null
var _silhouette_mat: Material = null
var _saved_env_bg: int = 0
var _saved_env_color: Color = Color.WHITE
var _saved_env_fog: bool = false


func _ready() -> void:
	_silhouette_mat = load("res://assets/modeler/_materials/silhouette_black.tres")
	if white_backdrop != null:
		white_backdrop.visible = false
	if gallery_ui != null:
		gallery_ui.visible = gallery_mode
	if gallery_mode:
		_load_gallery_index(0)


func _process(delta: float) -> void:
	if gallery_mode and turntable != null:
		turntable.rotate_y(deg_to_rad(turntable_speed_deg) * delta)


func _unhandled_input(event: InputEvent) -> void:
	if not gallery_mode:
		return
	if event is InputEventKey:
		var kev: InputEventKey = event as InputEventKey
		if kev.pressed and not kev.echo:
			if kev.physical_keycode == KEY_RIGHT or kev.physical_keycode == KEY_D:
				_step_gallery(1)
				get_viewport().set_input_as_handled()
			elif kev.physical_keycode == KEY_LEFT or kev.physical_keycode == KEY_A:
				_step_gallery(-1)
				get_viewport().set_input_as_handled()
			elif kev.physical_keycode == KEY_ESCAPE or kev.physical_keycode == KEY_F4:
				exit_gallery()
				get_viewport().set_input_as_handled()


func enter_gallery(start_index: int = 0) -> void:
	gallery_mode = true
	if gallery_ui != null:
		gallery_ui.visible = true
	_load_gallery_index(start_index)


func exit_gallery() -> void:
	if ResourceLoader.exists(return_scene_path):
		get_tree().change_scene_to_file(return_scene_path)


func _step_gallery(delta_idx: int) -> void:
	var available: Array[Dictionary] = _available_gallery_items()
	if available.is_empty():
		return
	_current_index = posmod(_current_index + delta_idx, available.size())
	_show_gallery_item(available[_current_index], _current_index, available.size())


func _load_gallery_index(idx: int) -> void:
	var available: Array[Dictionary] = _available_gallery_items()
	if available.is_empty():
		return
	_current_index = clampi(idx, 0, available.size() - 1)
	_show_gallery_item(available[_current_index], _current_index, available.size())


func _available_gallery_items() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for item: Dictionary in GALLERY_ITEMS:
		var path: String = String(item["scene"])
		if ResourceLoader.exists(path):
			out.append(item)
	return out


func _show_gallery_item(item: Dictionary, idx: int, total: int) -> void:
	var path: String = String(item["scene"])
	load_specimen(path, Vector3.ZERO)
	if turntable != null:
		turntable.rotation = Vector3.ZERO
	var dist: float = float(item.get("cam_dist", 2.0))
	var ty: float = float(item.get("target_y", 0.5))
	var cam: Camera3D = get_node_or_null("RevThreeQuarter") as Camera3D
	if cam != null:
		cam.fov = 45.0
		cam.global_position = Vector3(dist * 0.72, ty + dist * 0.42, dist * 0.85)
		cam.look_at(Vector3(0.0, ty, 0.0), Vector3.UP)
		cam.current = true
	if title_label != null:
		title_label.text = "%s, made with Xogot Modeler" % String(item["name"])
	if subtitle_label != null:
		subtitle_label.text = "Left / Right: Next Model    |    Esc: Return to Game"
	if counter_label != null:
		counter_label.text = "%d / %d" % [idx + 1, total]
	var show_refs: bool = dist <= 6.0
	if height_ruler != null:
		height_ruler.visible = show_refs
	if wren_silhouette != null:
		wren_silhouette.visible = show_refs


func clear_specimen() -> void:
	if _current_specimen != null and is_instance_valid(_current_specimen):
		_current_specimen.queue_free()
		_current_specimen = null
	for c: Node in specimen_slot.get_children():
		c.queue_free()


func load_specimen(scene_path: String, lift_offset: Vector3 = Vector3.ZERO) -> Node3D:
	clear_specimen()
	var packed: PackedScene = load(scene_path) as PackedScene
	if packed == null:
		push_error("[ModelLab] Failed to load specimen: %s" % scene_path)
		return null
	var inst: Node3D = packed.instantiate() as Node3D
	specimen_slot.add_child(inst)
	inst.position = lift_offset
	_current_specimen = inst
	return inst


func measure_specimen_aabb() -> AABB:
	if _current_specimen == null:
		return AABB()
	var has_box: bool = false
	var combined: AABB = AABB()
	var stack: Array[Node] = [_current_specimen]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is MeshInstance3D:
			var mi: MeshInstance3D = n as MeshInstance3D
			if mi.visible and mi.mesh != null:
				var local_aabb: AABB = mi.mesh.get_aabb()
				var xf: Transform3D = mi.global_transform
				var corners: Array[Vector3] = [
					xf * Vector3(local_aabb.position.x, local_aabb.position.y, local_aabb.position.z),
					xf * Vector3(local_aabb.end.x, local_aabb.position.y, local_aabb.position.z),
					xf * Vector3(local_aabb.position.x, local_aabb.end.y, local_aabb.position.z),
					xf * Vector3(local_aabb.position.x, local_aabb.position.y, local_aabb.end.z),
					xf * Vector3(local_aabb.end.x, local_aabb.end.y, local_aabb.position.z),
					xf * Vector3(local_aabb.end.x, local_aabb.position.y, local_aabb.end.z),
					xf * Vector3(local_aabb.position.x, local_aabb.end.y, local_aabb.end.z),
					xf * Vector3(local_aabb.end.x, local_aabb.end.y, local_aabb.end.z),
				]
				for p: Vector3 in corners:
					if not has_box:
						combined = AABB(p, Vector3.ZERO)
						has_box = true
					else:
						combined = combined.expand(p)
		for child: Node in n.get_children():
			stack.append(child)
	return combined


func count_specimen_triangles() -> int:
	if _current_specimen == null:
		return 0
	var total: int = 0
	var stack: Array[Node] = [_current_specimen]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is MeshInstance3D:
			var mi: MeshInstance3D = n as MeshInstance3D
			if mi.mesh != null:
				for s: int in range(mi.mesh.get_surface_count()):
					var arrays: Array = mi.mesh.surface_get_arrays(s)
					var indices: Variant = arrays[Mesh.ARRAY_INDEX]
					if indices is PackedInt32Array and (indices as PackedInt32Array).size() > 0:
						total += floori(float((indices as PackedInt32Array).size()) / 3.0)
					else:
						var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
						total += floori(float(verts.size()) / 3.0)
		for child: Node in n.get_children():
			stack.append(child)
	return total


func frame_review_cameras(aabb: AABB, gameplay_dist: float = 3.5, far_dist: float = 8.0) -> void:
	var center: Vector3 = aabb.get_center()
	var max_dim: float = maxf(maxf(aabb.size.x, aabb.size.y), maxf(aabb.size.z, 0.2))
	var radius: float = maxf(aabb.size.length() * 0.5, 0.15)
	# Fit full height comfortably inside 40 deg vertical FOV (tan(20 deg) = 0.364) with ~28% margin
	var dist: float = maxf(max_dim * 2.05, radius * 2.85)
	var set_cam := func(cam_name: String, pos: Vector3, fov_val: float, up_vec: Vector3 = Vector3.UP) -> void:
		var c: Camera3D = get_node_or_null(cam_name) as Camera3D
		if c != null:
			c.fov = fov_val
			c.global_position = pos
			c.look_at(center, up_vec)
	set_cam.call("RevFront", center + Vector3(0.0, max_dim * 0.06, dist), 40.0)
	set_cam.call("RevSide", center + Vector3(dist, max_dim * 0.06, 0.0), 40.0)
	set_cam.call("RevThreeQuarter", center + Vector3(dist * 0.72, max_dim * 0.42, dist * 0.78), 40.0)
	set_cam.call("RevTop", center + Vector3(0.0, dist * 1.15, 0.02), 40.0, Vector3.FORWARD)
	# RevGameplay: exact gameplay camera angle (50 deg FOV, ~16 deg pitch down)
	var gp_d: float = maxf(gameplay_dist, max_dim * 1.9)
	set_cam.call("RevGameplay", center + Vector3(0.0, gp_d * 0.30, gp_d * 0.95), 50.0)
	# RevFar: asset at concept-frame distance
	var far_d: float = maxf(far_dist, max_dim * 3.5)
	set_cam.call("RevFar", center + Vector3(far_d * 0.25, far_d * 0.22, far_d * 0.94), 50.0)


func set_silhouette_mode(enabled: bool) -> void:
	if _current_specimen == null:
		return
	var stack: Array[Node] = [_current_specimen]
	while not stack.is_empty():
		var n: Node = stack.pop_back()
		if n is MeshInstance3D:
			var mi: MeshInstance3D = n as MeshInstance3D
			mi.material_override = _silhouette_mat if enabled else null
		elif n is Light3D:
			(n as Light3D).visible = not enabled
		elif n is Sprite3D:
			(n as Sprite3D).visible = not enabled
		for child: Node in n.get_children():
			stack.append(child)
	if height_ruler != null:
		height_ruler.visible = not enabled
	if wren_silhouette != null:
		wren_silhouette.visible = not enabled
	if floor_mesh != null:
		floor_mesh.visible = not enabled
	if plinth_mesh != null:
		plinth_mesh.visible = not enabled
	if backdrop != null:
		backdrop.visible = not enabled
	if white_backdrop != null:
		white_backdrop.visible = false
	if world_env != null and world_env.environment != null:
		var env: Environment = world_env.environment
		if enabled:
			_saved_env_bg = env.background_mode
			_saved_env_color = env.background_color
			_saved_env_fog = env.fog_enabled
			env.background_mode = Environment.BG_COLOR
			env.background_color = Color.WHITE
			env.fog_enabled = false
			env.glow_enabled = false
		else:
			env.background_mode = _saved_env_bg as Environment.BGMode
			env.background_color = _saved_env_color
			env.fog_enabled = _saved_env_fog
			env.glow_enabled = true
