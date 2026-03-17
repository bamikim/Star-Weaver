extends Control

@onready var dust_label = $TopBar/DustContainer/DustLabel
@onready var sacred_label = $TopBar/SacredContainer/SacredLabel
@onready var seal_label = $TopBar/SealContainer/SealLabel
@onready var offline_popup = $OfflinePopup
@onready var offline_label = $OfflinePopup/VBoxContainer/OfflineLabel
@onready var claim_button = $OfflinePopup/VBoxContainer/ClaimButton
@onready var close_button = $OfflinePopup/VBoxContainer/CloseButton
@onready var equipment_popup = $EquipmentPopup
@onready var pond_tab = $MainContent/TabContainer/PondTab

func _ready():
	DataManager.connect("data_changed", Callable(self, "_on_data_changed"))
	_update_resource_ui()
	_setup_offline_popup()
	_setup_pond_tab()
	get_tree().connect("about_to_quit", Callable(self, "_on_about_to_quit"))

func _setup_offline_popup() -> void:
	claim_button.pressed.connect(_on_claim_offline)
	close_button.pressed.connect(_on_close_offline)
	if DataManager.pending_offline_reward > 0:
		offline_label.text = "%d초 동안 dust %d개를 모았습니다." % [DataManager.offline_reward_seconds, DataManager.pending_offline_reward]
		offline_popup.popup_centered()

func _on_claim_offline() -> void:
	var amount = DataManager.claim_offline_reward()
	if amount > 0:
		show_toast("오프라인 보상: dust +%d" % amount)
		offline_popup.hide()

func _on_close_offline() -> void:
	offline_popup.hide()

func _setup_pond_tab() -> void:
	if pond_tab:
		pond_tab.connect("summon_result", Callable(self, "_on_summon_result"))

func _on_summon_result(result) -> void:
	if result == null:
		show_toast("소환 실패 또는 자동 환원됨")
		return
	equipment_popup.show_equipment(result)

func _on_data_changed() -> void:
	_update_resource_ui()

func _update_resource_ui() -> void:
	dust_label.text = str(DataManager.dust)
	sacred_label.text = str(DataManager.sacred_water)
	seal_label.text = str(DataManager.seal)

func _on_about_to_quit() -> void:
	DataManager.on_game_exit()

func _notification(what: int) -> void:
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		# 백그라운드로 간 경우에도 저장
		DataManager.on_game_exit()

func show_toast(message: String) -> void:
	var toast_scene = preload("res://scenes/ui/Toast.tscn")
	var toast = toast_scene.instantiate()
	toast.show_toast(message)
	add_child(toast)
