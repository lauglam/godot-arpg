extends Area2D

# PlayerDetectionZone:
# 玩家监测区域，添加到需要监测玩家的对象上
# 玩家进入到此区域将被监测到
# 如: 蝙蝠敌人

var player = null

# 当别的主体进入此区域时被执行，并传入进入的主体
func _on_PlayerDetectionZone_body_entered(body):
	player = body

# 当别的主体离开此区域时被执行，并传入离开的主体
func _on_PlayerDetectionZone_body_exited(_body):
	player = null
