extends Control

# HealthUI:
# 用于添加到界面的生命值UI

var max_hearts = 4 setget set_max_hearts # 最大心数
var hearts = max_hearts setget set_hearts # 当前心数

onready var heartUIFull = $HeartUIFull
onready var heartUIEmpty = $HeartUIEmpty

func set_max_hearts(value):
	# 最大心数量最小值为1
	max_hearts = max(value, 1)
	# 设置UI中的最大心
	heartUIEmpty.rect_size.x = max_hearts * 15
	# 防止最大心数小于当前心数的情况
	self.hearts = min(hearts, max_hearts)

func set_hearts(value):
	# 钳制value，返回一个不小于0且不大于max_hearts的值
	hearts = clamp(value, 0, max_hearts)
	# 设置UI中还有多少颗心
	heartUIFull.rect_size.x = hearts * 15
	
func _ready():
	# 获取到PalyerStats
	# 这里可以使用全局Singleton的方法，但我觉得那种方法阅读性太差
	var main = get_tree().current_scene
	var palyerStats = main.get_node("/root/World/YSort/Player/PlayerStats")
	
	# 设置最大心数和心数
	self.max_hearts = palyerStats.max_health
	self.hearts = palyerStats.health
	
	# 链接信号，改变时设置心数
	var _e1 = palyerStats.connect("health_changed", self, "set_hearts")
	var _e2 = palyerStats.connect("max_health_changed", self, "set_max_hearts")
