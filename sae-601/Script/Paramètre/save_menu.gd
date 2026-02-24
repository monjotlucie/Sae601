extends Control

@export var slot_row_scene: PackedScene
@export var game_scene_path := "res://Scenes/Main.tscn"
@export var back_scene_path := "res://Scenes/Paramètre/MenuPrincipal.tscn"

@onready var slots_list: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SlotsList
@onready var back_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/BackButton
@onready var confirm_delete: ConfirmationDialog = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList/ConfirmDelete
@onready var loading_layer: CanvasLayer = $LoadingLayer
@onready var loading_text: Label = $LoadingLayer/Text

var pending_delete_slot_id: int = -1

func _ready() -> void:
	_apply_layout()
	$LoadingLayer/Bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$LoadingLayer/Text.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	loading_layer.visible = false

	if slot_row_scene == null:
		push_error("SaveMenu: slot_row_scene n'est pas assigné (glisse SlotRow.tscn dans l'inspecteur).")
		return

	back_btn.pressed.connect(_on_back_pressed)
	confirm_delete.confirmed.connect(_do_delete)

	_refresh_slots()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(back_scene_path)

func _refresh_slots() -> void:
	for c in slots_list.get_children():
		c.queue_free()

	for id in range(1, GameState.MAX_SLOTS + 1):
		var exists := GameState.has_save(id)
		var last_saved := GameState.get_last_saved_unix(id)

		var row = slot_row_scene.instantiate()
		slots_list.add_child(row)

		row.setup(id, "Partie %d" % id, last_saved, exists)

		# Connexions
		row.play.connect(_on_slot_play)
		row.delete.connect(_on_slot_delete)
		row.rename.connect(_on_slot_rename) 

func _on_slot_play(slot_id: int) -> void:
	GameState.current_slot_id = slot_id

	if GameState.has_save(slot_id):
		GameState.load_game(slot_id)
	else:
		GameState.new_game()
		GameState.save_game(slot_id)

	await _go_to_game_scene_async()

func _on_slot_delete(slot_id: int) -> void:
	pending_delete_slot_id = slot_id
	confirm_delete.dialog_text = "Supprimer cette partie ?"
	confirm_delete.popup_centered()

func _do_delete() -> void:
	if pending_delete_slot_id < 0:
		return

	GameState.delete_save(pending_delete_slot_id)
	pending_delete_slot_id = -1
	_refresh_slots()

func _on_slot_rename(slot_id: int) -> void:
	print("Rename demandé pour le slot :", slot_id)

func _apply_layout() -> void:
	var scroll := $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer as ScrollContainer
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL

	slots_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slots_list.size_flags_vertical = Control.SIZE_FILL

	if slots_list is VBoxContainer:
		(slots_list as VBoxContainer).add_theme_constant_override("separation", 12)

func _show_loading(msg: String = "Chargement...") -> void:
	loading_layer.visible = true
	loading_layer.layer = 100 # au-dessus de tout
	loading_text.text = msg
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	await get_tree().process_frame

func _hide_loading() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	loading_layer.visible = false

func _go_to_game_scene_async() -> void:
	await _show_loading("Chargement...")

	var path: String = game_scene_path
	ResourceLoader.load_threaded_request(path)

	while true:
		var status := ResourceLoader.load_threaded_get_status(path)

		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var packed := ResourceLoader.load_threaded_get(path) as PackedScene
			if packed != null:
				get_tree().change_scene_to_packed(packed)
			else:
				push_error("Chargement: PackedScene null pour " + path)
				_hide_loading()
			return

		if status == ResourceLoader.THREAD_LOAD_FAILED:
			push_error("Chargement échoué: " + path)
			_hide_loading()
			return

		await get_tree().process_frame
