extends CharacterBody2D

@onready var sprite = $Sprite
@onready var hitbox = $"Hitbox (Entities)"
@onready var pickup_area = $"Pickup Area"
@onready var damage_vignette = $"/root/Node2D/GameManager/Camera/Damage Vignette"

@export var MAX_HEALTH: int = 5
@export var BASE_SPEED: float = 200.0
@export var INVINCIBLE_TIME: float = 0.5
@export var DAMAGE_KNOCKBACK: float = 100.0

@export var upgrade_descriptions: Array[String]
@export var upgrade_icon: Resource

var pickup_range_mod = 1.0

var speed_mod = 1.0
var health = 0
var invincible_timer = 0.0
var experience = 0
var level = 1

func _ready():
	health = MAX_HEALTH

func _process(delta):
	invincible_timer = max(0, invincible_timer - delta)
	if invincible_timer > 0 and health > 0:
		sprite.modulate = Color(1,1-sqrt(invincible_timer/INVINCIBLE_TIME),1-sqrt(invincible_timer/INVINCIBLE_TIME),1)
		damage_vignette.modulate = Color(1,1,1,sqrt(invincible_timer/INVINCIBLE_TIME))
	else:
		sprite.modulate = Color(1,1,1,1)
		damage_vignette.modulate = Color(1,1,1,0)
	
	var movement_direction = Input.get_vector("left","right","up","down")
	if health <= 0:
		sprite.play("death")
		get_tree().paused = true
	elif movement_direction.length() != 0:
		sprite.play("walk")
		velocity = movement_direction * BASE_SPEED * speed_mod
		sprite.scale.x = -1 * abs(sprite.scale.x) if velocity.x < 0 else abs(sprite.scale.x)
		hitbox.scale.x = -1 * abs(hitbox.scale.x) if velocity.x < 0 else abs(hitbox.scale.x)
		move_and_slide()
	elif health > 0:
		sprite.play("default")
	
	# Pickup Area
	for area in pickup_area.get_overlapping_areas():
		if area.has_meta("pickup") or area.is_in_group("Food"):
			var playerDirection = global_position - area.global_position
			playerDirection = playerDirection / playerDirection.length()
			area.global_position += playerDirection * delta * BASE_SPEED * speed_mod * 2
			# Move Pickups (ex. EXP) towards the player here

func _on_hitbox_area_entered(area):
	# If hit by an enemy
	if area.is_in_group("Food"):
		area.queue_free()
		health = min(MAX_HEALTH, health+1)
		AudioManager.eat.play()
	elif area.is_in_group("Enemies"):
		if invincible_timer == 0:
			health -= 1
			invincible_timer = INVINCIBLE_TIME
		if area.get_script():
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

func damage(dmg: int):
	if invincible_timer == 0:
		health -= dmg
		invincible_timer = INVINCIBLE_TIME

func get_random_upgrade(index):
	return Vector2(index, randi_range(0, 2))

func get_upgrade_description(index: int):
	var desc = "[outline_size=10][outline_color=black]"
	desc += "[b][color=#8FBF00]Turtle[/color][/b][br]"
	match index:
		0:
			desc += "[i][color=#8f8f8f]You can do this all day.[/color][/i]"
			desc += "[br]Increases Max Health ([color=#8FFFFF]" + str(MAX_HEALTH) + " -> " + str(MAX_HEALTH + 1) + "[/color])."
			desc += "[br]Restores Health to Max ([color=#8FFFFF]" + str(MAX_HEALTH + 1) + "[/color])."
		1:
			desc += "[i][color=#8f8f8f]The force is stronger with this one.[/color][/i]"
			desc += "[br]Increases Pickup Range ([color=#8FFFFF]" + str(round(pickup_range_mod * 100) / 100.0) + "x -> " + str(round(pickup_range_mod * 1.25 * 100) / 100.0) + "x[/color])."
		2:
			desc += "[i][color=#8f8f8f]Gotta go faster.[/color][/i]"
			desc += "[br]Increases Movement Speed ([color=#8FFFFF]" + str(round(speed_mod * 100) / 100.0) + "x -> " + str(round(speed_mod * 1.25 * 100) / 100.0) + "x[/color])."
	desc += "[/outline_color][/outline_size]"
	return desc

func upgrade(index: int):
	match index:
		0:
			MAX_HEALTH += 1
			health = MAX_HEALTH
		1:
			pickup_area.get_child(0).shape.radius /= pickup_range_mod
			pickup_range_mod *= 1.25
			pickup_area.get_child(0).shape.radius *= pickup_range_mod
		2:
			speed_mod *= 1.25
