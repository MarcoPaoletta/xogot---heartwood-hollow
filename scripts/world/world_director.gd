class_name WorldDirector
extends Node3D

## Coordinates the continuous 4-zone world of Heartwood Hollow:
## zone transitions, atmosphere/fog shifts, story dialogues & decisions,
## Chief Bumble brawl/honey branches, Pip/Rook fog/brazier branches,
## Heartseed awakening, 3 endings + 3-shot epilogues, campfire respawns,
## and F1/F2/F4 presenter shortcuts.

signal dialogue_opened(speaker: String, lines: Array[String], choices: Array[Dictionary])
signal message_card_opened(text: String)
signal epilogue_line_shown(text: String)
signal epilogue_finished
signal hint_changed(text: String)
signal showcase_cam_changed(label: String)

@export var zone_spawns: Dictionary = {
	1: Vector3(0.0, 0.2, 41.0),
	2: Vector3(0.0, 0.2, -68.0),
	3: Vector3(0.0, 0.2, -118.0),
	4: Vector3(0.0, 0.2, -192.0),
}

@onready var world_env: WorldEnvironment = $WorldEnvironment
@onready var sun_light: DirectionalLight3D = $Sun
@onready var wren: WrenController = $Wren
@onready var menu_director: MenuCameraDirector = $MenuCameraDirector
@onready var zone1: Node3D = $Zone1_ThistlePath
@onready var zone2: Node3D = $Zone2_BridgeCamp
@onready var zone3: Node3D = $Zone3_FoggyRuins
@onready var zone4: Node3D = $Zone4_HeartChamber
@onready var heartseed: HeartseedController = $Zone4_HeartChamber/Heartseed
@onready var cam_path: Camera3D = $Zone1_ThistlePath/ConceptCam_Path
@onready var cam_bridge: Camera3D = $Zone2_BridgeCamp/ConceptCam_Bridge
@onready var cam_chamber: Camera3D = $Zone4_HeartChamber/ConceptCam_Chamber
@onready var showcase_orbit_cam: Camera3D = $Zone4_HeartChamber/HeartwoodOrbitCam

var _in_gameplay: bool = false
var _showcase_index: int = -1
var _orbit_angle: float = 0.0
var _active_choice_context: String = ""
var _bridge_trigger_fired: bool = false
var _pip_trigger_fired: bool = false
var _chamber_choice_opened: bool = false
var _first_blob_calmed: bool = false
var _first_swing_done: bool = false
var _epilogue_running: bool = false
var _fog_tween: Tween = null
var _env_runtime: Environment = null


func _ready() -> void:
	if world_env != null and world_env.environment != null:
		# Duplicate Environment at runtime so fog/grade tweaks never dirty disk .tres
		_env_runtime = world_env.environment.duplicate() as Environment
		world_env.environment = _env_runtime

	if wren != null:
		wren.fainted.connect(_on_wren_fainted)
		wren.attack_performed.connect(_on_wren_attack)
	if heartseed != null:
		heartseed.awakened.connect(_on_heartseed_awakened)
	if Story != null:
		Story.world_state_refresh_requested.connect(_refresh_world_state)
		Story.ending_requested.connect(_play_ending_epilogue)

	_connect_npcs_and_monsters()
	_refresh_world_state()
	enter_title_mode()


func _connect_npcs_and_monsters() -> void:
	for n: Node in get_tree().get_nodes_in_group(&"npcs"):
		if n is CastNPC:
			var npc: CastNPC = n as CastNPC
			if not npc.talked_to.is_connected(_on_npc_talked):
				npc.talked_to.connect(_on_npc_talked)
	for m: Node in get_tree().get_nodes_in_group(&"monsters"):
		if m is ForestMonster:
			var fm: ForestMonster = m as ForestMonster
			if not fm.calmed.is_connected(_on_monster_calmed):
				fm.calmed.connect(_on_monster_calmed)
			if fm.is_boss and not fm.defeated_boss.is_connected(_on_bumble_defeated):
				fm.defeated_boss.connect(_on_bumble_defeated)


