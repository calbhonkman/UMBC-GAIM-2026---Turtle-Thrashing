extends Node2D

@export var ROTATION_SPEED: float = 2.0
@export var KNOCKBACK: float = 50.0

func _process(delta):
	rotation += ROTATION_SPEED * delta
	
	for area in get_child(0).get_overlapping_areas():
		if area.has_meta("enemy"):
			var knockback_dir = (area.global_position - global_position)
			area.global_position += (knockback_dir / knockback_dir.length()) * KNOCKBACK
