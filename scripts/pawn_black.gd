
extends CharacterBody2D

const SPEED = 200.0
const JUMP_VELOCITY = -400.0

var is_attacking: bool = false
var spawn_position: Vector2   # 出生點
var is_shifting: bool = false

func _ready() -> void:
	# 記錄角色初始位置作為重生點
	spawn_position = global_position
	# 連接 Area2D 的 body_entered 訊號
	$Area2D.connect("body_entered", Callable(self, "_on_area_body_entered"))

func _physics_process(delta: float) -> void:
	# 重力
	var t = get_tree().create_timer(600)
	t.timeout.connect(Callable(self, "end"))
	
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	if Input.is_action_just_pressed("d"):
		shift(1)

	if Input.is_action_just_pressed("a"):
		shift(-1)

	# 跳躍
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 攻擊
	if Input.is_action_just_pressed("ui_attack"):
		attack()

	# 移動
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

func attack() -> void:
	if not is_attacking:
		is_attacking = true
		$AnimatedSprite2D.play("attack")
		await $AnimatedSprite2D.animation_finished
		$AnimatedSprite2D.play("unattack")
		await $AnimatedSprite2D.animation_finished
		$AnimatedSprite2D.play("default")
		is_attacking = false

func attack_on_area_body_entered(body: Node) -> void:
	if body.name == "knight":
		body.take_damage(10)
	if body.name == "knight2":
		body.take_damage2(10)
# 當 Area2D 偵測到任何物件
func _on_area_body_entered(body: Node) -> void:
	# 不管碰到誰都回到出生點
	if not is_shifting:
		if body.name == "knight":
			global_position = spawn_position
			velocity = Vector2.ZERO
		if body.name == "knight2":
			global_position = spawn_position
			velocity = Vector2.ZERO
	
func shift(direction: int) -> void:
	if is_shifting:
		return
	is_shifting = true

	# 設定衝刺速度
	velocity.x = direction * 1500

	# 計時 0.3 秒後結束衝刺
	await get_tree().create_timer(0.3).timeout
	velocity.x = 0
	is_shifting = false

func end() -> void:
	var window: ConfirmationDialog=$ConfirmationDialog
	window.dialog_text = "YOU WIN!"
	window.popup_centered()
