extends CollisionShape2D

func _process(delta):
	if shape is RectangleShape2D:
		shape.size = get_viewport().get_visible_rect().size
