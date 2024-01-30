extends Node2D

@export var astar: AstarGrid

func _process(_delta):
	queue_redraw()

func _draw():
	if astar.current_point_path.is_empty():
		return
		
	draw_polyline(astar.current_point_path, Color.GREEN, 3)
