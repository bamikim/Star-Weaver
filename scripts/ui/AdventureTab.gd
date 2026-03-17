extends Control

const CHAPTER_COUNT := 2
const STAGES_PER_CHAPTER := 10

@export var locked_stage_texture: Texture = null  # 잠금 스테이지 아이콘
@export var unlocked_stage_texture: Texture = null  # 해제 스테이지 아이콘
@export var cleared_stage_texture: Texture = null  # 클리어 스테이지 아이콘
@export var star_texture: Texture = null  # 별 아이콘

@onready var chapter_label = $VBoxContainer/Header/ChapterLabel
@onready var info_label = $VBoxContainer/InfoLabel
@onready var stage_grid = $VBoxContainer/ScrollContainer/StageGrid

func _ready():
	_update_stage_list()

func _update_stage_list() -> void:
	stage_grid.clear()
	for chapter in range(1, CHAPTER_COUNT + 1):
		chapter_label.text = "Chapter %d" % chapter
		for stage in range(1, STAGES_PER_CHAPTER + 1):
			var container = _create_stage_button(chapter, stage)
			stage_grid.add_child(container)

	_update_info()

func _create_stage_button(chapter: int, stage: int) -> Control:
	var container = Control.new()
	container.custom_minimum_size = Vector2(100, 120)

	var texture_rect = TextureRect.new()
	texture_rect.expand = true
	texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	texture_rect.custom_minimum_size = Vector2(80, 80)
	container.add_child(texture_rect)

	var label = Label.new()
	label.text = "%d-%d" % [chapter, stage]
	label.align = Label.ALIGN_CENTER
	label.custom_minimum_size = Vector2(80, 20)
	label.rect_position = Vector2(0, 85)
	container.add_child(label)

	var button = Button.new()
	button.custom_minimum_size = Vector2(100, 120)
	button.flat = true
	button.name = "%d_%d" % [chapter, stage]
	button.connect("pressed", Callable(self, "_on_stage_pressed"))
	container.add_child(button)

	var unlocked = DataManager.is_stage_unlocked(chapter, stage)
	var cleared = DataManager.is_stage_cleared(chapter, stage)

	if not unlocked:
		texture_rect.texture = locked_stage_texture if locked_stage_texture else null
		label.text += "\n(잠금)"
		button.disabled = true
	elif cleared:
		texture_rect.texture = cleared_stage_texture if cleared_stage_texture else null
		label.text += "\n★"
	else:
		texture_rect.texture = unlocked_stage_texture if unlocked_stage_texture else null

	return container

func _update_info() -> void:
	info_label.text = "현재 선택: Chapter %d-%d" % [DataManager.current_chapter, DataManager.current_stage]

func _on_stage_pressed(button: Button) -> void:
	var parts = button.name.split("_")
	if parts.size() != 2:
		return
	var chapter = int(parts[0])
	var stage = int(parts[1])
	DataManager.current_chapter = chapter
	DataManager.current_stage = stage
	_update_info()
	# 바로 전투 시작
	get_tree().change_scene_to_file("res://scenes/battle/BattleScene.tscn")
