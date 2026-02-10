extends Node2D

@onready var player: Player = $Joueur
@onready var spawn_point: Marker2D = $Marker2D


func _ready():
	player.respawn_requested.connect(_on_player_respawn)


func _on_player_respawn():
	player.global_position = spawn_point.global_position
	player.revive()
