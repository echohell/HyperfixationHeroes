@tool                                                                     # executes code in editor
class_name Unit
extends Path2D

signal walk_finished                                                      # emits when done walking

@onready var _sprite: Sprite2D = $PathFollow2D/Image
@onready var _anim_player: AnimationPlayer = $AnimationPlayer
@onready var _path_follow: PathFollow2D = $PathFollow2D

@export var grid: Resource
@export var move_speed := 250.0
@export var max_health: float = 10
@export var move_range: int = 6

@export var health: float = 10:
	set(value):
		health = clamp(value, 0, max_health)
		_play_animation()
		await ready

@export var skin: Texture:
	set(value):
		skin = value
		if not _sprite:
													# This means continue after this nodes _ready()
			await ready
		_sprite.texture = value
														 # Offset to apply to skin sprite in pixels

@export var skin_offset := Vector2.ZERO:
	set(value):
		skin_offset = value
		if not _sprite:
			await ready
		_sprite.position = value

													   # Coordinates of urrent cell cursor moved to
var cell := Vector2.ZERO:
	set(value):
											# changing the cell value, dont want the coords outside
		cell = grid.grid_clamp(value)                                  # the grid, so we clamp them

var is_selected := false:                              # toggles the selected animation on the unit
	set(value):
		is_selected = value
		if is_selected:
			_anim_player.play("selected")
		else:
			await get_tree().create_timer(randi() % 2).timeout
			_anim_player.play("idle")               # idle right now just resets the value of alpha

var _is_walking := false:
	set(value):
		_is_walking = value
		set_process(_is_walking)
		

func _ready() -> void:
	set_process(false)
	_path_follow.rotates = false
	randomize()

	cell = grid.calculate_grid_coords(position)
	position = grid.calculate_map_pos(cell)
	
	if not Engine.is_editor_hint():                            # create curve here so we can use it
		curve = Curve2D.new()
		
	await get_tree().create_timer(randi() % 3).timeout
	_anim_player.play("idle")


func _process(delta: float) -> void:
	_path_follow.progress += move_speed * delta

	if _path_follow.progress_ratio >= 1.0:
		_is_walking = false
		_path_follow.progress = 0.00001                         # DONT SET THIS TO 0.0 CAUSES ERROR
		position = grid.calculate_map_pos(cell)
		
		curve.clear_points()
		emit_signal("walk_finished")


func walk_along(path: PackedVector2Array) -> void:                   # start walking along the path
	if path.is_empty():
		return

	for point in path:
		curve.add_point(grid.calculate_map_pos(point) - position)
	cell = path[-1]
	_is_walking = true
	

func _play_animation():
	_anim_player.play("hurt")

func get_move_range():
	return move_range

func set_move_range(value: int):
	move_range = value
