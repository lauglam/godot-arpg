extends AnimatedSprite

# Effect:
# 特效，用于附加到一些拥有特效的AnimatedSprite对象上
# 在特效完成后会自动释放自身
# 如: 草丛、敌人

func _ready():
	var _e = connect("animation_finished", self, "_on_animation_finished")
	play("Animate")

# 当动画执行完毕会执行这个函数
func _on_animation_finished():
	queue_free()
