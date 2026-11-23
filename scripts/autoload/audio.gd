class_name AudioManager
extends Node

## Global audio service: Master bus boot mute (M toggles on every screen),
## settings persistence (fullscreen), crossfading zone music, layered ambience,
## and a pre-instanced SFX one-shot pool.

signal mute_changed(is_muted: bool)
signal fullscreen_changed(is_fullscreen: bool)

const SETTINGS_PATH: String = "user://settings.json"

const MUSIC_TRACKS: Dictionary = {
	&"title": "res://assets/audio/music/apple_cider.ogg",
	&"forest": "res://assets/audio/music/fairy_adventure_bpm140.ogg",
	&"battle": "res://assets/audio/music/battleThemeA.mp3",
	&"fog": "res://assets/audio/music/forest_whisper.ogg",
	&"chamber": "res://assets/audio/music/beautiful_forest.ogg",
}

const AMBIENCE_TRACKS: Dictionary = {
	&"forest": "res://assets/audio/ambience/forest_ambience.mp3",
	&"river": "res://assets/audio/ambience/park_ambience_river_90s.ogg",
	&"birds": "res://assets/audio/ambience/park_ambience_birds_90s.ogg",
}

const SFX_PATHS: Dictionary = {
	&"step_dirt": [
		"res://assets/audio/sfx/step_dirt_1.ogg",
		"res://assets/audio/sfx/step_dirt_2.ogg",
		"res://assets/audio/sfx/step_dirt_3.ogg",
		"res://assets/audio/sfx/step_dirt_4.ogg",
	],
	&"step_wood": [
		"res://assets/audio/sfx/step_wood_1.ogg",
		"res://assets/audio/sfx/step_wood_2.ogg",
		"res://assets/audio/sfx/step_wood_3.ogg",
		"res://assets/audio/sfx/step_wood_4.ogg",
	],
	&"step_stone": [
		"res://assets/audio/sfx/step_stone_1.ogg",
		"res://assets/audio/sfx/step_stone_2.ogg",
		"res://assets/audio/sfx/step_stone_3.ogg",
	],
	&"lantern_raise": [
		"res://assets/audio/sfx/cloth_1.ogg",
		"res://assets/audio/sfx/cloth_2.ogg",
	],
	&"lantern_lower": [
		"res://assets/audio/sfx/cloth_3.ogg",
	],
	&"calm_chime": [
		"res://assets/audio/sfx/calm_chime_1.ogg",
		"res://assets/audio/sfx/calm_chime_2.ogg",
	],
	&"sword_swing": [
		"res://assets/audio/sfx/sword_swish_1.ogg",
		"res://assets/audio/sfx/sword_swish_2.ogg",
	],
	&"sword_bonk": [
		"res://assets/audio/sfx/wood_bonk_1.ogg",
		"res://assets/audio/sfx/wood_bonk_2.ogg",
		"res://assets/audio/sfx/wood_bonk_3.ogg",
		"res://assets/audio/sfx/wood_bonk_4.ogg",
	],
	&"sparkle_poof": [
		"res://assets/audio/sfx/sparkle_poof_1.ogg",
		"res://assets/audio/sfx/sparkle_poof_2.ogg",
	],
	&"monster_happy": [
		"res://assets/audio/sfx/monster_happy_1.ogg",
		"res://assets/audio/sfx/monster_happy_2.ogg",
	],
	&"monster_grumpy": [
		"res://assets/audio/sfx/monster_grumpy_1.ogg",
		"res://assets/audio/sfx/monster_grumpy_2.ogg",
	],
	&"player_hurt": [
		"res://assets/audio/sfx/player_hurt_1.ogg",
		"res://assets/audio/sfx/player_hurt_2.ogg",
	],
	&"honey_pour": [
		"res://assets/audio/sfx/honey_pour_1.ogg",
		"res://assets/audio/sfx/honey_pour_2.ogg",
	],
	&"dialogue_blip": [
		"res://assets/audio/sfx/dialogue_blip_1.ogg",
		"res://assets/audio/sfx/dialogue_blip_2.ogg",
	],
	&"ui_hover": [
		"res://assets/audio/sfx/ui_hover.ogg",
	],
	&"ui_click": [
		"res://assets/audio/sfx/ui_click_1.ogg",
		"res://assets/audio/sfx/ui_click_2.ogg",
	],
	&"ui_reject": [
		"res://assets/audio/sfx/ui_reject.ogg",
	],
	&"seed_awaken": [
		"res://assets/audio/stingers/seed_awaken.ogg",
	],
	&"shield_equip": [
		"res://assets/audio/sfx/shield_equip.ogg",
	],
	&"brazier_light": [
		"res://assets/audio/sfx/brazier_light.ogg",
	],
}

const STINGER_PATHS: Dictionary = {
	&"ending_forest": "res://assets/audio/stingers/ending_forest.ogg",
	&"ending_home": "res://assets/audio/stingers/ending_home.ogg",
	&"ending_share": "res://assets/audio/stingers/ending_share.ogg",
	&"choice_honey": "res://assets/audio/stingers/choice_honey.ogg",
	&"choice_fight": "res://assets/audio/stingers/choice_fight.ogg",
	&"calm_burst": "res://assets/audio/stingers/calm_burst.ogg",
}

