extends CollisionShape2D

# This is meant to be used on any CollisionShape2D
# that needs to fill exactly the space of the screen.
# The lightning ability's CollisionShape2D uses this.

func _ready():
	if shape is RectangleShape2D:
		shape.size = get_viewport().get_visible_rect().size
