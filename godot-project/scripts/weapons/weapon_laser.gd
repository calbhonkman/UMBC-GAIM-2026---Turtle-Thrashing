extends Area2D

@export var DAMAGE: float = 4.0
@export var COOLDOWN: float = 10.0
@export var BULLET: Resource
@export var LIFETIME: float = 2.0
@export var KNOCKBACK: float = 100.0

@onready var player = $".."

@export var unlocked: bool = false
@export var upgrade_descriptions: Array[String]

var size_mod = 1.0

var bullet = null
var b_cooldown = 0.0
var b_target = null
var b_lifetime = 0.0

func _ready():
	if unlocked:
		visible = true
	
	b_cooldown = COOLDOWN

func _process(delta):
	if unlocked == false:
		return
	
	b_cooldown -= delta
	if bullet:
		b_lifetime -= delta
		if b_lifetime <= 0.0:
			bullet.queue_free()
		
		if b_target:
			bullet.global_position = global_position + (b_target.global_position - global_position)/2
			bullet.rotation = (b_target.global_position - global_position).angle()
			bullet.scale.x = (b_target.global_position - global_position).length() / 40
			bullet.scale.y = size_mod
			bullet.visible = true
		else:
			bullet.queue_free()
		
		for area in bullet.get_overlapping_areas():
			if area.has_meta("enemy"):
				area.damage(DAMAGE * delta)
				var knockback_dir = (area.global_position - player.global_position)
				area.global_position += (knockback_dir / knockback_dir.length()) * KNOCKBACK * delta

	
	elif b_cooldown <= 0.0:
		b_target = find_target()
		if b_target:
			bullet = BULLET.instantiate()
			add_child(bullet)
			bullet.global_position = global_position + (b_target.global_position - global_position)/2
			bullet.rotation = (b_target.global_position - global_position).angle()
			b_lifetime = LIFETIME
			b_cooldown = COOLDOWN

func find_target():
	var target_enemy = null
	for area in get_overlapping_areas():
		if area.has_meta("enemy") and (target_enemy == null or (area.global_position-global_position).length() > (target_enemy.global_position-global_position).length()):
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
			size_mod *= 1.5
