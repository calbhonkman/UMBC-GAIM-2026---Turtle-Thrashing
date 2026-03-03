extends CollisionShape2D

func _ready():
	if shape is RectangleShape2D:
		shape.size = get_viewport().get_visible_rect().size
