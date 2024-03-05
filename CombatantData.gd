extends Resource

class_name CombatantDefinition                                               # combatant definition

@export var name = ""

@export_group("Classes")
@export_enum("Melee", "Ranged", "Magic") var _class_t = 0
@export_enum("Ground", "Flying", "Mounted") var _class_m = 0

@export_group("Stats")
@export_range(1, 2, 1, "or_greater") var max_hp = 1
@export_range(1, 3, 1, "or_greater") var movement = 2
@export_range(1, 2, 1, "or_greater") var initiative = 1

@export_group("Visuals")
@export var icon: Texture2D
@export var map_sprite: Texture2D
@export var unit: PackedScene

@export_group("Skills")
@export var skills: Array[String]