func enter_title_mode() -> void:
	_in_gameplay = false
	_showcase_index = -1
	_epilogue_running = false
	if wren != null:
		wren.set_controls_enabled(false)
		wren.teleport_to(zone_spawns[1] as Vector3, PI)
	if menu_director != null:
		menu_director.active = true
		menu_director.make_current()
	if Audio != null:
		Audio.play_music(&"title", 0.8)
		Audio.set_zone_ambience(1)


func start_new_game() -> void:
	_epilogue_running = false
	_showcase_index = -1
	_bridge_trigger_fired = false
	_pip_trigger_fired = false
	_chamber_choice_opened = false
	_first_blob_calmed = false
	_first_swing_done = false
	if Story != null:
		Story.reset_story()
		Story.run_active = true
	if menu_director != null:
		menu_director.active = false
	_in_gameplay = true
	_reset_all_monsters()
	if heartseed != null:
		heartseed.reset_dim()
	_apply_zone_atmosphere(1, true)
	if wren != null:
		wren.heal_full()
		wren.teleport_to(zone_spawns[1] as Vector3, PI)
		wren.set_campfire_spawn(zone_spawns[1] as Vector3)
		wren.camera_pivot.clear_camera_override()
		wren.camera_pivot.get_camera().current = true
		wren.set_controls_enabled(false)
	_refresh_world_state()
	if Audio != null:
		Audio.play_music(&"forest", 1.0)
		Audio.set_zone_ambience(1)
	# Opening beat (GDD Section 3.2): Mayor Hollis speaks 2 lines & Mother Clove gives the honey pot!
	_open_dialogue("Mayor Hollis", [
		"The Heartseed went dark three nights ago, Wren.",
		"Now the forest monsters are on our roads. Find out why.",
	], [], "intro_mayor")


func jump_to_zone(zone_id: int) -> void:
	var zid: int = clampi(zone_id, 1, 4)
	_showcase_index = -1
	_epilogue_running = false
	if menu_director != null:
		menu_director.active = false
	_in_gameplay = true
	if Story != null:
		Story.run_active = true
		Story.set_zone(zid)
		if zid >= 2 and not Story.has_honey and not Story.honey_delivered:
			Story.grant_honey()
	var sp: Vector3 = zone_spawns.get(zid, Vector3(0.0, 0.2, 41.0)) as Vector3
	if wren != null:
		wren.camera_pivot.clear_camera_override()
		wren.camera_pivot.get_camera().current = true
		wren.teleport_to(sp, PI)
		wren.set_campfire_spawn(sp)
		wren.set_controls_enabled(true)
	_apply_zone_atmosphere(zid, false)
	_update_zone_music(zid)
	match zid:
		1:
			Story.set_quest("Find the ancient Heartwood")
			hint_changed.emit("Hold Right Mouse: Raise the lantern")
		2:
			Story.set_quest("Cross the river")
			hint_changed.emit("Approach Chief Bumble at the bridge camp")
		3:
			Story.set_quest("Explore the Foggy Ruins")
			hint_changed.emit("Find who is hiding in the misty plaza")
		4:
			Story.set_quest("Awaken the Heartseed")
			hint_changed.emit("Hold Right Mouse near the Heartwood to wake the seed")
	_refresh_world_state()


func spawn_presenter_monster_group() -> void:
	if wren == null:
		return
	var scenes: Array[String] = [
		"res://scenes/monsters/monster_blob.tscn",
		"res://scenes/monsters/monster_winged.tscn",
		"res://scenes/monsters/monster_furball.tscn",
	]
	var fwd: Vector3 = Vector3(sin(wren.visual_root.rotation.y), 0.0, cos(wren.visual_root.rotation.y))
	for i: int in range(scenes.size()):
		var packed: PackedScene = load(scenes[i]) as PackedScene
		if packed == null:
			continue
		var m: ForestMonster = packed.instantiate() as ForestMonster
		add_child(m)
		var lateral: float = (i - 1) * 2.2
		m.global_position = wren.global_position + fwd * 6.5 + Vector3(lateral, 0.1, 0.0)
		m.set_hostile_mode(true)
		m.calmed.connect(_on_monster_calmed)


