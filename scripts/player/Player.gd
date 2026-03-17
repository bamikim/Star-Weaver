extends CharacterBody2D

signal player_died
signal hp_changed(current_hp, max_hp)
signal damage_dealt(target, damage, is_critical)

@export var move_speed: float = 150.0
@export var attack_range: float = 150.0
@export var attack_interval: float = 1.0
@export var max_hp: float = 100.0
var current_hp: float
var _attack_timer: float = 0.0

func _ready():
	current_hp = max_hp
	_attack_timer = 0.0

func _physics_process(delta: float) -> void:
	_move_and_attack(delta)

func _move_and_attack(delta: float) -> void:
	var target = _find_nearest_enemy()
	if target:
		# 멈추고 공격
		velocity = Vector2.ZERO
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_attack_timer = attack_interval
			_attack(target)
	else:
		# 자동 이동
		velocity = Vector2.RIGHT * move_speed
	move_and_slide()

func _find_nearest_enemy():
	var best = null
	var best_dist = 1e9
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if not enemy.is_inside_tree():
			continue
		var d = global_position.distance_to(enemy.global_position)
		if d < attack_range and d < best_dist:
			best_dist = d
			best = enemy
	return best

func _attack(target):
	if not target:
		return
	var dmg = DataManager.get_total_attack()
	var is_critical = randf() < 0.1  # 10% 크리티컬 확률
	target.apply_damage(dmg)
	damage_dealt.emit(target, dmg, is_critical)

func apply_damage(amount: float) -> void:
	current_hp -= amount
	current_hp = max(0, current_hp)
	hp_changed.emit(current_hp, max_hp)

	if current_hp <= 0:
		player_died.emit()

func apply_damage(amount: float) -> void:
	hp -= amount
	if hp <= 0:
		hp = 0
		emit_signal("player_died")
	# UI 업데이트를 위해 씬에 알림
	if get_parent() and get_parent().has_method("_update_ui"):
		get_parent()._update_ui()
