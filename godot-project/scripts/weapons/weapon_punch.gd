extends Area2D

@export var SPEED: float = 500.0
@export var DAMAGE: float = 1.0
@export var COOLDOWN: float = 1.0
@export var AMOUNT: int = 1
@export var BULLET: Resource
@export var FADE_SPEED: float = 4.0
@export var DELAY: float = 0.5
@export var KNOCKBACK: float = 50.0

@export var unlocked: bool = false
@export var upgrade_descriptions: Array[String]

var delay = 0.0

var bullet = []
var b_cooldown = []
var b_target = []
var b_position = []
var b_prev = []

func _ready():
	if unlocked:
		visible = true
	
	for i in range(AMOUNT):
		bullet.append(null)
		b_cooldown.append(0.0)
		b_target.append(null)
		b_position.append(null)
		b_prev.append([])

func _process(delta):
	if unlocked == false:
		return
	
	delay -= delta
	for i in range(AMOUNT):
		b_cooldown[i] -= delta
		if bullet[i]:
			if b_target[i]:
				var b_target_dir = (b_target[i].global_position - b_position[i])
				b_target_dir = b_target_dir / b_target_dir.length()
				bullet[i].rotation = b_target_dir.angle()
				bullet[i].global_position += b_target_dir * delta * SPEED
				b_position[i] = bullet[i].global_position
				bullet[i].visible = true
				
				var entered_areas = []
				for area in bullet[i].get_overlapping_areas():
					if area == b_target[i]:
						b_target[i] = null
					if area not in b_prev[i] and area.has_meta("enemy"):
						area.damage(DAMAGE)
						var knockback_dir = (area.global_position - bullet[i].global_position)
						area.global_position += (knockback_dir / knockback_dir.length()) * KNOCKBACK
					if area != null:
						entered_areas.append(area)
				b_prev[i] = entered_areas
					
			elif bullet[i].get_child(0).modulate.a > 0:
				bullet[i].get_child(0).modulate.a -= delta * FADE_SPEED
				bullet[i].global_position = b_position[i]
			else:
				bullet[i].queue_free()
				bullet[i] = null
				b_target[i] = null
				b_position[i] = null
				b_prev[i] = []
		elif b_cooldown[i] <= 0.0 and delay <= 0.0:
			b_target[i] = find_target()
			if b_target[i]:
				bullet[i] = BULLET.instantiate()
				add_child(bullet[i])
				bullet[i].global_position = global_position
				b_position[i] = bullet[i].global_position
				b_cooldown[i] = COOLDOWN
				delay = DELAY

func find_target():
	var target_enemy = null
	for area in get_overlapping_areas():
		if b_target.count(area) < 1 and area.has_meta("enemy") and (target_enemy == null or (area.global_position-global_position).length() < (target_enemy.global_position-global_position).length()):
			target_enemy = area
	return target_enemy

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
			b_prev.append([])
		2:
			COOLDOWN *= 0.75
			DELAY *= 0.75
		3:
			KNOCKBACK *= 1.5
