extends CharacterBody2D


const SPEED = 100.0
const JUMP_VELOCITY = -250.0

var is_attacking: bool = false
	

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("ui_attack"):   # 在 Project Settings → Input Map 自訂一個 "attack"
		attack()
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
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
		# 讓動畫播完後自動結束攻擊狀態
		await $AnimatedSprite2D.animation_finished
		$AnimatedSprite2D.play("default")
		is_attacking = false
