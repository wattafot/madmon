extends Node

# AudioManager Singleton for Menschenmon
# Handles all audio playback including music, sound effects, and UI sounds

# Audio players
var music_player: AudioStreamPlayer
var sfx_player: AudioStreamPlayer
var ui_player: AudioStreamPlayer

# Audio settings
var master_volume: float = 1.0
var music_volume: float = 0.7
var sfx_volume: float = 0.8
var ui_volume: float = 0.6

# Audio streams (placeholders - would load actual audio files)
var audio_streams = {}

# Current music track
var current_music: String = ""
var music_fade_tween: Tween

func _ready():
	# Create audio players
	music_player = AudioStreamPlayer.new()
	sfx_player = AudioStreamPlayer.new()
	ui_player = AudioStreamPlayer.new()
	
	add_child(music_player)
	add_child(sfx_player)
	add_child(ui_player)
	
	# Set up audio players
	music_player.bus = "Music"
	sfx_player.bus = "SFX"
	ui_player.bus = "UI"
	
	# Set initial volumes
	music_player.volume_db = linear_to_db(master_volume * music_volume)
	sfx_player.volume_db = linear_to_db(master_volume * sfx_volume)
	ui_player.volume_db = linear_to_db(master_volume * ui_volume)
	
	# Load audio streams (placeholder - would load actual files)
	_load_audio_streams()

func _load_audio_streams():
	# Placeholder for loading actual audio files
	# In a real implementation, you would load .ogg or .wav files here
	
	# Example:
	# audio_streams["ui_select"] = preload("res://audio/ui_select.ogg")
	# audio_streams["ui_confirm"] = preload("res://audio/ui_confirm.ogg")
	# audio_streams["battle_music"] = preload("res://audio/battle_music.ogg")
	
	# For now, we'll just have placeholders
	audio_streams = {
		"ui_select": null,
		"ui_confirm": null,
		"ui_cancel": null,
		"ui_error": null,
		"ui_open": null,
		"ui_close": null,
		"battle_music": null,
		"menu_music": null,
		"hit_normal": null,
		"hit_critical": null,
		"heal": null,
		"victory": null,
		"defeat": null,
		"level_up": null,
		"item_use": null,
		"status_effect": null,
		"escape": null,
		"catch_success": null,
		"catch_fail": null
	}

# =============================================================================
# MUSIC SYSTEM
# =============================================================================

func play_music(track_name: String, fade_in: bool = true, loop: bool = true):
	if current_music == track_name:
		return
	
	# Stop current music
	if music_player.playing:
		if fade_in:
			await fade_out_music()
		else:
			music_player.stop()
	
	# Play new music
	if audio_streams.has(track_name) and audio_streams[track_name] != null:
		music_player.stream = audio_streams[track_name]
		music_player.loop = loop
		
		if fade_in:
			music_player.volume_db = linear_to_db(0.0)
			music_player.play()
			await fade_in_music()
		else:
			music_player.volume_db = linear_to_db(master_volume * music_volume)
			music_player.play()
		
		current_music = track_name
	else:
		print("AudioManager: Music track not found: ", track_name)

func stop_music(fade_out: bool = true):
	if music_player.playing:
		if fade_out:
			await fade_out_music()
		else:
			music_player.stop()
	
	current_music = ""

func fade_in_music(duration: float = 1.0):
	if music_fade_tween:
		music_fade_tween.kill()
	
	music_fade_tween = create_tween()
	music_fade_tween.tween_property(music_player, "volume_db", 
		linear_to_db(master_volume * music_volume), duration)

func fade_out_music(duration: float = 1.0):
	if music_fade_tween:
		music_fade_tween.kill()
	
	music_fade_tween = create_tween()
	music_fade_tween.tween_property(music_player, "volume_db", linear_to_db(0.0), duration)
	music_fade_tween.tween_callback(music_player.stop)

# =============================================================================
# SOUND EFFECTS
# =============================================================================

func play_sfx(sound_name: String, pitch: float = 1.0, volume_modifier: float = 1.0):
	if audio_streams.has(sound_name) and audio_streams[sound_name] != null:
		sfx_player.stream = audio_streams[sound_name]
		sfx_player.pitch_scale = pitch
		sfx_player.volume_db = linear_to_db(master_volume * sfx_volume * volume_modifier)
		sfx_player.play()
	else:
		# Debug sound effect call
		print("AudioManager: SFX played: ", sound_name)

func play_ui_sound(sound_name: String, pitch: float = 1.0, volume_modifier: float = 1.0):
	if audio_streams.has(sound_name) and audio_streams[sound_name] != null:
		ui_player.stream = audio_streams[sound_name]
		ui_player.pitch_scale = pitch
		ui_player.volume_db = linear_to_db(master_volume * ui_volume * volume_modifier)
		ui_player.play()
	else:
		# Debug UI sound call
		print("AudioManager: UI sound played: ", sound_name)

# =============================================================================
# CONVENIENCE FUNCTIONS
# =============================================================================

func play_ui_select():
	play_ui_sound("ui_select", 1.0, 0.8)

func play_ui_confirm():
	play_ui_sound("ui_confirm", 1.0, 1.0)

func play_ui_cancel():
	play_ui_sound("ui_cancel", 1.0, 1.0)

func play_ui_error():
	play_ui_sound("ui_error", 1.0, 1.0)

