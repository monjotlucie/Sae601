extends Node

signal day_night_changed(is_night: bool)
signal candles_changed(current: int, total: int)
signal candle_collected(candle_id: String)

const SAVE_PATH := "user://save.json"

var total_candles: int = 6
var candles_collected: int = 0
var collected_candles: Array[String] = []

var is_night := false
var respawn_position: Vector2 = Vector2.ZERO
var start_position: Vector2 = Vector2.ZERO
var active_checkpoint: Area2D = null
var open_pause_menu_on_load: bool = false

func _ready() -> void:
	load_game()
	
func add_candle(candle_id: String) -> void:
	if collected_candles.has(candle_id):
		return
	collected_candles.append(candle_id)
	candles_collected = collected_candles.size()
	candle_collected.emit(candle_id)
	candles_changed.emit(candles_collected, total_candles)

func save_game() -> void:
	var data := {
		"version": 1,
		"is_night": is_night,
		"respawn_x": respawn_position.x,
		"respawn_y": respawn_position.y,
		"collected_candles": collected_candles
	}

	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		print("Sauvegarde OK :", data)

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func toggle_day_night() -> void:
	is_night = !is_night
	day_night_changed.emit(is_night)
	
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		print("Aucune sauvegarde")
		return false

	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not f:
		return false

	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		print("Sauvegarde corrompue")
		return false

	is_night = bool(parsed.get("is_night", false))
	respawn_position = Vector2(
		float(parsed.get("respawn_x", 0.0)),
		float(parsed.get("respawn_y", 0.0))
	)

	collected_candles.clear()

	var arr = parsed.get("collected_candles", [])
	if arr != null:
		for v in arr:
			collected_candles.append(String(v))
	candles_collected = collected_candles.size()

	day_night_changed.emit(is_night)
	candles_changed.emit(candles_collected, total_candles)
	for cid in collected_candles:
		candle_collected.emit(cid)

	print("Chargement OK :", parsed)
	return true

func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
		print("Sauvegarde supprimée")

func new_game() -> void:
	is_night = false
	respawn_position = Vector2.ZERO
	collected_candles.clear()
	candles_collected = 0

	day_night_changed.emit(is_night)
	candles_changed.emit(candles_collected, total_candles)

func continue_game() -> bool:
	return load_game()
