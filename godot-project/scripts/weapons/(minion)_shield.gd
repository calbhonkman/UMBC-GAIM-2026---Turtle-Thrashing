extends Node2D

@export var BASE_ROTATION_SPEED: float = 2.0
@export var KNOCKBACK: float = 50.0

@export var unlocked: bool = false
@export var upgrade_descriptions: Array[String]

var rotation_speed_mod = 1.0

func _ready():
	if unlocked:
		visible = true

func _process(delta):
	if unlocked == false:
		return
	
	rotation += BASE_ROTATION_SPEED * rotation_speed_mod * delta
	
	for area in get_child(0).get_overlapping_areas():
		if area.has_meta("enemy"):
			var knockback_dir = (area.global_position - global_position)
			area.global_position += (knockback_dir / knockback_dir.length()) * KNOCKBACK

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
			desc += "[i][color=#8f8f8f]A new friend to help repel threats.[/color][/i]"
			desc += "[br]Unlocks the Shield minion."
		1:
			desc += "[i][color=#8f8f8f]Spiiinnnnnnnn..... [/color][/i]"
			desc += "[br]Increases Shield Rotation Speed ([color=#8FFFFF]" + str(round(rotation_speed_mod * 100) / 100.0) + "x -> " + str(round(rotation_speed_mod * 1.5 * 100) / 100.0) + "x[/color])."
	desc += "[/outline_color][/outline_size]"
	return desc

func upgrade(index: int):
	match index:
		0:
			unlocked = true
			visible = true
		1:
			rotation_speed_mod *= 1.5
