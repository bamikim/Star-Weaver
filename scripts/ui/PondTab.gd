extends Control

signal summon_result(equipment)

@onready var level_label = $VBoxContainer/LevelContainer/LevelLabel
@onready var summon_button = $VBoxContainer/SummonContainer/SummonButton
@onready var levelup_button = $VBoxContainer/LevelUpContainer/LevelUpButton

func _ready():
	_update_ui()
	DataManager.connect("data_changed", Callable(self, "_update_ui"))
	summon_button.pressed.connect(_on_summon_pressed)
	levelup_button.pressed.connect(_on_levelup_pressed)

func _update_ui() -> void:
	level_label.text = "연못 레벨: %d" % DataManager.pond_level
	var cost = DataManager.pond_level * 10
	levelup_button.text = "레벨업 (성수 %d)" % cost
	levelup_button.disabled = DataManager.sacred_water < cost

func _on_summon_pressed() -> void:
	var result = PondManager.summon()
	if result == null and DataManager.dust >= PondManager.SUMMON_COST:
		# 자동 환원됨
		var grade_names = ["Normal", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"]
		var grade = DataManager.auto_recycle_rank
		if grade > 0 and grade <= 5:
			get_parent().get_parent().get_parent().show_toast("%s 등급 자동 환원됨" % grade_names[grade])
	emit_signal("summon_result", result)

func _on_levelup_pressed() -> void:
	if PondManager.level_up_pond():
		get_parent().get_parent().get_parent().show_toast("연못 레벨업!")
		return
	get_parent().get_parent().get_parent().show_toast("성수가 부족합니다")
