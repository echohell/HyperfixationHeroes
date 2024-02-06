extends PointLight2D

func _physics_process(_delta):
	var inputDir = Vector2(
	Input.get_action_strength("right") - Input.get_action_strength("left"), 
	Input.get_action_strength("down") - Input.get_action_strength("up")
	)