func cycle_showcase_camera() -> void:
	_showcase_index = (_showcase_index + 1) % 5
	match _showcase_index:
		0:
			if cam_path != null:
				cam_path.current = true
				showcase_cam_changed.emit("ConceptCam_Path (Zone 1)")
		1:
			if cam_bridge != null:
				cam_bridge.current = true
				showcase_cam_changed.emit("ConceptCam_Bridge (Zone 2)")
		2:
			if cam_chamber != null:
				cam_chamber.current = true
				showcase_cam_changed.emit("ConceptCam_Chamber (Zone 4)")
		3:
			if showcase_orbit_cam != null:
				showcase_orbit_cam.current = true
				showcase_cam_changed.emit("Heartwood Orbit (M06)")
		4:
			_showcase_index = -1
			if wren != null and wren.camera_pivot != null:
				wren.camera_pivot.get_camera().current = true
			showcase_cam_changed.emit("")


func _process(delta: float) -> void:
	if _showcase_index == 3 and showcase_orbit_cam != null:
		_orbit_angle += delta * 0.28
		var center: Vector3 = Vector3(0.0, 14.0, -226.0)
		var r: float = 46.0
		showcase_orbit_cam.global_position = center + Vector3(sin(_orbit_angle) * r, 8.0, cos(_orbit_angle) * r)
		showcase_orbit_cam.look_at(center, Vector3.UP)

	if not _in_gameplay or wren == null or _epilogue_running:
		return

	# Track current zone by Wren's north-south progress (north = -Z)
	var z: float = wren.global_position.z
	var new_zone: int = 1
	if z < -176.0:
		new_zone = 4
	elif z < -110.0:
		new_zone = 3
	elif z < -62.0:
		new_zone = 2
	if Story != null and new_zone != Story.current_zone:
		Story.set_zone(new_zone)
		wren.set_campfire_spawn(zone_spawns[new_zone] as Vector3)
		_apply_zone_atmosphere(new_zone, false)
		_update_zone_music(new_zone)
		if new_zone == 2 and not Story.bridge_resolved:
			Story.set_quest("Cross the river")
		elif new_zone == 3 and not Story.pip_resolved:
			Story.set_quest("Search the Foggy Ruins")
		elif new_zone == 4 and not Story.seed_awakened:
			Story.set_quest("Awaken the Heartseed")
			hint_changed.emit("Hold Right Mouse to raise the lantern toward the Heartseed")

	# Auto-trigger Zone 2 Bridge Decision when approaching Chief Bumble at north end of bridge
	if not _bridge_trigger_fired and not Story.bridge_resolved and z < -87.0 and z > -104.0 and absf(wren.global_position.x) < 8.0:
		_bridge_trigger_fired = true
		_start_bridge_decision()

	# Auto-trigger Zone 3 Pip/Rook Decision on entering Ruins Plaza
	if not _pip_trigger_fired and not Story.pip_resolved and z < -134.0 and z > -150.0 and absf(wren.global_position.x) < 10.0:
		_pip_trigger_fired = true
		_start_pip_decision()

	# Allow lantern proximity in Zone 4 to awaken the Heartseed smoothly (within 14 m of socket/chamber center)
	if new_zone == 4 and wren.is_lantern_raised and heartseed != null and not heartseed.is_lit:
		if wren.global_position.z < -194.0:
			heartseed.trigger_awaken()


func _open_dialogue(speaker: String, lines: Array[String], choices: Array[Dictionary], ctx: String) -> void:
	_active_choice_context = ctx
	if Story != null:
		Story.dialogue_open = true
	if wren != null:
		wren.set_controls_enabled(false)
	if Audio != null:
		Audio.duck_music(true)
	dialogue_opened.emit(speaker, lines, choices)


