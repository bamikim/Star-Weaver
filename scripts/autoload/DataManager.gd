extends Node

signal data_changed

const SAVE_PATH := "user://save.cfg"
const MAX_OFFLINE_SECONDS := 28800 # 8시간

# 재화
var dust: int = 0 setget set_dust
var sacred_water: int = 0 setget set_sacred_water
var seal: int = 0 setget set_seal

# 연못 레벨
var pond_level: int = 1 setget set_pond_level

# 장비 슬롯
var equipment_slots := {
	"weapon": null,
	"armor": null,
	"accessory": null,
	"bag": null,
}

# 스테이지
var current_chapter: int = 1 setget set_current_chapter
var current_stage: int = 1 setget set_current_stage

# 스테이지 잠금/클리어 상태
var unlocked_stages := {
	"1": 1, # 챕터 1은 1스테이지부터 잠금 해제
	"2": 0, # 챕터 2는 첫 클리어 시 해제
}
var cleared_stages := {
	"1": [],
	"2": [],
}

func set_current_chapter(value: int) -> void:
	current_chapter = max(value, 1)
	save_all()

func set_current_stage(value: int) -> void:
	current_stage = max(value, 1)
	save_all()

# 오프라인 보상
var last_exit_time: int = 0
var pending_offline_reward: int = 0
var offline_reward_seconds: int = 0

# 자동 환원 설정: 0=없음, 1=Normal, 2=Uncommon, ... 5=Mythic
var auto_recycle_rank: int = 0

func _ready():
	load_all()
	calculate_offline_reward()

func set_dust(value: int) -> void:
	dust = max(value, 0)
	save_all()
	emit_signal("data_changed")

func set_sacred_water(value: int) -> void:
	sacred_water = max(value, 0)
	save_all()
	emit_signal("data_changed")

func set_seal(value: int) -> void:
	seal = max(value, 0)
	save_all()
	emit_signal("data_changed")

func set_pond_level(value: int) -> void:
	pond_level = clamp(value, 1, 20)
	save_all()
	# pond level change may affect ui
	emit_signal("data_changed")

func set_equipment(slot: String, equipment) -> void:
	if not equipment_slots.has(slot):
		return
	equipment_slots[slot] = equipment
	save_all()
	emit_signal("data_changed")

func get_total_attack() -> float:
	var total := 0.0
	for slot in equipment_slots.keys():
		var eq = equipment_slots[slot]
		if eq:
			total += eq.get_attack()
	return total

func save_all() -> void:
	var cfg = ConfigFile.new()
	cfg.set_value("resources", "dust", dust)
	cfg.set_value("resources", "sacred_water", sacred_water)
	cfg.set_value("resources", "seal", seal)
	cfg.set_value("pond", "level", pond_level)
	cfg.set_value("progress", "chapter", current_chapter)
	cfg.set_value("progress", "stage", current_stage)
	cfg.set_value("stage", "unlocked", unlocked_stages)
	cfg.set_value("stage", "cleared", cleared_stages)
	cfg.set_value("offline", "last_exit_time", last_exit_time)
	cfg.set_value("offline", "pending_offline_reward", pending_offline_reward)
	cfg.set_value("settings", "auto_recycle_rank", auto_recycle_rank)
	# 장비 저장
	for slot in equipment_slots.keys():
		var eq = equipment_slots[slot]
		if eq:
			cfg.set_value("equipment", slot, _serialize_equipment(eq))
	cfg.save(SAVE_PATH)

func _serialize_equipment(eq) -> Dictionary:
	return {
		"id": eq.id,
		"name": eq.name,
		"grade": eq.grade,
		"slot": eq.slot,
		"base_atk": eq.base_atk,
		"level": eq.level,
		"skill_id": eq.skill_id,
	}

func _deserialize_equipment(data: Dictionary):
	if data.empty():
		return null
	var eq = Equipment.new()
	eq.id = str(data.get("id", ""))
	eq.name = str(data.get("name", ""))
	eq.grade = int(data.get("grade", 0))
	eq.slot = str(data.get("slot", ""))
	eq.base_atk = float(data.get("base_atk", 0))
	eq.level = int(data.get("level", 0))
	eq.skill_id = str(data.get("skill_id", ""))
	return eq

func load_all() -> void:
	var cfg = ConfigFile.new()
	var err = cfg.load(SAVE_PATH)
	if err != OK:
		return
	dust = int(cfg.get_value("resources", "dust", dust))
	sacred_water = int(cfg.get_value("resources", "sacred_water", sacred_water))
	seal = int(cfg.get_value("resources", "seal", seal))
	pond_level = int(cfg.get_value("pond", "level", pond_level))
	current_chapter = int(cfg.get_value("progress", "chapter", current_chapter))
	current_stage = int(cfg.get_value("progress", "stage", current_stage))
	unlocked_stages = cfg.get_value("stage", "unlocked", unlocked_stages)
	cleared_stages = cfg.get_value("stage", "cleared", cleared_stages)
	last_exit_time = int(cfg.get_value("offline", "last_exit_time", last_exit_time))
	pending_offline_reward = int(cfg.get_value("offline", "pending_offline_reward", pending_offline_reward))
	auto_recycle_rank = int(cfg.get_value("settings", "auto_recycle_rank", auto_recycle_rank))

	# 장비 로드
	for slot in equipment_slots.keys():
		var eq_data = cfg.get_value("equipment", slot, {})
		if typeof(eq_data) == TYPE_DICTIONARY and not eq_data.empty():
			equipment_slots[slot] = _deserialize_equipment(eq_data)

func calculate_offline_reward() -> void:
	var now = OS.get_unix_time()
	if last_exit_time <= 0:
		last_exit_time = now
		return
	
	var sec = now - last_exit_time
	sec = clamp(sec, 0, MAX_OFFLINE_SECONDS)
	offline_reward_seconds = sec
	pending_offline_reward = sec # 1 dust per second

func claim_offline_reward() -> int:
	var reward = pending_offline_reward
	if reward <= 0:
		return 0
	dust += reward
	pending_offline_reward = 0
	offline_reward_seconds = 0
	save_all()
	return reward

func on_game_exit() -> void:
	last_exit_time = OS.get_unix_time()
	save_all()

func should_auto_recycle(rank: int) -> bool:
	if auto_recycle_rank <= 0:
		return false
	return rank <= auto_recycle_rank

func is_stage_unlocked(chapter: int, stage: int) -> bool:
	var key = str(chapter)
	if not unlocked_stages.has(key):
		return false
	return stage <= int(unlocked_stages[key])

func is_stage_cleared(chapter: int, stage: int) -> bool:
	var key = str(chapter)
	if not cleared_stages.has(key):
		return false
	return int(stage) in cleared_stages[key]

func mark_stage_cleared(chapter: int, stage: int) -> void:
	var key = str(chapter)
	if not cleared_stages.has(key):
		cleared_stages[key] = []
	if int(stage) not in cleared_stages[key]:
		cleared_stages[key].append(int(stage))
	# 잠금 해제 처리
	if not unlocked_stages.has(key):
		unlocked_stages[key] = 0
	# 현재 클리어한 스테이지가 잠금된 마지막 스테이지면 다음 스테이지를 해제
	var max_unlocked = int(unlocked_stages[key])
	if stage >= max_unlocked:
		var next_stage = stage + 1
		if chapter == 1 and next_stage > 10:
			# 챕터 2 첫 스테이지 해제
			unlocked_stages["2"] = max(int(unlocked_stages.get("2", 0)), 1)
		elif next_stage <= 10:
			unlocked_stages[key] = next_stage
	save_all()
