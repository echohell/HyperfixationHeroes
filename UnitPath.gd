extends TileMap

class_name UnitPath

@export var grid: Resource

var _astar: astar
var current_path := PackedVector2Array()
@onready var tile_map := $"../../Map"                            # hard map path to get solid tiles

func initialize(walkable_cells: Array) -> void:                     # create new pathfinder to find
	_astar = astar.new(grid, walkable_cells, tile_map)              # path between 2 walkable cells
	_astar.combat_map_update(tile_map.getcombatnumbers())          # pass in tiles to be made solid

func draw(cell_start: Vector2, cell_end: Vector2) -> void:           # find and draws the start and
	clear()                                                                             # end cells
	current_path = _astar.calculate_point_path(cell_start, cell_end) 
	set_cells_terrain_connect(0, current_path, 0, 0)               # terrain set connect for arrows

func stop() -> void:                                                # stops drawing path and clears
	_astar = null                                                  # astar pathfinder when finished
	clear()
