extends Control

const INPUT_BUTTON_SCENE := preload("res://Scenes/Paramètre/input_button.tscn")
const SAVE_PATH := "user://input_bindings.cfg"

@onready var action_list: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList

var is_remapping: bool = false
var action_to_remap: StringName
var remapping_row: Node = null

func _ready() -> void:
	_load_bindings()
	_create_action_list()

func _create_action_list() -> void:
	InputMap.load_from_project_settings()

	for child in action_list.get_children():
		child.queue_free()

	for action in InputMap.get_actions():
		if str(action).begins_with("ui_"):
			continue

		var row := INPUT_BUTTON_SCENE.instantiate()
		action_list.add_child(row)

		var label_action: Label = row.get_node("MarginContainer/HBoxContainer/LabelAction")
		var label_input: Label = row.get_node("MarginContainer/HBoxContainer/LabelInput")

		label_action.text = str(action)
		label_input.text = _get_action_first_event_text(action)

		# Stocker l'action dans la ligne (pratique)
		row.set_meta("action_name", action)

		# Clic sur la ligne => demande de remap
		if row.has_signal("remap_requested"):
			row.remap_requested.connect(_on_row_remap_requested)
		else:
			# Si tu n'as pas mis le script sur InputButton, fallback: on connecte pressed direct
			if row is Button:
				row.pressed.connect(_on_row_pressed_fallback.bind(row))

func _on_row_pressed_fallback(row: Node) -> void:
	_on_row_remap_requested(row)

func _on_row_remap_requested(row: Node) -> void:
	is_remapping = true
	remapping_row = row
	action_to_remap = row.get_meta("action_name")

	var label_input: Label = remapping_row.get_node("MarginContainer/HBoxContainer/LabelInput")
	label_input.text = "Appuie sur une touche..."

func _unhandled_input(event: InputEvent) -> void:
	if not is_remapping:
		return

	if event is InputEventMouseMotion:
		return

	if event is InputEventKey and not event.pressed:
		return
	if event is InputEventMouseButton and not event.pressed:
		return

	# ESC pour annuler
	if event is InputEventKey and event.keycode == KEY_ESCAPE:
		_cancel_remap()
		return

	_apply_remap(event)
	get_viewport().set_input_as_handled()

func _apply_remap(event: InputEvent) -> void:
	InputMap.action_erase_events(action_to_remap)
	InputMap.action_add_event(action_to_remap, event)

	var label_input: Label = remapping_row.get_node("$MarginContainer/HBoxContainer/LabelAction")
	label_input.text = event.as_text()

	is_remapping = false
	remapping_row = null

	_save_bindings()

func _cancel_remap() -> void:
	if remapping_row != null:
		var label_input: Label = remapping_row.get_node("$MarginContainer/HBoxContainer/LabelInput")
		label_input.text = _get_action_first_event_text(action_to_remap)

	is_remapping = false
	remapping_row = null

func _get_action_first_event_text(action: StringName) -> String:
	var events := InputMap.action_get_events(action)
	if events.size() == 0:
		return ""
	return events[0].as_text()

# ---- Sauvegarde / chargement robuste ----

func _save_bindings() -> void:
	var cfg := ConfigFile.new()

	for action in InputMap.get_actions():
		if str(action).begins_with("ui_"):
			continue

		var events := InputMap.action_get_events(action)
		if events.size() == 0:
			continue

		var e := events[0]
		var data := {}

		if e is InputEventKey:
			data = {"type":"key", "keycode": e.keycode, "physical_keycode": e.physical_keycode}
		elif e is InputEventMouseButton:
			data = {"type":"mouse", "button_index": e.button_index}
		else:
			continue

		cfg.set_value("input", str(action), data)

	cfg.save(SAVE_PATH)

func _load_bindings() -> void:
	var cfg := ConfigFile.new()
	var err := cfg.load(SAVE_PATH)
	if err != OK:
		return

	InputMap.load_from_project_settings()

	var keys := cfg.get_section_keys("input")
	for action_str in keys:
		var data = cfg.get_value("input", action_str, null)
		if data == null or typeof(data) != TYPE_DICTIONARY:
			continue

		var action: StringName = StringName(action_str)

		var ev: InputEvent = null
		if data.get("type") == "key":
			var k := InputEventKey.new()
			k.keycode = int(data.get("keycode", 0))
			k.physical_keycode = int(data.get("physical_keycode", 0))
			ev = k
		elif data.get("type") == "mouse":
			var m := InputEventMouseButton.new()
			m.button_index = int(data.get("button_index", 0))
			ev = m

		if ev != null:
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, ev)
