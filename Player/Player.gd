extends KinematicBody2D

# Player:
# 玩家角色

export var ACCELERATION = 40 # 加速度
export var MAX_SPEED = 80 # 最大速度
export var ROLL_SPEED = 125 # 翻滚速度
export var FRICTION = 80 # 摩擦力

# 状态
enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var playerStats = $PlayerStats
onready var blinkAnimationPlayer = $BlinkAnimationPlayer

func _ready():
	animationTree.active = true
	swordHitbox.knockback_vector = roll_vector

# delta: 在1秒60帧的时候，值是1/60
#        在1秒30帧的时候，值是1/30

# 这个函数每一帧都会执行一次
# 在60帧的时候人物前进的距离为: 400 * 60 = 2400
# 在30帧的时候任务前进的距离为: 400 * 30 = 1200
# 不同帧率下前进的距离不同，这需要解决

# 所以解决方法就是乘以delta
# 在60帧的时候人物前进的距离为: 400 * 1/60 * 60 = 400
# 在30帧的时候任务前进的距离为: 400 * 1/30 * 30 = 400
func _physics_process(_delta):
	match state:
		MOVE:
			move_state()
		
		ROLL:
			roll_state()
		
		ATTACK:
			attack_state()

# 移动状态
func move_state():
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	# 解决角色往对角线上移动，向量为根号2的问题
	input_vector = input_vector.normalized()
	
	if(input_vector != Vector2.ZERO):
		# 设置翻滚的方向
		roll_vector = input_vector
		# 设置敌人击退方向
		swordHitbox.knockback_vector = input_vector
		
		# 将输入的向量与每个动画树中的光标位置关联
		animationTree.set("parameters/Idle/blend_position", input_vector) # 空闲
		animationTree.set("parameters/Run/blend_position", input_vector) # 移动
		animationTree.set("parameters/Attack/blend_position", input_vector) # 攻击
		animationTree.set("parameters/Roll/blend_position", input_vector) # 翻滚
		
		# 将动画状态过度Run
		animationState.travel("Run")
		# 按照设定的加速度、最大速度移动角色
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION)
	else:
		# 将动画状态过度Idle
		animationState.travel("Idle")
		# 按照设定的摩擦力让角色停止移动
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
	
	move()
	
	# 按下攻击键: 移动状态->攻击状态
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	
	# 按下翻滚键: 移动状态->翻滚状态
	if Input.is_action_just_pressed("roll"):
		state = ROLL
		# 滚动时无敌
		hurtbox.start_invincibility(1)

# 攻击状态
# 攻击状态执行完毕: 攻击状态->移动状态 
func attack_state():
	velocity = Vector2.ZERO
	animationState.travel("Attack")

# 翻滚状态
# 翻滚状态执行完毕: 翻滚状态->移动状态 
func roll_state():
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

# 移动
func move():
	velocity = move_and_slide(velocity)

# 当攻击动画执行完毕时，会回调这个函数
func attack_animation_finished():
	state = MOVE

# 当翻滚动画执行完毕时，会回调这个函数
func roll_animation_finished():
	state = MOVE

# 当有另一个区域进入此区域时执行，并传入进入的区域
func _on_Hurtbox_area_entered(area):
	playerStats.health -= area.damage
	hurtbox.enable_hit_effect()
	hurtbox.start_invincibility(0.5)
	
	# 当角色死亡时，会被释放，连同角色的所有节点都会被释放（包括音效）
	# 所以，将受伤音效附加到根节点
	var PlayerHurtSound = load("res://Player/PlayerHurtSound.tscn")
	var playerHurtSound = PlayerHurtSound.instance()
	get_tree().current_scene.add_child(playerHurtSound)

# 没生命时，释放自身
func _on_PlayerStats_no_health():
	queue_free()

# 无敌开始时执行
func _on_Hurtbox_invincibility_started():
	# 播放闪烁动画
	if state != ROLL: blinkAnimationPlayer.play("Start")

# 无敌结束后执行
func _on_Hurtbox_invincibility_end():
	# 播放闪烁动画
	blinkAnimationPlayer.play("Stop")
