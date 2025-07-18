extends Node

# Comprehensive Audio Management System for Menschenmon
# Handles music, sound effects, voice acting, and audio settings

signal audio_settings_changed
signal music_track_changed(track_name: String)
signal sound_effect_played(effect_name: String)

# Audio players
var music_player: AudioStreamPlayer
var ambient_player: AudioStreamPlayer
var sfx_players: Array = []  # Array of AudioStreamPlayer
var voice_player: AudioStreamPlayer

# Audio pools for performance
var sfx_pool_size: int = 10
var current_sfx_index: int = 0

# Audio settings
var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 0.9
var voice_volume: float = 1.0
var ambient_volume: float = 0.6

# Music system
var current_music_track: String = ""
var music_fade_duration: float = 2.0
var music_loop_enabled: bool = true

# Sound libraries
var music_library: Dictionary = {}
var sfx_library: Dictionary = {}
var voice_library: Dictionary = {}
var ambient_library: Dictionary = {}

# Audio state
var audio_enabled: bool = true
var music_enabled: bool = true
var sfx_enabled: bool = true
var voice_enabled: bool = true
var ambient_enabled: bool = true

# Crossfade system
var crossfade_tween: Tween
var current_crossfade_target: AudioStreamPlayer

func _ready():
	# Initialize audio system
	print("AudioManager: Initializing...")
	
	# Create audio players
	_create_audio_players()
	
	# Load audio libraries
	_load_audio_libraries()
	
	# Setup audio buses
	_setup_audio_buses()
	
	# Connect to settings system
	_connect_to_settings()
	
	print("AudioManager: Ready")

func _create_audio_players():
	# Create main music player
	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	music_player.bus = "Music"
	add_child(music_player)
	
	# Create ambient audio player
	ambient_player = AudioStreamPlayer.new()
	ambient_player.name = "AmbientPlayer"
	ambient_player.bus = "Ambient"
	add_child(ambient_player)
	
	# Create voice player
	voice_player = AudioStreamPlayer.new()
	voice_player.name = "VoicePlayer"
	voice_player.bus = "Voice"
	add_child(voice_player)
	
	# Create SFX player pool
	for i in range(sfx_pool_size):
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.name = "SFXPlayer" + str(i)
		sfx_player.bus = "SFX"
		add_child(sfx_player)
		sfx_players.append(sfx_player)
	
	# Create crossfade tween (will be created when needed)
	crossfade_tween = null
	
	print("AudioManager: Created ", sfx_pool_size, " SFX players")

func _load_audio_libraries():
	# Load music tracks
	_load_music_library()
	
	# Load sound effects
	_load_sfx_library()
	
	# Load voice clips
	_load_voice_library()
	
	# Load ambient sounds
	_load_ambient_library()

func _load_music_library():
	# Define music tracks (placeholder paths)
	music_library = {
		"overworld": "res://audio/music/overworld.ogg",
		"battle": "res://audio/music/battle.ogg",
		"victory": "res://audio/music/victory.ogg",
		"defeat": "res://audio/music/defeat.ogg",
		"menu": "res://audio/music/menu.ogg",
		"dialogue": "res://audio/music/dialogue.ogg",
		"emotional": "res://audio/music/emotional.ogg",
		"suspense": "res://audio/music/suspense.ogg"
	}
	
	print("AudioManager: Loaded ", music_library.size(), " music tracks")

func _load_sfx_library():
	# Define sound effects (placeholder paths)
	sfx_library = {
		# UI sounds
		"ui_select": "res://audio/sfx/ui_select.ogg",
		"ui_confirm": "res://audio/sfx/ui_confirm.ogg",
		"ui_cancel": "res://audio/sfx/ui_cancel.ogg",
		"ui_error": "res://audio/sfx/ui_error.ogg",
		
		# Battle sounds
		"battle_start": "res://audio/sfx/battle_start.ogg",
		"attack_hit": "res://audio/sfx/attack_hit.ogg",
		"attack_miss": "res://audio/sfx/attack_miss.ogg",
		"critical_hit": "res://audio/sfx/critical_hit.ogg",
		"super_effective": "res://audio/sfx/super_effective.ogg",
		"not_effective": "res://audio/sfx/not_effective.ogg",
		"status_effect": "res://audio/sfx/status_effect.ogg",
		"level_up": "res://audio/sfx/level_up.ogg",
		"hp_low": "res://audio/sfx/hp_low.ogg",
		"faint": "res://audio/sfx/faint.ogg",
		
		# Catch sounds
		"catch_throw": "res://audio/sfx/catch_throw.ogg",
		"catch_success": "res://audio/sfx/catch_success.ogg",
		"catch_fail": "res://audio/sfx/catch_fail.ogg",
		"catch_break": "res://audio/sfx/catch_break.ogg",
		
		# Human sounds
		"human_cry_benedikt": "res://audio/sfx/human_benedikt.ogg",
		"human_cry_felix": "res://audio/sfx/human_felix.ogg",
		"human_cry_anna": "res://audio/sfx/human_anna.ogg",
		
		# Environment sounds
		"footstep": "res://audio/sfx/footstep.ogg",
		"door_open": "res://audio/sfx/door_open.ogg",
		"door_close": "res://audio/sfx/door_close.ogg",
		"item_pickup": "res://audio/sfx/item_pickup.ogg",
		"save_game": "res://audio/sfx/save_game.ogg",
		"load_game": "res://audio/sfx/load_game.ogg"
	}
	
	print("AudioManager: Loaded ", sfx_library.size(), " sound effects")