func on_dialogue_closed(chosen_id: String) -> void:
	if Story != null:
		Story.dialogue_open = false
	if Audio != null:
		Audio.duck_music(false)

	var ctx: String = _active_choice_context
	_active_choice_context = ""

	match ctx:
		"intro_mayor":
			_open_dialogue("Mother Clove", [
				"Take my last pot of honey. Monsters love it. So do couriers.",
			], [], "intro_clove")
			return
		"intro_clove":
			if Story != null:
				Story.grant_honey()
				Story.intro_played = true
			if Audio != null:
				Audio.play_sfx(&"honey_pour", 0.95, 1.08, -4.0)
			hint_changed.emit("Hold Right Mouse: Raise the lantern")
		"decision_bridge":
			if wren != null:
				wren.camera_pivot.clear_camera_override()
				wren.camera_pivot.get_camera().current = true
			if chosen_id == "fight":
				_execute_bridge_fight()
			elif chosen_id == "honey":
				_execute_bridge_honey()
		"decision_pip_intro":
			_open_dialogue("Captain Rook", [
				"There you are, little thief. Courier, did you find the shard?",
			], [
				{"id": "turn_in", "label": "Turn Pip in", "style": "red", "locked": false},
				{"id": "keep", "label": "Keep the secret", "style": "green", "locked": false},
			], "decision_pip")
			return
		"decision_pip":
			if chosen_id == "turn_in":
				_execute_pip_turn_in()
			elif chosen_id == "keep":
				_execute_pip_keep()
		"decision_heartseed":
			if chosen_id in ["forest", "home", "share"]:
				if Story != null:
					Story.trigger_ending(chosen_id)
				return

	if wren != null and not _epilogue_running:
		wren.camera_pivot.clear_camera_override()
		wren.camera_pivot.get_camera().current = true
		wren.set_controls_enabled(true)


func _on_npc_talked(npc_id: String, npc: CastNPC) -> void:
	if _epilogue_running:
		return
	if wren != null and npc != null:
		# Ease camera to warm over-shoulder framing of the speaker (0.5s)
		var dir: Vector3 = (npc.global_position - wren.global_position).normalized()
		var right: Vector3 = dir.cross(Vector3.UP).normalized()
		var cam_pos: Vector3 = wren.global_position - dir * 2.1 + right * 0.9 + Vector3(0.0, 1.45, 0.0)
		var look_pt: Vector3 = npc.global_position + Vector3(0.0, 1.15, 0.0)
		wren.camera_pivot.set_camera_override(Transform3D(Basis.IDENTITY, cam_pos).looking_at(look_pt, Vector3.UP), 46.0)

	match npc_id:
		"mayor_hollis":
			_open_dialogue("Mayor Hollis", [
				"The Heartseed went dark three nights ago, Wren.",
				"Follow the path north to the great Heartwood and find out why.",
			], [], "talk_mayor")
		"mother_clove":
			if Story.honey_delivered:
				_open_dialogue("Mother Clove", [
					"My bakery is quiet without honey, but I hope it helped you out there.",
				], [], "talk_clove")
			else:
				_open_dialogue("Mother Clove", [
					"Keep that honey pot safe! Chief Bumble has the biggest sweet tooth in the woods.",
				], [], "talk_clove")
		"bramble":
			Story.met_bramble = true
			_open_dialogue("Bramble", [
				"A courier! Chief Bumble holds the bridge ahead. He has a sweet tooth.",
				"And mind the fog in the ruins. Something small is hiding there.",
			], [], "talk_bramble")
		"pip", "moss", "captain_rook":
			if not Story.pip_resolved:
				_pip_trigger_fired = true
				_start_pip_decision()
			elif npc_id == "pip":
				_open_dialogue("Pip", ["Thank you for keeping our secret! Follow Moss's sparkles!"], [], "talk_pip")
			elif npc_id == "captain_rook":
				_open_dialogue("Captain Rook", ["My braziers cleared the fog. Stay sharp ahead, courier."], [], "talk_rook")


func _start_bridge_decision() -> void:
	if cam_bridge != null:
		cam_bridge.current = true
	_open_dialogue("Chief Bumble", [
		"The bridge is ours, little courier. What will you give for it?",
	], [
		{"id": "fight", "label": "Fight for the bridge", "style": "red", "locked": false},
		{"id": "honey", "label": "Offer the honey", "style": "gold", "locked": false},
	], "decision_bridge")


