extends CanvasLayer

@onready var panel := $Panel

var _can_close := false
var _closed := false

func _ready() -> void:
	panel.visible = true
	
	await get_tree().create_timer(3.0).timeout
	_can_close = true

func _unhandled_input(_event: InputEvent) -> void:
	if _closed:
		return
	
	if not _can_close:
		return
	
	_close()

func _close() -> void:
	_closed = true
	panel.visible = false
	queue_free()
