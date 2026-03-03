extends Node2D

@export var ROTATION_SPEED: float = 2.0
@export var KNOCKBACK: float = 50.0

@export var unlocked: bool = false
@export var upgrade_descriptions: Array[String]

func _ready():
	if unlocked:
		visible = true

func _process(delta):
	if unlocked == false:
		return
	
	rotation += ROTATION_SPEED * delta
	
	for area in get_child(0).get_overlapping_areas():
		if area.has_meta("enemy"):
			var knockback_dir = (area.global_position - global_position)
			area.global_position += (knockback_dir / knockback_dir.length()) * KNOCKBACK

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
			ROTATION_SPEED *= 1.25