func _execute_bridge_fight() -> void:
	if Audio != null:
		Audio.play_stinger(&"choice_fight")
		Audio.play_music(&"battle", 0.6)
	# Activate Bumble (6 hits) + 3 camp monsters to hostile!
	var bumble: ForestMonster = zone2.get_node_or_null("ChiefBumble") as ForestMonster
	if bumble != null:
		bumble.set_hostile_mode(true, true)
	for nm: String in ["CampBlob", "CampWinged", "CampFurball"]:
		var cm: ForestMonster = zone2.get_node_or_null(nm) as ForestMonster
		if cm != null:
			cm.set_hostile_mode(true, true)
	hint_changed.emit("Left Mouse: Bonk Chief Bumble (6 hits) — Lantern stuns him!")


func _on_bumble_defeated(_bumble: ForestMonster) -> void:
	if Story != null:
		Story.apply_bridge_choice("fight", false)
	if Audio != null:
		Audio.play_music(&"forest", 1.0)
	_open_dialogue("Chief Bumble", [
		"Fine! Take your bridge! The east woods will remember this!",
	], [], "bumble_after_fight")
	hint_changed.emit("Continue north into the Foggy Ruins")


func _execute_bridge_honey() -> void:
	if Audio != null:
		Audio.play_sfx(&"honey_pour", 0.95, 1.05, -2.0)
		Audio.play_stinger(&"choice_honey")
	if Story != null:
		Story.apply_bridge_choice("honey", true)
	# Camp cheers and dances in a ring around the campfire!
	var center: Vector3 = Vector3(0.0, 0.1, -94.0)
	var idx: int = 0
	for nm: String in ["ChiefBumble", "CampBlob", "CampWinged", "CampFurball"]:
		var cm: ForestMonster = zone2.get_node_or_null(nm) as ForestMonster
		if cm != null:
			cm.start_camp_dance(center, idx * 1.55)
			idx += 1
	_open_dialogue("Chief Bumble", [
		"Honey! You are a friend of the camp now. Take the east path through the clearing!",
	], [], "bumble_after_honey")
	message_card_opened.emit("Back in Thistle, Mother Clove closes her bakery. That was her last honey.")
	hint_changed.emit("Head north or take the east shortcut to the Foggy Ruins")


func _start_pip_decision() -> void:
	_open_dialogue("Pip", [
		"Please don't tell! Moss is sick, and the shard keeps her warm.",
	], [], "decision_pip_intro")


func _execute_pip_turn_in() -> void:
	if Story != null:
		Story.apply_pip_choice("turn_in")
	if Audio != null:
		Audio.play_sfx(&"shield_equip", 0.95, 1.05, -2.0)
		Audio.play_sfx(&"brazier_light", 0.95, 1.08, -4.0)
	_apply_zone_atmosphere(3, false) # Braziers burn away the fog!
	_open_dialogue("Captain Rook", [
		"Good work. Take my old shield, it kept me safe for forty years. I have lit the braziers north.",
	], [], "rook_after_turn_in")
	hint_changed.emit("Follow the lit braziers north to the Heart Chamber")


func _execute_pip_keep() -> void:
	if Story != null:
		Story.apply_pip_choice("keep")
	if Audio != null:
		Audio.play_stinger(&"calm_burst")
	_open_dialogue("Pip", [
		"You kept my secret! Moss knows the way through the mist. Follow her sparkles!",
	], [], "pip_after_keep")
	hint_changed.emit("Follow Moss's golden sparkle trail north to the Heart Chamber")


func _on_heartseed_awakened() -> void:
	if _chamber_choice_opened:
		return
	_chamber_choice_opened = true
	if cam_chamber != null:
		cam_chamber.current = true
	var share_ok: bool = Story != null and Story.is_share_unlocked()
	_open_dialogue("The Heartseed", [
		"The ancient Heartseed glows with warm golden light. Choose where the light belongs." if share_ok else "The ancient Heartseed glows. (Share locked: you need friends on both sides of the forest.)",
	], [
		{"id": "forest", "label": "Return it to the forest", "style": "green", "locked": false},
		{"id": "home", "label": "Carry it home to Thistle", "style": "red", "locked": false},
		{"id": "share", "label": "Share the light", "style": "gold", "locked": not share_ok},
	], "decision_heartseed")


