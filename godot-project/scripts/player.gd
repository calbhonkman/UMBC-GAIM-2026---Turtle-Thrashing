extends CharacterBody2D

@onready var sprite = $Sprite
@onready var indicator = $Indicator
@onready var camera = $"../Camera"

@export var SPEED = 200
@export var CAMERA_DIST = 100
@export var HEALTH = 5
@export var INVINCIBLE_TIME = 1.0
var invincible_timer = 0

func _process(delta):
	invincible_timer = max(0, invincible_timer - delta)
	if invincible_timer > 0:
		sprite.modulate = Color(1,1-sqrt(invincible_timer/INVINCIBLE_TIME),1-sqrt(invincible_timer/INVINCIBLE_TIME),1)
	else:
		sprite.modulate = Color(1,1,1,1)
	
	var movement_vector = Input.get_vector("left","right","up","down")
	camera.global_position = lerp(camera.global_position, global_position + movement_vector * CAMERA_DIST, delta)
	if movement_vector.length() != 0:
		sprite.play("walk")
		indicator.visible = true
		indicator.rotation = movement_vector.angle()
		sprite.scale.x = abs(sprite.scale.x) * movement_vector.x / abs(movement_vector.x) if movement_vector.x != 0 else sprite.scale.x
		move_and_collide(movement_vector * SPEED * delta)
	elif HEALTH > 0:
		sprite.play("default")
		indicator.visible = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	# If hit by an enemy
	if area.get_script() and area.get_script().get_path() == "res://scripts/enemy.gd":
		if invincible_timer == 0:
			HEALTH -= 1
			invincible_timer = INVINCIBLE_TIME
			if HEALTH == 0:
				sprite.play("death")
		area.queue_free()
