extends Area2D

@onready var hitbox = $CollisionPolygon2D

func play(anim):
	$AnimatedSprite2D.play(anim)
