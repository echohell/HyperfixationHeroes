extends Node2D

class_name Player

@export var astar: AstarGrid
@export var inventory: Inventory = preload("res://Inventory/UI/PlayerInventory.tres")
@export var moveSpeed : float = 300
@export var path : Array[Vector2i]

func _ready():
	resize(1,1)                 #test for resizing individual child nodes

func _physics_process(_delta):
	var inputDir = Vector2(
	Input.get_action_strength("right") - Input.get_action_strength("left"), 
	Input.get_action_strength("down") - Input.get_action_strength("up")
	)
	
	# velocity = inputDir * moveSpeed
	# move_and_slide()
	
	if path.is_empty():
		return
	
	var target_pos = astar.getTarget()
	global_position = global_position.move_toward(target_pos, 1)
	
	if global_position == target_pos:
		astar.popFrontPath()
	

func resize(x,y):
	get_node("Sprite2D").scale *= Vector2(x, y)               #test to pull node from parent to child

func collect(item):
	inventory.insert(item)

func _input(event):
	if event.is_action_pressed("left click") == false:
		return
	
	astar.idPathing()
	path = astar.getPath()
