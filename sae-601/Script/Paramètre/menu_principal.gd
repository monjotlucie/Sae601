extends Node2D

func _ready():
	hide()

func open():
	show()
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close():
	hide()
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# === BOUTONS ===

func _on_jouer_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Paramètre/InputSettings.tscn")

func _on_quitter_pressed() -> void:
	get_tree().quit()
