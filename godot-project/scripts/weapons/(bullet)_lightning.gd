extends Area2D

@onready var cloud = $Cloud
@onready var strike = $Strike
var mode = "default"

var damage = 0.0

func _process(delta):
	match mode:
		"default":
			cloud.play("cloud1")
			mode = "cloud"
		"cloud":
			if not cloud.is_playing():
				cloud.play("cloud2")
				strike.play("strike1")
				mode = "strike"
		"strike":
			if not strike.is_playing():
				AudioManager.cloud.play()
				for area in get_overlapping_areas():
					if area.is_in_group("Enemies"):
						area.damage(damage)
						$"/root/Node2D/GameManager".create_damage_particle(area.global_position, damage)
				strike.play("strike2")
				mode = "done"
		"done":
			if not strike.is_playing():
				queue_free()
