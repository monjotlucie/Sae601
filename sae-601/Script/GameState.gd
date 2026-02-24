extends Node

signal day_night_changed(is_night: bool)
signal candles_changed(current: int, total: int)
signal candle_collected(candle_id: String)

const SAVE_DIR: String = "user://saves"
const INDEX_PATH: String = "user://saves/index.json"
const MAX_SLOTS: int = 6

var current_slot_id: int = 1

var _session_start_unix: int = 0
var _session_loaded_playtime_sec: int = 0

var total_candles: int = 6
var candles_collected: int = 0
var collected_candles: Array[String] = []

var is_night: bool = false
var respawn_position: Vector2 = Vector2.ZERO
var start_position: Vector2 = Vector2.ZERO
var active_checkpoint: Area2D = null
var open_pause_menu_on_load: bool = false

func _ready() -> void:
	_ensure_save_dir()
	_ensure_index_file()

func _slot_path(slot_id: int) -> String:
	return "%s/slot_%d.json" % [SAVE_DIR, slot_id]

func _ensure_save_dir() -> void:
	DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func _default_index() -> Dictionary:
	var slots: Array[Dictionary] = []
	for i: int in range(1, MAX_SLOTS + 1):
		slots.append({
			"id": i,
			"name": "Partie %d" % i
		})
	return {"slots": slots}

func _ensure_index_file() -> void:
	if not FileAccess.file_exists(INDEX_PATH):
		_save_index(_default_index())

func _load_index() -> Dictionary:
	_ensure_save_dir()
	_ensure_index_file()

	var f: FileAccess = FileAccess.open(INDEX_PATH, FileAccess.READ)
	if f == null:
		return _default_index()

	var text: String = f.get_as_text()
	var parsed_variant: Variant = JSON.parse_string(text)
	if typeof(parsed_variant) != TYPE_DICTIONARY:
		return _default_index()

	return parsed_variant as Dictionary

func _save_index(idx: Dictionary) -> void:
	var f: FileAccess = FileAccess.open(INDEX_PATH, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(idx))

func get_slot_name(slot_id: int) -> String:
	var idx: Dictionary = _load_index()
	var slots_variant: Variant = idx.get("slots", [])
	var slots: Array = slots_variant as Array

	for s_variant: Variant in slots:
		var s: Dictionary = s_variant as Dictionary
		if int(s.get("id", -1)) == slot_id:
			return String(s.get("name", "Partie %d" % slot_id))

	return "Partie %d" % slot_id

func set_slot_name(slot_id: int, new_name: String) -> void:
	var name: String = new_name.strip_edges()
	if name.is_empty():
		name = "Partie %d" % slot_id

	var idx: Dictionary = _load_index()
	var slots_variant: Variant = idx.get("slots", [])
	var slots: Array = slots_variant as Array

	var found: bool = false
	for i: int in range(slots.size()):
		var s: Dictionary = slots[i] as Dictionary
		if int(s.get("id", -1)) == slot_id:
			s["name"] = name
			slots[i] = s
			found = true
			break

	if not found:
		slots.append({"id": slot_id, "name": name})

	idx["slots"] = slots
	_save_index(idx)


func add_candle(candle_id: String) -> void:
	if collected_candles.has(candle_id):
		return
	collected_candles.append(candle_id)
	candles_collected = collected_candles.size()
	candle_collected.emit(candle_id)
	candles_changed.emit(candles_collected, total_candles)

func toggle_day_night() -> void:
	is_night = !is_night
	day_night_changed.emit(is_night)


func has_save(slot_id: int = current_slot_id) -> bool:
	return FileAccess.file_exists(_slot_path(slot_id))

func save_game(slot_id: int = current_slot_id) -> void:
	_ensure_save_dir()

	var now: int = Time.get_unix_time_from_system()
	var elapsed: int = 0
	if _session_start_unix > 0:
		elapsed = maxi(0, now - _session_start_unix)

	var total_playtime: int = _session_loaded_playtime_sec + elapsed

	var data: Dictionary = {
		"version": 1,
		"is_night": is_night,
		"respawn_x": respawn_position.x,
		"respawn_y": respawn_position.y,
		"collected_candles": collected_candles,
		"saved_unix": now,
		"playtime_sec": total_playtime
	}

	var path: String = _slot_path(slot_id)
	var f: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(data))
		print("Sauvegarde OK (slot ", slot_id, ")")

	_session_loaded_playtime_sec = total_playtime
	_session_start_unix = now

func load_game(slot_id: int = current_slot_id) -> bool:
	var path: String = _slot_path(slot_id)

	if not FileAccess.file_exists(path):
		print("Aucune sauvegarde pour le slot ", slot_id)
		return false

	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return false

	var text: String = f.get_as_text()
	var parsed_variant: Variant = JSON.parse_string(text)
	if typeof(parsed_variant) != TYPE_DICTIONARY:
		print("Sauvegarde corrompue (slot ", slot_id, ")")
		return false

	var data: Dictionary = parsed_variant as Dictionary

	is_night = bool(data.get("is_night", false))
	respawn_position = Vector2(
		float(data.get("respawn_x", 0.0)),
		float(data.get("respawn_y", 0.0))
	)

	collected_candles.clear()
	var arr_variant: Variant = data.get("collected_candles", [])
	var arr: Array = arr_variant as Array
	for v: Variant in arr:
		collected_candles.append(String(v))

	candles_collected = collected_candles.size()

	day_night_changed.emit(is_night)
	candles_changed.emit(candles_collected, total_candles)
	for cid: String in collected_candles:
		candle_collected.emit(cid)

	_session_start_unix = Time.get_unix_time_from_system()
	_session_loaded_playtime_sec = int(data.get("playtime_sec", 0))

	print("Chargement OK (slot ", slot_id, ")")
	return true

func delete_save(slot_id: int = current_slot_id) -> void:
	var path: String = _slot_path(slot_id)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
		print("Sauvegarde supprimée (slot ", slot_id, ")")

func new_game() -> void:
	is_night = false
	respawn_position = Vector2.ZERO
	collected_candles.clear()
	candles_collected = 0

	_session_start_unix = Time.get_unix_time_from_system()
	_session_loaded_playtime_sec = 0

	day_night_changed.emit(is_night)
	candles_changed.emit(candles_collected, total_candles)

func continue_game(slot_id: int = current_slot_id) -> bool:
	return load_game(slot_id)


func get_last_saved_unix(slot_id: int) -> int:
	var path: String = _slot_path(slot_id)
	if not FileAccess.file_exists(path):
		return 0

	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return 0

	var text: String = f.get_as_text()
	var parsed_variant: Variant = JSON.parse_string(text)
	if typeof(parsed_variant) != TYPE_DICTIONARY:
		return 0

	var data: Dictionary = parsed_variant as Dictionary
	return int(data.get("saved_unix", 0))

func get_playtime_sec(slot_id: int) -> int:
	var path: String = _slot_path(slot_id)
	if not FileAccess.file_exists(path):
		return 0

	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		return 0

	var text: String = f.get_as_text()
	var parsed_variant: Variant = JSON.parse_string(text)
	if typeof(parsed_variant) != TYPE_DICTIONARY:
		return 0

	var data: Dictionary = parsed_variant as Dictionary
	return int(data.get("playtime_sec", 0))
