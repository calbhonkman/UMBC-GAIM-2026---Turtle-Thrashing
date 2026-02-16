extends Area2D

@export var MAX_LIFETIME = 1
@export var SPEED = 800

var lifetime = 0
var direction = Vector2.ZERO

func set_direction(d: Vector2):
	direction = d

func _process(delta):
	lifetime += delta
	if (lifetime >= MAX_LIFETIME):
		queue_free()
	global_position += direction * SPEED * delta
