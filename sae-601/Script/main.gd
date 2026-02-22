extends Node2D

@onready var player: Player = $Joueur
@onready var spawn_point: Marker2D = $Marker2D
@onready var pause_menu = $PauseMenu
@onready var fade = $FadeLayer

func _ready():
	player.respawn_requested.connect(_on_player_respawn)
	print("PAUSED ?", get_tree().paused)
	
	if GameState.open_pause_menu_on_load:
		GameState.open_pause_menu_on_load = false
		pause_menu.open()

func _on_player_respawn():
	print("Respawn demandé")
	print("Position sauvegardée :", GameState.respawn_position)

	await fade.fade_out(0.3)

	if GameState.respawn_position != Vector2.ZERO:
		player.global_position = GameState.respawn_position
	else:
		player.global_position = spawn_point.global_position

	player.revive()

	await fade.fade_in(0.3)



func _input(event):
	if event.is_action_pressed("pause"):
		if pause_menu.visible:
			pause_menu.close()
		else:
			pause_menu.open()
