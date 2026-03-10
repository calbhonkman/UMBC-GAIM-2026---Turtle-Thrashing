extends Area2D

@export var DAMAGE: float = 0.5
@export var COOLDOWN: float = 10.0
@export var BULLET: Resource
@export var LIFETIME: float = 5.0
@export var KNOCKBACK: float = 200.0

@onready var player = $".."

@export var unlocked: bool = false
@export var upgrade_descriptions: Array[String]

var size_mod = 1.0

var bullet = null
var b_cooldown = 0.0
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
		
		bullet.rotation = (get_global_mouse_position() - global_position).angle()
		bullet.scale.y = size_mod
		bullet.visible = true
		
		for area in bullet.get_overlapping_areas():
			if area.is_in_group("Enemies"):
				area.damage(DAMAGE * delta)
				var knockback_dir = (area.global_position - player.global_position)
				area.global_position += (knockback_dir / knockback_dir.length()) * KNOCKBACK * delta

	
	elif b_cooldown <= 0.0 and bullet == null:
		bullet = BULLET.instantiate()
		add_child(bullet)
		b_lifetime = LIFETIME
		b_cooldown = COOLDOWN

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
			size_mod += 1.0
		2:
			KNOCKBACK *= 1.25
