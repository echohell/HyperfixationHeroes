extends Node2D

class_name GameBoard                                       # THIS IS FOR GAME LOGIC, DONT TIE IT UP
														# Alot of these are not going to be working

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]
const tile_checks = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]

@export var grid: Resource
@export var combat: Combat
@export var controlling_node: Node2D
@export var _action_panel: Control
@export var _playergroup: Node2D
															# global vars being used for game logic

var _astar = AStarGrid2D.new()
var _selected_skill: String
var _skill_name: String
var _next_position
var _position_id = 0
var _move_speed = 250.0
var _previous_position : Vector2i
var _path : PackedVector2Array
var _attack_target_pos
var _blocked_target_pos
var _move_pressed = false
var _arrived = true
var _skill_selected = false
var _player_turn = true
var _units := {}                                                  # Map coords cell to ref the unit
var _active_unit: Unit
var _combatant
var _walkable_cells := []
var _occupied_spaces = []
var _blocking_spaces = [[],[],[]]                                #ground, then flying, then mounted
var movement = 3:
	set = set_movement,
	get = get_movement

@onready var _bgmap := $"../Background Tiles"                   # hard map path to background tiles
@onready var _tilemap := $"../Map"                               # hard map path to get solid tiles
@onready var _enemygroup: Node2D = $EnemyGroup
@onready var _unit_overlay: UnitOverlay = $UnitOverlay
@onready var _unit_path: UnitPath = $UnitPath


# signal update_information(text: String)         # not used yet
# signal movement_changed(movement: int)          # not used yet
signal finished_move
# signal target_selection_start()                 # not used yet
# signal target_selection_finish()                # not used yet


func _unhandled_input(event: InputEvent) -> void:
	if _player_turn == false:                                 # dont allow input if not player turn
		return
	
	if event is InputEventMouseButton:                                           # left click check
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.is_released():
				if _skill_selected == true:                                 # if its a skill select
					var mouse_position = get_global_mouse_position()
					var mouse_pos_i = _bgmap.local_to_map(mouse_position)
					var comb = get_combatant_at_pos(mouse_pos_i)           # get combatant position
					if comb != null and comb.alive:
						target_selected(comb)                    # if target is alive, its selected
					elif _arrived == true:                             # if not moving, move player
						move_player()
	
	if _active_unit and event.is_action_pressed("ui_cancel"):         # checks for escape to cancel
		_deselect_active_unit()
		_clear_active_unit()
		_turn_off_canvas()



func get_combatant_at_pos(target_position: Vector2i):           # func gets combatant at given cell
	for comb in combat.combatants:
		if comb.position == target_position and comb.alive:
			return comb
	return null

func _ready() -> void:
	_astar.region = Rect2i(-1, 3, grid.size.x + 1, grid.size.y)                  # this is combat zone
	_astar.cell_size = grid.cell_size                                    # is set in grid resource
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN   # manhattan is for 4 point
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER   # can turn this on if we want diagonal
	_astar.update()
	
	for i in _tilemap.getcombatnumbers():                        # set point solids for combat area
		var checkvalresult = checkvalue(i)
		if checkvalresult == true:
			_astar.set_point_solid(i)
	
	_reinitialize()

func checkvalue(value):
	var valy = value.y
	if (valy > 3 and valy <= 17):
		return true
	else:
		return false

func _on_combat_processing_combatant_added(combatant):                       # adds combatant space
	_occupied_spaces.append(combatant.position)

func _on_combat_processing_combatant_down(combatant):                     # removes combatant space
	_occupied_spaces.erase(combatant.position)

func _on_combat_processing_turn_advance(combatant: Dictionary):         # process turn advancements
	
	_combatant = combatant
	
	if combatant.side == 0:
		_player_turn = true
	else:
		_player_turn = false
	
	controlling_node = combatant.sprite                                  # controlling node changes
	movement = combatant.movement                                     # their movement value is set
	# update_point_weight()                                    # still deciding if i wanna use this


func update_point_weight():
	pass

func get_distance(point1: Vector2i, point2: Vector2i):      # get absolute integer between 2 values
	return absi(point1.x - point2.x) + absi(point1.y - point2.y)


