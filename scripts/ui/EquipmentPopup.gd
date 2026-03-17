extends WindowDialog

@onready var equipment_name = $VBoxContainer/EquipmentName
@onready var new_atk_label = $VBoxContainer/StatsContainer/NewAtkLabel
@onready var current_atk_label = $VBoxContainer/StatsContainer/CurrentAtkLabel
@onready var comparison_label = $VBoxContainer/StatsContainer/ComparisonLabel
@onready var equip_button = $VBoxContainer/ButtonsContainer/EquipButton
@onready var dismantle_button = $VBoxContainer/ButtonsContainer/DismantleButton
@onready var close_button = $VBoxContainer/ButtonsContainer/CloseButton

var current_equipment = null
var new_equipment = null

func _ready():
	equip_button.pressed.connect(_on_equip_pressed)
	dismantle_button.pressed.connect(_on_dismantle_pressed)
	close_button.pressed.connect(hide)

func show_equipment(equipment):
	new_equipment = equipment
	current_equipment = DataManager.equipment_slots.get(equipment.slot)

	equipment_name.text = "%s (%s)" % [equipment.name, _get_grade_name(equipment.grade)]

	var new_atk = equipment.get_attack()
	var current_atk = current_equipment != null ? current_equipment.get_attack() : 0
	new_atk_label.text = "새 ATK: %.1f" % new_atk
	current_atk_label.text = "현재 ATK: %.1f" % current_atk

	if new_atk > current_atk:
		comparison_label.text = "▲"
		comparison_label.add_theme_color_override("font_color", Color(0, 1, 0))
	elif new_atk < current_atk:
		comparison_label.text = "▼"
		comparison_label.add_theme_color_override("font_color", Color(1, 0, 0))
	else:
		comparison_label.text = "="
		comparison_label.add_theme_color_override("font_color", Color(1, 1, 1))

	popup_centered()

func _get_grade_name(grade: int) -> String:
	var grades = ["Normal", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"]
	return grades[grade] if grade < grades.size() else "Unknown"

func _on_equip_pressed() -> void:
	DataManager.set_equipment(new_equipment.slot, new_equipment)
	hide()

func _on_dismantle_pressed() -> void:
	PondManager.dismantle_equipment(new_equipment)
	hide()
