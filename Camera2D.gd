extends Camera2D

	 # not currently being used, is just a camera movement script that zooms based on tile map size

@export var _tilemap : TileMap
var _velocity: Vector2 = Vector2.ZERO                        # velocity, accel, max speed, fall off
var _acceleration = 100                                                   # for movements of camera
var _max_speed = 20
var _falloff = 35

func _ready():
	set_anchor_mode(Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT)                # anchor camera to top left
	var zoom_vector = get_camera_zoom_from_tilemap()                       # get camera zoom vector
	set_zoom(zoom_vector)                                           # set zoom based on zoom vector
	apply_camera_limits()                                                # apply camera limitations


func _process(_delta):
	var input_vector = Input.get_vector("camera_left","camera_right","camera_up","camera_down")
	calculate_velocity(input_vector)                            # calc velocity based on directions
	update_global_position()                                    # updates global position of camera

func apply_camera_limits():
	var tilemap_info = get_tilemap_info()                      # return array of size and tile size
	var level_size = Vector2i(tilemap_info.tile_size * tilemap_info.size)  # var is tilesize * size
	
	set_limit(SIDE_LEFT, 0)                                         # set the limits of each corner
	set_limit(SIDE_TOP, 0)
	set_limit(SIDE_RIGHT, level_size.x)
	set_limit(SIDE_BOTTOM, level_size.y)

func update_global_position():
	var delta = get_process_delta_time()                                       # get the delta time
	
	global_position += lerp(_velocity, Vector2.ZERO, pow(2, -32 * delta))    # lerp values by delta
	
	var zoomed_viewport_size = get_viewport_to_zoom_scale()                 # var for viewport zoom
	
	var left_limit = get_limit(SIDE_LEFT)                              # var get limit of 4 corners
	var right_limit = get_limit(SIDE_RIGHT) - zoomed_viewport_size.x
	var top_limit = get_limit(SIDE_TOP)
	var bottom_limit = get_limit(SIDE_BOTTOM) - zoomed_viewport_size.y
	
	global_position.x = clamp(global_position.x, left_limit, right_limit)# update and clamp globals
	global_position.y = clamp(global_position.y, top_limit, bottom_limit)

func get_viewport_to_zoom_scale():
	var zoom_vector = get_zoom()                                                 # get current zoom
	var zoomed_viewport_size = Vector2i(                            # set Vector2i of viewport size
		get_viewport().size[0] / zoom_vector.x,
		get_viewport().size[1] / zoom_vector.y,
	)
	
	return zoomed_viewport_size                                            # return zoomed viewport

func calculate_velocity(direction: Vector2):
	var delta = get_process_delta_time()                                           # get delta time
	_velocity += direction * _acceleration * delta                                # modify velocity
	
	if direction.x == 0:
		_velocity.x = lerp(0.0, _velocity.x, pow(2, -_falloff * delta))              # lerp x and y
	if direction.y == 0:
		_velocity.y = lerp(0.0, _velocity.y, pow(2, -_falloff * delta))
	
	_velocity.x = clamp(_velocity.x, -_max_speed, _max_speed)                    # clamp after lerp
	_velocity.y = clamp(_velocity.y, -_max_speed, _max_speed)

func get_camera_zoom_from_tilemap():                                   # gets camera clamped values
	var viewport_size = get_viewport().size
	var tilemap_info = get_tilemap_info()
	var level_size = Vector2i(tilemap_info.tile_size * tilemap_info.size)
	var viewport_aspect = float(viewport_size[0]) / viewport_size[1]
	var level_aspect = float(level_size.x) / level_size.y
	var new_zoom = 1.0
	
	if level_aspect > viewport_aspect:
		new_zoom = float(viewport_size[1]) / level_size.y
	else:
		new_zoom = float(viewport_size[0]) / level_size.x
	
	print (new_zoom)
	new_zoom = clamp(new_zoom, 0.0, 1.5)                               # change this to change zoom
	
	return Vector2(new_zoom, new_zoom)
	

func get_tilemap_info():                                        # returns array of size / tile size
	var tile_size = _tilemap.get_tileset().tile_size
	var tilemap_rect = _tilemap.get_used_rect()
	var tilemap_size = Vector2i(
		tilemap_rect.end.x - tilemap_rect.position.x,
		tilemap_rect.end.y - tilemap_rect.position.y
	)
	return {"size": tilemap_size, "tile_size": tile_size}
