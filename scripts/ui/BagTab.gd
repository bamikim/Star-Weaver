extends Control

@export var equipment_slot_texture: Texture = null  # 장비 슬롯 배경
@export var weapon_icon: Texture = null  # 무기 아이콘
@export var armor_icon: Texture = null  # 방어구 아이콘
@export var accessory_icon: Texture = null  # 액세서리 아이콘
@export var bag_icon: Texture = null  # 가방 아이콘

@onready var equipment_grid = $VBoxContainer/ScrollContainer/EquipmentGrid

func _ready():
	_create_equipment_slots()

func _create_equipment_slots() -> void:
	var slots = ["weapon", "armor", "accessory", "bag"]
	for slot in slots:
		var slot_container = _create_equipment_slot(slot)
		equipment_grid.add_child(slot_container)

func _create_equipment_slot(slot_name: String) -> Control:
	var container = Control.new()
	container.custom_minimum_size = Vector2(120, 150)

	var bg_rect = TextureRect.new()
	if equipment_slot_texture:
		bg_rect.texture = equipment_slot_texture
	else:
		var color_rect = ColorRect.new()
		color_rect.color = Color(0.4, 0.4, 0.4, 0.5)
		color_rect.custom_minimum_size = Vector2(100, 100)
		container.add_child(color_rect)

	if equipment_slot_texture:
		container.add_child(bg_rect)

	var icon_rect = TextureRect.new()
	var icon_texture = _get_slot_icon(slot_name)
	if icon_texture:
		icon_rect.texture = icon_texture
	else:
		var label = Label.new()
		label.text = "%s\n슬롯" % slot_name.capitalize()
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
	var equipment = DataManager.equipment_slots.get(slot_name)
	if equipment:
		name_label.text = equipment.name
	else:
		name_label.text = "빈 슬롯"
	name_label.align = Label.ALIGN_CENTER
	name_label.custom_minimum_size = Vector2(100, 20)
	name_label.rect_position = Vector2(0, 110)
	container.add_child(name_label)

	return container

func _get_slot_icon(slot_name: String) -> Texture:
	match slot_name:
		"weapon":
			return weapon_icon
		"armor":
			return armor_icon
		"accessory":
			return accessory_icon
		"bag":
			return bag_icon
	return null
