class_name HeartwoodMain
extends Node

## Top-level game coordinator for Heartwood Hollow (scenes/main.tscn).
## Connects the live continuous 3D World (WorldDirector) to the cozy GameUI,
## handles title/gameplay/pause/ending transitions, and F1-F4 presenter tools.

@onready var world: WorldDirector = $World
@onready var ui: GameUI = $GameUI

var _in_gameplay: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_connect_signals()
	ui.show_title_mode()
	if world != null and world.wren != null:
		ui.update_hearts(world.wren.hearts, world.wren.max_hearts)


func _connect_signals() -> void:
	if world != null:
		world.dialogue_opened.connect(func(sp: String, lines: Array[String], choices: Array[Dictionary]) -> void:
			ui.open_dialogue(sp, lines, choices)
		)
		world.message_card_opened.connect(func(txt: String) -> void:
			ui.show_message_card(txt)
		)
		world.epilogue_line_shown.connect(func(txt: String) -> void:
			ui.show_epilogue_line(txt)
		)
		world.epilogue_finished.connect(func() -> void:
			ui.show_end_card()
		)
		world.hint_changed.connect(func(txt: String) -> void:
			ui.set_hint(txt)
		)
		world.showcase_cam_changed.connect(func(lbl: String) -> void:
			ui.set_showcase_label(lbl)
		)
		if world.wren != null:
			world.wren.hearts_changed.connect(func(cur: float, mx: float) -> void:
				ui.update_hearts(cur, mx)
			)
			world.wren.hurt_flash_requested.connect(func() -> void:
				ui.flash_hurt_vignette()
			)
			world.wren.interact_prompt_changed.connect(func(txt: String, wp: Vector3) -> void:
				ui.set_interact_prompt(txt, wp)
			)

	if ui != null:
		ui.start_game_requested.connect(_on_start_game)
		ui.restart_zone_requested.connect(_on_restart_zone)
		ui.play_again_requested.connect(_on_play_again)
		ui.dialogue_choice_completed.connect(func(cid: String) -> void:
			if world != null:
				world.on_dialogue_closed(cid)
		)
		ui.presenter_zone_requested.connect(func(zid: int) -> void:
			_in_gameplay = true
			ui.set_paused(false)
			ui.show_gameplay_mode()
			if world != null:
				world.jump_to_zone(zid)
		)
		ui.presenter_bridge_requested.connect(func(ch: String) -> void:
			if Story != null:
				Story.apply_bridge_choice(ch, false)
			ui.show_message_card("Presenter: Bridge choice set to " + ch)
		)
		ui.presenter_pip_requested.connect(func(ch: String) -> void:
			if Story != null:
				Story.apply_pip_choice(ch)
			ui.show_message_card("Presenter: Pip choice set to " + ch)
		)
		ui.presenter_ending_requested.connect(func(eid: String) -> void:
			_in_gameplay = false
			ui.set_paused(false)
			if world != null:
				world.play_ending_direct(eid)
		)
		ui.presenter_heal_requested.connect(func() -> void:
			if world != null and world.wren != null:
				world.wren.heal_full()
			ui.show_message_card("God Mode: %s (Full Hearts)" % ("ON" if Story != null and Story.god_mode else "OFF"))
		)
		ui.presenter_spawn_requested.connect(func() -> void:
			if world != null:
				world.spawn_presenter_monster_group()
		)
		ui.presenter_start_over_requested.connect(_on_play_again)
		ui.gallery_requested.connect(_open_modeler_gallery)

	if Story != null:
		Story.message_card_requested.connect(func(txt: String) -> void:
			ui.show_message_card(txt)
		)


func _on_start_game() -> void:
	Engine.time_scale = 1.0
	ui.fade_transition(func() -> void:
		_in_gameplay = true
		ui.show_gameplay_mode()
		if world != null:
			world.start_new_game()
	, 0.35)


func _on_restart_zone() -> void:
	Engine.time_scale = 1.0
	var zid: int = Story.current_zone if Story != null else 1
	ui.fade_transition(func() -> void:
		if world != null:
			world.jump_to_zone(zid)
			if world.wren != null:
				world.wren.heal_full()
	, 0.25)


func _on_play_again() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	ui.fade_transition(func() -> void:
		_in_gameplay = false
		ui.show_title_mode()
		if Story != null:
			Story.reset_story()
		if world != null:
			world.enter_title_mode()
	, 0.35)


func _open_modeler_gallery() -> void:
	Engine.time_scale = 1.0
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if Story != null:
		Story.open_gallery_on_lab_load = true
	get_tree().change_scene_to_file("res://tests/model_lab.tscn")


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		if _in_gameplay and (ui.dialogue_panel == null or not ui.dialogue_panel.visible):
			ui.set_paused(not get_tree().paused)
			get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"presenter_panel"):
		ui.toggle_presenter_f1()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"showcase_cam"):
		if world != null:
			world.cycle_showcase_camera()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"toggle_hud"):
		ui.toggle_hud_f3()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"modeler_gallery"):
		_open_modeler_gallery()
		get_viewport().set_input_as_handled()
