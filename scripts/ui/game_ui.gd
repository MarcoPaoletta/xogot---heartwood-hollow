class_name GameUI
extends CanvasLayer

## Cozy concept-matched UI for Heartwood Hollow (GDD Section 8 & 12):
## - Title screen over live forest (logo, Start, Quit, credit line)
## - Minimal HUD (5 hearts top-left, golden "!" quest pill top-right, mute speaker + M corner, hint pill, world E prompt)
## - Concept-exact Dialogue Box (#FDECD2 cream panel, #81441F brown pill name tag, 45 cps typewriter, big red/gold/green buttons)
## - Pause Menu, Message Card, Epilogue Banner, End Card, Hurt Vignette, Screen Fade, and F1 Presenter Panel!

signal start_game_requested
signal restart_zone_requested
signal play_again_requested
signal dialogue_choice_completed(chosen_id: String)
signal presenter_zone_requested(zone_id: int)
signal presenter_bridge_requested(choice: String)
signal presenter_pip_requested(choice: String)
signal presenter_ending_requested(ending_id: String)
signal presenter_heal_requested
signal presenter_spawn_requested
signal presenter_start_over_requested
signal gallery_requested

const TYPE_CPS: float = 45.0

@onready var hurt_vignette: ColorRect = $HurtVignette
@onready var screen_fade: ColorRect = $ScreenFade
@onready var hud_root: Control = $HUD
@onready var hearts_row: HBoxContainer = $HUD/HeartsRow
@onready var quest_label: Label = $HUD/QuestPill/HBox/QuestText
@onready var hint_pill: PanelContainer = $HUD/HintPill
@onready var hint_label: Label = $HUD/HintPill/HintLabel
@onready var interact_pill: PanelContainer = $HUD/InteractPill
@onready var interact_label: Label = $HUD/InteractPill/InteractLabel
@onready var showcase_pill: PanelContainer = $HUD/ShowcasePill
@onready var showcase_label: Label = $HUD/ShowcasePill/ShowcaseLabel
@onready var mute_pill: PanelContainer = $MuteCorner/MutePill
@onready var mute_label: Label = $MuteCorner/MutePill/MuteLabel
@onready var title_screen: Control = $TitleScreen
@onready var dialogue_panel: Control = $DialogueBox
@onready var speaker_label: Label = $DialogueBox/NameTag/SpeakerLabel
@onready var dialogue_text: Label = $DialogueBox/Panel/VBox/LineLabel
@onready var choices_row: HBoxContainer = $DialogueBox/Panel/VBox/ChoicesRow
@onready var continue_hint: Label = $DialogueBox/Panel/VBox/ContinueHint
@onready var pause_screen: Control = $PauseScreen
@onready var message_card: PanelContainer = $MessageCard
@onready var message_label: Label = $MessageCard/MessageLabel
@onready var epilogue_bar: PanelContainer = $EpilogueBar
@onready var epilogue_label: Label = $EpilogueBar/EpilogueLabel
@onready var end_card: Control = $EndCard
@onready var end_title: Label = $EndCard/Panel/VBox/EndingTitle
@onready var end_summary: Label = $EndCard/Panel/VBox/SummaryLabel
@onready var presenter_panel: PanelContainer = $PresenterPanel

var _lines: Array[String] = []
var _line_idx: int = 0
var _choices: Array[Dictionary] = []
var _type_chars: float = 0.0
var _line_complete: bool = false
var _hud_hidden_f3: bool = false
var _in_gameplay: bool = false
var _msg_tween: Tween = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_wire_buttons()
	_setup_initial_visibility()
	if Audio != null:
		Audio.mute_changed.connect(_on_mute_changed)
		_on_mute_changed(Audio.is_muted())
	if Story != null:
		Story.quest_changed.connect(_on_quest_changed)
		_on_quest_changed(Story.quest_text)


