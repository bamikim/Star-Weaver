extends Label

var velocity = Vector2(0, -100)
var lifetime = 1.5
var timer = 0.0

func setup(damage: int, is_critical: bool = false) -> void:
	text = str(damage)
	if is_critical:
		add_theme_color_override("font_color", Color(1, 0.5, 0))  # 주황색 크리티컬
		custom_fonts.font.size = 48
	else:
		add_theme_color_override("font_color", Color(1, 1, 1))  # 흰색 일반

func _process(delta: float) -> void:
	timer += delta
	global_position += velocity * delta

	# 페이드 아웃
	modulate.a = 1.0 - (timer / lifetime)

	if timer >= lifetime:
		queue_free()