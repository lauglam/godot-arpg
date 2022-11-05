extends KinematicBody2D

# Bat:
# 蝙蝠敌人

# 逻辑：
# 开始游戏->巡逻状态/空闲状态（这两个状态都会监测玩家是否进入可追逐区域）
# 监测到玩家->追逐玩家状态->玩家离开追逐区域->空闲状态->巡逻状态/空闲状态...

export var ACCELERATION = 5 # 加速度
export var MAX_SPEED = 50 # 最大速度
export var FRICTION = 2 # 摩擦力

enum {
	IDLE, # 空闲
	WANDER, # 巡逻
	CHASE # 追逐玩家
}

var velocity = Vector2.ZERO # 速度
var knockback = Vector2.ZERO # 被击退的距离

var state = WANDER

onready var stats = $Stats
onready var animatedSprite = $AnimatedSprite
onready var playerDetectionZone = $PlayerDetectionZone
onready var hurtbox = $Hurtbox
onready var wanderController = $WanderController
onready var blinkAnimationPlayer = $BlinkAnimationPlayer

func _physics_process(_delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION)
			
			seek_player()
			if wanderController.is_stopped():
				update_wander()
		
		WANDER:
			seek_player()
			# 判断巡逻已经停止或者离目标地点已经足够近
			if wanderController.is_stopped() || global_position.distance_to(wanderController.target_position) <= 1:
				update_wander()
			
			# 获取巡逻的方向，并计算速度
			accelerate_towards_point(wanderController.target_position)
		
		CHASE:
			var player = playerDetectionZone.player
			if player != null:
				# 获取玩家的方向，并计算速度
				accelerate_towards_point(player.global_position)
			else:
				state = IDLE
	
	velocity = move_and_slide(velocity)

# 调整面向和方向，并计算速度
func accelerate_towards_point(point):
	# 获取方向
	var direction = global_position.direction_to(point)
	velocity = velocity.move_toward(direction * MAX_SPEED, ACCELERATION)
	
	# 让蝙蝠面向它飞行的方向
	# flip_h: flip horizontal 水平翻转
	# true: 往左飞  false: 往右飞
	animatedSprite.flip_h = velocity.x < 0

# 寻找玩家
func seek_player():
	if playerDetectionZone.player != null:
		state = CHASE

# 决定下一帧的状态并保持1-3秒
func update_wander():
	state = pick_random_state([IDLE, WANDER])
	# 保持状态1-3秒
	wanderController.start_wander(rand_range(1, 3))

# 随机选择一个状态
func pick_random_state(state_list):
	# 洗牌，打乱并返回第一个
	state_list.shuffle()
	return state_list.pop_front()
	

# 当有别的area接触时执行，并传入接触的area（这里的area是SwordHitbox）
func _on_Hurtbox_area_entered(area):
	hurtbox.enable_hit_effect()
	hurtbox.start_invincibility(0.3)
	stats.health -= area.damage
	knockback = area.knockback_vector * 120

# 当血量小于0时执行
func _on_Stats_no_health():
	# 当蝙蝠被消灭时，创建一个EnemyDeathEffect场景
	var _EnemyDeathEffect = load("res://Effects/EnemyDeathEffect.tscn")
	# 创建场景的引用，只能对场景的引用进行操作
	var enemyDeathEffect = _EnemyDeathEffect.instance()
	
	# 获取当前场景的根（这里也就是World）
#	var main = get_tree().current_scene
#	main.add_child(enemyDeathEffect)
	
	# 或者直接获取父节点，加进去
	get_parent().add_child(enemyDeathEffect)
	
	# 为EnemyDeathEffect添加位置
	enemyDeathEffect.global_position = global_position
	
	queue_free()

# 无敌开始时执行
func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")

# 无敌结束后执行
func _on_Hurtbox_invincibility_end():
	blinkAnimationPlayer.play("Stop")
