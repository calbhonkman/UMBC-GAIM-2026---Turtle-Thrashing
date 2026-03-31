extends Area2D

@export var BULLET: Resource

@export var unlocked: bool = false
@export var upgrade_descriptions: Array[String]
@export var upgrade_icon: Resource

@export var BASE_DAMAGE: float = 0.25
@export var BASE_RANGE: float = 200.0
@export var RANGE_BUFFER: float = 50.0

var damage = 0.0
var range_mod = 1.0

var bullets = []
var b_target = []

func _ready():
	damage = BASE_DAMAGE
	
	if unlocked:
		visible = true

func _process(delta):
	if unlocked == false:
		return
	
	get_child(0).shape.radius = BASE_RANGE * range_mod
	
	for area in get_overlapping_areas():
		if area.is_in_group("Enemies") and area not in b_target:
			bullets.append(BULLET.instantiate())
			add_child(bullets.back())
			b_target.append(area)
			bullets.back().global_position = area.global_position
	
	for i in range(bullets.size()):
		if i >= b_target.size():
			pass
		elif b_target[i] and (b_target[i].global_position - global_position).length() <= (BASE_RANGE * range_mod) + RANGE_BUFFER:
			bullets[i].global_position = b_target[i].global_position
			b_target[i].damage(damage * delta)
		else:
			bullets[i].queue_free()
			bullets.remove_at(i)
			b_target.remove_at(i)
			i += -1

func get_random_upgrade(index):
	if not unlocked:
		return Vector2(index, 0)
	else:
		return Vector2(index, randi_range(1, 2))

func get_upgrade_description(index: int):
	var desc = "[outline_size=10][outline_color=black]"
	desc += "[b][color=#FF0000]Flamestarter[/color][/b][br]"
	match index:
		0:
			desc += "Unlocks the Flamestarter weapon."
			desc += "[br]Burns nearby enemies over time."
		1:
			desc += "[i][color=#8f8f8f]Your Flamestarter now affects a wider area.[/color][/i]"
			desc += "[br]Increases Flamestarter Range ([color=#8FFFFF]" + str(round(range_mod * 100) / 100.0) + " -> " + str(round(range_mod * 1.25 * 100) / 100.0) + "[/color])."
		2:
			desc += "[i][color=#8f8f8f]Your Flamestarter now does more damage.[/color][/i]"
			desc += "[br]Increases Flamestarter Damage ([color=#8FFFFF]" + str(round(damage * 100) / 100.0) + " -> " + str(round(damage * 1.5 * 100) / 100.0) + "[/color])."
	desc += "[/outline_color][/outline_size]"
	return desc

func upgrade(index: int):
	match index:
		0:
			# Unlock Firestarter
			unlocked = true
			visible = true
		1:
			# Firestarter Range +25%
			range_mod *= 1.25
		2:
			# Firestarter Damage +50%
			damage *= 1.5
