# battle_hud.gd
# 전투 중 UI 표시 (HP/MP, 턴 순서)
extends CanvasLayer

# ========================================
# UI 노드 참조
# ========================================
@onready var turn_order_label = $MarginContainer/VBoxContainer/TurnOrderPanel/HBoxContainer/TurnOrderLabel
@onready var character_stats_list = $MarginContainer/VBoxContainer/CharacterStatsPanel/CharacterStatsList

# ========================================
# 캐릭터 스탯 UI 프리팹 (동적 생성)
# ========================================
var character_stat_uis: Dictionary = {}  # 캐릭터 → UI 매핑

# ========================================
# 초기화
# ========================================
func _ready():
	pass  # 전투 매니저가 setup_characters() 호출할 거예요

# ========================================
# 캐릭터 UI 생성
# ========================================
func setup_characters(characters: Array):
	# 기존 UI 제거
	for child in character_stats_list.get_children():
		child.queue_free()
	
	character_stat_uis.clear()
	
	# 각 캐릭터마다 UI 생성
	for character in characters:
		var stat_ui = create_character_stat_ui(character)
		character_stats_list.add_child(stat_ui)
		character_stat_uis[character] = stat_ui

# ========================================
# 캐릭터 스탯 UI 생성 (HBoxContainer)
# ========================================
func create_character_stat_ui(character) -> HBoxContainer:
	var container = HBoxContainer.new()
	container.custom_minimum_size = Vector2(0, 60)
	
	# 1. 이름 라벨
	var name_label = Label.new()
	name_label.text = character.character_name
	name_label.custom_minimum_size = Vector2(100, 0)
	name_label.add_theme_font_size_override("font_size", 18)
	container.add_child(name_label)
	
	# 2. HP 바 컨테이너
	var hp_container = VBoxContainer.new()
	hp_container.name = "HPContainer"
	hp_container.custom_minimum_size = Vector2(200, 0)
	
	var hp_label = Label.new()
	hp_label.name = "HPLabel"
	hp_label.text = "HP: %d/%d" % [character.current_hp, character.max_hp]
	hp_label.add_theme_font_size_override("font_size", 14)
	hp_container.add_child(hp_label)
	
	var hp_bar = ProgressBar.new()
	hp_bar.name = "HPBar"
	hp_bar.max_value = character.max_hp
	hp_bar.value = character.current_hp
	hp_bar.show_percentage = false
	hp_bar.custom_minimum_size = Vector2(200, 20)
	hp_container.add_child(hp_bar)
	
	container.add_child(hp_container)
	
	# 3. MP 바 컨테이너
	var mp_container = VBoxContainer.new()
	mp_container.name = "MPContainer"
	mp_container.custom_minimum_size = Vector2(200, 0)
	
	var mp_label = Label.new()
	mp_label.name = "MPLabel"
	mp_label.text = "MP: %d/%d" % [character.current_mp, character.max_mp]
	mp_label.add_theme_font_size_override("font_size", 14)
	mp_container.add_child(mp_label)
	
	var mp_bar = ProgressBar.new()
	mp_bar.name = "MPBar"
	mp_bar.max_value = character.max_mp
	mp_bar.value = character.current_mp
	mp_bar.show_percentage = false
	mp_bar.custom_minimum_size = Vector2(200, 20)
	mp_container.add_child(mp_bar)
	
	container.add_child(mp_container)
	
	return container

# ========================================
# 캐릭터 스탯 업데이트
# ========================================
func update_character_stats(character):
	if not character_stat_uis.has(character):
		return
	
	var ui = character_stat_uis[character]
	
	# HP 업데이트 (이름으로 찾기!)
	var hp_label = ui.get_node("HPContainer/HPLabel")
	var hp_bar = ui.get_node("HPContainer/HPBar")
	hp_label.text = "HP: %d/%d" % [character.current_hp, character.max_hp]
	hp_bar.value = character.current_hp
	
	# MP 업데이트 (이름으로 찾기!)
	var mp_label = ui.get_node("MPContainer/MPLabel")
	var mp_bar = ui.get_node("MPContainer/MPBar")
	mp_label.text = "MP: %d/%d" % [character.current_mp, character.max_mp]
	mp_bar.value = character.current_mp

# ========================================
# 턴 순서 업데이트
# ========================================
func update_turn_order(turn_order: Array):
	var names = []
	for character in turn_order:
		if character.is_alive:
			names.append(character.character_name)
	
	turn_order_label.text = "턴 순서: " + " → ".join(names)

# ========================================
# 현재 턴 강조
# ========================================
func highlight_current_turn(character):
	turn_order_label.text = ">>> %s의 턴! <<<" % character.character_name
