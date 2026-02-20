extends Area2D

@onready var player = $"/root/Node2D/Player"

@export var SPEED = 80

func _process(delta):
	if player:
		var playerDirection = player.global_position - global_position
		playerDirection = playerDirection / playerDirection.length()
		global_position += playerDirection * delta * SPEED

func death():
<<<<<<< Updated upstream
=======
	var new_xp = XP.instantiate()
	new_xp.global_position = global_position
	get_parent().add_child(new_xp)
>>>>>>> Stashed changes
	queue_free()
