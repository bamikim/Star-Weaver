extends Node

# 전체 게임 상태 관리

signal game_started
signal game_paused
signal game_resumed
signal game_exited

func _ready():
	# 초기화용 자리
	pass

func start_game():
	emit_signal("game_started")

func pause_game():
	emit_signal("game_paused")

func resume_game():
	emit_signal("game_resumed")

func exit_game():
	emit_signal("game_exited")
