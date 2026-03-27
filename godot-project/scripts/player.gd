extends CharacterBody2D

@onready var sprite = $Sprite
@onready var pickup_area = $"Pickup Area"
@onready var damage_vignette = $"/root/Node2D/GameManager/Camera/Damage Vignette"

@export var SPEED: float = 200.0
@export var MAX_HEALTH: int = 5
@export var INVINCIBLE_TIME: float = 1.0

var health
var invincible_timer = 0
var experience = 0
var level = 1

func _ready():
	health = MAX_HEALTH

func _process(delta):
	invincible_timer = max(0, invincible_timer - delta)
	if invincible_timer > 0:
		sprite.modulate = Color(1,1-sqrt(invincible_timer/INVINCIBLE_TIME),1-sqrt(invincible_timer/INVINCIBLE_TIME),1)
	else:
		sprite.modulate = Color(1,1,1,1)
	
	if experience >= (level * 10 + ((level-1) * 10) / 4):
		level += 1
	
	var movement_direction = Input.get_vector("left","right","up","down")
	if health <= 0:
		sprite.play("death")
		get_tree().paused = true
	elif movement_direction.length() != 0:
		sprite.play("walk")
		sprite.scale.x = abs(sprite.scale.x) * movement_direction.x / abs(movement_direction.x) if movement_direction.x != 0 else sprite.scale.x
		velocity = movement_direction * SPEED
		move_and_slide()
	elif health > 0:
		sprite.play("default")
	
	# Pickup Area
	for area in pickup_area.get_overlapping_areas():
		if area.has_meta("pickup"):
			# Move Pickups (ex. EXP) towards the player here
			pass

func _on_hitbox_area_entered(area):
	# If hit by an enemy
<<<<<<< Updated upstream
	if area.has_meta("enemy"):
		if invincible_timer == 0:
			health -= 1
			invincible_timer = INVINCIBLE_TIME
		area.death()
=======
	if area.is_in_group("Food"):
		area.queue_free()
		health = min(MAX_HEALTH, health+1)
		AudioManager.eat.play()
	elif area.is_in_group("Enemies"):
		self.damage(1)
		if area.get_script():
			area.global_position += ((area.global_position - global_position) / (area.global_position - global_position).length()) * DAMAGE_KNOCKBACK
	elif area.is_in_group("Enemy Bullets"):
		self.damage(1)
		area.queue_free()
>>>>>>> Stashed changes
	# If hit by exp
	elif area.has_meta("exp"):
		experience += 1
		area.queue_free()
<<<<<<< Updated upstream
=======

func damage(dmg: int):
	if invincible_timer == 0:
		health -= dmg
		invincible_timer = INVINCIBLE_TIME
		damage_vignette.modulate.a = 0.5

func get_random_upgrade(index):
	return Vector2(index, randi_range(0, 2))

func get_upgrade_description(index: int):
	var desc = "[outline_size=10][outline_color=black]"
	desc += "[b][color=#8FBF00]Turtle[/color][/b][br]"
	match index:
		0:
			desc += "[i][color=#8f8f8f]All this running around has improved your stamina[/color][/i]"
			desc += "[br]Increases Max Health ([color=#8FFFFF]" + str(MAX_HEALTH) + " -> " + str(MAX_HEALTH + 1) + "[/color])."
			desc += "[br]Restores Health to Max ([color=#8FFFFF]" + str(MAX_HEALTH + 1) + "[/color])."
		1:
			desc += "[i][color=#8f8f8f]The force is now stronger with this one.[/color][/i]"
			desc += "[br]Increases Pickup Range ([color=#8FFFFF]" + str(round(pickup_range_mod * 100) / 100.0) + "x -> " + str(round(pickup_range_mod * 1.25 * 100) / 100.0) + "x[/color])."
		2:
			desc += "[i][color=#8f8f8f]\"Gotta go faster.\"[/color][/i]"
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
>>>>>>> Stashed changes