func _setup_initial_visibility() -> void:
	if hurt_vignette != null:
		hurt_vignette.modulate.a = 0.0
	if screen_fade != null:
		screen_fade.modulate.a = 0.0
		screen_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if title_screen != null: title_screen.visible = true
	if hud_root != null: hud_root.visible = false
	if dialogue_panel != null: dialogue_panel.visible = false
	if pause_screen != null: pause_screen.visible = false
	if message_card != null: message_card.visible = false
	if epilogue_bar != null: epilogue_bar.visible = false
	if end_card != null: end_card.visible = false
	if presenter_panel != null: presenter_panel.visible = false
	if hint_pill != null: hint_pill.visible = false
	if interact_pill != null: interact_pill.visible = false
	if showcase_pill != null: showcase_pill.visible = false


func _wire_buttons() -> void:
	_bind_btn("TitleScreen/CenterVBox/Buttons/StartBtn", func() -> void:
		_click_sfx()
		start_game_requested.emit()
	)
	_bind_btn("TitleScreen/CenterVBox/Buttons/GalleryBtn", func() -> void:
		_click_sfx()
		gallery_requested.emit()
	)
	_bind_btn("TitleScreen/CenterVBox/Buttons/QuitBtn", func() -> void:
		_click_sfx()
		get_tree().quit()
	)
	_bind_btn("PauseScreen/Panel/VBox/ResumeBtn", func() -> void:
		_click_sfx()
		set_paused(false)
	)
	_bind_btn("PauseScreen/Panel/VBox/RestartZoneBtn", func() -> void:
		_click_sfx()
		set_paused(false)
		restart_zone_requested.emit()
	)
	_bind_btn("PauseScreen/Panel/VBox/FullscreenBtn", func() -> void:
		_click_sfx()
		if Audio != null: Audio.toggle_fullscreen()
	)
	_bind_btn("PauseScreen/Panel/VBox/MuteBtn", func() -> void:
		_click_sfx()
		if Audio != null: Audio.toggle_mute()
	)
	_bind_btn("PauseScreen/Panel/VBox/QuitBtn", func() -> void:
		_click_sfx()
		get_tree().quit()
	)
	_bind_btn("EndCard/Panel/VBox/Buttons/PlayAgainBtn", func() -> void:
		_click_sfx()
		play_again_requested.emit()
	)
	_bind_btn("EndCard/Panel/VBox/Buttons/QuitEndBtn", func() -> void:
		_click_sfx()
		get_tree().quit()
	)

	# F1 Presenter Panel buttons
	for z: int in range(1, 5):
		var zid: int = z
		_bind_btn("PresenterPanel/VBox/ZoneRow/Z%dBtn" % z, func() -> void:
			_click_sfx()
			presenter_zone_requested.emit(zid)
		)
	_bind_btn("PresenterPanel/VBox/ChoiceRow/FightBtn", func() -> void:
		_click_sfx()
		presenter_bridge_requested.emit("fight")
	)
	_bind_btn("PresenterPanel/VBox/ChoiceRow/HoneyBtn", func() -> void:
		_click_sfx()
		presenter_bridge_requested.emit("honey")
	)
	_bind_btn("PresenterPanel/VBox/ChoiceRow/TurnInBtn", func() -> void:
		_click_sfx()
		presenter_pip_requested.emit("turn_in")
	)
	_bind_btn("PresenterPanel/VBox/ChoiceRow/KeepBtn", func() -> void:
		_click_sfx()
		presenter_pip_requested.emit("keep")
	)
	_bind_btn("PresenterPanel/VBox/EndRow/EndForestBtn", func() -> void:
		_click_sfx()
		presenter_panel.visible = false
		presenter_ending_requested.emit("forest")
	)
	_bind_btn("PresenterPanel/VBox/EndRow/EndHomeBtn", func() -> void:
		_click_sfx()
		presenter_panel.visible = false
		presenter_ending_requested.emit("home")
	)
	_bind_btn("PresenterPanel/VBox/EndRow/EndShareBtn", func() -> void:
		_click_sfx()
		presenter_panel.visible = false
		presenter_ending_requested.emit("share")
	)
	_bind_btn("PresenterPanel/VBox/UtilRow/GodBtn", func() -> void:
		_click_sfx()
		if Story != null: Story.god_mode = not Story.god_mode
		presenter_heal_requested.emit()
	)
	_bind_btn("PresenterPanel/VBox/UtilRow/SpawnBtn", func() -> void:
		_click_sfx()
		presenter_spawn_requested.emit()
	)
	_bind_btn("PresenterPanel/VBox/UtilRow/Speed1Btn", func() -> void:
		_click_sfx()
		Engine.time_scale = 1.0
	)
	_bind_btn("PresenterPanel/VBox/UtilRow/Speed2Btn", func() -> void:
		_click_sfx()
		Engine.time_scale = 2.0
	)
	_bind_btn("PresenterPanel/VBox/UtilRow/Speed4Btn", func() -> void:
		_click_sfx()
		Engine.time_scale = 4.0
	)
	_bind_btn("PresenterPanel/VBox/UtilRow/ResetBtn", func() -> void:
		_click_sfx()
		presenter_panel.visible = false
		presenter_start_over_requested.emit()
	)


