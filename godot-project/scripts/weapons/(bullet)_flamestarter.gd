extends Node2D

@export var IGNITE_SPEED: float = 5.0

func _process(delta):
	if scale.x < 1.0:
		scale += Vector2(1.0, 1.0) * IGNITE_SPEED * delta
	elif scale.x > 1.0:
		scale = Vector2(1.0, 1.0)
