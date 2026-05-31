extends Area2D

@onready var camera = $"/root/Node2D/GameManager/Camera"

@export var BULLET: Resource

@export var unlocked: bool = false
@export var upgrade_descriptions: Array[String]
@export var upgrade_icon: Resource
@export var upgrade_icon_selected: Resource

@export var BASE_SPEED: float = 650.0
@export var BASE_DAMAGE: float = 1.0
@export var BASE_COOLDOWN: float = 2.0
@export var BASE_BOUNCES: int = 1
@export var BASE_DELAY: float = 0.5
@export var KNOCKBACK: float = 50.0
@export var POS_OFFSET: float = 25.0

var speed = 0.0
var damage = 0.0
var cooldown = 0.0
var delay = 0.0
var size_mod = 1.0
var max_bounces = 0
var screen_size = 0.0

var bullets = []
var b_bounces = []
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
	max_bounces = BASE_BOUNCES
	
	screen_size = camera.get_viewport_rect().size

func _process(delta):
	if unlocked == false:
		return
		
	if bullets.is_empty():
		cooldown -= delta
	if cooldown <= 0.0 and is_enemy_in_area(self):
		cooldown = BASE_COOLDOWN
		spawn_bullet()
	
	# Kill old bullets
	for i in range(bullets.size()-1, -1, -1):
		if b_bounces[i] < 0:
			var dead_bullet = bullets.pop_at(i)
			dead_bullet.queue_free()
			b_bounces.remove_at(i)
			b_direction.remove_at(i)
			b_position.remove_at(i)
			b_prev.remove_at(i)
	
	var cam_left = camera.global_position.x - screen_size.x / 2
	var cam_right = camera.global_position.x + screen_size.x / 2
	var cam_up = camera.global_position.y - screen_size.y / 2
	var cam_down = camera.global_position.y + screen_size.y / 2
	
	# Move remaining bullets
	for i in range(bullets.size()):
		if bullets[i].global_position.x <= cam_left or bullets[i].global_position.x >= cam_right:
			b_bounces[i] -= 1
			b_prev[i].clear()
			b_direction[i].x *= -1
			bullets[i].global_position.x = cam_left + POS_OFFSET if bullets[i].global_position.x <= cam_left else cam_right - POS_OFFSET
		elif bullets[i].global_position.y <= cam_up or bullets[i].global_position.y >= cam_down:
			b_bounces[i] -= 1
			b_prev[i].clear()
			b_direction[i].y *= -1
			bullets[i].global_position.y = cam_up + POS_OFFSET if bullets[i].global_position.y <= cam_up else cam_down - POS_OFFSET
			
		bullets[i].global_position = b_position[i] + b_direction[i] * delta * speed
		b_position[i] = bullets[i].global_position
		
		for area in bullets[i].get_overlapping_areas():
			if area not in b_prev[i] and area.is_in_group("Enemies") and area.get_script():
				b_prev[i].append(area)
				area.damage(damage)
				$"/root/Node2D/GameManager".create_damage_particle(area.global_position, damage)
				AudioManager.punch.play()
				if not "knockback_immunity" in area or not area.knockback_immunity:
					var knockback_dir = (area.global_position - global_position)
					area.global_position += (knockback_dir / knockback_dir.length()) * KNOCKBACK		

func is_enemy_in_area(area: Area2D):
	for body in area.get_overlapping_areas():
		if body.is_in_group("Enemies"):
			return true
	return false

func spawn_bullet():
	AudioManager.whoosh.play()
	var new_bullet = BULLET.instantiate()
	add_child(new_bullet)
	new_bullet.global_position = global_position
	new_bullet.scale *= size_mod
	bullets.append(new_bullet)
	b_bounces.append(max_bounces)
	
	# Will fire in the direction of the closest enemy
	var nearest_enemy_pos = null
	for area in get_overlapping_areas():
		if area.is_in_group("Enemies") and (nearest_enemy_pos == null or (area.global_position - global_position).length() < (nearest_enemy_pos - global_position).length()):
			nearest_enemy_pos = area.global_position
	b_direction.append((nearest_enemy_pos - global_position).normalized())
	new_bullet.look_at(nearest_enemy_pos)
	
	b_position.append(global_position)
	b_prev.append([])

func get_random_upgrade(index):
	if not unlocked:
		return Vector2(index, 0)
	else:
		return Vector2(index, randi_range(1, 3))

func get_upgrade_description(index: int):
	var desc = "[outline_size=10][outline_color=black]"
	desc += "[b]Punch[/b][br]"
	match index:
		0:
			desc += "Unlocks the Bowling Ball weapon."
			desc += "[br]Throws a bowling ball that bounces across the screen."
		1:
			desc += "[i][color=#8f8f8f]Bowling Ball now does more damage.[/color][/i]"
			desc += "[br]Increases Bowling Ball Damage ([color=#8FFFFF]" + str(round(damage * 100) / 100.0) + " -> " + str(round((damage + 0.5) * 100) / 100.0) + "[/color])."
		2:
			desc += "[i][color=#8f8f8f]Bolwing Ball rolls faster.[/color][/i]"
			desc += "[br]Increases Bowling Ball Speed ([color=#8FFFFF]" + str(round(speed * 100) / 100.0) + " -> " + str(round(speed * 1.25 * 100) / 100.0) + "[/color])."
		3:
			desc += "[i][color=#8f8f8f]Bowling Ball bounces more.[/color][/i]"
			desc += "[br]Increases Bowling Ball Bounces ([color=#8FFFFF]" + str(max_bounces) + " -> " + str(max_bounces + 1) + "[/color])."
	desc += "[/outline_color][/outline_size]"
	return desc

func upgrade(index: int):
	match index:
		0:
			unlocked = true
			visible = true
		1:
			damage += 0.5
		2:
			speed *= 1.25
		3:
			max_bounces += 1
