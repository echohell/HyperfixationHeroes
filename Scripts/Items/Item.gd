extends Node

class_name Item

@export var ID : int
@export var itemName : String
@export var Description : String
@export var value : int
@export var icon : Texture2D
@export var dropChance : int

enum itemType {Consumable, Equip, Special, Quest, Pet}
const itemToStr := ["Consumable", "Equip", "Special", "Quest", "Pet"]

enum equipType {None, Head, Chest, Legs, Boots, Neck, MainHand, OffHand, Gloves, Ring1, Ring2, Trinket, Shoulder, Cape, Belt}
const equipToStr := ["None", "Head", "Chest", "Legs", "Boots", "Neck", "MainHand", "OffHand", "Gloves", "Ring1", "Ring2", "Trinket", "Shoulder", "Cape", "Belt"]
