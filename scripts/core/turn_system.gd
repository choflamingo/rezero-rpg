# turn_system.gd
# 턴 순서를 계산하고 관리하는 시스템
extends Node

# ========================================
# 시그널
# ========================================
signal turn_order_updated(order: Array)  # 턴 순서 변경 시
signal turn_started(character)           # 턴 시작 시

# ========================================
# 턴 관련 변수
# ========================================
var all_characters: Array = []  # 전투 참여 캐릭터 전체
var turn_order: Array = []      # 턴 순서 (정렬된 배열)
var current_turn_index: int = 0 # 현재 턴 인덱스
var current_character = null    # 현재 행동 중인 캐릭터

# ========================================
# 턴 시스템 초기화
# ========================================
func initialize(characters: Array):
	all_characters = characters
	calculate_turn_order()
	current_turn_index = 0
	print("=== 턴 시스템 초기화 완료 ===")

# ========================================
# 턴 순서 계산 (속도 기반 정렬)
# ========================================
func calculate_turn_order():
	# 살아있는 캐릭터만 필터링
	var alive_characters = all_characters.filter(func(c): return c.is_alive)
	
	# 속도(speed) 기준 내림차순 정렬
	turn_order = alive_characters.duplicate()
	turn_order.sort_custom(func(a, b): return a.speed > b.speed)
	
	# 로그 출력
	print("\n--- 턴 순서 ---")
	for i in range(turn_order.size()):
		var character = turn_order[i]
		print("%d. %s (속도: %d)" % [i+1, character.character_name, character.speed])
	print("---------------\n")
	
	turn_order_updated.emit(turn_order)

# ========================================
# 다음 턴으로 진행
# ========================================
func next_turn():
	# 현재 캐릭터 턴 종료
	if current_character != null:
		current_character.end_turn()
	
	# 다음 캐릭터로 이동
	current_turn_index += 1
	
	# 한 라운드 끝나면 다시 처음으로
	if current_turn_index >= turn_order.size():
		current_turn_index = 0
		print("\n=== 새 라운드 시작 ===\n")
		recalculate_if_needed()
	
	# 현재 캐릭터 가져오기
	if turn_order.size() > 0:
		current_character = turn_order[current_turn_index]
		
		# 죽은 캐릭터면 스킵
		if not current_character.is_alive:
			print("%s는 쓰러져있다. 턴 스킵." % current_character.character_name)
			next_turn()
			return
		
		# HUD 업데이트 
		var battle_hud = get_tree().get_first_node_in_group("battle_hud")
		if battle_hud:
			battle_hud.highlight_current_turn(current_character)
		
		# 턴 시작
		turn_started.emit(current_character)
		current_character.start_turn()

# ========================================
# 턴 순서 재계산 (캐릭터 사망 시)
# ========================================
func recalculate_if_needed():
	var alive_count = turn_order.filter(func(c): return c.is_alive).size()
	
	# 죽은 캐릭터가 있으면 재계산
	if alive_count < turn_order.size():
		print(">> 턴 순서 재계산 중...")
		calculate_turn_order()
		current_turn_index = 0

# ========================================
# 전투 종료 체크
# ========================================
func check_battle_end() -> String:
	var allies_alive = all_characters.filter(func(c): return not c.is_enemy and c.is_alive).size()
	var enemies_alive = all_characters.filter(func(c): return c.is_enemy and c.is_alive).size()
	
	if allies_alive == 0:
		return "defeat"  # 패배
	elif enemies_alive == 0:
		return "victory"  # 승리
	else:
		return "ongoing"  # 전투 중

# ========================================
# 특정 캐릭터 제거 (사망 시)
# ========================================
func remove_character(character):
	all_characters.erase(character)
	turn_order.erase(character)
	print("%s가 전투에서 제외되었다." % character.character_name)
