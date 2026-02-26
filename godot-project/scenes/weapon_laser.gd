extends Area2D

@export var DAMAGE: float = 4.0
@export var COOLDOWN: float = 10.0
@export var BULLET: Resource
@export var LIFETIME: float = 2.0


var dmg = 0.0
var cldwn = 0.0
var size_mod = 1.0

var bullet = null
var b_cooldown = 0.0
var b_target = null
var b_lifetime = 0.0

func _ready():
	dmg = DAMAGE
	cldwn = COOLDOWN
	b_cooldown = cldwn

func _process(delta):
	b_cooldown -= delta
	if bullet:
		b_lifetime -= delta
		if b_lifetime <= 0.0:
			bullet.queue_free()
		
		if b_target:
			bullet.global_position = global_position + (b_target.global_position - global_position)/2
			bullet.rotation = (b_target.global_position - global_position).angle()
			bullet.scale.x = (b_target.global_position - global_position).length() / 40
			bullet.visible = true
		else:
			bullet.queue_free()
		
		for area in bullet.get_overlapping_areas():
			if area.has_meta("enemy"):
				area.damage(dmg * delta)
	
	elif b_cooldown <= 0.0:
		b_target = find_target()
		if b_target:
			bullet = BULLET.instantiate()
			add_child(bullet)
			bullet.global_position = global_position + (b_target.global_position - global_position)/2
			bullet.rotation = (b_target.global_position - global_position).angle()
			b_lifetime = LIFETIME
			b_cooldown = cldwn

func find_target():
	var target_enemy = null
	for area in get_overlapping_areas():
		if area.has_meta("enemy") and (target_enemy == null or (area.global_position-global_position).length() > (target_enemy.global_position-global_position).length()):
			target_enemy = area
	return target_enemy
