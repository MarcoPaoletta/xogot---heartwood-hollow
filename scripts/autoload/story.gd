class_name StoryState
extends Node

## Global narrative flags, quest state, decision consequences, and run telemetry.

signal flags_changed
signal quest_changed(new_quest: String)
signal zone_changed(zone_id: int)
signal stats_changed
signal message_card_requested(text: String)
signal ending_requested(ending_id: String)
signal world_state_refresh_requested

var bridge_choice: String = "" # "", "fight", "honey"
var pip_choice: String = "" # "", "turn_in", "keep"
var ending: String = "" # "", "forest", "home", "share"

var intro_played: bool = false
var has_honey: bool = false
var honey_delivered: bool = false
var met_bramble: bool = false
var bridge_resolved: bool = false
var shortcut_open: bool = false
var pip_resolved: bool = false
var has_shield: bool = false
var braziers_lit: bool = false
var sparkle_trail_active: bool = false
var seed_awakened: bool = false
var ending_played: bool = false

var current_zone: int = 1
var quest_text: String = "Find the ancient Heartwood"
var monsters_calmed: int = 0
var monsters_bonked: int = 0
var run_time_sec: float = 0.0
var run_active: bool = false
var god_mode: bool = false
var dialogue_open: bool = false
var open_gallery_on_lab_load: bool = false


func _process(delta: float) -> void:
	if run_active and not get_tree().paused and not dialogue_open:
		run_time_sec += delta


func is_east_woods_hostile() -> bool:
	return bridge_choice == "fight"


func is_share_unlocked() -> bool:
	return bridge_choice == "honey" and pip_choice == "keep"


func reset_story() -> void:
	bridge_choice = ""
	pip_choice = ""
	ending = ""
	intro_played = false
	has_honey = false
	honey_delivered = false
	met_bramble = false
	bridge_resolved = false
	shortcut_open = false
	pip_resolved = false
	has_shield = false
	braziers_lit = false
	sparkle_trail_active = false
	seed_awakened = false
	ending_played = false
	current_zone = 1
	quest_text = "Find the ancient Heartwood"
	monsters_calmed = 0
	monsters_bonked = 0
	run_time_sec = 0.0
	run_active = false
	dialogue_open = false
	quest_changed.emit(quest_text)
	zone_changed.emit(current_zone)
	flags_changed.emit()
	stats_changed.emit()
	world_state_refresh_requested.emit()


func set_quest(text: String) -> void:
	if quest_text == text:
		return
	quest_text = text
	quest_changed.emit(quest_text)


func set_zone(zone_id: int) -> void:
	var clamped: int = clampi(zone_id, 1, 4)
	if current_zone == clamped:
		return
	current_zone = clamped
	zone_changed.emit(current_zone)


func record_monster_calmed() -> void:
	monsters_calmed += 1
	stats_changed.emit()


func record_monster_bonked() -> void:
	monsters_bonked += 1
	stats_changed.emit()


func grant_honey() -> void:
	has_honey = true
	honey_delivered = false
	flags_changed.emit()
	world_state_refresh_requested.emit()


func apply_bridge_choice(choice: String, trigger_card: bool = true) -> void:
	bridge_choice = choice
	bridge_resolved = true
	if choice == "honey":
		has_honey = false
		honey_delivered = true
		shortcut_open = true
		set_quest("Explore the Foggy Ruins")
		if trigger_card:
			message_card_requested.emit("Back in Thistle, Mother Clove closes her bakery. That was her last honey.")
	elif choice == "fight":
		shortcut_open = false
		set_quest("Press on through the Foggy Ruins")
	flags_changed.emit()
	world_state_refresh_requested.emit()


func apply_pip_choice(choice: String) -> void:
	pip_choice = choice
	pip_resolved = true
	if choice == "turn_in":
		has_shield = true
		braziers_lit = true
		sparkle_trail_active = false
		set_quest("Enter the Heart Chamber")
	elif choice == "keep":
		has_shield = false
		braziers_lit = false
		sparkle_trail_active = true
		set_quest("Follow Moss to the Heart Chamber")
	flags_changed.emit()
	world_state_refresh_requested.emit()


func awaken_seed() -> void:
	if seed_awakened:
		return
	seed_awakened = true
	set_quest("Choose where the light belongs")
	flags_changed.emit()
	world_state_refresh_requested.emit()


func trigger_ending(ending_id: String) -> void:
	ending = ending_id
	ending_played = true
	run_active = false
	flags_changed.emit()
	ending_requested.emit(ending_id)


func get_bridge_choice_label() -> String:
	if bridge_choice == "honey":
		return "Offered the honey to Chief Bumble"
	if bridge_choice == "fight":
		return "Fought for the bridge"
	return "Undecided"


func get_pip_choice_label() -> String:
	if pip_choice == "keep":
		return "Kept Pip's secret"
	if pip_choice == "turn_in":
		return "Turned Pip in to Captain Rook"
	return "Undecided"


func get_ending_title() -> String:
	match ending:
		"forest":
			return "Return It to the Forest"
		"home":
			return "Carry It Home to Thistle"
		"share":
			return "Share the Light"
		_:
			return "Journey Complete"


func get_formatted_time() -> String:
	var total: int = int(run_time_sec)
	var mins: int = floori(float(total) / 60.0)
	var secs: int = total % 60
	return "%d:%02d" % [mins, secs]
