extends Area2D

@export var SPEED: float = 500.0
@export var BASE_DAMAGE: float = 2.0
@export var COOLDOWN: float = 3.0
@export var AMOUNT: int = 1
@export var BULLET: Resource

@export var unlocked: bool = false
@export var upgrade_descriptions: Array[String]
@export var upgrade_icon: Resource
@export var upgrade_icon_selected: Resource

var size_mod = 1.0
var damage = BASE_DAMAGE

var bullet = []
var b_cooldown = []
var b_target = []
var b_position = []

func _ready():
	if unlocked:
		visible = true
	
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
				b_position[i] = b_target[i].global_position
			bullet[i].global_position = b_position[i]
			bullet[i].visible = true
		elif b_cooldown[i] <= 0.0: # and delay <= 0.0:
			b_target[i] = find_target()
			if b_target[i]:
				bullet[i] = BULLET.instantiate()
				add_child(bullet[i])
				b_position[i] = b_target[i].global_position
				bullet[i].global_position = b_position[i]
				bullet[i].scale *= size_mod
				bullet[i].damage = damage
				b_cooldown[i] = COOLDOWN

func find_target():
	var possible_targets = []
	for area in get_overlapping_areas():
		if b_target.count(area) < 1 and area.is_in_group("Enemies"):
			possible_targets.append(area)
	if not possible_targets.is_empty():
		return possible_targets[randi_range(0,possible_targets.size()-1)]
	return null

func get_random_upgrade(index):
	if not unlocked:
		return Vector2(index, 0)
	else:
		return Vector2(index, randi_range(1, 3))

func get_upgrade_description(index: int):
	var desc = "[outline_size=10][outline_color=black]"
	desc += "[b][color=#FFFF00]Lightning[/color][/b][br]"
	match index:
		0:
			desc += "Unlocks the Lightning weapon."
			desc += "[br]Zaps a random enemy onscreen with lightning."
		1:
			desc += "[i][color=#8f8f8f]Your Lightning now strikes more enemies.[/color][/i]"
			desc += "[br]Increases Lightning Strikes ([color=#8FFFFF]" + str(AMOUNT) + " -> " + str(AMOUNT + 1) + "[/color])."
		2:
			desc += "[i][color=#8f8f8f]Your Lightning now does more damage.[/color][/i]"
			desc += "[br]Increases Lightning Damage ([color=#8FFFFF]" + str(round(damage * 100) / 100.0) + " -> " + str(round(damage * 1.5 * 100) / 100.0) + "[/color])."
		3:
			desc += "[i][color=#8f8f8f]Your Lightning now strikes a larger area.[/color][/i]"
			desc += "[br]Increases Lightning Strike Size ([color=#8FFFFF]" + str(round(size_mod * 100) / 100.0) + "x -> " + str(round(size_mod * 1.5 * 100) / 100.0) + "x[/color])."
	desc += "[/outline_color][/outline_size]"
	return desc

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
			damage *= 1.5
		3:
			size_mod *= 1.5