func play_ending_direct(ending_id: String) -> void:
	if Story != null:
		Story.trigger_ending(ending_id)


func _play_ending_epilogue(ending_id: String) -> void:
	_epilogue_running = true
	_in_gameplay = false
	if menu_director != null:
		menu_director.active = false
	if wren != null:
		wren.set_controls_enabled(false)
	if heartseed != null:
		heartseed.set_lit_instant()
	if Audio != null:
		Audio.play_stinger(StringName("ending_" + ending_id))
		Audio.play_music(&"chamber", 0.8)

	var line_text: String = ""
	match ending_id:
		"forest":
			line_text = "The woods healed. Thistle learned to live by the forest's rules."
			if _env_runtime != null:
				_env_runtime.adjustment_saturation = 1.28
				_env_runtime.adjustment_brightness = 1.08
				_env_runtime.fog_light_color = Color("#B8E68E")
		"home":
			line_text = "Thistle was safe and bright. The forest fell asleep."
			if _env_runtime != null:
				_env_runtime.adjustment_saturation = 0.62
				_env_runtime.adjustment_brightness = 0.94
				_env_runtime.fog_light_color = Color("#9AB0C4")
		"share":
			line_text = "Forest and village shared the light. Mother Clove came home, with honey from a new friend."
			if _env_runtime != null:
				_env_runtime.adjustment_saturation = 1.20
				_env_runtime.adjustment_brightness = 1.10
				_env_runtime.fog_light_color = Color("#F4E59E")

	epilogue_line_shown.emit(line_text)
	# Three 4-second epilogue camera shots across Heart Chamber, Bridge, and Thistle Gate!
	var shots: Array[Camera3D] = [cam_chamber, cam_bridge, cam_path]
	for cam: Camera3D in shots:
		if not _epilogue_running:
			return
		if cam != null:
			cam.current = true
		await get_tree().create_timer(3.2).timeout
	if _epilogue_running:
		epilogue_finished.emit()


func _refresh_world_state() -> void:
	if Story == null:
		return
	# Zone 2 visual consequences: fight collapses tents; honey opens east shortcut!
	var tent1: Node3D = zone2.get_node_or_null("CampTent1") as Node3D
	var tent2: Node3D = zone2.get_node_or_null("CampTent2") as Node3D
	if tent1 != null:
		tent1.rotation_degrees.z = 72.0 if Story.bridge_choice == "fight" else 0.0
	if tent2 != null:
		tent2.rotation_degrees.z = -72.0 if Story.bridge_choice == "fight" else 0.0
	var shortcut: Node3D = zone2.get_node_or_null("EastShortcut") as Node3D
	if shortcut != null:
		shortcut.visible = Story.shortcut_open

	# Zone 3 visual consequences: braziers lit & fog cleared vs Pip & Moss sparkle trail!
	var fog_group: Node3D = zone3.get_node_or_null("FogCards") as Node3D
	if fog_group != null:
		fog_group.visible = not Story.braziers_lit
	var brazier_lights: Node3D = zone3.get_node_or_null("BrazierFlames") as Node3D
	if brazier_lights != null:
		brazier_lights.visible = Story.braziers_lit
	var sparkle_trail: Node3D = zone3.get_node_or_null("SparkleTrail") as Node3D
	if sparkle_trail != null:
		sparkle_trail.visible = Story.sparkle_trail_active

	# Extra hostile monsters in Zones 3 & 4 when east_woods_hostile == true
	var hostile_extra: Node3D = zone3.get_node_or_null("HostileExtras") as Node3D
	if hostile_extra != null:
		hostile_extra.visible = Story.is_east_woods_hostile()
		for c: Node in hostile_extra.get_children():
			if c is ForestMonster:
				(c as ForestMonster).set_hostile_mode(Story.is_east_woods_hostile())

	# Zone 4 cast presence based on choices!
	var z4_bumble: Node3D = zone4.get_node_or_null("ChamberBumble") as Node3D
	if z4_bumble != null:
		z4_bumble.visible = Story.bridge_choice != "fight"
	var z4_pip: Node3D = zone4.get_node_or_null("ChamberPip") as Node3D
	if z4_pip != null:
		z4_pip.visible = Story.pip_choice != "turn_in"
	var z4_moss: Node3D = zone4.get_node_or_null("ChamberMoss") as Node3D
	if z4_moss != null:
		z4_moss.visible = Story.pip_choice != "turn_in"


