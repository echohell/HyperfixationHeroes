extends Node2D

class_name GameBoard                                       # THIS IS FOR GAME LOGIC, DONT TIE IT UP
														# Alot of these are not going to be working

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

@export var grid: Resource
@export var combat: Combat
@export var controlling_node: Node2D
															# global vars being used for game logic
var _selected_skill: String
var _next_position
var _position_id = 0
var _move_speed = 20
var _prev_pos : Vector2i
var _path : PackedVector2Array
var _attack_target_pos
var _blocked_target_pos
var _arrived = true
var _skill_selected = false
var _player_turn = true
var _units := {}                                                  # Map coords cell to ref the unit
var _active_unit: Unit
var _walkable_cells := []
var _occupied_spaces = []
var _blocking_spaces = [[],[],[]]                                #ground, then flying, then mounted
var movement = 3:
	set = set_movement,
	get = get_movement

@onready var _playergroup: Node2D = $PlayerGroup
@onready var _enemygroup: Node2D = $EnemyGroup
@onready var _unit_overlay: UnitOverlay = $UnitOverlay
@onready var _unit_path: UnitPath = $UnitPath
@onready var _action_panel: Panel = $"../Camera2D/CombatHUD/ActionButtons/HolderPanel"


# signal update_information(text: String)         # not used yet
# signal movement_changed(movement: int)          # not used yet
signal finished_move
# signal target_selection_start()                 # not used yet
# signal target_selection_finish()                # not used yet


func _unhandled_input(event: InputEvent) -> void:                    # this is a test function for
	# if event.is_action_pressed("Damage_test"):                       # taking damage
		# _playergroup.get_node("Fourth").health -= 1.3
		# update_information.emit("[center][color=white]{0} player has taken: \n [color=red]13 damage.[/color] \n\n".format(["Fourth"]))
		
	if _active_unit and event.is_action_pressed("ui_cancel"):         # checks for escape to cancel
		_deselect_active_unit()
		_clear_active_unit()

#finish this






func get_combatant_at_pos(target_position: Vector2i):           # func gets combatant at given cell
	for comb in combat.combatants:
		if comb.position == target_position and comb.alive:
			return combat
		return null

func _ready() -> void:
		_reinitialize()


#finish this

func _on_combat_processing_combatant_added(combatant):
	pass



func _on_combat_processing_combatant_down(combatant):
	pass



func _on_combat_processing_turn_advance(combatant: Dictionary):
	pass


func update_point_weight():
	pass

func get_distance(point1: Vector2i, point2: Vector2i):      # get absolute integer between 2 values
	return absi(point1.x - point2.x) + absi(point1.y - point2.y)


func process(_delta):
	pass

#finish this




func set_movement(value: int):
	movement = value
	# movement_changed.emit(value)           #not emitting anything yet


func get_movement():
	return movement

func ai_process(target_position: Vector2i):
	pass

#finish this

func ai_move(target_position: Vector2i):
	pass


#finish this

func find_path(tile_pos: Vector2i):
	pass


#finish this

func move_player():
	pass


func move_on_path(current_pos):
	pass


func set_selected_skill(skill: String):
	_selected_skill = skill


func begin_target_selection():
	_skill_selected = true
	# target_selection_start.emit()          # not used yet


func target_selected(target: Dictionary):
	_skill_selected = false
	# target_selection_finish.emit()          # not used yet
	pass


func get_tile_costs(tile):
	pass


func get_tile_cost_at_point(point):
	pass





func _get_configuration_warning() -> String:                                # check grid for safety
	var warning := ""
	if not grid:
		warning = "Attach Resource Grid."
	return warning


func is_occupied(cell: Vector2) -> bool:                                  # return true if occupied
	return _units.has(cell)


func get_walkable_cells(unit: Unit) -> Array:              # returns array of cells for yellow move
	return _flood_fill(unit.cell, unit.move_range)


func _reinitialize() -> void:                                 # clears and refills dictionary units
	_units.clear()

	for child in _playergroup.get_children():                      # adds unit to player group list
		var unit := child as Unit
		if not unit:
			continue
		_units[unit.cell] = unit
	
	for child in _enemygroup.get_children():                        # adds unit to enemy group list
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
	_clear_active_unit()


func _select_unit(cell: Vector2) -> void:               # Selects unit in cell if there's one there
	if not _units.has(cell):
		return

	_turn_on_canvas(cell)
	_active_unit = _units[cell]           # Sets active unit and draws its walk cells and move path
	_active_unit.is_selected = true
	_walkable_cells = get_walkable_cells(_active_unit)
	_unit_overlay.draw(_walkable_cells)
	_unit_path.initialize(_walkable_cells)


func _deselect_active_unit() -> void:       # Deselects active unit, clearing cell overlay and path
	_active_unit.is_selected = false
	_unit_overlay.clear()
	_unit_path.stop()


func _clear_active_unit() -> void:         # Clears ref to active unit and corresponding walk cells
	_active_unit = null
	_walkable_cells.clear()


func _on_cursor_accept_pressed(cell: Vector2) -> void:         # IMPORTANT: NODE CALLS, DONT FUCKEM
	if not _active_unit:
		_select_unit(cell)
	elif _active_unit.is_selected:
		_turn_off_canvas()
		_move_active_unit(cell)


func _on_cursor_moved(new_cell: Vector2) -> void:            # if unit is active and selected, draw
	if _active_unit and _active_unit.is_selected:
		_unit_path.draw(_active_unit.cell, new_cell)


func _turn_on_canvas(cell: Vector2):                           # turn on canvas and modify position
	_action_panel.visible = true
	_action_panel.set_position(cell * 32)

func _turn_off_canvas():                                                         # turns off canvas
	_action_panel.visible = false


func _on_move_pressed():                                                    # calls canvas off func
	_turn_off_canvas()

