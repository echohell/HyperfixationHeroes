extends Node2D

class_name AstarGrid

@export var player: Player;
@onready var tileMap = $"../Background Tiles"

var astarGrid: AStarGrid2D
var current_path: Array[Vector2i]
var current_point_path: PackedVector2Array

func _ready():
	astarGrid = AStarGrid2D.new()
	astarGrid.region = tileMap.get_used_rect()
	astarGrid.cell_size = Vector2(16,16)
	astarGrid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	astarGrid.update()
	
	print(str(tileMap.get_used_rect()))
	
	for x in tileMap.get_used_rect().size.x:
		for y in tileMap.get_used_rect().size.y:
			var tilePos = Vector2i(x + tileMap.get_used_rect().position.x, y + tileMap.get_used_rect().position.y)
			
			var tileData = tileMap.get_cell_tile_data(0, tilePos + Vector2i(2,0))
			
			if tileData == null or tileData.get_custom_data("walkable") == false:
				astarGrid.set_point_solid(tilePos)

func idPathing():
	var idPath = astarGrid.get_id_path(
		tileMap.local_to_map(player.global_position), 
		tileMap.local_to_map(get_global_mouse_position()))
	
	if idPath.is_empty() == false:
		current_path = idPath
		current_point_path = astarGrid.get_point_path(
			tileMap.local_to_map(player.global_position), 
			tileMap.local_to_map(get_global_mouse_position()))
			
		for i in current_point_path.size():
			current_point_path[i] = current_point_path[i] + Vector2(48,16)

func getPath():
	return current_path

func getTarget():
	if tileMap.map_to_local(current_path.front()) != null:
		return tileMap.map_to_local(current_path.front())

func popFrontPath():
	current_path.pop_front()
