extends Area2D

@export var SPEED: float = 500.0
@export var DAMAGE: float = 1.0
@export var COOLDOWN: float = 1.0
@export var AMOUNT: int = 1
@export var BULLET: Resource
@export var FADE_SPEED: float = 4.0
@export var DELAY: float = 0.5

var spd = 0.0
var dmg = 0.0
var cldwn = 0.0
var delay = 0.0

var amnt = 0
var bullet = []
var b_cooldown = []
var b_target = []
var b_position = []

func _ready():
	spd = SPEED
	dmg = DAMAGE
	cldwn = COOLDOWN
	amnt = AMOUNT
	
	for i in range(amnt):
		bullet.append(null)
		b_cooldown.append(0.0)
		b_target.append(null)
		b_position.append(null)

func _process(delta):
	delay -= delta
	for i in range(amnt):
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
						area.damage(dmg)
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
				b_position[i] = bullet[i].global_position
				b_cooldown[i] = cldwn
				delay = DELAY

func find_target():
	var possible_targets = []
	for area in get_overlapping_areas():
		if b_target.count(area) < 1 and area.has_meta("enemy"):
			possible_targets.append(area)
	if not possible_targets.is_empty():
		return possible_targets[randi_range(0,possible_targets.size()-1)]
	return null
