extends Sprite2D

func _process(_delta: float) -> void:
	var rainbow_color = Color.from_hsv($"/root/Node2D/GameManager".exp_hue, 0.8, 0.8)
	modulate = rainbow_color
