extends Area2D

@onready var player = $"/root/Node2D/Player"
@onready var sprite = $AnimatedSprite2D
const EXP = preload("uid://bln5qlwy18sjf")

@export var SPEED = 80

func _process(delta):
	if player:
		var playerDirection = player.global_position - global_position
		playerDirection = playerDirection / playerDirection.length()
		global_position += playerDirection * delta * SPEED
		sprite.scale.x = -1 * abs(sprite.scale.x) * playerDirection.x / abs(playerDirection.x) if playerDirection.x != 0 else sprite.scale.x
		sprite.play("walk")
		
func death():
	var new_xp = EXP.instantiate()
	new_xp.global_position = global_position
	get_parent().add_child(new_xp)
	queue_free()
