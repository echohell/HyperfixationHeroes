extends CharacterBody2D

var speed = 100
var accel = 4

@export var nav: NavigationAgent2D

func _physics_process(delta):
	
	var direction = Vector3()
	
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	
	velocity = velocity.lerp(direction * speed, accel * delta)
	
	move_and_slide()

func _input(event: InputEvent) -> void:
	
	if event is InputEventMouseButton:                                           # left click check
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_released():
				
				nav.target_position = get_global_mouse_position()
