extends Control

@export var skill_node_texture: Texture = null  # 스킬 노드 아이콘
@export var locked_skill_texture: Texture = null  # 잠금 스킬 아이콘
@export var unlocked_skill_texture: Texture = null  # 해제 스킬 아이콘

@onready var skill_tree = $VBoxContainer/ScrollContainer/SkillTree

func _ready():
	_create_skill_tree()

func _create_skill_tree() -> void:
	var skills = [
		{"name": "공격력 +10%", "level": 0, "max_level": 5, "cost": 10},
		{"name": "체력 +20", "level": 0, "max_level": 3, "cost": 15},
		{"name": "크리티컬 확률 +5%", "level": 0, "max_level": 4, "cost": 20},
		{"name": "Dust 획득량 +10%", "level": 0, "max_level": 3, "cost": 25},
		{"name": "연못 레벨 보너스", "level": 0, "max_level": 2, "cost": 50},
		{"name": "오프라인 보상 +50%", "level": 0, "max_level": 1, "cost": 100},
	]

	var y_offset = 50
	for i in range(skills.size()):
		var skill = skills[i]
		var node = _create_skill_node(skill, i)
		node.rect_position = Vector2(100 + (i % 3) * 200, y_offset + (i / 3) * 150)
		skill_tree.add_child(node)

func _create_skill_node(skill_data: Dictionary, index: int) -> Control:
	var container = Control.new()
	container.custom_minimum_size = Vector2(150, 120)

	var bg_rect = TextureRect.new()
	if skill_node_texture:
		bg_rect.texture = skill_node_texture
	else:
		var color_rect = ColorRect.new()
		color_rect.color = Color(0.3, 0.3, 0.5, 0.7)
		color_rect.custom_minimum_size = Vector2(140, 110)
		container.add_child(color_rect)

	if skill_node_texture:
		container.add_child(bg_rect)

	var icon_rect = TextureRect.new()
	if unlocked_skill_texture:
		icon_rect.texture = unlocked_skill_texture
	else:
		var label = Label.new()
		label.text = "스킬\n노드"
		label.align = Label.ALIGN_CENTER
		label.valign = Label.VALIGN_CENTER
		label.custom_minimum_size = Vector2(50, 50)
		label.rect_position = Vector2(10, 10)
		container.add_child(label)

	if unlocked_skill_texture:
		icon_rect.expand = true
		icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon_rect.custom_minimum_size = Vector2(50, 50)
		icon_rect.rect_position = Vector2(10, 10)
		container.add_child(icon_rect)

	var name_label = Label.new()
	name_label.text = skill_data["name"]
	name_label.custom_minimum_size = Vector2(130, 30)
	name_label.rect_position = Vector2(10, 70)
	container.add_child(name_label)

	var level_label = Label.new()
	level_label.text = "Lv.%d/%d" % [skill_data["level"], skill_data["max_level"]]
	level_label.custom_minimum_size = Vector2(130, 20)
	level_label.rect_position = Vector2(10, 100)
	container.add_child(level_label)

	return container
