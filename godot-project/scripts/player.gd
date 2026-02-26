extends CharacterBody2D

@onready var sprite = $Sprite
@onready var pickup_area = $"Pickup Area"

@export var SPEED: float = 200.0
@export var MAX_HEALTH: int = 5
@export var INVINCIBLE_TIME: float = 1.0

var speed
var health
var invincible_timer = 0
var experience = 0
var level = 1

func _ready():
	speed = SPEED
	health = MAX_HEALTH

func _process(delta):
	invincible_timer = max(0, invincible_timer - delta)
	if invincible_timer > 0:
		sprite.modulate = Color(1,1-sqrt(invincible_timer/INVINCIBLE_TIME),1-sqrt(invincible_timer/INVINCIBLE_TIME),1)
	else:
		sprite.modulate = Color(1,1,1,1)
	
	var movement_direction = Input.get_vector("left","right","up","down")
	if health <= 0:
		sprite.play("death")
		get_tree().paused = true
	elif movement_direction.length() != 0:
		sprite.play("walk")
		sprite.scale.x = abs(sprite.scale.x) * movement_direction.x / abs(movement_direction.x) if movement_direction.x != 0 else sprite.scale.x
		velocity = movement_direction * speed
		move_and_slide()
	elif health > 0:
		sprite.play("default")
	
	# Pickup Area
	for area in pickup_area.get_overlapping_areas():
		if area.has_meta("pickup"):
			var playerDirection = global_position - area.global_position
			playerDirection = playerDirection / playerDirection.length()
			area.global_position += playerDirection * delta * SPEED * 2
			# Move Pickups (ex. EXP) towards the player here

func _on_hitbox_area_entered(area):
	# If hit by an enemy
	if area.has_meta("enemy"):
		if invincible_timer == 0:
			health -= 1
			invincible_timer = INVINCIBLE_TIME
		area.damage(INF)
	# If hit by exp
	elif area.has_meta("exp"):
		experience += 1
		area.queue_free()
