@tool
extends Resource

class_name Grid

@export var size := Vector2(20,20)                                     # grid size in rows and cols
@export var cell_size := Vector2(32,32)                                       # cell size in pixels

var _half_cell_size = cell_size / 2                                             # half of cell size

func calculate_map_pos(grid_pos: Vector2) -> Vector2:            # returns position of cell centers
	return grid_pos * cell_size + _half_cell_size


func calculate_grid_coords(map_position: Vector2) -> Vector2: # snaps editor images to closest cell
	return (map_position / cell_size).floor()


func is_within_bounds(cell_coords: Vector2) -> bool:           # returns true or false if in bounds
	var out := cell_coords.x >= 0 and cell_coords.x < size.x
	return out and cell_coords.y >= 0 and cell_coords.y < size.y


func grid_clamp(grid_pos: Vector2) -> Vector2:               # clamps grid pos to be in grid bounds
	var out := grid_pos
	out.x = clamp(out.x, 0, size.x - 1.0)
	out.y = clamp(out.y, 0, size.y - 1.0)
	return out
