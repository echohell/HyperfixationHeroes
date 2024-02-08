extends Node

class_name Quest

@export var id : int
@export var questName : String
@export var Description : String
@export var isComplete : bool
@export var isFinished : bool
@export var objectives : Array

enum questType {Main, Side, Repeatable, Daily}
const questToStr := ["Main", "Side", "Repeatable", "Daily"]

enum goalType {Kill, Collect, GoTo, Interact}
const goalToStr := ["Kill", "Collect", "GoTo", "Interact"]

func _ready():
	start()
	assignQuest()

func start():
	var appendingVars = [true, false, true, false]    #example of how to insert an array of bool
	objectives.insert(0, appendingVars)

func checkObjective():
	for i in range(objectives.size()):
		if (objectives[i] != true):
			pass;
	print("Completed Checking Objectives")
	isComplete = true

func assignQuest():
	var qType = questType.Main
	var gType = goalType.GoTo #example of how to assign types and output the string const value of enums
	
	print("Quest name is: " + str(questName) + ", description: " + str(Description) + ".")
	print("Quest type is: " + str(questToStr[qType]) + ", goal type is: " + str(goalToStr[gType]) + ".")
