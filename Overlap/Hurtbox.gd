extends Area2D

# Hurtbox:
# 用于添加到可以受到伤害的对象上

# 无敌功能流程：
# 外界调用 start_invincibility(duration) 函数并传入无敌持续时间
# ->开启无敌(开始计时)->发出无敌开始信号->计时结束->发出无敌结束信号

# 注意monitoring与monitorable的区别
# monitoring是监测有没有别的区域进入
# monitorable是决定是否能被别的区域监测到

onready var timer = $Timer

var invincible = false setget set_invincible # 是否无敌

signal invincibility_started # 无敌开始信号
signal invincibility_end # 无敌结束信号

func set_invincible(value):
	invincible = value
	# 触发是否无敌的信号
	if invincible:
		# 无敌开始时不开启监测别的区域是否进入
		set_deferred("monitoring", false)
		emit_signal("invincibility_started")
	else:
		# 无敌结束后开启监测别的区域是否进入
		set_deferred("monitoring", true)
		emit_signal("invincibility_end")

# 传入持续时间，开启无敌
func start_invincibility(duration):
	# 此处需要加上self关键字，否则不会访问setter
	self.invincible = true
	timer.start(duration)

# 当计时器结束时执行
func _on_Timer_timeout():
	# 结束无敌
	# 此处需要加上self关键字，否则不会访问setter
	self.invincible = false

# 开启被攻击特效
func enable_hit_effect():
	# 当被攻击时，创建一个HitEffect场景
	var _HitEffect = load("res://Effects/HitEffect.tscn")
	# 创建场景的引用，只能对场景的引用进行操作
	var hitEffect = _HitEffect.instance()
	
	# 获取当前场景的根（这里也就是World）
	var main = get_tree().current_scene
	main.add_child(hitEffect)
	
	# 为HitEffect添加位置
	hitEffect.global_position = global_position

