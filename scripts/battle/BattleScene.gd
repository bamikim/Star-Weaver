extends Node2D

@export var player_scene: PackedScene = preload("res://scenes/player/Player.tscn")
@export var enemy_scene: PackedScene = preload("res://scenes/enemy/Enemy.tscn")

@onready var damage_numbers = $UI/DamageNumbers
@onready var enemy_hp_bars = $UI/EnemyHPBars
@onready var wave_label = $UI/TopBar/WaveLabel
@onready var stage_label = $UI/TopBar/StageLabel
@onready var player_hp_bar = $UI/BottomBar/PlayerHPBar
@onready var player_hp_label = $UI/BottomBar/PlayerHPLabel

var damage_number_scene = preload("res://scenes/ui/DamageNumber.tscn")
var enemy_hp_bar_scene = preload("res://scenes/ui/EnemyHPBar.tscn")

func _ready():
	BattleManager.connect("wave_started", Callable(self, "_on_wave_started"))
	BattleManager.connect("stage_cleared", Callable(self, "_on_stage_cleared"))
	BattleManager.connect("player_died", Callable(self, "_on_player_died"))
	BattleManager.connect("player_hp_changed", Callable(self, "_on_player_hp_changed"))
	_start_battle()

func _start_battle() -> void:
	# 플레이어 스폰
	var player = player_scene.instantiate()
	player.global_position = Vector2(200, 400)
	player.connect("player_died", Callable(self, "_on_player_died"))
	player.connect("damage_dealt", Callable(self, "_on_damage_dealt"))
	add_child(player)
	BattleManager.start_stage(DataManager.current_chapter, DataManager.current_stage)
	_update_ui()

func _update_ui() -> void:
	wave_label.text = "Wave: %d/%d" % [BattleManager.current_wave, BattleManager.WAVES_PER_STAGE]
	stage_label.text = "Stage: %d-%d" % [DataManager.current_chapter, DataManager.current_stage]

func _on_wave_started(wave_index: int) -> void:
	_update_ui()
	# 적 스폰
	_spawn_wave(wave_index)

func _spawn_wave(wave_index: int) -> void:
	var count = 1
	var grade = "normal"
	if wave_index < BattleManager.WAVES_PER_STAGE:
		count = 3 + randi() % 3
		# 하나는 elite
		for i in range(count - 1):
			_spawn_enemy("normal")
		_spawn_enemy("elite")
	else:
		_spawn_enemy("boss")

func _spawn_enemy(grade: String) -> void:
	var enemy = enemy_scene.instantiate()
	enemy.add_to_group("enemies")
	enemy.global_position = Vector2(800, 400 + randi() % 200 - 100)
	enemy.setup(DataManager.current_chapter, DataManager.current_stage, grade)
	enemy.connect("damage_dealt", Callable(self, "_on_damage_dealt"))
	enemy.connect("enemy_died", Callable(self, "_on_enemy_died"))
	add_child(enemy)

	# 적 HP 바 생성
	_create_enemy_hp_bar(enemy)

func _create_enemy_hp_bar(enemy: Node2D) -> void:
	var hp_bar = enemy_hp_bar_scene.instantiate()
	hp_bar.setup(enemy)
	enemy_hp_bars.add_child(hp_bar)

func _on_damage_dealt(target: Node2D, damage: int, is_critical: bool = false) -> void:
	# 데미지 숫자 표시
	var damage_number = damage_number_scene.instantiate()
	damage_number.setup(damage, is_critical)
	damage_number.global_position = target.global_position + Vector2(randi() % 40 - 20, randi() % 40 - 20)
	damage_numbers.add_child(damage_number)

func _on_enemy_died(enemy: Node2D) -> void:
	# 적 HP 바 제거
	for hp_bar in enemy_hp_bars.get_children():
		if hp_bar.enemy == enemy:
			hp_bar.queue_free()
			break

func _on_player_hp_changed(current_hp: int, max_hp: int) -> void:
	player_hp_bar.value = float(current_hp) / max_hp * 100
	player_hp_label.text = "HP: %d/%d" % [current_hp, max_hp]

func _on_stage_cleared(chapter: int, stage: int) -> void:
	# 보상 및 다음 스테이지 진행
	DataManager.dust += 20
	DataManager.current_stage = stage

func _on_player_died() -> void:
	# 자동 리셋
	BattleManager.on_player_died()
	# 재시작을 위해 씬 재로드
	get_tree().reload_current_scene()
