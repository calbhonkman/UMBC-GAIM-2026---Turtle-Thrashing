extends Area2D

# Parent container for the bullets/fists/etc
# So that their movement isn't affected by the player's movement
@onready var mother_of_all_bullets = $"../../MotherOfAllBullets"

# Time (in seconds) between each attack
@export var COOLDOWN: float = 3.0

# Hold CTRL and drag a prefab in to get this line
const FIST = preload("uid://csgsdh6itco8")

# Time (in seconds) since the last attack
var timer = 0.0

func _ready():
	# Fire immediately the first time
	timer = COOLDOWN

func _process(delta):
	timer += delta
	
	# Attack is ready
	if timer >= COOLDOWN:
		var closest_enemy = null
		# Check for enemies within the player's attack range
		for area in get_overlapping_areas():
			if area.get_script() == null or area.get_script().get_path() != "res://scripts/enemy.gd":
				# area is not an enemy
				pass
			elif closest_enemy == null:
				# this is the first enemy that's been found
				closest_enemy = area
			elif (area.position - position).length() < (closest_enemy.position - position).length():
				# this is not the first enemy that's been found
				# but it is the closest
				closest_enemy = area
		# If an enemy is within range
		if closest_enemy != null:
			timer = 0
			# See line 11 for FIST
			var new_bullet = FIST.instantiate()
			# The bullet won't exist until you set its parent
			mother_of_all_bullets.add_child(new_bullet)
			new_bullet.global_position = global_position
			new_bullet.set_target(closest_enemy)