func _bind_btn(path: String, cb: Callable) -> void:
	var btn: Button = get_node_or_null(path) as Button
	if btn == null:
		return
	btn.pressed.connect(cb)
	btn.pivot_offset = btn.custom_minimum_size * 0.5
	btn.mouse_entered.connect(func() -> void:
		var tw: Tween = create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_property(btn, "scale", Vector2(1.05, 1.05), 0.12).set_trans(Tween.TRANS_BACK)
		if Audio != null: Audio.play_sfx(&"ui_hover", 0.96, 1.04, -12.0)
	)
	btn.mouse_exited.connect(func() -> void:
		var tw: Tween = create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_property(btn, "scale", Vector2.ONE, 0.12)
	)


func _click_sfx() -> void:
	if Audio != null:
		Audio.play_sfx(&"ui_click", 0.95, 1.06, -5.0)


func fade_transition(mid_callback: Callable, duration: float = 0.35) -> void:
	if screen_fade == null:
		mid_callback.call()
		return
	screen_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	var tw: Tween = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(screen_fade, "modulate:a", 1.0, duration).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(mid_callback)
	tw.tween_property(screen_fade, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_SINE)
	tw.tween_callback(func() -> void: screen_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE)


func show_title_mode() -> void:
	_in_gameplay = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if title_screen != null: title_screen.visible = true
	if hud_root != null: hud_root.visible = false
	if dialogue_panel != null: dialogue_panel.visible = false
	if end_card != null: end_card.visible = false
	if epilogue_bar != null: epilogue_bar.visible = false


func show_gameplay_mode() -> void:
	_in_gameplay = true
	if title_screen != null: title_screen.visible = false
	if end_card != null: end_card.visible = false
	if epilogue_bar != null: epilogue_bar.visible = false
	if hud_root != null: hud_root.visible = not _hud_hidden_f3


func set_paused(paused: bool) -> void:
	if not _in_gameplay:
		return
	get_tree().paused = paused
	if pause_screen != null:
		pause_screen.visible = paused
	if paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif dialogue_panel == null or not dialogue_panel.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func toggle_hud_f3() -> void:
	_hud_hidden_f3 = not _hud_hidden_f3
	if hud_root != null:
		hud_root.visible = _in_gameplay and not _hud_hidden_f3


func toggle_presenter_f1() -> void:
	if presenter_panel == null:
		return
	presenter_panel.visible = not presenter_panel.visible
	if presenter_panel.visible:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif _in_gameplay and (dialogue_panel == null or not dialogue_panel.visible) and not get_tree().paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func update_hearts(current: float, _max_h: float) -> void:
	if hearts_row == null:
		return
	var count: int = hearts_row.get_child_count()
	for i: int in range(count):
		var h: Label = hearts_row.get_child(i) as Label
		if h == null:
			continue
		var full_thresh: float = float(i) + 1.0
		if current >= full_thresh:
			h.modulate = Color("#F04444")
		elif current > float(i):
			h.modulate = Color("#FF9470")
		else:
			h.modulate = Color(0.28, 0.22, 0.22, 0.55)


func flash_hurt_vignette() -> void:
	if hurt_vignette == null:
		return
	var tw: Tween = create_tween()
	tw.tween_property(hurt_vignette, "modulate:a", 0.55, 0.06)
	tw.tween_property(hurt_vignette, "modulate:a", 0.0, 0.45).set_trans(Tween.TRANS_SINE)


