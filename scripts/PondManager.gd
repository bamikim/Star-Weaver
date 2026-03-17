extends Node

# 소환 시스템 (연못)

const SUMMON_COST := 100
const RANKS := ["Normal", "Uncommon", "Rare", "Epic", "Legendary", "Mythic"]
const DISMANTLE_REWARD := {
	0: 1,
	1: 3,
	2: 8,
	3: 20,
	4: 60,
	5: 200,
}

var probability_table := {
	1: {0: 0.90, 1: 0.10},
	5: {0: 0.40, 1: 0.45, 2: 0.10, 3: 0.05},
	10: {0: 0.10, 1: 0.25, 2: 0.40, 3: 0.20, 4: 0.049, 5: 0.001},
	20: {0: 0.01, 1: 0.04, 2: 0.15, 3: 0.40, 4: 0.35, 5: 0.05},
}

func _ready():
	pass

func summon() -> Equipment:
	if DataManager.dust < SUMMON_COST:
		return null
	DataManager.dust -= SUMMON_COST
	var grade = _roll_grade(DataManager.pond_level)
	var equipment = _create_equipment_for_grade(grade)
	# 자동 환원 기준 적용
	if DataManager.should_auto_recycle(grade):
		var reward = dismantle_equipment(equipment)
		return null
	return equipment

func _roll_grade(level: int) -> int:
	# 가장 가까운 설정을 찾는다.
	var best_level = 1
	for l in probability_table.keys():
		if level >= l:
			best_level = l
	var probs = probability_table[best_level]
	var r = randf()
	var acc = 0.0
	for grade in probs.keys():
		acc += probs[grade]
		if r <= acc:
			return grade
	# 만약 누락되었으면 최고 등급
	return probs.keys()[-1]

func _create_equipment_for_grade(grade: int) -> Equipment:
	var eq = Equipment.new()
	eq.grade = grade
	eq.id = "%s_%s" % [RANKS[grade].to_lower(), str(OS.get_unix_time())]
	eq.name = "%s %s" % [RANKS[grade], "장비"]
	eq.slot = ["weapon", "armor", "accessory", "bag"][randi() % 4]
	# base_atk는 Equipment가 초기화 시 grade에 맞춰 설정
	return eq

func dismantle_equipment(equipment: Equipment) -> int:
	if equipment == null:
		return 0
	var rank = equipment.grade
	var reward = DISMANTLE_REWARD.get(rank, 0)
	DataManager.sacred_water += reward
	return reward

func level_up_pond() -> bool:
	var next_level = clamp(DataManager.pond_level + 1, 1, 20)
	var cost = DataManager.pond_level * 10
	if DataManager.sacred_water < cost:
		return false
	DataManager.sacred_water -= cost
	DataManager.pond_level = next_level
	return true

func debug_simulate_summons(level: int, count: int) -> Dictionary:
	var results := {
		"counts": {
			0: 0,
			1: 0,
			2: 0,
			3: 0,
			4: 0,
			5: 0,
		}
	}
	for i in range(count):
		var grade = _roll_grade(level)
		results["counts"][grade] += 1
	return results
