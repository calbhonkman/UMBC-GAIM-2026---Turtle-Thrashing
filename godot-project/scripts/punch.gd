extends Area2D

@onready var mother_of_all_bullets = $"../../MotherOfAllBullets"

@export var COOLDOWN: float = 3.0

const FIST = preload("uid://csgsdh6itco8")

var timer = 0.0

func _process(delta):
	timer += delta
	
	if timer >= COOLDOWN:
		var closest_enemy = null
		for area in get_overlapping_areas():
			if area.get_script().get_path() != "res://scripts/enemy.gd":
				pass
			elif closest_enemy == null:
				closest_enemy = area
			elif (area.position - position).length() < (closest_enemy.position - position).length():
				closest_enemy = area
		if closest_enemy != null:
			timer = 0
			var new_bullet = FIST.instantiate()
			mother_of_all_bullets.add_child(new_bullet)
			new_bullet.global_position = global_position
			new_bullet.set_target(closest_enemy)