func _apply_zone_atmosphere(zone_id: int, instant: bool) -> void:
	if _env_runtime == null:
		return
	var target_fog_col: Color = Color("#CFE3A0")
	var target_fog_begin: float = 35.0
	var target_fog_density: float = 0.008
	var target_sat: float = 1.10
	if zone_id == 3 and (Story == null or not Story.braziers_lit):
		target_fog_col = Color("#B9C7C9")
		target_fog_begin = 8.0
		target_fog_density = 0.024
		target_sat = 0.92
	elif zone_id == 4:
		target_fog_col = Color("#E5E4A2")
		target_fog_begin = 38.0
		target_fog_density = 0.007
		target_sat = 1.15

	if instant:
		_env_runtime.fog_light_color = target_fog_col
		_env_runtime.fog_depth_begin = target_fog_begin
		_env_runtime.fog_density = target_fog_density
		_env_runtime.adjustment_saturation = target_sat
		return

	if _fog_tween != null and _fog_tween.is_valid():
		_fog_tween.kill()
	_fog_tween = create_tween()
	_fog_tween.set_parallel(true)
	_fog_tween.tween_property(_env_runtime, "fog_light_color", target_fog_col, 1.4)
	_fog_tween.tween_property(_env_runtime, "fog_depth_begin", target_fog_begin, 1.4)
	_fog_tween.tween_property(_env_runtime, "fog_density", target_fog_density, 1.4)
	_fog_tween.tween_property(_env_runtime, "adjustment_saturation", target_sat, 1.4)


func _update_zone_music(zone_id: int) -> void:
	if Audio == null:
		return
	Audio.set_zone_ambience(zone_id)
	match zone_id:
		1, 2:
			Audio.play_music(&"forest", 1.2)
		3:
			Audio.play_music(&"fog", 1.2)
		4:
			Audio.play_music(&"chamber", 1.2)


func _on_monster_calmed(_m: ForestMonster) -> void:
	if not _first_blob_calmed:
		_first_blob_calmed = true
		hint_changed.emit("Nice! Left Mouse: Swing your wooden sword at grumpy monsters")


func _on_wren_attack(_step: int) -> void:
	if _first_blob_calmed and not _first_swing_done:
		_first_swing_done = true
		hint_changed.emit("")


func _on_wren_fainted() -> void:
	await get_tree().create_timer(1.1).timeout
	if wren == null:
		return
	var z: int = Story.current_zone if Story != null else 1
	var sp: Vector3 = zone_spawns.get(z, Vector3(0.0, 0.2, 41.0)) as Vector3
	wren.heal_full()
	wren.teleport_to(sp, PI)
	wren.set_controls_enabled(true)
	message_card_opened.emit("Wren rested by the warm campfire and recovered full hearts.")


func _reset_all_monsters() -> void:
	for m: Node in get_tree().get_nodes_in_group(&"monsters"):
		if m is ForestMonster:
			var fm: ForestMonster = m as ForestMonster
			fm.visible = true
			fm.collision_layer = 8
			fm.collision_mask = 11
			fm.set_physics_process(true)
			fm.hp = fm.max_hp
			fm.calm_progress = 0.0
			fm.state = ForestMonster.State.IDLE
			fm.global_position = fm._home_pos
			if fm.model_holder != null:
				fm.model_holder.scale = fm._base_model_scale
			fm.set_hostile_mode(fm.start_grumpy)
