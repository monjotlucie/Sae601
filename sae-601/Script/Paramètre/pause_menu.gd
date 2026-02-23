extends CanvasLayer

@onready var input_settings: Node = get_tree().current_scene.get_node_or_null("UILayer/InputSettings")

func _ready():
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
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
	close()

func _on_options_pressed() -> void:
	if input_settings == null:
		push_error("InputSettings introuvable : attendu UILayer/InputSettings. Vérifie le nom des nodes.")
		return
	hide()
	input_settings.open_from_pause_menu()
	
func _on_menu_pressed() -> void:
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().change_scene_to_file("res://Scenes/Paramètre/MenuPrincipal.tscn")
	
func _on_quitter_pressed() -> void:
	get_tree().quit()
