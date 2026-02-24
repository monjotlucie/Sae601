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

	if last_saved_unix <= 0:
		date_label.text = "Dernière sauvegarde : Jamais"
	else:
		var now_utc: int = Time.get_unix_time_from_system()
		var now_local_dict: Dictionary = Time.get_datetime_dict_from_system()
		var now_local_as_unix: int = Time.get_unix_time_from_datetime_dict(now_local_dict)
		var offset_sec: int = now_local_as_unix - now_utc

		var local_unix: int = last_saved_unix + offset_sec
		var dt: Dictionary = Time.get_datetime_dict_from_unix_time(local_unix)

		date_label.text = "Dernière sauvegarde : %02d/%02d/%04d %02d:%02d" % [
			dt.day, dt.month, dt.year, dt.hour, dt.minute
		]

	ren_btn.custom_minimum_size = Vector2(48, 48)
	ren_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	del_btn.custom_minimum_size = Vector2(48, 48)
	del_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	del_btn.disabled = not exists
	del_btn.visible = exists  

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
