extends HBoxContainer
signal play(slot_id: int)
signal delete(slot_id: int)
signal rename(slot_id: int)

@onready var play_btn: Button = $Inputbutton/MarginContainer/HBoxContainer/PlayButton
@onready var date_label: Label = $Inputbutton/MarginContainer/HBoxContainer/DateLabel
@onready var del_btn: Button = $Inputbutton/MarginContainer/HBoxContainer/DeleteButton
@onready var ren_btn: Button = $Inputbutton/MarginContainer/HBoxContainer/RenameButton
@onready var inner: HBoxContainer = $Inputbutton/MarginContainer/HBoxContainer

var slot_id: int

func setup(id: int, slot_name: String, last_saved_unix: int, exists: bool) -> void:
	slot_id = id

	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	custom_minimum_size = Vector2(0, 60)
	
	inner.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	inner.size_flags_vertical = Control.SIZE_FILL
	play_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	play_btn.custom_minimum_size = Vector2(380, 48)
	date_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	date_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	
	play_btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	date_label.size_flags_horizontal = Control.SIZE_FILL

	del_btn.custom_minimum_size = Vector2(48, 48)
	del_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	ren_btn.custom_minimum_size = Vector2(48, 48)
	ren_btn.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

	play_btn.text = "Reprendre la partie" if exists else "Nouvelle partie"
	play_btn.disabled = false

	if last_saved_unix <= 0:
		date_label.text = "Dernière sauvegarde : Jamais"
	else:
		var dt := Time.get_datetime_dict_from_unix_time(last_saved_unix)
		date_label.text = "Dernière sauvegarde : %02d/%02d/%04d" % [dt.day, dt.month, dt.year]

	del_btn.disabled = not exists

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
