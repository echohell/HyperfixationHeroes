extends Node

class_name Skill

@export var id : int
@export var skillName : String = ""
@export var Description : String = ""
@export var Damage : int
@export var AtkRange : int
@export var Reticle : Texture2D
@export var Icon : Texture2D
enum skillType{Magic, Ability, Passive, Reactive}
enum elementType{Neutral, Fire, Water, Earth, Wind, Holy, Dark, Arcane}
enum effectType{None, Immobilize, Stun, Silence, Cripple, Burn, Poison, Bleed, Paralyze, Undead, statRes, HoT, Reraise, Shield, EleRes}
