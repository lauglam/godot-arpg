extends Node2D

# Grass:
# 草丛

func create_grass_effect():
	# 当草被消灭时，创建一个GrassEffect场景
	var _GrassEffect = load("res://Effects/GrassEffect.tscn")
	# 创建场景的引用，只能对场景的引用进行操作
	var grassEffect = _GrassEffect.instance()
	
	# 获取当前场景的根（这里也就是World）
#	var main = get_tree().current_scene
#	main.add_child(grassEffect)
	
	# 或者直接获取父节点，加进去
	get_parent().add_child(grassEffect)
	
	# 为GrassEffect添加位置
	grassEffect.global_position = global_position

# 当Hitbox进入到Hurtbox的范围时执行
func _on_Hurtbox_area_entered(_area):
	create_grass_effect()
	queue_free()
