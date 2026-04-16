extends Node2D

@export var BASE_ROTATION_SPEED: float = 2.0
@export var STUN_DURATION: float = 0.25
@export var MOVE_SPEED: float = 5.0

@export var unlocked: bool = false
@export var upgrade_descriptions: Array[String]
@export var upgrade_icon: Resource

@onready var shield = $Area2D
var anti_turtle_position = null
var move_speed_mod = 1.0

func _ready():
	anti_turtle_position = global_position
	if unlocked:
		visible = true

func _process(delta):
	if unlocked == false:
		return
	
	if shield.global_position != get_global_mouse_position():
		var player_dir = (get_global_mouse_position() - shield.global_position)
		var rotation_dir = angle_difference(shield.rotation, player_dir.angle())
		shield.rotation += rotation_dir if player_dir.length() > (MOVE_SPEED * move_speed_mod) else 0.0
		shield.global_position = anti_turtle_position + (player_dir / player_dir.length()) * min((MOVE_SPEED * move_speed_mod), player_dir.length())
		anti_turtle_position = shield.global_position
	
	for area in get_child(0).get_overlapping_areas():
		if area.is_in_group("Enemies") and area.has_method("stun"):
			area.stun(STUN_DURATION)
		if area.is_in_group("Enemy Bullets"):
			area.queue_free()

func get_random_upgrade(index):
	if not unlocked:
		return Vector2(index, 0)
	else:
		return Vector2(index, randi_range(1, 1))

func get_upgrade_description(index: int):
	var desc = "[outline_size=10][outline_color=black]"
	desc += "[b][color=#008FFF]Shield[/color][/b][br]"
	match index:
		0:
			desc += "Unlocks the Shield minion."
			desc += "[br]Rotates around you to keep enemies away."
		1:
			desc += "[i][color=#8f8f8f]Your Shield now moves faster.[/color][/i]"
			desc += "[br]Increases Shield Move Speed ([color=#8FFFFF]" + str(round(move_speed_mod * 100) / 100.0) + "x -> " + str(round(move_speed_mod * 1.25 * 100) / 100.0) + "x[/color])."
	desc += "[/outline_color][/outline_size]"
	return desc

func upgrade(index: int):
	match index:
		0:
			unlocked = true
			visible = true
			anti_turtle_position = global_position
		1:
			move_speed_mod *= 1.25
