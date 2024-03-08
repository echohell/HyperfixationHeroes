extends TileMap

class_name BlockedTiles

func draw(cells: Array) -> void:                                        # just draws walkable tiles
	clear()                                                             # for flood fill
	for cell in cells:
		set_cell(0, cell, 0, Vector2i(0,0))
