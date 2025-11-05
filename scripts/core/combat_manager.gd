# combat_manager.gd
# 전투 흐름을 총괄하는 매니저
extends Node

# ========================================
# 자식 노드 참조
# ========================================
@onready var turn_system = $TurnSystem  # 턴 시스템
@onready var battle_hud = get_node("../BattleHUD") #HUD 연결

# ========================================
# 전투 상태
# ========================================
enum BattleState {
	SETUP,      # 전투 준비
	TURN,       # 턴 진행 중
	ANIMATING,  # 애니메이션 재생 중
	VICTORY,    # 승리
	DEFEAT      # 패배
}

var current_state: BattleState = BattleState.SETUP

# ========================================
# 캐릭터 그룹
# ========================================
var allies: Array = []    # 아군 (용사 + 파티원)
var enemies: Array = []   # 적

# ========================================
# 전투 시작
# ========================================

func start_battle():
	print("\n========================================")
	print("         전투 시작!")
	print("========================================\n")
	
	current_state = BattleState.SETUP
	
	# 캐릭터 수집
	collect_characters()
	
	# HUD 초기화 (새로 추가!)
	var all_characters = allies + enemies
	battle_hud.setup_characters(all_characters)
	
	# 턴 시스템 초기화
	turn_system.initialize(all_characters)
	
	# 턴 순서 HUD 업데이트 (새로 추가!)
	battle_hud.update_turn_order(turn_system.turn_order)
	
	# 첫 턴 시작
	current_state = BattleState.TURN
	turn_system.next_turn()

# ========================================
# 캐릭터 수집 (씬에서)
# ========================================
func collect_characters():
	# 그룹으로 수집 (나중에 씬에서 그룹 설정)
	allies = get_tree().get_nodes_in_group("allies")
	enemies = get_tree().get_nodes_in_group("enemies")
	
	print(">> 아군: %d명" % allies.size())
	print(">> 적: %d명" % enemies.size())

# ========================================
# 캐릭터 행동 처리 (캐릭터가 호출)
# ========================================
func on_character_action(actor, action_type: String, target):
	if current_state != BattleState.TURN:
		return
	
	print("\n[행동] %s → %s" % [actor.character_name, action_type])
	
	# 행동 실행
	match action_type:
		"attack":
			execute_attack(actor, target)
		"heal":
			# 이미 실행됨 (party_member.gd에서)
			pass
		"defend":
			print("%s가 방어했다!" % actor.character_name)
	
	# 전투 종료 체크
	await get_tree().create_timer(0.3).timeout  # 애니메이션 대기
	check_battle_result()
	
	# 다음 턴
	if current_state == BattleState.TURN:
		turn_system.next_turn()

# ========================================
# 공격 실행
# ========================================
func execute_attack(attacker, target):
	if target == null:
		target = select_auto_target(attacker)
	
	if target == null:
		print("공격할 대상이 없다!")
		return
	
	# 데미지 계산 및 적용
	var damage = attacker.do_attack(target)
	
	# UI 업데이트 (새로 추가!)
	battle_hud.update_character_stats(target)
	
	await get_tree().create_timer(0.2).timeout

# ========================================
# 자동 대상 선택
# ========================================
func select_auto_target(attacker):
	var targets: Array = []
	
	# 공격자가 아군이면 적을, 적이면 아군을
	if attacker.is_enemy:
		targets = allies.filter(func(c): return c.is_alive)
	else:
		targets = enemies.filter(func(c): return c.is_alive)
	
	# 랜덤 선택
	if targets.size() > 0:
		return targets[randi() % targets.size()]
	else:
		return null

# ========================================
# 전투 결과 체크
# ========================================
func check_battle_result():
	var result = turn_system.check_battle_end()
	
	match result:
		"victory":
			current_state = BattleState.VICTORY
			print("\n========================================")
			print("         승리!")
			print("========================================\n")
			await get_tree().create_timer(1.0).timeout
			end_battle()
		
		"defeat":
			current_state = BattleState.DEFEAT
			print("\n========================================")
			print("         패배...")
			print("========================================\n")
			await get_tree().create_timer(1.0).timeout
			end_battle()

# ========================================
# 전투 종료
# ========================================
func end_battle():
	print("전투가 종료되었습니다.")
	# 나중에: 보상 지급, 씬 전환 등
	get_tree().reload_current_scene()  # 테스트용 재시작
