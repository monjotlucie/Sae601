extends CanvasLayer

@onready var candles_label: Label = $CandlesLabel
var hide_task_id: int = 0

func _ready() -> void:
	candles_label.visible = false
	GameState.candles_changed.connect(_on_candles_changed)

func _on_candles_changed(current: int, total: int) -> void:
	candles_label.text = str(current) + "/" + str(total)
	candles_label.visible = true

	hide_task_id += 1
	var my_id := hide_task_id
	await get_tree().create_timer(5.0).timeout

	if my_id == hide_task_id:
		candles_label.visible = false
