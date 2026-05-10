extends Area2D

@onready var player = $"/root/Node2D/Player"
@onready var sprite = $AnimatedSprite2D
@onready var shadow_sprite = $Shadow

@export var CHARGE_TIME: float = 1.0
var timer: float = 0.0
var striking: bool = false

func _process(delta):
	timer += delta
	if timer >= CHARGE_TIME and not striking:
		shadow_sprite.play("blank")
		sprite.play("strike")
		striking = true
		if not AudioManager.eel_lightning.playing:
			AudioManager.eel_lightning.play()
	if striking and not sprite.is_playing():
		if player.hitbox in get_overlapping_areas():
			player.damage(1)
		queue_free()
