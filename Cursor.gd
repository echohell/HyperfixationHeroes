@tool                                                                     # executes code in editor
extends Node2D

class_name Cursor

								# signals for accepting click on hovered cell or pressing ui_accept
signal accept_pressed(cell)
signal moved(new_cell)

@export var grid: Resource
@export var ui_cd := 0.1                                        # time before cursor can move again

@onready var _timer: Timer = $Timer
@onready var _anim_player: AnimationPlayer = $AnimationPlayer


														# coords for current cell the cursor hovers
var cell := Vector2.ZERO:
	set(value):
		var new_cell: Vector2 = grid.grid_clamp(value)                           # clamp the coords
		if new_cell.is_equal_approx(cell):                      # if in same cell don't do anything
			return
		
		cell = new_cell                                          # if we move to a new cell, send a
		position = grid.calculate_map_pos(cell)            # signal and start cd timer for dir keys
		emit_signal("moved", cell)
		_timer.start()


func _ready() -> void:
	_anim_player.play("Cursor")                                 # on ready, player cursor animation
	_timer.wait_time = ui_cd
	position = grid.calculate_map_pos(cell)                  # set cursor position to grid calc pos


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:                           # check the events being submitted
		cell = grid.calculate_grid_coords(event.position)                    # left click or accept
	elif event.is_action_pressed("left click") or event.is_action_pressed("ui_accept"):
		emit_signal("accept_pressed", cell)                   # send signal that press was accepted
		get_viewport().set_input_as_handled()

	var should_move := event.is_pressed()                   # bool returns true if event is pressed
	if event.is_echo():                                      # bool returns true if event is echoed
		should_move = should_move and _timer.is_stopped()
	
	if not should_move:
		return
	
	if event.is_action("ui_right"):                              # left right up down with keyboard
		cell +=Vector2.RIGHT
	elif event.is_action("ui_up"):
		cell +=Vector2.UP
	elif event.is_action("ui_left"):
		cell +=Vector2.LEFT
	elif event.is_action("ui_down"):
		cell +=Vector2.DOWN


func _draw() -> void:                                         # draw cursor rectangle to show place
	draw_rect(Rect2(-grid.cell_size / 2, grid.cell_size), Color.ALICE_BLUE, false, 3)
