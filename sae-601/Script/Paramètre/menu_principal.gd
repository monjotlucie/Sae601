extends Node2D

func _ready():
	Engine.max_fps = 30 
	hide()

func open():
	show()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close():
	hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_jouer_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Paramètre/SaveMenu.tscn")

func _on_options_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/Paramètre/InputSettingsPrincipal.tscn")

func _on_quitter_pressed() -> void:
	get_tree().quit()
