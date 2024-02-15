extends HBoxContainer

class_name PlayerHealthStatus

@onready var p1 = $Player1
@onready var p2 = $Player2
@onready var p3 = $Player3
@onready var p4 = $Player4

@onready var p1bar = $Player1/ProgressBG/PlayerHP
@onready var p2bar = $Player2/ProgressBG/PlayerHP
@onready var p3bar = $Player3/ProgressBG/PlayerHP
@onready var p4bar = $Player4/ProgressBG/PlayerHP

func set_icon(texture: Texture2D, idpos: int):
	if idpos == 1: p1.texture = texture
	elif idpos == 2: p2.texture = texture
	elif idpos == 3: p3.texture = texture
	elif idpos == 4: p4.texture = texture


func set_health(value: float, _name: String):
	match _name:
		"Main": p1bar.value = value
		"Second": p2bar.value = value
		"Third": p3bar.value = value
		"Fourth": p4bar.value = value
