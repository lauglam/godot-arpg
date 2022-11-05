extends Node2D

# WanderController:
# 巡逻控制器，用于附加到会巡逻的对象上

export var wander_range = 32

onready var start_position = global_position # 启示位置(不变值)
onready var target_position = global_position # 目标位置

onready var timer = $Timer

# 更新目标位置
func update_target_postion():
	# 获得一个随机的范围
	var target_vector = Vector2(rand_range(-wander_range, wander_range), rand_range(-wander_range, wander_range))
	target_position = start_position + target_vector

# 开始巡逻
func start_wander(duration):
	timer.start(duration)

func _on_Timer_timeout():
	update_target_postion()

# 是否停止巡逻
func is_stopped():
	return timer.is_stopped()
