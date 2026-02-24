extends HBoxContainer

signal play(slot_id: int)
signal delete(slot_id: int)
signal rename(slot_id: int)

@onready var inner: HBoxContainer = $Inputbutton/MarginContainer/HBoxContainer
@onready var spacer: Control = $Inputbutton/MarginContainer/HBoxContainer/Spacer

@onready var play_btn: Button = $Inputbutton/MarginContainer/HBoxContainer/PlayButton
@onready var date_label: Label = $Inputbutton/MarginContainer/HBoxContainer/DateLabel
@onready var ren_btn: Button = $Inputbutton/MarginContainer/HBoxContainer/RenameButton
@onready var del_btn: Button = $Inputbutton/MarginContainer/HBoxContainer/DeleteButton

var slot_id: int = -1

func setup(id: int, slot_name: String, last_saved_unix: int, exists: bool) -> void:
	slot_id = id

	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_FILL
	custom_minimum_size = Vector2(0, 60)

	inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner.size_flags_vertical = Control.SIZE_FILL

	spacer.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	spacer.custom_minimum_size = Vector2(12, 0)

	play_btn.visible = true
	play_btn.disabled = false
	play_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	play_btn.custom_minimum_size = Vector2(520, 48)
	play_btn.clip_text = true

	if exists:
		play_btn.text = "Reprendre : " + slot_name
	else:
		play_btn.text = "Nouvelle : " + slot_name

	date_label.size_flags_horizontal = Control.SIZE_FILL
	date_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	date_label.text = _format_last_save(last_saved_unix)

	ren_btn.custom_minimum_size = Vector2(48, 48)
	ren_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	del_btn.custom_minimum_size = Vector2(48, 48)
	del_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	del_btn.disabled = not exists
	del_btn.visible = exists
	ren_btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ren_btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER

	del_btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	del_btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
	
	ren_btn.text = ""
	del_btn.text = ""
	
	ren_btn.custom_minimum_size = Vector2(56, 56)
	del_btn.custom_minimum_size = Vector2(56, 56)
	
	if not play_btn.pressed.is_connected(_emit_play):
		play_btn.pressed.connect(_emit_play)
	if not del_btn.pressed.is_connected(_emit_delete):
		del_btn.pressed.connect(_emit_delete)
	if not ren_btn.pressed.is_connected(_emit_rename):
		ren_btn.pressed.connect(_emit_rename)

func _emit_play() -> void:
	emit_signal("play", slot_id)

func _emit_delete() -> void:
	emit_signal("delete", slot_id)

func _emit_rename() -> void:
	emit_signal("rename", slot_id)


func _format_last_save(last_saved_unix: int) -> String:
	if last_saved_unix <= 0:
		return "Dernière sauvegarde : Jamais"

	var saved_local_unix: int = _to_local_unix(last_saved_unix)
	var dt_saved: Dictionary = Time.get_datetime_dict_from_unix_time(saved_local_unix)
	var now_local: Dictionary = Time.get_datetime_dict_from_system()

	var today_midnight_local: int = Time.get_unix_time_from_datetime_dict({
		"year": int(now_local.get("year", 0)),
		"month": int(now_local.get("month", 0)),
		"day": int(now_local.get("day", 0)),
		"hour": 0,
		"minute": 0,
		"second": 0
	})
	var yesterday_midnight_local: int = today_midnight_local - 86400
	var dt_yesterday: Dictionary = Time.get_datetime_dict_from_unix_time(yesterday_midnight_local)

	var prefix: String
	if _same_date(dt_saved, now_local):
		prefix = "Aujourd’hui"
	elif _same_date(dt_saved, dt_yesterday):
		prefix = "Hier"
	else:
		prefix = "%02d/%02d/%04d" % [
			int(dt_saved.get("day", 0)),
			int(dt_saved.get("month", 0)),
			int(dt_saved.get("year", 0))
		]

	var hh: int = int(dt_saved.get("hour", 0))
	var mm: int = int(dt_saved.get("minute", 0))
	return "Dernière sauvegarde : %s %02d:%02d" % [prefix, hh, mm]

func _local_offset_seconds() -> int:
	var now_utc: int = Time.get_unix_time_from_system()
	var now_local_dict: Dictionary = Time.get_datetime_dict_from_system()
	var now_local_as_unix: int = Time.get_unix_time_from_datetime_dict(now_local_dict)
	return now_local_as_unix - now_utc

func _to_local_unix(unix_utc: int) -> int:
	return unix_utc + _local_offset_seconds()

func _same_date(a: Dictionary, b: Dictionary) -> bool:
	return int(a.get("year", 0)) == int(b.get("year", 0)) \
		and int(a.get("month", 0)) == int(b.get("month", 0)) \
		and int(a.get("day", 0)) == int(b.get("day", 0))
