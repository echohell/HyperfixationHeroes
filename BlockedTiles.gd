extends TileMap

class_name BlockedTiles

var bgtilearray = []
var bgtiles

func confirmtileblock():
	bgtiles = get_parent().get_node("Map")
	for layers in (bgtiles.get_layers_count()):
		for values in (bgtiles.get_used_cells(layers)):
			bgtilearray.append(values + Vector2i(1,0))
	
	draw(bgtilearray)

func draw(cells: Array) -> void:                                    # just draws non walkable tiles
	clear()                                                             # for flood fill
	for cell in cells:
		set_cell(0, cell, 0, Vector2i(0,0))

