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
var start_position: Vector2 = Vector2.ZERO

const SAVE_PATH := "user://save.json"

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

func save_game() -> void:
	var data := {
		"respawn_x": respawn_position.x,
		"respawn_y": respawn_position.y,
		"is_night": is_night
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		print("Sauvegarde OK :", data)

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		print("Aucune sauvegarde trouvée")
		return

	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not f:
		return

	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		print("Sauvegarde corrompue")
		return

	respawn_position = Vector2(parsed.get("respawn_x", 0.0), parsed.get("respawn_y", 0.0))
	is_night = bool(parsed.get("is_night", false))
	day_night_changed.emit(is_night)

	print("Chargement OK. Respawn:", respawn_position, "Night:", is_night)