@onready var _music_a: AudioStreamPlayer = get_node_or_null("MusicA") as AudioStreamPlayer
@onready var _music_b: AudioStreamPlayer = get_node_or_null("MusicB") as AudioStreamPlayer
@onready var _amb_forest: AudioStreamPlayer = get_node_or_null("AmbienceForest") as AudioStreamPlayer
@onready var _amb_river: AudioStreamPlayer = get_node_or_null("AmbienceRiver") as AudioStreamPlayer
@onready var _amb_birds: AudioStreamPlayer = get_node_or_null("AmbienceBirds") as AudioStreamPlayer
@onready var _lantern_hum: AudioStreamPlayer = get_node_or_null("LanternHum") as AudioStreamPlayer
@onready var _stinger: AudioStreamPlayer = get_node_or_null("StingerPlayer") as AudioStreamPlayer
@onready var _sfx_pool_root: Node = get_node_or_null("SfxPool")

var _master_bus: int = 0
var _is_muted: bool = true
var _is_fullscreen: bool = false
var _active_music_a: bool = true
var _current_track: StringName = &""
var _music_base_db: float = -10.0
var _music_duck_db: float = 0.0
var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_cursor: int = 0
var _stream_cache: Dictionary = {}
var _music_tween: Tween = null
var _amb_tween: Tween = null
var _hum_tween: Tween = null
var _rng: RandomNumberGenerator = RandomNumberGenerator.new()


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_rng.randomize()
	_master_bus = AudioServer.get_bus_index("Master")
	# Mandatory rule (GDD Section 11 & DoD #10): ALWAYS boot muted.
	set_muted(true)
	_collect_sfx_pool()
	_load_settings()
	_setup_ambience_players()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_mute"):
		toggle_mute()
		get_viewport().set_input_as_handled()


func is_muted() -> bool:
	return _is_muted


func set_muted(muted: bool) -> void:
	_is_muted = muted
	if _master_bus >= 0:
		AudioServer.set_bus_mute(_master_bus, _is_muted)
	mute_changed.emit(_is_muted)


func toggle_mute() -> void:
	set_muted(not _is_muted)


func is_fullscreen() -> bool:
	return _is_fullscreen


func set_fullscreen(enabled: bool) -> void:
	_is_fullscreen = enabled
	var mode: DisplayServer.WindowMode = DisplayServer.WINDOW_MODE_FULLSCREEN if enabled else DisplayServer.WINDOW_MODE_WINDOWED
	DisplayServer.window_set_mode(mode)
	_save_settings()
	fullscreen_changed.emit(_is_fullscreen)


func toggle_fullscreen() -> void:
	set_fullscreen(not _is_fullscreen)


func play_music(track_key: StringName, fade_sec: float = 1.2) -> void:
	if track_key == _current_track:
		return
	if not MUSIC_TRACKS.has(track_key):
		return
	var stream: AudioStream = _load_looping_stream(String(MUSIC_TRACKS[track_key]))
	if stream == null:
		return
	_current_track = track_key
	var incoming: AudioStreamPlayer = _music_b if _active_music_a else _music_a
	var outgoing: AudioStreamPlayer = _music_a if _active_music_a else _music_b
	_active_music_a = not _active_music_a
	if incoming == null:
		return
	incoming.stream = stream
	incoming.volume_db = -42.0
	incoming.play()
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
	_music_tween = create_tween()
	_music_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_music_tween.set_parallel(true)
	_music_tween.tween_property(incoming, "volume_db", _music_base_db + _music_duck_db, fade_sec).set_trans(Tween.TRANS_SINE)
	if outgoing != null and outgoing.playing:
		_music_tween.tween_property(outgoing, "volume_db", -46.0, fade_sec).set_trans(Tween.TRANS_SINE)
		_music_tween.chain().tween_callback(outgoing.stop)


func duck_music(ducked: bool) -> void:
	_music_duck_db = -7.0 if ducked else 0.0
	var active: AudioStreamPlayer = _music_a if _active_music_a else _music_b
	if active == null or not active.playing:
		return
	var tw: Tween = create_tween()
	tw.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tw.tween_property(active, "volume_db", _music_base_db + _music_duck_db, 0.35).set_trans(Tween.TRANS_SINE)


func set_zone_ambience(zone_id: int) -> void:
	var forest_db: float = -16.0
	var river_db: float = -48.0
	var birds_db: float = -18.0
	match zone_id:
		1:
			forest_db = -16.0
			river_db = -48.0
			birds_db = -17.0
		2:
			forest_db = -18.0
			river_db = -13.0
			birds_db = -24.0
		3:
			forest_db = -14.0
			river_db = -48.0
			birds_db = -48.0
		4:
			forest_db = -17.0
			river_db = -48.0
			birds_db = -15.0
	if _amb_tween != null and _amb_tween.is_valid():
		_amb_tween.kill()
	_amb_tween = create_tween()
	_amb_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_amb_tween.set_parallel(true)
	if _amb_forest != null:
		_amb_tween.tween_property(_amb_forest, "volume_db", forest_db, 1.2)
	if _amb_river != null:
		_amb_tween.tween_property(_amb_river, "volume_db", river_db, 1.2)
	if _amb_birds != null:
		_amb_tween.tween_property(_amb_birds, "volume_db", birds_db, 1.2)


