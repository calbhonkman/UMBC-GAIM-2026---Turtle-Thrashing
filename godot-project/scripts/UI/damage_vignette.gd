extends Sprite2D

@export var FADE_SPEED: float = 2.0

func _process(delta):
	modulate.a = clamp(modulate.a - (FADE_SPEED * delta), 0.0, 1.0)
