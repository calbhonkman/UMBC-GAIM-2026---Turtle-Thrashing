extends Sprite2D

@export var EXP_COLOR_SPEED: float = 2.0

var hue: float = 0.0


func _process(delta: float) -> void:
	hue = wrapf(hue + (EXP_COLOR_SPEED * delta), 0.0, 1.0)
	var rainbow_color = Color.from_hsv(hue, 0.8, 0.8)
	modulate = rainbow_color
