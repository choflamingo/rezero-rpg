# hero.gd
# 용사 캐릭터 (플레이어가 직접 조작)
extends "res://scripts/characters/character_base.gd"

# ========================================
# 용사 전용 설정
# ========================================
signal action_selected(action_type: String, target)  # 행동 선택 시그널
# action_type: "attack", "skill", "item" 등
# target: 대상 캐릭터

# ========================================
# 초기화
# ========================================
func _ready():
	super._ready()  # 부모 클래스 _ready() 실행

	current_hp = max_hp
	current_mp = max_mp
	
	update_visual()

# ========================================
# 시각화 (빨간색)
# ========================================
func update_visual():
	if visual:
		visual.color = Color.RED  # 용사 = 빨간색

# ========================================
# 턴 시작 (UI 대기)
# ========================================
func start_turn():
	super.start_turn()  # 부모 함수 실행
	
	print(">> 플레이어 입력 대기 중...")
	# 실제로는 UI에서 버튼 활성화
	# 지금은 자동으로 공격 (테스트용)
	await get_tree().create_timer(0.5).timeout  # 0.5초 대기
	test_auto_action()

# ========================================
# 테스트용 자동 행동 (나중에 삭제)
# ========================================
func test_auto_action():
	print("용사가 자동으로 공격을 선택했다! (테스트)")
	action_selected.emit("attack", null)  # null = 대상은 전투 매니저가 정함

# ========================================
# 공격 실행
# ========================================
func do_attack(target) -> int:
	if not is_alive:
		return 0
	
	var damage = 20  # 기본 공격력
	print("용사가 %s를 공격!" % target.character_name)
	target.take_damage(damage)
	
	return damage

# ========================================
# 스킬 실행 (나중에 확장)
# ========================================
func do_skill(skill_name: String, target) -> bool:
	# 간단한 스킬 예시
	if skill_name == "강타":
		if use_mp(10):
			var damage = 40
			print("용사가 강타를 사용!")
			target.take_damage(damage)
			return true
	
	return false
