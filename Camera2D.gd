extends Camera2D

# Camera2D:
# 增加可以手动拖拽锚点，用于设置相机的限制的功能

onready var topLeft = $Limits/TopLeft
onready var bottomRight = $Limits/BottomRight

func _ready():
	# 将相机限制设置为锚点的位置
	limit_top = topLeft.position.y
	limit_left = topLeft.position.x
	limit_bottom = bottomRight.position.y
	limit_right = bottomRight.position.x

