# character_base.gd
# 모든 캐릭터(용사/파티원/적)의 공통 베이스 클래스
extends Node2D

# ========================================
# 캐릭터 기본 정보
# ========================================
@export var character_name: String = "Unknown"  # 캐릭터 이름
@export var is_enemy: bool = false  # 적인가? (아군 구분용)

# ========================================
# 스탯 (HP/MP)
# ========================================
@export var max_hp: int = 100  # 최대 체력
@export var max_mp: int = 50   # 최대 마나
var current_hp: int = 100      # 현재 체력
var current_mp: int = 50       # 현재 마나

# ========================================
# 턴 시스템
# ========================================
@export var speed: int = 10    # 속도 (높을수록 먼저 행동)
var is_alive: bool = true      # 살아있는가?
var is_turn_active: bool = false  # 지금 내 턴인가?

# ========================================
# 시각화 (ColorRect)
# ========================================
var visual: ColorRect  # 캐릭터를 표현할 네모 박스

# ========================================
# 초기화
# ========================================
func _ready():
	# 체력/마나 초기화
	current_hp = max_hp
	current_mp = max_mp
	
	# ColorRect 생성 (시각화용 네모)
	visual = ColorRect.new()
	visual.size = Vector2(64, 64)  # 64x64 크기
	visual.position = Vector2(-32, -32)  # 중앙 정렬
	add_child(visual)
	
	# 색상 설정 (자식 클래스에서 오버라이드)
	update_visual()

# ========================================
# 시각화 업데이트 (색상 변경)
# ========================================
func update_visual():
	# 기본 색상 (회색)
	if visual:
		visual.color = Color.GRAY

# ========================================
# 데미지 받기
# ========================================
func take_damage(amount: int):
	current_hp -= amount
	current_hp = max(0, current_hp)  # 0 이하로 안 내려가게
	
	print("%s가 %d 데미지를 받았다! (HP: %d/%d)" % [character_name, amount, current_hp, max_hp])
	
	# 체력 0이면 사망
	if current_hp <= 0:
		die()

# ========================================
# 회복
# ========================================
func heal(amount: int):
	current_hp += amount
	current_hp = min(current_hp, max_hp)  # 최대치 넘지 않게
	
	print("%s가 %d 회복했다! (HP: %d/%d)" % [character_name, amount, current_hp, max_hp])

# ========================================
# MP 소모
# ========================================
func use_mp(amount: int) -> bool:
	if current_mp >= amount:
		current_mp -= amount
		return true
	else:
		print("%s의 MP가 부족하다!" % character_name)
		return false

# ========================================
# 사망 처리
# ========================================
func die():
	is_alive = false
	print("%s가 쓰러졌다!" % character_name)
	
	# 시각적으로 어둡게
	if visual:
		visual.color = Color.DIM_GRAY

# ========================================
# 턴 시작 (자식 클래스에서 오버라이드)
# ========================================
func start_turn():
	is_turn_active = true
	print("--- %s의 턴 시작 ---" % character_name)

# ========================================
# 턴 종료
# ========================================
func end_turn():
	is_turn_active = false
	print("--- %s의 턴 종료 ---" % character_name)
