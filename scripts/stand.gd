extends CharacterBody2D

const GRAVITY = 500.0
const JUMP_FORCE = -300.0
const DASH_SPEED = 100.0
const DETECT_RANGE = 200.0
const ATTACK_DURATION = 1     # 攻擊持續時間
const ATTACK_COOLDOWN = 0.25     # 攻擊冷卻時間（秒）

var health: int = 30
var player: Node2D
var is_attacking: bool = false
var can_attack: bool = true     # 是否可以攻擊
var dash_dir: int = 0

func _ready() -> void:
	player = get_node("../pawn-black")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if is_attacking:
		# 攻擊期間持續保持衝刺速度
		velocity.x = dash_dir * DASH_SPEED
	else:
		start_attack()

	move_and_slide()
func take_damage(amount:int)-> void:
	Manageritem.player_health-=amount
	print("玩家受傷，剩餘血量",health)
	if Manageritem.player_health<=0:
		player_die()
		
func _on_Attackbox_body_entered(body: Node) -> void:
	if body.name == "pawn-black":
		if body.has_method("take_damage"):
			body.take_damage(10)

func player_die()->void:
	print("玩家死亡")
	var window: ConfirmationDialog=$ConfirmationDialog
	window.dialog_text = "YOU DIE!"
	window.popup_centered()

func start_attack() -> void:
	if not can_attack:
		return

	# 播放攻擊動畫（不等待）
	if $AnimatedSprite2D:
		$AnimatedSprite2D.play("attack")

	# 記錄衝刺方向
	is_attacking = true
	can_attack = false
	dash_dir = sign(player.global_position.x - global_position.x)
	velocity.x = dash_dir * DASH_SPEED

	# 設定計時器，攻擊持續 ATTACK_DURATION 秒
	var t = get_tree().create_timer(ATTACK_DURATION)
	t.timeout.connect(end_attack)

func end_attack() -> void:
	is_attacking = false
	velocity.x = 0
	if $AnimatedSprite2D:
		$AnimatedSprite2D.play("default")

	# 攻擊結束後進入冷卻
	var cooldown_timer = get_tree().create_timer(ATTACK_COOLDOWN)
	cooldown_timer.timeout.connect(reset_attack)

func reset_attack() -> void:
	can_attack = true
	
func _on_Hurtbox_area_entered(area: Area2D) -> void:
	if area == get_node("../pawn-black/attack"):
		health -= 10
		print("怪物受傷，剩餘血量: ", health)
		if health <= 0:
			die()

func die() -> void:
	print("怪物死亡")
	if $AnimatedSprite2D:
		$AnimatedSprite2D.play("die")
	await get_tree().create_timer(0.5).timeout
	queue_free()
