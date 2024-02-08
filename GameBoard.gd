extends Node2D

class_name GameBoard                                       # THIS IS FOR GAME LOGIC, DONT TIE IT UP

const DIRECTIONS = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

@export var grid: Resource

var _units := {}                                                  # Map coords cell to ref the unit
var _active_unit: Unit
var _walkable_cells := []

@onready var _unit_overlay: UnitOverlay = $UnitOverlay
@onready var _unit_path: UnitPath = $UnitPath


func _ready() -> void:
	_reinitialize()


func _unhandled_input(event: InputEvent) -> void:
	if _active_unit and event.is_action_pressed("ui_cancel"):         # checks for escape to cancel
		_deselect_active_unit()
		_clear_active_unit()


func _get_configuration_warning() -> String:                                # check grid for safety
	var warning := ""
	if not grid:
		warning = "You need a Grid resource for this node to work."
	return warning


func is_occupied(cell: Vector2) -> bool:                                  # return true is occupied
	return _units.has(cell)


func get_walkable_cells(unit: Unit) -> Array:              # returns array of cells for yellow move
	return _flood_fill(unit.cell, unit.move_range)


func _reinitialize() -> void:                                 # clears and refills dictionary units
	_units.clear()

	for child in get_children():
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
		_move_active_unit(cell)


func _on_cursor_moved(new_cell: Vector2) -> void:
	if _active_unit and _active_unit.is_selected:
		_unit_path.draw(_active_unit.cell, new_cell)
