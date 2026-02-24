extends Control

@export var slot_row_scene: PackedScene
@export var game_scene_path := "res://Scenes/Main.tscn"
@export var back_scene_path := "res://Scenes/Paramètre/MenuPrincipal.tscn"

@onready var slots_list: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/SlotsList
@onready var back_btn: Button = $PanelContainer/MarginContainer/VBoxContainer/BackButton
@onready var confirm_delete: ConfirmationDialog = $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer/ActionList/ConfirmDelete

var pending_delete_slot_id := -1

func _ready() -> void:
	_apply_layout()
	
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

		var row = slot_row_scene.instantiate()
		slots_list.add_child(row)

		row.setup(id, "Partie %d" % id, 0, exists)

		row.play.connect(_on_slot_play)
		row.delete.connect(_on_slot_delete)

func _on_slot_play(slot_id: int) -> void:
	GameState.current_slot_id = slot_id

	if GameState.has_save(slot_id):
		GameState.load_game(slot_id)
	else:
		GameState.new_game()
		GameState.save_game(slot_id)

	get_tree().change_scene_to_file(game_scene_path)

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

func _apply_layout() -> void:
	var scroll := $PanelContainer/MarginContainer/VBoxContainer/ScrollContainer as ScrollContainer
	scroll.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL

	slots_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slots_list.size_flags_vertical = Control.SIZE_FILL

	if slots_list is VBoxContainer:
		(slots_list as VBoxContainer).add_theme_constant_override("separation", 12)
