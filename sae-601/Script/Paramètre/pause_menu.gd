extends CanvasLayer

@onready var input_settings = get_parent().get_node("InputSettings")

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

# === BOUTONS ===

func _on_jouer_pressed() -> void:
	close()

func _on_options_pressed() -> void:
	hide()
	input_settings.open_from_pause_menu()

func _on_quitter_pressed() -> void:
	get_tree().quit()
