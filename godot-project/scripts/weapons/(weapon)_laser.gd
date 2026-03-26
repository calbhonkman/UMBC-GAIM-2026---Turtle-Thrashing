extends Area2D


@export var unlocked: bool = false
@export var upgrade_descriptions: Array[String]

@export var DAMAGE: float = 1.0
@export var COOLDOWN: float = 10.0
@export var BULLET: Resource
@export var LIFETIME: float = 5.0
@export var BASE_KNOCKBACK: float = 100

@onready var player = $".."

var knockback_mod = 1.0
var size_mod = 1.0

var bullet = null
var b_cooldown = 0.0
var b_lifetime = 0.0

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
		
		bullet.rotation = (get_global_mouse_position() - global_position).angle()
		bullet.scale.y = size_mod
		bullet.visible = true
		
		for area in bullet.get_overlapping_areas():
			if area.is_in_group("Enemies"):
				area.damage(DAMAGE * delta)
				var knockback_dir = (area.global_position - player.global_position)
				area.global_position += (knockback_dir / knockback_dir.length()) * BASE_KNOCKBACK * knockback_mod * delta

	
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
	var desc = "[outline_size=10][outline_color=black][b][color=#00BF00]Laser[/color][/b][br]"
	match index:
		0:
			desc += "[i][color=#8f8f8f]You now have a deadly laser pointer.[/color][/i]"
			desc += "[br]Unlocks the Laser weapon."
		1:
			desc += "[i][color=#8f8f8f]Your laser is now wider.[/color][/i]"
			desc += "[br]Increases Laser Width ([color=#8FFFFF]" + str(round(size_mod * 100) / 100.0) + "x -> " + str(round(size_mod * 1.5 * 100) / 100.0) + "x[/color])."
		2:
			desc += "[i][color=#8f8f8f]Your laser now has more force.[/color][/i]"
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
