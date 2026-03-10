extends Area2D

@export var BULLET: Resource

@export var unlocked: bool = false
@export var upgrade_descriptions: Array[String]

@export var BASE_SPEED: float = 800.0
@export var BASE_DAMAGE: float = 1.0
@export var BASE_COOLDOWN: float = 2.0
@export var BASE_DELAY: float = 0.5
@export var LIFETIME: float = 1.0
@export var FADE_SPEED: float = 4.0
@export var KNOCKBACK: float = 50.0

var speed = 0.0
var damage = 0.0
var cooldown = 0.0
var delay = 0.0
var size_mod = 1.0

var bullets = []
var b_lifetime = []
var b_direction = []
var b_position = []
var b_prev = []

func _ready():
	if unlocked:
		visible = true
	
	speed = BASE_SPEED
	damage = BASE_DAMAGE
	cooldown = BASE_COOLDOWN
	delay = BASE_DELAY

func _process(delta):
	if unlocked == false:
		return
	
	cooldown -= delta
	if cooldown <= 0.0 and is_enemy_in_area(self):
		cooldown = BASE_COOLDOWN
		spawn_bullet()
	
	# Kill old bullets
	for i in range(bullets.size()-1, -1, -1):
		b_lifetime[i] -= delta
		if b_lifetime[i] <= 0.0:
			var dead_bullet = bullets.pop_at(i)
			dead_bullet.queue_free()
			b_lifetime.remove_at(i)
			b_direction.remove_at(i)
			b_position.remove_at(i)
			b_prev.remove_at(i)
	
	# Move remaining bullets
	for i in range(bullets.size()):
		bullets[i].global_position = b_position[i] + b_direction[i] * delta * max(0, pow(b_lifetime[i] / LIFETIME,2)) * speed
		b_position[i] = bullets[i].global_position
		
		bullets[i].get_child(0).modulate = Color(1,1,1,max(0, pow(b_lifetime[i] / LIFETIME,2)))
		
		for area in bullets[i].get_overlapping_areas():
			if area not in b_prev[i] and area.is_in_group("Enemies"):
				b_prev[i].append(area)
				area.damage(damage)
				var knockback_dir = (area.global_position - global_position)
				area.global_position += (knockback_dir / knockback_dir.length()) * KNOCKBACK


func is_enemy_in_area(area: Area2D):
	for body in area.get_overlapping_areas():
		if body.is_in_group("Enemies"):
			return true
	return false

func spawn_bullet():
	var new_bullet = BULLET.instantiate()
	add_child(new_bullet)
	new_bullet.global_position = global_position
	new_bullet.scale *= size_mod
	bullets.append(new_bullet)
	b_lifetime.append(LIFETIME)
	
	# Will fire in the direction of the closest enemy
	var nearest_enemy_pos = null
	for area in get_overlapping_areas():
		if area.is_in_group("Enemies") and (nearest_enemy_pos == null or (area.global_position - global_position).length() < (nearest_enemy_pos - global_position).length()):
			nearest_enemy_pos = area.global_position
	b_direction.append((nearest_enemy_pos - global_position).normalized())
	new_bullet.look_at(nearest_enemy_pos)
	
	b_position.append(global_position)
	b_prev.append([])

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
			damage += 0.5 * BASE_DAMAGE
		2:
			BASE_COOLDOWN *= 0.75
			BASE_DELAY *= 0.75
		3:
			size_mod += 0.5
