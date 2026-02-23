extends Node

signal day_night_changed(is_night: bool)
signal candles_changed(current: int, total: int)
signal candle_collected(candle_id: String)

var total_candles: int = 6
var candles_collected: int = 0
var collected_candles: Array[String] = []

var is_night := false
var respawn_position: Vector2 = Vector2.ZERO
var active_checkpoint: Area2D = null
var open_pause_menu_on_load: bool = false

func toggle_day_night() -> void:
	is_night = !is_night
	day_night_changed.emit(is_night)

func add_candle(candle_id: String) -> void:
	if collected_candles.has(candle_id):
		return

	collected_candles.append(candle_id)
	candles_collected = collected_candles.size()

	candle_collected.emit(candle_id)
	candles_changed.emit(candles_collected, total_candles)

func reset_candles() -> void:
	collected_candles.clear()
	candles_collected = 0
	candles_changed.emit(candles_collected, total_candles)
