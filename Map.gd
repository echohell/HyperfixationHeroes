extends TileMap

class_name Foreground_Map

var _combatzonenumbers = []                                     # array of cells inside combat zone
@onready var Map = $"."

func _ready():
	for layers in (Map.get_layers_count()):                           # iterate over all the layers
		for values in (Map.get_used_cells(layers)):            # for all the values in these layers
			_combatzonenumbers.append(values + Vector2i(1,0))              # append it to the array


func _clearcombatzone():
	_combatzonenumbers.clear()                                            # clear the combat values

func getcombatnumbers():
	return _combatzonenumbers                                               # get the combat values
