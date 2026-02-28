extends Control

@export var slot_row_scene: PackedScene
@export var game_scene_path: String = "res://Scenes/Main.tscn"
@export var back_scene_path: String = "res://Scenes/Paramètre/MenuPrincipal.tscn"

@onready var slots_list: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SlotsList
@onready var back_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/BackButton
@onready var confirm_delete: ConfirmationDialog = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList/ConfirmDelete

@onready var loading_layer: CanvasLayer = $LoadingLayer
@onready var loading_text: Label = $LoadingLayer/Text

@onready var rename_dialog: AcceptDialog = $RenameDialog
@onready var rename_input: LineEdit = $RenameDialog/RenameInput

var pending_rename_slot_id: int = -1
var pending_delete_slot_id: int = -1

var _loading_running: bool = false
var _loading_task_id: int = 0

var _rows_by_id: Dictionary = {}


func _ready() -> void:
	Engine.max_fps = 30

	_apply_layout()

	rename_dialog.title = "Changer le nom de la partie"
	rename_dialog.ok_button_text = "Valider"
	rename_dialog.min_size = Vector2(520, 180)
	rename_dialog.exclusive = true

	rename_input.custom_minimum_size = Vector2(480, 40)
	rename_input.placeholder_text = "Entrez un nom"
	rename_dialog.confirmed.connect(_do_rename)

	$LoadingLayer/Bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$LoadingLayer/Text.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	loading_layer.visible = false

	if slot_row_scene == null:
		push_error("SaveMenu: slot_row_scene n'est pas assigné.")
		return

	back_btn.pressed.connect(_on_back_pressed)
	confirm_delete.confirmed.connect(_do_delete)

	_refresh_slots_full()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(back_scene_path)




func _refresh_slots_full() -> void:
	for c in slots_list.get_children():
		c.queue_free()
	_rows_by_id.clear()

	for id: int in range(1, GameState.MAX_SLOTS + 1):
		_create_or_update_row(id)


func _create_or_update_row(id: int) -> void:
	var exists: bool = GameState.has_save(id)
	var last_saved: int = GameState.get_last_saved_unix(id)
	var name: String = GameState.get_slot_name(id)

	var row = _rows_by_id.get(id, null)
	if row == null:
		row = slot_row_scene.instantiate()
		slots_list.add_child(row)
		_rows_by_id[id] = row

		row.play.connect(_on_slot_play)
		row.delete.connect(_on_slot_delete)
		row.rename.connect(_on_slot_rename)


	if row.has_method("setup"):
		row.setup(id, name, last_saved, exists)
	elif row.has_method("update_row"):
		row.update_row(id, name, last_saved, exists)
	else:
		push_warning("Row n'a pas de méthode setup/update_row. Ajoute-en une pour éviter de rebuild l'UI.")


func _remove_row(id: int) -> void:
	var row = _rows_by_id.get(id, null)
	if row != null:
		_rows_by_id.erase(id)
		row.queue_free()



func _on_slot_play(slot_id: int) -> void:
	GameState.current_slot_id = slot_id

	if GameState.has_save(slot_id):
		GameState.load_game(slot_id)
	else:
		GameState.new_game()
		GameState.save_game(slot_id)
		_create_or_update_row(slot_id)

	await _go_to_game_scene_async()


func _on_slot_delete(slot_id: int) -> void:
	pending_delete_slot_id = slot_id
	confirm_delete.dialog_text = "Supprimer cette partie ?"
	confirm_delete.popup_centered()


func _do_delete() -> void:
	if pending_delete_slot_id < 0:
		return

	GameState.delete_save(pending_delete_slot_id)

	_create_or_update_row(pending_delete_slot_id)

	pending_delete_slot_id = -1


func _on_slot_rename(slot_id: int) -> void:
	pending_rename_slot_id = slot_id
	rename_input.text = GameState.get_slot_name(slot_id)
	rename_dialog.popup_centered()
	await get_tree().process_frame
	rename_input.grab_focus()
	rename_input.select_all()


func _do_rename() -> void:
	if pending_rename_slot_id < 0:
		return

	var new_name: String = rename_input.text.strip_edges()
	if new_name.is_empty():
		new_name = "Partie %d" % pending_rename_slot_id

	GameState.set_slot_name(pending_rename_slot_id, new_name)

	_create_or_update_row(pending_rename_slot_id)

	pending_rename_slot_id = -1




func _apply_layout() -> void:
	var scroll := $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer as ScrollContainer
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL

	slots_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slots_list.size_flags_vertical = Control.SIZE_FILL

	if slots_list is VBoxContainer:
		(slots_list as VBoxContainer).add_theme_constant_override("separation", 12)

	var total_w: int = 560 + 420 + 56 + 56 + 12
	slots_list.custom_minimum_size = Vector2(total_w, 0)

	slots_list.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	slots_list.size_flags_horizontal = Control.SIZE_SHRINK_CENTER




func _show_loading(msg: String = "Chargement") -> void:
	loading_layer.visible = true
	loading_layer.layer = 100
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_start_loading_animation(msg)
	await get_tree().process_frame


func _hide_loading() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	_stop_loading_animation()
	loading_layer.visible = false


func _go_to_game_scene_async() -> void:
	await _show_loading("Chargement")

	var tree := get_tree()
	if tree == null:
		return

	var path: String = game_scene_path

	if OS.has_feature("web"):
		_hide_loading()
		if is_inside_tree():
			tree.change_scene_to_file(path)
		return

	ResourceLoader.load_threaded_request(path)

	while true:
		if not is_inside_tree():
			return

		var status := ResourceLoader.load_threaded_get_status(path)

		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var packed := ResourceLoader.load_threaded_get(path) as PackedScene
			_hide_loading()
			if packed != null and tree != null:
				tree.change_scene_to_packed(packed)
			else:
				push_error("Chargement: PackedScene null pour " + path)
			return

		if status == ResourceLoader.THREAD_LOAD_FAILED:
			push_error("Chargement échoué: " + path)
			_hide_loading()
			return

		await get_tree().process_frame


func _start_loading_animation(base_text: String = "Chargement") -> void:
	_loading_running = true
	_loading_task_id += 1
	var my_id: int = _loading_task_id
	_loading_loop(base_text, my_id)


func _stop_loading_animation() -> void:
	_loading_running = false


func _loading_loop(base_text: String, my_id: int) -> void:
	await get_tree().process_frame

	var step: int = 0
	while _loading_running and my_id == _loading_task_id:
		loading_text.text = base_text + ".".repeat(step)
		step = (step + 1) % 4
		await get_tree().create_timer(0.2).timeout
