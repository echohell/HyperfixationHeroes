@tool
extends Node2D

class_name Cursor

signal accept_pressed(cell)
signal moved(new_cell)

@export var grid: Resource
@export var ui_cd := 0.1
@onready var _timer: Timer = $Timer
@onready var _anim_player: AnimationPlayer = $AnimationPlayer


var cell := Vector2.ZERO:
	set(value):
		var new_cell: Vector2 = grid.grid_clamp(value)
		if new_cell.is_equal_approx(cell):
			return
		
		cell = new_cell
		position = grid.calculate_map_pos(cell)
		emit_signal("moved", cell)
		_timer.start()


func _ready() -> void:
	_anim_player.play("Cursor")
	_timer.wait_time = ui_cd
	position = grid.calculate_map_pos(cell)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		cell = grid.calculate_grid_coords(event.position)
	elif event.is_action_pressed("click") or event.is_action_pressed("ui_accept"):
		emit_signal("accept_pressed", cell)
		get_viewport().set_input_as_handled()

	var should_move := event.is_pressed()
	if event.is_echo():
		should_move = should_move and _timer.is_stopped()
	
	if not should_move:
		return
	
	if event.is_action("ui_right"):
		cell +=Vector2.RIGHT
	elif event.is_action("ui_up"):
		cell +=Vector2.UP
	elif event.is_action("ui_left"):
		cell +=Vector2.LEFT
	elif event.is_action("ui_down"):
		cell +=Vector2.DOWN


func _draw() -> void:
	draw_rect(Rect2(-grid.cell_size / 2, grid.cell_size), Color.ALICE_BLUE, false, 3)
