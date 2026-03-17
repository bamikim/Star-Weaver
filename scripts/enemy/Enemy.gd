extends CharacterBody2D

@export var grade: String = "normal" # normal, elite, boss
@export var base_hp: float = 50.0
@export var base_atk: float = 5.0

var current_hp: float
var max_hp: float
var attack_power: float
var stage_number: int = 1

signal hp_changed(current_hp, max_hp)
signal damage_dealt(target, damage, is_critical)
signal enemy_died(enemy)

func setup(chapter: int, stage: int, grade_str: String) -> void:
	grade = grade_str
	stage_number = stage
	max_hp = base_hp * pow(1.2, stage_number)
	current_hp = max_hp
	attack_power = base_atk * pow(1.2, stage_number)

func apply_damage(amount: float) -> void:
	var old_hp = current_hp
	current_hp -= amount
	current_hp = max(0, current_hp)

	# 데미지 딜 시그널 (크리티컬은 임시로 랜덤)
	var is_critical = randf() < 0.1
	damage_dealt.emit(self, amount, is_critical)

	hp_changed.emit(current_hp, max_hp)

	if current_hp <= 0:
		_die()

func _die() -> void:
	enemy_died.emit(self)
	# 드롭
	match grade:
		"normal":
			DataManager.dust += 5
		"elite":
			DataManager.dust += 15
		"boss":
			DataManager.dust += 50
	# BattleManager에 알림
	BattleManager.on_enemy_defeated()
	queue_free()
