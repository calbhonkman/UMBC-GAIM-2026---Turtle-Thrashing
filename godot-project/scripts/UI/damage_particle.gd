extends RichTextLabel

@export var SPEED: float = 100.0

func _process(delta):
	if modulate.a <= 0:
		queue_free()
	global_position.y += -1 * SPEED * delta
	modulate.a += -1 * delta
