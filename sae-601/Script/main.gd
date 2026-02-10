extends Node2D

@onready var player: Player = $Joueur
@onready var spawn_point: Marker2D = $Marker2D
@onready var pause_menu = $PauseMenu


func _ready():
	player.respawn_requested.connect(_on_player_respawn)

func _input(event):
	if event.is_action_pressed("pause"):
		if pause_menu.visible:
			pause_menu.close()
		else:
			pause_menu.open()

func _on_player_respawn():
	player.global_position = spawn_point.global_position
	player.revive()
