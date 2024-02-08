extends Resource

class_name astar

const Directions = [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]

var _grid: Resource
var _astar := AStarGrid2D.new()


	# initialize all functions and information needed for astar performance (can also be in _ready)
func _init(grid: Grid, walkable_cells: Array) -> void:
	_grid = grid
	_astar.region = Rect2i(0, 0, _grid.size.x, _grid.size.y)                  # .size is deprecated
	_astar.cell_size = _grid.cell_size
	_astar.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER   # can turn this on if we want diagonal
	_astar.update()
	
	for y in _grid.size.y:                                         # iterate through all x y coords
		for x in _grid.size.x:
			if not walkable_cells.has(Vector2(x,y)):               # look for anything outside grid
				_astar.set_point_solid(Vector2(x,y))           # set to solid so its not accessible


func calculate_point_path(start: Vector2, end: Vector2) -> PackedVector2Array:
	return _astar.get_id_path(start, end)                     # return PACKED vector2 array of path
