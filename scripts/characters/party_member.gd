# party_member.gd
# 파티원 캐릭터 (간단한 AI - 갬빗 없이)
extends "res://scripts/characters/character_base.gd"

# ========================================
# 파티원 역할
# ========================================
enum Role {
	TANK,    # 탱커
	HEALER,  # 힐러
	DPS      # 딜러
}

@export var role: Role = Role.DPS  # 역할 설정

# ========================================
# 초기화
# ========================================
func _ready():
	super._ready()
	
	character_name = "파티원"
	is_enemy = false
	
	## 역할별 스탯 설정
	#match role:
		#Role.TANK:
			#character_name = "탱커"
			#max_hp = 200
			#max_mp = 30
			#speed = 8
		#Role.HEALER:
			#character_name = "힐러"
			#max_hp = 80
			#max_mp = 100
			#speed = 10
		#Role.DPS:
			#character_name = "딜러"
			#max_hp = 120
			#max_mp = 50
			#speed = 11
	
	current_hp = max_hp
	current_mp = max_mp
	update_visual()

# ========================================
# 시각화 (파란색)
# ========================================
func update_visual():
	if visual:
		visual.color = Color.BLUE  # 파티원 = 파란색

# ========================================
# 턴 시작 (자동 AI 판단)
# ========================================
func start_turn():
	super.start_turn()
	
	# 0.3초 후 AI 행동 (생각하는 것처럼 보이게)
	await get_tree().create_timer(0.3).timeout
	decide_action()

# ========================================
# AI 행동 결정 (간단한 IF문)
# ========================================
func decide_action():
	# 나중에 갬빗 시스템으로 교체할 부분
	
	# 1. 힐러: 아군 체력 낮으면 회복
	if role == Role.HEALER:
		if try_heal():
			return
	
	# 2. 기본: 공격
	do_auto_attack()

# ========================================
# 자동 공격
# ========================================
func do_auto_attack():
	print("%s가 적을 공격!" % character_name)
	# 전투 매니저에게 "공격하겠다" 알림
	get_parent().on_character_action(self, "attack", null)

# ========================================
# 회복 시도 (힐러 전용)
# ========================================
func try_heal() -> bool:
	# 아군 중 체력 50% 이하인 캐릭터 찾기
	var allies = get_tree().get_nodes_in_group("allies")
	
	for ally in allies:
		if ally.is_alive and ally.current_hp < ally.max_hp * 0.5:
			if use_mp(15):
				print("%s가 %s를 회복!" % [character_name, ally.character_name])
				ally.heal(30)
				get_parent().on_character_action(self, "heal", ally)
				return true
	
	return false

# ========================================
# 공격 실행
# ========================================
func do_attack(target) -> int:
	if not is_alive:
		return 0
	
	var damage = 15  # 파티원 기본 공격력
	target.take_damage(damage)
	return damage
