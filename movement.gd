extends CharacterBody2D

var speed = 1000
var accel = 4
var stored_vel = Vector2(0,0)

@export var target_pos: Vector2
@export var inv: Control
@export var nav: NavigationAgent2D

@onready var AnimSprite = $Sprite2D2

func _physics_process(delta):
	if nav.is_navigation_finished():
		AnimSprite.play("idle")
		return
	
	if inv.visible == false:
		
		var current_agent_pos: Vector2 = global_position
		var next_path_pos: Vector2 = nav.get_next_path_position()
	
		var vel: Vector2 = next_path_pos - current_agent_pos
		vel = vel.normalized()
		
		if vel.x > 0 and (vel.y <= .65 and vel.y >= -.65):
			AnimSprite.play("walk_right")
		elif vel.x < 0 and (vel.y <= .65 and vel.y >= -.65):
			AnimSprite.play("walk_left")
		elif vel.y < 0 and (vel.x < .66 and vel.x > -.66):
			AnimSprite.play("walk_up")
		elif vel.y > 0 and (vel.x < .66 and vel.x > -.66):
			AnimSprite.play("walk_down")
		if vel.x == 0 and vel.y == 0:
			AnimSprite.play("idle")
	
		velocity = vel.lerp(vel * speed, accel * delta)
			
		move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:                                           # left click check
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_released():
				
				nav.target_position = get_global_mouse_position()
