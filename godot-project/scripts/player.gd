extends CharacterBody2D

@onready var sprite = $Sprite
@onready var hitbox = $"Hitbox (Entities)"
@onready var pickup_area = $"Pickup Area"

@export var BASE_SPEED: float = 200.0
@export var MAX_HEALTH: int = 5
@export var INVINCIBLE_TIME: float = 0.5
@export var DAMAGE_KNOCKBACK: float = 100.0

@export var upgrade_descriptions: Array[String]

var speed = 0
var health = 0
var invincible_timer = 0.0
var experience = 0
var level = 1

func _ready():
	speed = BASE_SPEED
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
		velocity = movement_direction * speed
		sprite.scale.x = -1 * abs(sprite.scale.x) if velocity.x < 0 else abs(sprite.scale.x)
		hitbox.scale.x = -1 * abs(hitbox.scale.x) if velocity.x < 0 else abs(hitbox.scale.x)
		move_and_slide()
	elif health > 0:
		sprite.play("default")
	
	# Pickup Area
	for area in pickup_area.get_overlapping_areas():
		if area.has_meta("pickup"):
			var playerDirection = global_position - area.global_position
			playerDirection = playerDirection / playerDirection.length()
			area.global_position += playerDirection * delta * speed * 2
			# Move Pickups (ex. EXP) towards the player here

func _on_hitbox_area_entered(area):
	# If hit by an enemy
	if area.has_meta("food"):
		area.queue_free()
		health = min(MAX_HEALTH, health+1)
	elif area.is_in_group("Enemies"):
		if invincible_timer == 0:
			health -= 1
			invincible_timer = INVINCIBLE_TIME
		area.global_position += ((area.global_position - global_position) / (area.global_position - global_position).length()) * DAMAGE_KNOCKBACK
	elif area.is_in_group("Enemy Bullets"):
		if invincible_timer == 0:
			health -= 1
			invincible_timer = INVINCIBLE_TIME
		area.queue_free()
	# If hit by exp
	elif area.has_meta("exp"):
		experience += 1
		AudioManager.xp_pickup_sfx.play()
		area.queue_free()

func get_upgrade():
	return randi_range(0, upgrade_descriptions.size()-1)

func upgrade(index: int):
	match index:
		0:
			MAX_HEALTH += 1
			health = MAX_HEALTH
		1:
			pickup_area.get_child(0).shape.radius *= 1.25
		2:
			speed += BASE_SPEED * 0.5
