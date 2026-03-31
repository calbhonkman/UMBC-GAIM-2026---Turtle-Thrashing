extends Area2D


@export var unlocked: bool = false
@export var upgrade_descriptions: Array[String]
@export var upgrade_icon: Resource

@export var BASE_DAMAGE: float = 0.2
@export var COOLDOWN: float = 10.0
@export var BULLET: Resource
@export var LIFETIME: float = 5.0
@export var BASE_KNOCKBACK: float = 50
@export var DAMAGE_TIME: float = 0.5

@onready var player = $".."

var damage = BASE_DAMAGE

var knockback_mod = 1.0
var size_mod = 1.0

var bullet = null
var b_cooldown = 0.0
var b_lifetime = 0.0
var b_target = []
var b_timer = []

func _ready():
	if unlocked:
		visible = true

func _process(delta):
	if unlocked == false:
		return
	
	b_cooldown -= delta
	if bullet:
		b_lifetime -= delta
		if b_lifetime <= 0.0:
			bullet.queue_free()
			AudioManager.laser.stop()
		
		else:
			bullet.rotation = (get_global_mouse_position() - global_position).angle()
			bullet.scale.y = size_mod
			bullet.visible = true
			
			var new_targets = []
			for area in bullet.get_overlapping_areas():
				if area.is_in_group("Enemies"):
					new_targets.append(area)
					if area not in b_target:
						b_target.append(area)
						b_timer.append(0.0)
			
			for i in b_target.size():
				if i >= b_target.size():
					pass
				elif b_target[i] and b_target[i] in new_targets:
					b_timer[i] += delta
					if b_timer[i] >= DAMAGE_TIME:
						b_target[i].damage(damage)
						$"/root/Node2D/GameManager".create_damage_particle(b_target[i].global_position, damage)
						b_timer[i] += -1 * DAMAGE_TIME
					var knockback_dir = (b_target[i].global_position - player.global_position)
					b_target[i].global_position += (knockback_dir / knockback_dir.length()) * BASE_KNOCKBACK * knockback_mod * delta
				else:
					b_target.remove_at(i)
					b_timer.remove_at(i)
					i += -1
	
	elif b_cooldown <= 0.0 and bullet == null:
		AudioManager.laser.play()
		bullet = BULLET.instantiate()
		add_child(bullet)
		b_lifetime = LIFETIME
		b_cooldown = COOLDOWN

func get_random_upgrade(index):
	if not unlocked:
		return Vector2(index, 0)
	else:
		return Vector2(index, randi_range(1, 2))

func get_upgrade_description(index: int):
	var desc = "[outline_size=10][outline_color=black]"
	desc += "[b][color=#00BF00]Laser[/color][/b][br]"
	match index:
		0:
			desc += "Unlocks the Laser weapon."
			desc += "[br]Fires a laser in the direction of your mouse cursor."
		1:
			desc += "[i][color=#8f8f8f]Your Laser is now wider.[/color][/i]"
			desc += "[br]Increases Laser Width ([color=#8FFFFF]" + str(round(size_mod * 100) / 100.0) + "x -> " + str(round(size_mod * 1.5 * 100) / 100.0) + "x[/color])."
		2:
			desc += "[i][color=#8f8f8f]Your Laser is now more repulsive.[/color][/i]"
			desc += "[br]Increases Laser Knockback by ([color=#8FFFFF]" + str(round(knockback_mod * 100) / 100.0) + "x -> " + str(round(knockback_mod * 1.5 * 100) / 100.0) + "x[/color])."
	desc += "[/outline_color][/outline_size]"
	return desc

func upgrade(index: int):
	match index:
		0:
			unlocked = true
			visible = true
		1:
			size_mod *= 1.5
		2:
			knockback_mod *= 1.5
