@tool
extends Node2D

class_name astar

const Directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]    # cardinal directions

var _grid: Resource
var _astar := AStarGrid2D.new()                                                # initialize on call
var _solid_points_array := []                  # array for appending points needed to be made solid

	  # initialize all base functions and info needed for astar performance (can also be in _ready)
func _init(grid: Grid, walkable_cells: Array, tile_map: TileMap) -> void:
	_grid = grid
	_astar.region = Rect2i(0, 3, _grid.size.x, _grid.size.y)                  # this is combat zone
	_astar.cell_size = _grid.cell_size                                    # is set in grid resource
	_astar.default_compute_heuristic = AStarGrid2D.HEURISTIC_MANHATTAN   # manhattan is for 4 point
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER   # can turn this on if we want diagonal
	_astar.update()                                                # updates internal state of grid
	
	for y in _grid.size.y:                                         # iterate through all x y coords
		if (y >= 3 and y < _grid.size.y):
			for x in _grid.size.x:
				if not walkable_cells.has(Vector2(x,y)):           # look for anything outside grid
					_astar.set_point_solid(Vector2(x,y))       # set to solid so its not accessible
					_solid_points_array.append(Vector2(x,y)) # append that to the solid point array

	var array = tile_map.get_used_cells_by_id(-1, 5)                   # get used cells by layer id
	for arr in array:
		if (arr.y >= 3 and arr.y < _grid.size.y):
			var tile_data = tile_map.get_cell_tile_data(0, arr)                     # get tile data
			if tile_data == null or tile_data.get_custom_data("not_walkable") == true:  # check val
				_astar.set_point_solid(arr)             # if null or bool not walking, set to solid
				_solid_points_array.append(arr)          # append the cell to the solid point array

func calculate_point_path(start: Vector2, end: Vector2) -> PackedVector2Array:
	var _endy = end.y                                           # set a var we can use to check min
	if (_endy < 3 or _endy >= 17):
		return _astar.get_id_path(start, start)           # if end y is less than 3, return no path
	else:
		var _end = clamp(end.y, 3, _grid.size.y)        # clamp y to ensure that it stays in bounds
		end = Vector2(end.x, _end)
		return _astar.get_id_path(start, end)                 # return PACKED vector2 array of path

func combat_map_update(array_of_tiles: Array):                          # pass in an array of tiles
	for array_data in array_of_tiles:
		_astar.set_point_solid(array_data)                               # set those tiles as solid
		_solid_points_array.append(array_data)                   # append data to solid point array
