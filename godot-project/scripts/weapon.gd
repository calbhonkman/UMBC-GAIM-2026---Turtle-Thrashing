extends Area2D

# Parent container for the bullets/fists/etc
# So that their movement isn't affected by the player's movement
@onready var bullets_group = $"../../(Group) Bullets"

@export var DAMAGE: float = 1.0
# Time (in seconds) between each attack
@export var COOLDOWN: float = 3.0
# Thing that is being created by the weapon (fist, cloud, etc.)
@export var BULLET: Resource
@export var ATTACK_TYPE: String = "random"

# Time (in seconds) since the last attack
var timer = 0.0

func _ready():
	# Fire immediately the first time
	timer = COOLDOWN

func _process(delta):
	timer += delta
	
	# Attack is ready
	if timer >= COOLDOWN:
		match(ATTACK_TYPE):
			"random":
				find_random_enemy()
			"closest":
				find_closest_enemy()

func attack(target: Area2D):
	var new_bullet = BULLET.instantiate()
	# The bullet won't exist until you set its parent
	bullets_group.add_child(new_bullet)
	new_bullet.global_position = global_position
	new_bullet.set_target(target)
	new_bullet.set_damage(DAMAGE)

func find_random_enemy():
	var possible_targets = []
	for area in get_overlapping_areas():
		if area.has_meta("enemy"):
			possible_targets.append(area)
	if not possible_targets.is_empty():
		attack(possible_targets[randi_range(0,possible_targets.size()-1)])
		timer = 0.0

func find_closest_enemy():
	var closest_enemy = null
	for area in get_overlapping_areas():
		if area.has_meta("enemy") and (closest_enemy == null or (area.global_position-global_position).length() < (closest_enemy.global_position-global_position).length()):
			closest_enemy = area
	if closest_enemy != null:
		attack(closest_enemy)
		timer = 0.0
