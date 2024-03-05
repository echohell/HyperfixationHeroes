extends TileMap

class_name Foreground_Map

var _fullmapnumbers = []                                         # array of cells based on cell ids
var _combatzonenumbers = []                                     # array of cells inside combat zone
@onready var Map = $"."

func _ready():
	for layers in (Map.get_layers_count()):                           # iterate over all the layers
		for values in (Map.get_used_cells(layers)):            # for all the values in these layers
			_fullmapnumbers.append(values + Vector2i(1,0))                 # append it to the array
			
	_filtercombatnumbers()                                  # can just call this when combat starts

func _filtercombatnumbers():
	for values in _fullmapnumbers:                                  # iterate over all layer values
		if (values.x > 0) or (values.x <= 40) and (values.y > 3) or (values.y <= 17):  # check vals
			_combatzonenumbers.append(values)                       # append it to the combat array

func _clearcombatzone():
	_combatzonenumbers.clear()                                            # clear the combat values

func getcombatnumbers():
	return _combatzonenumbers                                               # get the combat values
