extends Control

var enemy: Node2D
@onready var hp_bar = $HPBar
@onready var hp_label = $HPLabel

func setup(target_enemy: Node2D) -> void:
	enemy = target_enemy
	enemy.connect("hp_changed", Callable(self, "_on_enemy_hp_changed"))
	_update_display()

func _process(delta: float) -> void:
	if enemy and is_instance_valid(enemy):
		global_position = enemy.global_position + Vector2(0, -80)  # 적 위쪽에 표시
	else:
		queue_free()

func _on_enemy_hp_changed(current_hp: int, max_hp: int) -> void:
	_update_display()

func _update_display() -> void:
	if not enemy or not is_instance_valid(enemy):
		queue_free()
		return

	var current_hp = enemy.current_hp
	var max_hp = enemy.max_hp

	hp_bar.value = float(current_hp) / max_hp * 100
	hp_label.text = "HP: %d/%d" % [current_hp, max_hp]

	# HP에 따라 색상 변경
	if current_hp <= max_hp * 0.25:
		hp_bar.add_theme_color_override("font_color", Color(1, 0, 0))  # 빨강
	elif current_hp <= max_hp * 0.5:
		hp_bar.add_theme_color_override("font_color", Color(1, 1, 0))  # 노랑
	else:
		hp_bar.add_theme_color_override("font_color", Color(0, 1, 0))  # 초록