func play_ui_open():
	play_ui_sound("ui_open", 1.0, 0.9)

func play_ui_close():
	play_ui_sound("ui_close", 1.0, 0.9)

func play_hit_sound(is_critical: bool = false):
	if is_critical:
		play_sfx("hit_critical", 1.0, 1.2)
	else:
		play_sfx("hit_normal", 1.0, 1.0)

func play_heal_sound():
	play_sfx("heal", 1.0, 1.0)

func play_victory_sound():
	play_sfx("victory", 1.0, 1.0)

func play_defeat_sound():
	play_sfx("defeat", 1.0, 1.0)

func play_level_up_sound():
	play_sfx("level_up", 1.0, 1.0)

func play_item_use_sound():
	play_sfx("item_use", 1.0, 1.0)

func play_status_effect_sound():
	play_sfx("status_effect", 1.0, 1.0)

func play_escape_sound():
	play_sfx("escape", 1.0, 1.0)

func play_catch_sound(success: bool):
	if success:
		play_sfx("catch_success", 1.0, 1.0)
	else:
		play_sfx("catch_fail", 1.0, 1.0)

# =============================================================================
# VOLUME CONTROL
# =============================================================================

func set_master_volume(volume: float):
	master_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()

func set_music_volume(volume: float):
	music_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()

func set_sfx_volume(volume: float):
	sfx_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()

func set_ui_volume(volume: float):
	ui_volume = clamp(volume, 0.0, 1.0)
	_update_volumes()

func _update_volumes():
	music_player.volume_db = linear_to_db(master_volume * music_volume)
	sfx_player.volume_db = linear_to_db(master_volume * sfx_volume)
	ui_player.volume_db = linear_to_db(master_volume * ui_volume)

# =============================================================================
# BATTLE MUSIC SYSTEM
# =============================================================================

func start_battle_music():
	play_music("battle_music", true, true)

func start_menu_music():
	play_music("menu_music", true, true)

func play_victory_music():
	play_music("victory", false, false)

func play_defeat_music():
	play_music("defeat", false, false)

# =============================================================================
# DYNAMIC AUDIO EFFECTS
# =============================================================================

func play_random_hit_sound(attack_type: String = "normal"):
	var pitch_variation = randf_range(0.9, 1.1)
	var volume_variation = randf_range(0.8, 1.0)
	
	match attack_type.to_lower():
		"alkohol":
			play_sfx("hit_normal", pitch_variation * 0.8, volume_variation * 1.2)
		"party":
			play_sfx("hit_normal", pitch_variation * 1.3, volume_variation * 1.1)
		"chaos":
			play_sfx("hit_normal", pitch_variation * 1.5, volume_variation * 1.3)
		"gemutlich":
			play_sfx("hit_normal", pitch_variation * 0.7, volume_variation * 0.9)
		_:
			play_sfx("hit_normal", pitch_variation, volume_variation)

func play_damage_sound(damage_amount: int):
	# Play different sounds based on damage amount
	var pitch = 1.0
	var volume = 1.0
	
	if damage_amount > 50:
		pitch = 0.8
		volume = 1.2
	elif damage_amount > 30:
		pitch = 0.9
		volume = 1.1
	elif damage_amount > 10:
		pitch = 1.0
		volume = 1.0
	else:
		pitch = 1.1
		volume = 0.9
	
	play_sfx("hit_normal", pitch, volume)

# =============================================================================
# SAVE/LOAD SYSTEM
# =============================================================================

func save_audio_settings():
	var save_data = {
		"master_volume": master_volume,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"ui_volume": ui_volume
	}
	
	var save_file = FileAccess.open("user://audio_settings.save", FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(save_data))
		save_file.close()

func load_audio_settings():
	var save_file = FileAccess.open("user://audio_settings.save", FileAccess.READ)
	if save_file:
		var json_string = save_file.get_as_text()
		save_file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var save_data = json.data
			master_volume = save_data.get("master_volume", 1.0)
			music_volume = save_data.get("music_volume", 0.7)
			sfx_volume = save_data.get("sfx_volume", 0.8)
			ui_volume = save_data.get("ui_volume", 0.6)
			_update_volumes()

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

func is_music_playing() -> bool:
	return music_player.playing

func is_sfx_playing() -> bool:
	return sfx_player.playing

func get_current_music() -> String:
	return current_music

func linear_to_db(linear_value: float) -> float:
	if linear_value <= 0.0:
		return -80.0
	return 20.0 * log(linear_value) / log(10.0)

# =============================================================================
# DEBUG FUNCTIONS
# =============================================================================

func test_all_sounds():
	print("Testing all UI sounds...")
	play_ui_select()
	await get_tree().create_timer(0.5).timeout
	play_ui_confirm()
	await get_tree().create_timer(0.5).timeout
	play_ui_cancel()
	await get_tree().create_timer(0.5).timeout
	
	print("Testing battle sounds...")
	play_hit_sound(false)
	await get_tree().create_timer(0.5).timeout
	play_hit_sound(true)
	await get_tree().create_timer(0.5).timeout
	play_heal_sound()
	await get_tree().create_timer(0.5).timeout
	
	print("Audio test complete!")

func mute_all():
	set_master_volume(0.0)

func unmute_all():
	set_master_volume(1.0)