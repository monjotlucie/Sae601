extends CanvasLayer

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

func _on_reprendre_pressed() -> void:
	close()

func _on_options_pressed() -> void:
	print("Options (à venir)")

func _on_quitter_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()
