extends CharacterBody2D

@onready var sprite = $Sprite
@onready var camera = $Camera
@onready var indicator = $Indicator

@export var SPEED = 200
@export var CAMERA_DIST = 100
@export var HEALTH = 5
@export var invincibility_length = 10
var invincible_tick = 0

func _process(delta):
	invincible_tick -= 1
	var movement_vector = Input.get_vector("left","right","up","down")
	camera.global_position = lerp(camera.global_position, global_position + movement_vector * CAMERA_DIST, delta)
	if movement_vector.length() != 0:
		sprite.play("walk")
		indicator.visible = true
		indicator.rotation = movement_vector.angle()
		sprite.scale.x = abs(sprite.scale.x) * movement_vector.x / abs(movement_vector.x) if movement_vector.x != 0 else sprite.scale.x
		move_and_collide(movement_vector * SPEED * delta)
	else:
		sprite.play("default")
		indicator.visible = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_script() and area.get_script().get_path() == "res://scripts/enemy.gd":
		if invincible_tick < 0:
			HEALTH -= 1
			invincible_tick = invincibility_length
			if 	HEALTH == 0:
				self.queue_free()
		area.queue_free()
