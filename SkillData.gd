extends Resource

class_name skillDefinitions                                  # definition later called by skillData

# if we need to add more things here like a reticle, etc. etc. it will update all skills

@export var name: String                                                                     # name
@export var skill_base: String   
@export var skill_desc: String  #Cam Edit                                                 # the base calc
@export var min_range: int                                                          # min max range
@export var max_range: int
@export var min_damage: int                                                        # min max damage
@export var max_damage: int
@export var min_hitchance: int                                                 # min max hit chance
@export var max_hitchance: int
@export var icon: Texture2D                                                            # skill icon