func _process(delta):                        # processed ai if they have not arrived at destination
	if _arrived == false:
		controlling_node.position += controlling_node.position.direction_to(_next_position) * delta * _move_speed
		#_enemygroup.get_child(_enemy_turn_val).position = controlling_node.position + Vector2(16,16) # offset for sprite pos
		if (_player_turn == false):
			_enemygroup.get_node(_combatant.name).position = Vector2i(controlling_node.position) + Vector2i(16, 16)
		
		if controlling_node.position.distance_to(_next_position) < 1:
			_occupied_spaces.erase(_previous_position)               # change the space it occupies
			_astar.set_point_weight_scale(_previous_position, 1)    # set the weight back to normal
			var tile_cost = get_tile_costs(_previous_position)                   # check tile costs
			controlling_node.position = _next_position
			var new_pos: Vector2i = _bgmap.local_to_map(_next_position)          # var new position
			combat.get_current_combatant().position = new_pos
			_previous_position = new_pos
			_occupied_spaces.append(new_pos)         # append the new position as an occupied space
			update_point_weight()             # this is where i would update the solid point weight
			var next_tile_cost = get_tile_costs(new_pos)
			movement -= tile_cost                                # movement is reduced by tile cost
													   # various checks to ensure ai can still move
			if _position_id < _path.size() - 1 and movement > 0 and next_tile_cost <= movement:
				_position_id += 1
				_next_position = _path[_position_id]
			else:
				finished_move.emit()            # if they dont clear all checks, their move is done
				_arrived = true


func set_movement(value: int):
	movement = value

func get_movement():
	return movement

func ai_process(target_position: Vector2i):                      # pass in where the ai wants to go
	var current_position = _bgmap.local_to_map(controlling_node.position)  # checks its current pos
	for tile in tile_checks:                                        # check each cardinal direction
		if !_astar.is_point_solid(target_position + tile):              # if the point is not solid
			ai_move(target_position + tile)                                # move in the target pos
			break
	return finished_move                                                    # return when completed


func ai_move(target_position: Vector2i):                       # pass in the target pos + tile size
	var current_position = _bgmap.local_to_map(controlling_node.position)     # convert current pos
	find_path(target_position)                                                # find the astar path
	move_on_path(current_position)                                   # move on the given astar path
	

func find_path(tile_pos: Vector2i):
	var current_position = _bgmap.local_to_map(controlling_node.position)     # convert current pos
	
	if _astar.get_point_weight_scale(tile_pos) > 999999:            # check the solid point weights
		var dir: Vector2i                                       # set var direction to cardinal dir
		if current_position.x > tile_pos.x:
			dir = Vector2i.RIGHT
		if current_position.y > tile_pos.y:
			dir = Vector2i.DOWN
		if current_position.x < tile_pos.x:
			dir = Vector2i.LEFT
		if current_position.y > tile_pos.y:
			dir = Vector2i.UP
		tile_pos += dir                                    # tile position is modified by direction
	_path = _astar.get_point_path(current_position, tile_pos)   # generate the points to get to end
	queue_redraw()                                            # queue redraw forces a canvas update


func move_player():                                                     # not really being used atm
	var current_position = _bgmap.local_to_map(controlling_node.position)       
	var _path_size = _path.size()
	if _path_size > 1 and movement > 0:
		move_on_path(current_position)


func move_on_path(current_pos):                             # move on path is used by player and ai
	_previous_position = current_pos                     # set the previous pos to where we are now
	_position_id = 1                                               # update a global var for pos id
	_next_position = _path[_position_id]                                  # next pos is incremented
	_arrived = false                               # if we're still in this code, we havent arrived
	queue_redraw()                                                                 # force a redraw


func set_selected_skill(skill: String, skill_name: String):  # pass in the skill and the skill name
	_selected_skill = skill                                            # these are global variables
	_skill_name = skill_name


func begin_target_selection():                                    # triggers if a skill is selected        
	_skill_selected = true


func target_selected(target: Dictionary):                        # triggers if a target is selected
	combat.call(_selected_skill, combat.get_current_combatant(), target, _skill_name) # trigger atk
	_skill_selected = false                       # skill has now been used and can be set to false


func get_tile_costs(tile):                              # will be used when we have to calc terrain
	var tile_data = _bgmap.get_cell_tile_data(0, tile)                    # like rocks, swamp, etc.
	if combat.get_current_combatant().movement_class == 0:              # if they are a ground unit
		return int(tile_data.get_custom_data("Cost"))                     # consider the cost value
	else:
		return 1                                # if they are mounted or flying, treat it as 1 cost


func get_tile_cost_at_point(point):                        # this does the same as above, but point
	var tile = _bgmap.local_to_map(point)
	var tile_data = _bgmap.get_cell_tile_data(0, tile)
	if combat.get_current_combatant().movement_class == 0:
		return int(tile_data.get_custom_data("Cost"))
	else:
		return 1
	

