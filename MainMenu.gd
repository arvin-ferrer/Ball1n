extends Control

@onready var settings_panel = $SettingsPanel
@onready var slider_music = $SettingsPanel/VBoxContainer/SliderMusic
@onready var slider_sfx = $SettingsPanel/VBoxContainer/SliderSFX

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	get_tree().paused = true
	
	var music_idx = AudioServer.get_bus_index("Music")
	var sfx_idx = AudioServer.get_bus_index("SFX")
	
	if music_idx != -1:
		slider_music.value = db_to_linear(AudioServer.get_bus_volume_db(music_idx))
	if sfx_idx != -1:
		slider_sfx.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_idx))

func _on_btn_play_pressed():
	get_tree().paused = false
	visible = false

func _on_btn_settings_pressed():
	settings_panel.visible = true

func _on_btn_quit_pressed():
	get_tree().quit()

func _on_btn_back_pressed():
	settings_panel.visible = false

func _on_slider_music_value_changed(value):
	var bus_idx = AudioServer.get_bus_index("Music")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))

func _on_slider_sfx_value_changed(value):
	var bus_idx = AudioServer.get_bus_index("SFX")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