func set_hint(text: String) -> void:
	if hint_pill == null or hint_label == null:
		return
	hint_label.text = text
	hint_pill.visible = not text.is_empty()


func set_interact_prompt(text: String, _world_pos: Vector3) -> void:
	if interact_pill == null or interact_label == null:
		return
	interact_label.text = text
	interact_pill.visible = not text.is_empty() and (dialogue_panel == null or not dialogue_panel.visible)


func set_showcase_label(text: String) -> void:
	if showcase_pill == null or showcase_label == null:
		return
	showcase_label.text = text
	showcase_pill.visible = not text.is_empty()


func show_message_card(text: String) -> void:
	if message_card == null or message_label == null:
		return
	message_label.text = text
	message_card.visible = true
	message_card.modulate.a = 0.0
	if _msg_tween != null and _msg_tween.is_valid():
		_msg_tween.kill()
	_msg_tween = create_tween()
	_msg_tween.tween_property(message_card, "modulate:a", 1.0, 0.3)
	_msg_tween.tween_interval(4.2)
	_msg_tween.tween_property(message_card, "modulate:a", 0.0, 0.4)
	_msg_tween.tween_callback(func() -> void: message_card.visible = false)


func show_epilogue_line(text: String) -> void:
	if hud_root != null: hud_root.visible = false
	if dialogue_panel != null: dialogue_panel.visible = false
	if epilogue_bar != null and epilogue_label != null:
		epilogue_label.text = text
		epilogue_bar.visible = true
		epilogue_bar.modulate.a = 0.0
		var tw: Tween = create_tween()
		tw.tween_property(epilogue_bar, "modulate:a", 1.0, 0.45)


func show_end_card() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if epilogue_bar != null: epilogue_bar.visible = false
	if end_card == null:
		return
	if Story != null:
		if end_title != null:
			end_title.text = Story.get_ending_title()
		if end_summary != null:
			end_summary.text = "Bridge: %s\nFoggy Ruins: %s\nMonsters Calmed: %d   |   Bonked: %d   |   Time: %s" % [
				Story.get_bridge_choice_label(),
				Story.get_pip_choice_label(),
				Story.monsters_calmed,
				Story.monsters_bonked,
				Story.get_formatted_time(),
			]
	end_card.visible = true
	end_card.modulate.a = 0.0
	var tw: Tween = create_tween()
	tw.tween_property(end_card, "modulate:a", 1.0, 0.4)


func open_dialogue(speaker: String, lines: Array[String], choices: Array[Dictionary]) -> void:
	_lines = lines
	_line_idx = 0
	_choices = choices
	_type_chars = 0.0
	_line_complete = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if speaker_label != null:
		speaker_label.text = speaker
	if dialogue_panel != null:
		dialogue_panel.visible = true
		dialogue_panel.modulate.a = 0.0
		var tw: Tween = create_tween()
		tw.tween_property(dialogue_panel, "modulate:a", 1.0, 0.22)
	_start_current_line()


func _start_current_line() -> void:
	_type_chars = 0.0
	_line_complete = false
	if dialogue_text != null and _line_idx < _lines.size():
		dialogue_text.text = _lines[_line_idx]
		dialogue_text.visible_characters = 0
	_populate_choices(false)
	if continue_hint != null:
		continue_hint.visible = false


