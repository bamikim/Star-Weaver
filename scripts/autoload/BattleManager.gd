extends Node

signal stage_cleared(chapter, stage)
signal player_died()
signal wave_started(wave_index)
signal wave_cleared(wave_index)
signal player_hp_changed(current_hp, max_hp)

var current_chapter: int = 1
var current_stage: int = 1
var current_wave: int = 0
var enemies_remaining: int = 0

const WAVES_PER_STAGE := 5

func start_stage(chapter: int, stage: int) -> void:
	current_chapter = chapter
	current_stage = stage
	current_wave = 0
	_next_wave()

func _next_wave() -> void:
	current_wave += 1
	if current_wave > WAVES_PER_STAGE:
		# 스테이지 클리어
		DataManager.mark_stage_cleared(current_chapter, current_stage)
		emit_signal("stage_cleared", current_chapter, current_stage)
		# 같은 스테이지 자동 반복 (비재귀 호출)
		current_wave = 0
		call_deferred("_next_wave")
		return

	emit_signal("wave_started", current_wave)
	_enemies_for_wave(current_wave)

func _enemies_for_wave(wave: int) -> void:
	if wave < WAVES_PER_STAGE:
		# wave 1~4: normal 3~5, elite 1
		enemies_remaining = 3 + randi() % 3 + 1 # 3~5
		# elite will be included but counts as 1 enemy in total
	else:
		# boss wave
		enemies_remaining = 1

func on_enemy_defeated() -> void:
	if enemies_remaining <= 0:
		return
	enemies_remaining -= 1
	if enemies_remaining <= 0:
		emit_signal("wave_cleared", current_wave)
		_next_wave()

func on_player_died() -> void:
	emit_signal("player_died")

func on_player_died() -> void:
	emit_signal("player_died")
	# 리셋
	current_wave = 0
	start_stage(current_chapter, current_stage)