func set_lantern_hum(active: bool) -> void:
	if _lantern_hum == null:
		return
	if _hum_tween != null and _hum_tween.is_valid():
		_hum_tween.kill()
	_hum_tween = create_tween()
	if active:
		if not _lantern_hum.playing and _lantern_hum.stream != null:
			_lantern_hum.volume_db = -38.0
			_lantern_hum.play()
		_hum_tween.tween_property(_lantern_hum, "volume_db", -20.0, 0.25)
	else:
		_hum_tween.tween_property(_lantern_hum, "volume_db", -45.0, 0.25)
		_hum_tween.chain().tween_callback(_lantern_hum.stop)


func play_sfx(key: StringName, pitch_min: float = 0.92, pitch_max: float = 1.08, volume_db: float = -4.0) -> void:
	if _sfx_players.is_empty() or not SFX_PATHS.has(key):
		return
	var paths: Array = SFX_PATHS[key]
	if paths.is_empty():
		return
	var path: String = String(paths[_rng.randi_range(0, paths.size() - 1)])
	var stream: AudioStream = _load_cached_stream(path)
	if stream == null:
		return
	var player: AudioStreamPlayer = _sfx_players[_sfx_cursor]
	_sfx_cursor = (_sfx_cursor + 1) % _sfx_players.size()
	player.stream = stream
	player.pitch_scale = _rng.randf_range(pitch_min, pitch_max)
	player.volume_db = volume_db
	player.play()


func play_stinger(key: StringName, volume_db: float = -4.0) -> void:
	if _stinger == null or not STINGER_PATHS.has(key):
		return
	var stream: AudioStream = _load_cached_stream(String(STINGER_PATHS[key]))
	if stream == null:
		return
	_stinger.stream = stream
	_stinger.volume_db = volume_db
	_stinger.pitch_scale = 1.0
	_stinger.play()


func _collect_sfx_pool() -> void:
	_sfx_players.clear()
	if _sfx_pool_root == null:
		return
	for child: Node in _sfx_pool_root.get_children():
		if child is AudioStreamPlayer:
			_sfx_players.append(child as AudioStreamPlayer)


func _setup_ambience_players() -> void:
	if _amb_forest != null:
		_amb_forest.stream = _load_looping_stream(String(AMBIENCE_TRACKS[&"forest"]))
		_amb_forest.volume_db = -18.0
		if _amb_forest.stream != null:
			_amb_forest.play()
	if _amb_river != null:
		_amb_river.stream = _load_looping_stream(String(AMBIENCE_TRACKS[&"river"]))
		_amb_river.volume_db = -48.0
		if _amb_river.stream != null:
			_amb_river.play()
	if _amb_birds != null:
		_amb_birds.stream = _load_looping_stream(String(AMBIENCE_TRACKS[&"birds"]))
		_amb_birds.volume_db = -20.0
		if _amb_birds.stream != null:
			_amb_birds.play()
	if _lantern_hum != null:
		var hum: AudioStream = _load_looping_stream(String(AMBIENCE_TRACKS[&"forest"]))
		if hum != null:
			_lantern_hum.stream = hum
			_lantern_hum.pitch_scale = 1.85
			_lantern_hum.volume_db = -45.0


func _load_cached_stream(path: String) -> AudioStream:
	if _stream_cache.has(path):
		return _stream_cache[path] as AudioStream
	if not ResourceLoader.exists(path):
		return null
	var res: Resource = ResourceLoader.load(path)
	if res is AudioStream:
		_stream_cache[path] = res
		return res as AudioStream
	return null


func _load_looping_stream(path: String) -> AudioStream:
	var base: AudioStream = _load_cached_stream(path)
	if base == null:
		return null
	var dup: AudioStream = base.duplicate() as AudioStream
	if dup is AudioStreamOggVorbis:
		var ogg: AudioStreamOggVorbis = dup as AudioStreamOggVorbis
		ogg.loop = true
		ogg.loop_offset = 0.0
	elif dup is AudioStreamMP3:
		var mp3: AudioStreamMP3 = dup as AudioStreamMP3
		mp3.loop = true
		mp3.loop_offset = 0.0
	return dup


func _load_settings() -> void:
	if not FileAccess.file_exists(SETTINGS_PATH):
		return
	var file: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return
	var text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if not (parsed is Dictionary):
		return
	var data: Dictionary = parsed as Dictionary
	if data.has("fullscreen") and data["fullscreen"] is bool:
		_is_fullscreen = bool(data["fullscreen"])
		if _is_fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _save_settings() -> void:
	var file: FileAccess = FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file == null:
		return
	var data: Dictionary = {
		"muted_last": _is_muted,
		"fullscreen": _is_fullscreen,
	}
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