func _load_voice_library():
	# Define voice clips (placeholder paths)
	voice_library = {
		"benedikt_intro": "res://audio/voice/benedikt_intro.ogg",
		"felix_laugh": "res://audio/voice/felix_laugh.ogg",
		"anna_chaos": "res://audio/voice/anna_chaos.ogg",
		"narrator_intro": "res://audio/voice/narrator_intro.ogg"
	}
	
	print("AudioManager: Loaded ", voice_library.size(), " voice clips")

func _load_ambient_library():
	# Define ambient sounds (placeholder paths)
	ambient_library = {
		"forest": "res://audio/ambient/forest.ogg",
		"city": "res://audio/ambient/city.ogg",
		"indoor": "res://audio/ambient/indoor.ogg",
		"battle_arena": "res://audio/ambient/battle_arena.ogg",
		"night": "res://audio/ambient/night.ogg"
	}
	
	print("AudioManager: Loaded ", ambient_library.size(), " ambient sounds")

func _setup_audio_buses():
	# Create audio buses for different audio types
	# This would be done in Godot's audio bus setup, but we can set volumes here
	_update_audio_volumes()

func _connect_to_settings():
	# Connect to settings system when available
	var settings_manager = get_node_or_null("/root/SettingsManager")
	if settings_manager:
		settings_manager.settings_changed.connect(_on_settings_changed)

func _on_settings_changed(settings: Dictionary):
	# Update audio settings when changed
	if settings.has("master_volume"):
		master_volume = settings["master_volume"]
	if settings.has("music_volume"):
		music_volume = settings["music_volume"]
	if settings.has("sfx_volume"):
		sfx_volume = settings["sfx_volume"]
	if settings.has("voice_volume"):
		voice_volume = settings["voice_volume"]
	if settings.has("ambient_volume"):
		ambient_volume = settings["ambient_volume"]
	
	_update_audio_volumes()
	audio_settings_changed.emit()

func _update_audio_volumes():
	# Update volume for all audio players
	if music_player:
		music_player.volume_db = _linear_to_db(master_volume * music_volume)
	
	if ambient_player:
		ambient_player.volume_db = _linear_to_db(master_volume * ambient_volume)
	
	if voice_player:
		voice_player.volume_db = _linear_to_db(master_volume * voice_volume)
	
	for sfx_player in sfx_players:
		sfx_player.volume_db = _linear_to_db(master_volume * sfx_volume)

func _linear_to_db(linear: float) -> float:
	if linear <= 0.0:
		return -80.0
	return 20.0 * log(linear) / log(10.0)

# Public API - Music Control
func play_music(track_name: String, fade_in: bool = true, loop: bool = true):
	if not music_enabled or not audio_enabled:
		return
	
	if track_name == current_music_track:
		return  # Already playing
	
	if track_name in music_library:
		var music_path = music_library[track_name]
		var music_stream = load(music_path)
		
		if music_stream != null:
			if fade_in and music_player.playing:
				_crossfade_to_music(music_stream, loop)
			else:
				music_player.stream = music_stream
				music_player.playing = true
				if loop:
					music_player.stream.loop = true
				current_music_track = track_name
				music_track_changed.emit(track_name)
				print("AudioManager: Playing music track: ", track_name)
		else:
			print("AudioManager: Failed to load music: ", music_path)
	else:
		print("AudioManager: Music track not found: ", track_name)

func stop_music(fade_out: bool = true):
	if fade_out:
		_fade_out_music()
	else:
		music_player.stop()
		current_music_track = ""

func pause_music():
	if music_player.playing:
		music_player.stream_paused = true

func resume_music():
	if music_player.stream_paused:
		music_player.stream_paused = false

