extends CharacterBody2D

var DAMAGEPOPUP = preload("res://damage.tscn")
var pressed = false
var enemyhp : int = 200
var enemymaxhp : int = 200
var damage : int = 0
@onready var label = get_node("Label")

func _ready():
	_updatehp(0)

func _input(event):
	if (pressed == true):
		var damage = round(randf_range(10,20))
		if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			if get_viewport_rect().has_point(to_local(event.position)):
				var text = DAMAGEPOPUP.instantiate()
				text.amount = damage
				add_child(text)
				_updatehp(damage)
			
func _updatehp(damage):
	enemyhp = enemyhp - damage
	if enemyhp <= 0:
		queue_free()
	elif enemyhp > 0:
		label.set_text(str(enemyhp) + "/" + str(enemymaxhp))

func _on_area_2d_mouse_exited():
	pressed = false

func _on_area_2d_mouse_entered():
	pressed = true
