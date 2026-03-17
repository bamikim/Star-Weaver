extends Control

@onready var label = $Panel/Label
@onready var tween: Tween

var duration: float = 2.0

func show_toast(message: String, show_duration: float = 2.0) -> void:
	label.text = message
	duration = show_duration
	
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, 0.3)
	tween.tween_interval(duration)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(queue_free)
