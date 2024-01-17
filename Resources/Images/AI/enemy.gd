extends CharacterBody2D

var DAMAGEPOPUP = preload("res://damage.tscn")
var pressed = false

func _input(event):
	if (pressed == true):
		var damage = round(randf_range(10,20))
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if get_viewport_rect().has_point(to_local(event.position)):
				print(damage)
				var text = DAMAGEPOPUP.instantiate()
				text.amount = damage
				add_child(text)
			
			


func _on_area_2d_mouse_exited():
	pressed = false

func _on_area_2d_mouse_entered():
	pressed = true
