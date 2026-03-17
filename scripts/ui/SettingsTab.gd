extends Control

@onready var auto_recycle_option = $VBoxContainer/ScrollContainer/SettingsContainer/AutoRecycleContainer/AutoRecycleOption
@onready var sound_slider = $VBoxContainer/ScrollContainer/SettingsContainer/SoundContainer/SoundSlider
@onready var sfx_slider = $VBoxContainer/ScrollContainer/SettingsContainer/SFXContainer/SFXSlider
@onready var language_option = $VBoxContainer/ScrollContainer/SettingsContainer/LanguageContainer/LanguageOption

func _ready():
	# 자동 환원 설정
	auto_recycle_option.clear()
	auto_recycle_option.add_item("Off", 0)
	auto_recycle_option.add_item("Normal 이하", 1)
	auto_recycle_option.add_item("Uncommon 이하", 2)
	auto_recycle_option.add_item("Rare 이하", 3)
	auto_recycle_option.add_item("Epic 이하", 4)
	auto_recycle_option.add_item("Legendary 이하", 5)
	auto_recycle_option.selected = DataManager.auto_recycle_rank
	auto_recycle_option.connect("item_selected", Callable(self, "_on_auto_recycle_changed"))

	# 사운드 설정 (임시 - 실제로는 AudioServer 사용)
	sound_slider.value = 50  # 기본값
	sfx_slider.value = 50    # 기본값
	sound_slider.connect("value_changed", Callable(self, "_on_sound_changed"))
	sfx_slider.connect("value_changed", Callable(self, "_on_sfx_changed"))

	# 언어 설정
	language_option.clear()
	language_option.add_item("한국어", 0)
	language_option.add_item("English", 1)
	language_option.selected = 0  # 기본 한국어
	language_option.connect("item_selected", Callable(self, "_on_language_changed"))

func _on_auto_recycle_changed(idx: int) -> void:
	DataManager.auto_recycle_rank = idx
	DataManager.save_all()

func _on_sound_changed(value: float) -> void:
	# TODO: AudioServer.master_volume = value / 100.0
	print("배경음악 볼륨: %d%%" % value)

func _on_sfx_changed(value: float) -> void:
	# TODO: AudioServer.sfx_volume = value / 100.0
	print("효과음 볼륨: %d%%" % value)

func _on_language_changed(idx: int) -> void:
	var languages = ["ko", "en"]
	print("언어 변경: %s" % languages[idx])
	# TODO: TranslationServer.set_locale(languages[idx])
