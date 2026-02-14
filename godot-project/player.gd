extends CharacterBody2D

@export var SPEED = 200
@export var CAMERA_DIST = 100

@onready var camera = $Camera2D



func _process(delta):
	print(position)
	var movement_vector = Input.get_vector("left","right","up","down")
	camera.global_position = lerp(camera.global_position, global_position + movement_vector * CAMERA_DIST, delta)
	print(movement_vector)
	if movement_vector.length() != 0:
		move_and_collide(movement_vector * SPEED * delta)
