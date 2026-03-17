extends Resource
class_name Equipment

@export var id: String = ""
@export var name: String = ""
@export var grade: int = 0 # 0=Normal, 1=Uncommon, 2=Rare, 3=Epic, 4=Legendary, 5=Mythic
@export var slot: String = "weapon" # weapon, armor, accessory, bag
@export var base_atk: float = 10
@export var level: int = 0
@export var skill_id: String = ""

const BASE_ATK_BY_GRADE := {
	0: 10.0,
	1: 25.0,
	2: 60.0,
	3: 150.0,
	4: 400.0,
	5: 1000.0,
}

func _init():
	# 기본 값 세팅
	if BASE_ATK_BY_GRADE.has(grade):
		base_atk = BASE_ATK_BY_GRADE[grade]

func get_attack() -> float:
	return base_atk * pow(1.15, level)