func set_music_position(position: float):
	if music_player.playing:
		music_player.seek(position)

func get_music_position() -> float:
	return music_player.get_playback_position()

func is_music_playing() -> bool:
	return music_player.playing

func _crossfade_to_music(new_stream: AudioStream, loop: bool):
	# Create temporary player for crossfade
	var temp_player = AudioStreamPlayer.new()
	temp_player.stream = new_stream
	temp_player.bus = "Music"
	temp_player.volume_db = -80.0  # Start silent
	if loop:
		temp_player.stream.loop = true
	add_child(temp_player)
	temp_player.play()
	
	# Crossfade
	crossfade_tween = create_tween()
	crossfade_tween.tween_parallel().tween_property(music_player, "volume_db", -80.0, music_fade_duration)
	crossfade_tween.tween_parallel().tween_property(temp_player, "volume_db", _linear_to_db(master_volume * music_volume), music_fade_duration)
	
	await crossfade_tween.finished
	
	# Switch players
	music_player.stop()
	remove_child(music_player)
	music_player = temp_player
	current_music_track = ""  # Will be set by caller

func _fade_out_music():
	var original_volume = music_player.volume_db
	crossfade_tween = create_tween()
	crossfade_tween.tween_property(music_player, "volume_db", -80.0, music_fade_duration)
	await crossfade_tween.finished
	music_player.stop()
	music_player.volume_db = original_volume
	current_music_track = ""

# Public API - Sound Effects
func play_sfx(effect_name: String, volume_override: float = 1.0):
	if not sfx_enabled or not audio_enabled:
		return
	
	if effect_name in sfx_library:
		var sfx_path = sfx_library[effect_name]
		var sfx_stream = load(sfx_path)
		
		if sfx_stream != null:
			var sfx_player = _get_available_sfx_player()
			if sfx_player:
				sfx_player.stream = sfx_stream
				sfx_player.volume_db = _linear_to_db(master_volume * sfx_volume * volume_override)
				sfx_player.play()
				sound_effect_played.emit(effect_name)
				print("AudioManager: Playing SFX: ", effect_name)
		else:
			print("AudioManager: Failed to load SFX: ", sfx_path)
	else:
		print("AudioManager: SFX not found: ", effect_name)

func play_sfx_at_position(effect_name: String, position: Vector2, volume_override: float = 1.0):
	# For 2D positional audio (future enhancement)
	play_sfx(effect_name, volume_override)

func stop_all_sfx():
	for sfx_player in sfx_players:
		sfx_player.stop()

func _get_available_sfx_player() -> AudioStreamPlayer:
	# Round-robin selection of SFX players
	var player = sfx_players[current_sfx_index]
	current_sfx_index = (current_sfx_index + 1) % sfx_pool_size
	return player

# Public API - Voice
func play_voice(voice_name: String, interrupt_current: bool = true):
	if not voice_enabled or not audio_enabled:
		return
	
	if voice_name in voice_library:
		var voice_path = voice_library[voice_name]
		var voice_stream = load(voice_path)
		
		if voice_stream != null:
			if interrupt_current or not voice_player.playing:
				voice_player.stream = voice_stream
				voice_player.play()
				print("AudioManager: Playing voice: ", voice_name)
		else:
			print("AudioManager: Failed to load voice: ", voice_path)
	else:
		print("AudioManager: Voice clip not found: ", voice_name)

func stop_voice():
	voice_player.stop()

func is_voice_playing() -> bool:
	return voice_player.playing

# Public API - Ambient
func play_ambient(ambient_name: String, fade_in: bool = true, loop: bool = true):
	if not ambient_enabled or not audio_enabled:
		return
	
	if ambient_name in ambient_library:
		var ambient_path = ambient_library[ambient_name]
		var ambient_stream = load(ambient_path)
		
		if ambient_stream != null:
			if fade_in and ambient_player.playing:
				_fade_ambient_to(ambient_stream, loop)
			else:
				ambient_player.stream = ambient_stream
				ambient_player.playing = true
				if loop:
					ambient_player.stream.loop = true
				print("AudioManager: Playing ambient: ", ambient_name)
		else:
			print("AudioManager: Failed to load ambient: ", ambient_path)
	else:
		print("AudioManager: Ambient sound not found: ", ambient_name)

func stop_ambient(fade_out: bool = true):
	if fade_out:
		_fade_out_ambient()
	else:
		ambient_player.stop()

