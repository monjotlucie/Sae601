extends Button

signal remap_requested(row: Node)

func _ready() -> void:
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	emit_signal("remap_requested", self)