func _populate_choices(show_now: bool) -> void:
	if choices_row == null:
		return
	var show_choices: bool = show_now and _line_idx >= _lines.size() - 1 and not _choices.is_empty()
	choices_row.visible = show_choices
	if not show_choices:
		return
	var style_colors: Dictionary = {
		"red": [Color("#DA4838"), Color("#9B2A1E")],
		"gold": [Color("#EF970C"), Color("#A86605")],
		"green": [Color("#6B8D2F"), Color("#47621B")],
		"locked": [Color("#8F8880"), Color("#68625C")],
	}
	var btns: Array[Node] = choices_row.get_children()
	for i: int in range(btns.size()):
		var btn: Button = btns[i] as Button
		if btn == null:
			continue
		if i < _choices.size():
			var ch: Dictionary = _choices[i]
			var locked: bool = bool(ch.get("locked", false))
			btn.visible = true
			btn.disabled = locked
			btn.text = ("[Locked] " + String(ch["label"])) if locked else String(ch["label"])
			var st_key: String = "locked" if locked else String(ch.get("style", "gold"))
			var cols: Array = style_colors.get(st_key, style_colors["gold"]) as Array
			var sb := StyleBoxFlat.new()
			sb.bg_color = cols[0] as Color
			sb.border_color = cols[1] as Color
			sb.set_border_width_all(4)
			sb.set_corner_radius_all(44)
			sb.content_margin_left = 28
			sb.content_margin_right = 28
			sb.content_margin_top = 14
			sb.content_margin_bottom = 14
			btn.add_theme_stylebox_override("normal", sb)
			var hov := sb.duplicate() as StyleBoxFlat
			hov.bg_color = (cols[0] as Color).lightened(0.10)
			btn.add_theme_stylebox_override("hover", hov)
			btn.add_theme_stylebox_override("pressed", sb)
			btn.add_theme_stylebox_override("disabled", sb)
			# Disconnect prior dynamic handlers cleanly
			for conn: Dictionary in btn.pressed.get_connections():
				btn.pressed.disconnect(conn["callable"] as Callable)
			var cid: String = String(ch["id"])
			btn.pressed.connect(func() -> void:
				_click_sfx()
				_close_dialogue_with(cid)
			)
		else:
			btn.visible = false


func _close_dialogue_with(chosen_id: String) -> void:
	if dialogue_panel != null:
		dialogue_panel.visible = false
	if _in_gameplay and (presenter_panel == null or not presenter_panel.visible) and not get_tree().paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	dialogue_choice_completed.emit(chosen_id)


func _process(delta: float) -> void:
	if dialogue_panel != null and dialogue_panel.visible and not _line_complete and _line_idx < _lines.size():
		var full_len: int = _lines[_line_idx].length()
		var prev_int: int = int(_type_chars)
		_type_chars += TYPE_CPS * delta
		var cur_int: int = mini(full_len, int(_type_chars))
		if dialogue_text != null:
			dialogue_text.visible_characters = cur_int
		if cur_int > prev_int and cur_int % 4 == 0 and Audio != null:
			Audio.play_sfx(&"dialogue_blip", 0.92, 1.12, -16.0)
		if cur_int >= full_len:
			_finish_current_line()


func _finish_current_line() -> void:
	_line_complete = true
	if dialogue_text != null:
		dialogue_text.visible_characters = -1
	var has_choices_now: bool = _line_idx >= _lines.size() - 1 and not _choices.is_empty()
	_populate_choices(true)
	if continue_hint != null:
		continue_hint.visible = not has_choices_now


func _input(event: InputEvent) -> void:
	if dialogue_panel == null or not dialogue_panel.visible:
		return
	var advance: bool = false
	if event is InputEventMouseButton:
		var mb: InputEventMouseButton = event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			# Only advance on click if not clicking a choice button
			if not (choices_row != null and choices_row.visible):
				advance = true
	elif event is InputEventKey:
		var kev: InputEventKey = event as InputEventKey
		if kev.pressed and not kev.echo and (kev.physical_keycode == KEY_SPACE or kev.physical_keycode == KEY_ENTER or kev.physical_keycode == KEY_E):
			if not (choices_row != null and choices_row.visible):
				advance = true
	if advance:
		if not _line_complete:
			_finish_current_line()
		else:
			_line_idx += 1
			if _line_idx < _lines.size():
				_start_current_line()
			else:
				_close_dialogue_with("")
		get_viewport().set_input_as_handled()


func _on_mute_changed(muted: bool) -> void:
	if mute_label != null:
		mute_label.text = "Muted (M)" if muted else "Sound On (M)"
	if mute_pill != null:
		var tw: Tween = create_tween()
		tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tw.tween_property(mute_pill, "scale", Vector2(1.08, 1.08), 0.08)
		tw.tween_property(mute_pill, "scale", Vector2.ONE, 0.12)


func _on_quest_changed(text: String) -> void:
	if quest_label != null:
		quest_label.text = text
