extends CanvasLayer

@onready var candles_label: Label = $CandlesLabel
@onready var win_label: Label = $WinLabel

var hide_task_id: int = 0
var win_shown := false

func _ready() -> void:
	candles_label.visible = false
	win_label.visible = false
	GameState.candles_changed.connect(_on_candles_changed)

func _on_candles_changed(current: int, total: int) -> void:
	# Affichage compteur
	candles_label.text = str(current) + "/" + str(total)
	candles_label.visible = true

	hide_task_id += 1
	var my_id := hide_task_id
	_hide_counter_later(my_id)

	# Victoire
	if not win_shown and total > 0 and current >= total:
		win_shown = true
		_show_win_message()

func _hide_counter_later(my_id: int) -> void:
	await get_tree().create_timer(5.0).timeout
	if my_id == hide_task_id and not win_shown:
		candles_label.visible = false

func _show_win_message() -> void:
	win_label.text = "Vous avez tout trouvé !\nVous avez gagné !"
	win_label.visible = true
	candles_label.visible = false
