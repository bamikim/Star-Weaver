extends Control

@export var spirit_slot_texture: Texture = null  # 정령 슬롯 배경
@export var empty_spirit_texture: Texture = null  # 빈 슬롯 아이콘

@onready var spirits_grid = $VBoxContainer/ScrollContainer/SpiritsGrid

func _ready():
	_create_spirit_slots()

func _create_spirit_slots() -> void:
	for i in range(6):  # 임시로 6개 슬롯
		var slot = _create_spirit_slot(i)
		spirits_grid.add_child(slot)

func _create_spirit_slot(index: int) -> Control:
	var container = Control.new()
	container.custom_minimum_size = Vector2(120, 150)

	var bg_rect = TextureRect.new()
	if spirit_slot_texture:
		bg_rect.texture = spirit_slot_texture
	else:
		var color_rect = ColorRect.new()
		color_rect.color = Color(0.3, 0.3, 0.3, 0.5)
		color_rect.custom_minimum_size = Vector2(100, 100)
		container.add_child(color_rect)
		var icon_rect = TextureRect.new()
		if empty_spirit_texture:
			icon_rect.texture = empty_spirit_texture
		else:
			var label = Label.new()
			label.text = "빈 슬롯\n%d" % (index + 1)
			label.align = Label.ALIGN_CENTER
			label.valign = Label.VALIGN_CENTER
			label.custom_minimum_size = Vector2(100, 100)
			container.add_child(label)
		return container

	if spirit_slot_texture:
		container.add_child(bg_rect)

	var icon_rect = TextureRect.new()
	if empty_spirit_texture:
		icon_rect.texture = empty_spirit_texture
	else:
		var label = Label.new()
		label.text = "빈 슬롯\n%d" % (index + 1)
		label.align = Label.ALIGN_CENTER
		label.valign = Label.VALIGN_CENTER
		label.custom_minimum_size = Vector2(100, 100)
		container.add_child(label)
		return container

	icon_rect.expand = true
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_rect.custom_minimum_size = Vector2(80, 80)
	icon_rect.rect_position = Vector2(10, 10)
	container.add_child(icon_rect)

	var name_label = Label.new()
	name_label.text = "정령 %d" % (index + 1)
	name_label.align = Label.ALIGN_CENTER
	name_label.custom_minimum_size = Vector2(100, 20)
	name_label.rect_position = Vector2(0, 110)
	container.add_child(name_label)

	return container
