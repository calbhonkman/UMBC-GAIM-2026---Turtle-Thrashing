extends CharacterBody2D

@export var SPEED = 100

func _process(delta):
	print(position)
	var movement_vector = Input.get_vector("left","right","up","down")
	if movement_vector.length() != 0:
		move_and_collide(movement_vector * SPEED * delta)
