extends Area2D

@export var player_group_name := "player"
@export var candle_id: String = ""

var picked := false

func _ready() -> void:
	if candle_id != "" and GameState.collected_candles.has(candle_id):
		get_parent().queue_free()
		return
		
	body_entered.connect(_on_body_entered)
	print("Candle", candle_id, "saved list:", GameState.collected_candles)

func _on_body_entered(body: Node) -> void:
	if picked:
		return
	if candle_id == "":
		return
	if body.is_in_group(player_group_name):
		picked = true
		GameState.add_candle(candle_id)
		get_parent().queue_free()