func _fade_ambient_to(new_stream: AudioStream, loop: bool):
	var original_volume = ambient_player.volume_db
	crossfade_tween = create_tween()
	crossfade_tween.tween_property(ambient_player, "volume_db", -80.0, 1.0)
	await crossfade_tween.finished
	
	ambient_player.stream = new_stream
	if loop:
		ambient_player.stream.loop = true
	ambient_player.play()
	
	crossfade_tween = create_tween()
	crossfade_tween.tween_property(ambient_player, "volume_db", original_volume, 1.0)

func _fade_out_ambient():
	var original_volume = ambient_player.volume_db
	crossfade_tween = create_tween()
	crossfade_tween.tween_property(ambient_player, "volume_db", -80.0, 1.0)
	await crossfade_tween.finished
	ambient_player.stop()
	ambient_player.volume_db = original_volume

# Public API - Settings
func set_master_volume(volume: float):
	master_volume = clamp(volume, 0.0, 1.0)
	_update_audio_volumes()

func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)
	_update_audio_volumes()

func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)
	_update_audio_volumes()

func set_voice_volume(volume: float):
	voice_volume = clamp(volume, 0.0, 1.0)
	_update_audio_volumes()

func set_ambient_volume(volume: float):
	ambient_volume = clamp(volume, 0.0, 1.0)
	_update_audio_volumes()

func set_audio_enabled(enabled: bool):
	audio_enabled = enabled
	if not enabled:
		stop_music(false)
		stop_all_sfx()
		stop_voice()
		stop_ambient(false)

func set_music_enabled(enabled: bool):
	music_enabled = enabled
	if not enabled:
		stop_music(false)

func set_sfx_enabled(enabled: bool):
	sfx_enabled = enabled
	if not enabled:
		stop_all_sfx()

func set_voice_enabled(enabled: bool):
	voice_enabled = enabled
	if not enabled:
		stop_voice()

func set_ambient_enabled(enabled: bool):
	ambient_enabled = enabled
	if not enabled:
		stop_ambient(false)

# Public API - Utility
func get_current_music_track() -> String:
	return current_music_track

func get_audio_settings() -> Dictionary:
	return {
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"voice_volume": voice_volume,
		"ambient_volume": ambient_volume,
		"audio_enabled": audio_enabled,
		"music_enabled": music_enabled,
		"sfx_enabled": sfx_enabled,
		"voice_enabled": voice_enabled,
		"ambient_enabled": ambient_enabled
	}

func get_available_tracks() -> Dictionary:
	return {
		"music": music_library.keys(),
		"sfx": sfx_library.keys(),
		"voice": voice_library.keys(),
		"ambient": ambient_library.keys()
	}

# Battle-specific audio functions
func play_battle_music():
	play_music("battle", true, true)

func play_victory_music():
	play_music("victory", true, false)

func play_defeat_music():
	play_music("defeat", true, false)

func play_attack_sfx(attack_type: String, is_critical: bool = false, effectiveness: float = 1.0):
	if is_critical:
		play_sfx("critical_hit")
	else:
		play_sfx("attack_hit")
	
	if effectiveness > 1.0:
		play_sfx("super_effective")
	elif effectiveness < 1.0:
		play_sfx("not_effective")

func play_catch_sequence(success: bool):
	play_sfx("catch_throw")
	await get_tree().create_timer(1.0).timeout
	
	if success:
		play_sfx("catch_success")
	else:
		play_sfx("catch_fail")

# UI-specific audio functions
func play_ui_select():
	play_sfx("ui_select", 0.7)

func play_ui_confirm():
	play_sfx("ui_confirm", 0.8)

func play_ui_cancel():
	play_sfx("ui_cancel", 0.6)

func play_ui_error():
	play_sfx("ui_error", 0.9)

# Scene-specific audio functions
func play_scene_audio(scene_name: String):
	match scene_name:
		"overworld":
			play_music("overworld")
			play_ambient("forest")
		"battle":
			play_battle_music()
			play_ambient("battle_arena")
		"menu":
			play_music("menu")
			stop_ambient()
		"dialogue":
			play_music("dialogue")
		_:
			# Default to overworld music
			play_music("overworld")

# Debug functions
func test_audio_system():
	print("AudioManager: Testing audio system...")
	
	# Test music
	play_music("overworld")
	await get_tree().create_timer(2.0).timeout
	
	# Test SFX
	play_sfx("ui_select")
	await get_tree().create_timer(0.5).timeout
	play_sfx("attack_hit")
	await get_tree().create_timer(0.5).timeout
	
	# Test voice
	play_voice("benedikt_intro")
	await get_tree().create_timer(1.0).timeout
	
	# Test ambient
	play_ambient("forest")
	
	print("AudioManager: Audio test complete")