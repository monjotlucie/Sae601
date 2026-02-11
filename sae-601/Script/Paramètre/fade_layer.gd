extends CanvasLayer

@onready var rect: ColorRect = $ColorRect

func fade_out(duration := 0.3):
	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 1.0, duration)
	await tween.finished

func fade_in(duration := 0.3):
	var tween = create_tween()
	tween.tween_property(rect, "modulate:a", 0.0, duration)
	await tween.finished
