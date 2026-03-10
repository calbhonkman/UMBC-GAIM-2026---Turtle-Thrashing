extends Area2D

@export var BULLET: Resource

@export var unlocked: bool = false
@export var upgrade_descriptions: Array[String]

@export var BASE_DAMAGE: float = 0.5
@export var BASE_RANGE: float = 250.0

var damage = 0.0
var range = 0.0

var bullets = []
var b_target = []

func _ready():
	damage = BASE_DAMAGE
	range = BASE_RANGE
	
	if unlocked:
		visible = true

func _process(delta):
	if unlocked == false:
		return
	
	get_child(0).shape.radius = range
	
	for area in get_overlapping_areas():
		if area.is_in_group("Enemies") and area not in b_target:
			bullets.append(BULLET.instantiate())
			add_child(bullets.back())
			b_target.append(area)
			bullets.back().global_position = area.global_position
	
	for i in range(bullets.size()):
		if i >= b_target.size():
			pass
		elif b_target[i] and (b_target[i].global_position - global_position).length() <= range:
			bullets[i].global_position = b_target[i].global_position
			b_target[i].damage(damage * delta)
		else:
			bullets[i].queue_free()
			bullets.remove_at(i)
			b_target.remove_at(i)
			i += -1

func get_upgrade():
	if unlocked:
		return randi_range(1, upgrade_descriptions.size()-1)
	return 0

func upgrade(index: int):
	match index:
		0:
			# Unlock Firestarter
			unlocked = true
			visible = true
		1:
			# Firestarter Range +50%
			range += 0.25 * BASE_RANGE
		2:
			# Firestarter Damage +50%
			damage += 0.25 * BASE_DAMAGE
