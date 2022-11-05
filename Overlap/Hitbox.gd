extends Area2D

# Hitbox:
# 用于添加到可以造成伤害的对象上
# 如: 玩家角色的剑、蝙蝠敌人

export var damage = 1 setget set_damage # 伤害

func set_damage(value):
	# 最小伤害值为1
	damage = max(value, 1)
