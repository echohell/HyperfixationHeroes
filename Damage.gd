extends Marker2D

@onready var label = get_node("Label")
var amount

@export var SPEED : int = 50
@export var FRICTION : int = 15
var SHIFT_DIRECTION: Vector2 = Vector2.ZERO


func _ready():
	label.set_text(str(amount))
	print("_ready called")
	SHIFT_DIRECTION = Vector2(randf_range(-1,1), randf_range(-1,1))

func _process(delta):
	global_position +=SPEED * SHIFT_DIRECTION * delta
	SPEED = max(SPEED - FRICTION * delta, 0)


