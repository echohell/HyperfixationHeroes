extends CharacterBody2D

@export var moveSpeed : float = 300

func _physics_process(_delta):
	var inputDir = Vector2(
	Input.get_action_strength("right") - Input.get_action_strength("left"), 
	Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	velocity = inputDir * moveSpeed
	move_and_slide()
