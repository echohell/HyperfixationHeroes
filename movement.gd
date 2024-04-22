extends CharacterBody2D

var speed = 1000
var accel = 4
var stored_vel = Vector2(0,0)

@export var target_pos: Vector2
@export var inv: Control
@export var nav: NavigationAgent2D

func _physics_process(delta):
	if nav.is_navigation_finished():
		return
	
	if inv.visible == false:
		
		var current_agent_pos: Vector2 = global_position
		var next_path_pos: Vector2 = nav.get_next_path_position()
	
		var vel: Vector2 = next_path_pos - current_agent_pos
		vel = vel.normalized()
	
		velocity = vel.lerp(vel * speed, accel * delta)
		move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:                                           # left click check
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_released():
				
				nav.target_position = get_global_mouse_position()
