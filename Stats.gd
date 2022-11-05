extends Node

# Stats:
# 数值，用于添加到拥有数值的对象上
# 如: 玩家角色、敌人

export var max_health = 1 setget set_max_health
onready var health = max_health setget set_health

signal no_health
signal health_changed(value)
signal max_health_changed(value)

func set_max_health(value):
	# 最大生命值最小为1
	max_health = max(value, 1)
	# 触发最大生命值已改变信号
	emit_signal("max_health_changed", max_health)
	# 防止最大生命值小于当前生命值的情况
	if health != null: self.health = min(health, max_health)

func set_health(value):
	# 钳制value，返回一个不小于0且不大于max_health的值
	health = clamp(value, 0, max_health)
	# 触发生命值已改变信号
	emit_signal("health_changed", health)
	
	if health <= 0: emit_signal("no_health")
