extends Control

@onready var continue_btn: Button = $Panel/VBoxContainer/ContinueButton
@onready var new_btn: Button = $Panel/VBoxContainer/NewGameButton
@onready var back_btn: Button = $Panel/VBoxContainer/BackButton
@onready var confirm: ConfirmationDialog = $Panel/ConfirmNewGame

@export var game_scene_path := "res://Scenes/Main.tscn"
@export var back_scene_path := "res://Scenes/Paramètre/MenuPrincipal.tscn"

func _ready() -> void:
	continue_btn.visible = GameState.has_save()

	continue_btn.pressed.connect(_on_continue_pressed)
	new_btn.pressed.connect(_on_new_pressed)
	back_btn.pressed.connect(_on_back_pressed)
	confirm.confirmed.connect(_on_confirm_new_game)

func _on_continue_pressed() -> void:
	GameState.load_game()
	get_tree().change_scene_to_file(game_scene_path)

func _on_new_pressed() -> void:
	confirm.popup_centered()

func _on_confirm_new_game() -> void:
	GameState.delete_save()
	GameState.new_game()
	get_tree().change_scene_to_file(game_scene_path)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file(back_scene_path)
