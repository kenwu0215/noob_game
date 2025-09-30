class_name Knight1
extends CharacterBody2D

var GRAVITY: float = 5000.0
var JUMP_FORCE: float = -100.0
var DASH_SPEED: float = 200.0
var DETECT_RANGE: float = 200.0

var health: int = 30
var is_attacking: bool = false
var dash_dir: int = 0

# 攻擊間隔，避免每幀扣血
var attack_cooldown: bool = false

func _init() -> void:
	collision_layer=0
	collision_mask=2

#func _ready()->void:
	
	#connect("area_entered",self,"_on_area_entered")

func _on_area_entered(hitbox: Knight1)-> void:
	if hitbox==null:
		return
	if owner.has_method("take_damage"):
		owner.take_damage(10)
	#if Manageritem.player_health==0
'''
func die() -> void:
	print("怪物死亡")
	if sprite:
		sprite.play("die")
	await get_tree().create_timer(0.5).timeout
	queue_free()
'''
func player_die() -> void:
	print("玩家死亡")
	var window: ConfirmationDialog = $ConfirmationDialog
	window.dialog_text = "YOU DIE!"
	window.popup_centered()
