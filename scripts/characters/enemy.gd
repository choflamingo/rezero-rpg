# enemy.gd
# 적/보스 캐릭터
extends "res://scripts/characters/character_base.gd"

# ========================================
# 보스 설정
# ========================================
@export var is_boss: bool = false  # 보스인가?
@export var boss_multiplier: float = 2.0   # 보스 배율 (기본 2배)

# ========================================
# 초기화
# ========================================
func _ready():
	super._ready()
	
	# 보스라면 배율 적용
	if is_boss:
		character_name += " (Boss)"
		max_hp *= boss_multiplier
		max_mp *= boss_multiplier
		speed *= boss_multiplier * 0.8   # 속도는 0.8배 정도만 반영 (너무 빠르지 않게)
	#character_name = "슬라임"
	#is_enemy = true
	
	#if is_boss:
		#character_name = "보스"
		#max_hp = 500
		#max_mp = 100
		#speed = 9
	#else:
		#max_hp = 80
		#max_mp = 20
		#speed = 7
	
	current_hp = max_hp
	current_mp = max_mp
	update_visual()

# ========================================
# 시각화 (검은색)
# ========================================
func update_visual():
	if visual:
		visual.color = Color.BLACK  # 적 = 검은색

# ========================================
# 턴 시작 (간단한 AI)
# ========================================
func start_turn():
	super.start_turn()
	
	# 0.5초 대기 (생각하는 것처럼)
	await get_tree().create_timer(0.5).timeout
	decide_action()

# ========================================
# AI 행동 결정
# ========================================
func decide_action():
	# 70% 확률로 공격, 30% 방어
	if randf() < 0.7:
		do_auto_attack()
	else:
		print("%s가 방어 태세를 취했다!" % character_name)
		get_parent().on_character_action(self, "defend", self)

# ========================================
# 자동 공격
# ========================================
func do_auto_attack():
	print("%s가 아군을 공격!" % character_name)
	get_parent().on_character_action(self, "attack", null)

# ========================================
# 공격 실행
# ========================================
func do_attack(target) -> int:
	if not is_alive:
		return 0
	
	var damage = 10 if not is_boss else 25  # 보스는 더 강함
	target.take_damage(damage)
	return damage
