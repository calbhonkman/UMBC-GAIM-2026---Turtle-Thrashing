extends Area2D

@export var SPEED: float = 500.0
@export var DAMAGE: float = 1.0
@export var COOLDOWN: float = 1.0
@export var AMOUNT: int = 1
@export var BULLET: Resource

@export var unlocked: bool = false
@export var upgrade_descriptions: Array[String]

var size_mod = 1.0

var bullet = []
var b_cooldown = []
var b_target = []
var b_position = []

func _ready():
	for i in range(AMOUNT):
		bullet.append(null)
		b_cooldown.append(0.0)
		b_target.append(null)
		b_position.append(null)

func _process(delta):
	if unlocked == false:
		return
	
	for i in range(AMOUNT):
		b_cooldown[i] -= delta
		if bullet[i]:
			if b_target[i]:
				bullet[i].global_position = b_target[i].global_position
				b_position[i] = bullet[i].global_position
				bullet[i].visible = true
			else:
				bullet[i].global_position = b_position[i]
			
			if not bullet[i].get_child(0).is_playing():
				for area in bullet[i].get_overlapping_areas():
					if area.has_meta("enemy"):
						area.damage(DAMAGE)
				bullet[i].queue_free()
				bullet[i] = null
				b_target[i] = null
				b_position[i] = null
		
		elif b_cooldown[i] <= 0.0: # and delay <= 0.0:
			b_target[i] = find_target()
			if b_target[i]:
				bullet[i] = BULLET.instantiate()
				add_child(bullet[i])
				bullet[i].global_position = global_position
				bullet[i].scale *= size_mod
				b_position[i] = bullet[i].global_position
				b_cooldown[i] = COOLDOWN

func find_target():
	var possible_targets = []
	for area in get_overlapping_areas():
		if b_target.count(area) < 1 and area.has_meta("enemy"):
			possible_targets.append(area)
	if not possible_targets.is_empty():
		return possible_targets[randi_range(0,possible_targets.size()-1)]
	return null

func get_upgrade():
	if unlocked:
		return randi_range(1, upgrade_descriptions.size()-1)
	return 0

func upgrade(index: int):
	match index:
		0:
			unlocked = true
			visible = true
		1:
			AMOUNT += 1
			bullet.append(null)
			b_cooldown.append(0.0)
			b_target.append(null)
			b_position.append(null)
		2:
			DAMAGE *= 1.5
		3:
			size_mod *= 1.25
