extends Area2D

var target = null
var damage = 1.0

func set_target(t: Area2D):
	target = t
	global_position = target.global_position
	visible = true

func set_damage(d: float):
	damage = d

func _process(delta):
	global_position = target.global_position if target else global_position

func _on_animated_sprite_2d_animation_finished():
	if $AnimatedSprite2D.animation == "default":
		for area in get_overlapping_areas():
			if area.has_meta("enemy"):
				area.damage(damage)
		queue_free()
