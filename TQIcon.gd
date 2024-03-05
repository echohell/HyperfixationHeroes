extends TextureRect

@export var _animplayer: AnimationPlayer

func set_side(side: int):                                      # this is for UI of turn queue icons
	match side:                                                  # sets side colors based on 0 or 1
		0:
			$Border.modulate = Color.LIGHT_SKY_BLUE                        # players get light blue
		1:
			$Border.modulate = Color.CRIMSON                              # enemies get crimson red

func turn_taken(taken: bool):
	_animplayer.play("fadeout")                             # fade out animation when turn is taken

func reset():
	_animplayer.play("reset")
