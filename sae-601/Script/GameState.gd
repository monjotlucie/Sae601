extends Node

signal day_night_changed(is_night: bool)
signal candles_changed(current: int, total: int)
signal candle_collected(candle_id: String)

const SAVE_DIR := "user://saves"
const MAX_SLOTS := 6

# Slot par défaut (tu pourras le changer depuis le menu plus tard)
var current_slot_id: int = 1

var total_candles: int = 6
var candles_collected: int = 0
var collected_candles: Array[String] = []

var is_night := false
var respawn_position: Vector2 = Vector2.ZERO
var start_position: Vector2 = Vector2.ZERO
var active_checkpoint: Area2D = null
var open_pause_menu_on_load: bool = false

func _ready() -> void:
	# Avant: load_game() automatique sur 1 fichier.
	# Maintenant: on peut le garder, mais sur le slot courant.
	load_game(current_slot_id)

func _slot_path(slot_id: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIR, slot_id]

func _ensure_save_dir() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)

func add_candle(candle_id: String) -> void:
	if collected_candles.has(candle_id):
		return
	collected_candles.append(candle_id)
	candles_collected = collected_candles.size()
	candle_collected.emit(candle_id)
	candles_changed.emit(candles_collected, total_candles)

func save_game(slot_id: int = current_slot_id) -> void:
	_ensure_save_dir()

	var data := {
		"version": 1,
		"is_night": is_night,
		"respawn_x": respawn_position.x,
		"respawn_y": respawn_position.y,
		"collected_candles": collected_candles,
		"saved_unix": Time.get_unix_time_from_system()
	}

	var path := _slot_path(slot_id)
	var f := FileAccess.open(path, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		print("Sauvegarde OK (slot ", slot_id, ") :", data)

func has_save(slot_id: int = current_slot_id) -> bool:
	return FileAccess.file_exists(_slot_path(slot_id))

func toggle_day_night() -> void:
	is_night = !is_night
	day_night_changed.emit(is_night)

func load_game(slot_id: int = current_slot_id) -> bool:
	var path := _slot_path(slot_id)

	if not FileAccess.file_exists(path):
		print("Aucune sauvegarde pour le slot ", slot_id)
		return false

	var f := FileAccess.open(path, FileAccess.READ)
	if not f:
		return false

	var parsed = JSON.parse_string(f.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		print("Sauvegarde corrompue (slot ", slot_id, ")")
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

	print("Chargement OK (slot ", slot_id, ") :", parsed)
	return true

func delete_save(slot_id: int = current_slot_id) -> void:
	var path := _slot_path(slot_id)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("Sauvegarde supprimée (slot ", slot_id, ")")

func new_game() -> void:
	is_night = false
	respawn_position = Vector2.ZERO
	collected_candles.clear()
	candles_collected = 0

	day_night_changed.emit(is_night)
	candles_changed.emit(candles_collected, total_candles)

func continue_game(slot_id: int = current_slot_id) -> bool:
	return load_game(slot_id)