func _draw():                                                        # currently doesnt do anything
	if _arrived == true and _player_turn == true:
		var _path_length = movement
		for i in range(_path.size()):
			var point = _path[i]
			if i > 0:
				_path_length -= get_tile_cost_at_point(point)



func _get_configuration_warning() -> String:                                # check grid for safety
	var warning := ""
	if not grid:
		warning = "Attach Resource Grid."
	return warning


func is_occupied(cell: Vector2) -> bool:                                  # return true if occupied
	return _units.has(cell)


func get_walkable_cells(unit: Unit) -> Array:              # returns array of cells for yellow move
	return _flood_fill(unit.cell, movement)


func _reinitialize() -> void:                                 # clears and refills dictionary units
	_units.clear()

	for child in _playergroup.get_children():            # adds unit to player group list currently
		var unit := child as Unit
		if not unit:
			continue
		_units[unit.cell] = unit
		
	


					# Returns array with all the coords of walkable cells based on the max distance
func _flood_fill(cell: Vector2, max_distance: int) -> Array:
	var array := []
	var stack := [cell]
	while not stack.size() == 0:
		var current = stack.pop_back()
		if not grid.is_within_bounds(current):
			continue
		if current in array:
			continue

		var difference: Vector2 = (current - cell).abs()
		var distance := int(difference.x + difference.y)
		if distance > max_distance:
			continue

		array.append(current)
		for direction in DIRECTIONS:
			var coordinates: Vector2 = current + direction
			if is_occupied(coordinates):
				continue
			if coordinates in array:
				continue
			if coordinates in stack:
				continue

			stack.append(coordinates)
	return array


				 # Updates the unit dict with the target pos and asks the active unit to walk to it
func _move_active_unit(new_cell: Vector2) -> void:
	if is_occupied(new_cell) or not new_cell in _walkable_cells:
		return
	_units.erase(_active_unit.cell)
	_units[new_cell] = _active_unit
	_deselect_active_unit()
	_active_unit.walk_along(_unit_path.current_path)
	await _active_unit.walk_finished
	controlling_node.position = Vector2i(_active_unit.position - Vector2(16, 16))
	combat.get_current_combatant().position = Vector2i((_active_unit.position - Vector2(16, 16)) / 32)
	_clear_active_unit()


func _select_unit(cell: Vector2) -> void:               # Selects unit in cell if there's one there
	
	# check if the active unit is the same as the unit clicked, if it is, turn on canvas,
	# if its not, display basic stats like health, mana, speed, skills, etc etc (can be done after)
	
	if not _units.has(cell):
		return
	if (_player_turn == true):
		if (Vector2i(cell) == _combatant.position):
			_turn_on_canvas(cell)
			_active_unit = _units[cell]                                                  # Sets active unit
			_active_unit.is_selected = true

func _deselect_active_unit() -> void:       # Deselects active unit, clearing cell overlay and path
	if (_player_turn == true):
		_active_unit.is_selected = false
		_move_pressed = false
		_unit_overlay.clear()
		_unit_path.stop()


func _clear_active_unit() -> void:         # Clears ref to active unit and corresponding walk cells
	_active_unit = null
	_walkable_cells.clear()



func _on_cursor_accept_pressed(cell: Vector2) -> void:        # accept unit press, make active unit
	if not _active_unit:
		_select_unit(cell)
	elif _active_unit.is_selected:
		_move_active_unit(cell)
		movement -= _unit_path.get_calculated_size() - 1
								   # reduce movement range by point path size after confirming move

func _on_cursor_moved(new_cell: Vector2) -> void:               # check active unit values and draw
	if _active_unit and _active_unit.is_selected and _move_pressed == true:
		_unit_path.draw(_active_unit.cell, new_cell)


func _turn_on_canvas(cell: Vector2):
	_action_panel.visible = true
	_action_panel.set_position(cell * 32)

func _turn_off_canvas():
	_action_panel.visible = false


func _on_move_pressed():                              # is move range is greater than 0, show paths
	if movement > 0:
		_move_pressed = true
		_walkable_cells = get_walkable_cells(_active_unit)
		_unit_overlay.draw(_walkable_cells)
		_unit_path.initialize(_walkable_cells)
		_turn_off_canvas()
	
	else:
		_turn_on_canvas(_active_unit.cell) # if move range is less than or equal to, keep canvas on


func _on_cancel_pressed():                           # if cancel is pressed, perform like ui_cancel
	_deselect_active_unit()
	_clear_active_unit()
	_turn_off_canvas()
