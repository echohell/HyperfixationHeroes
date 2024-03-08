extends TextureRect

@export var _animplayer: AnimationPlayer

func set_side(side: int):                                      # this is for UI of turn queue icons
	match side:                                                  # sets side colors based on 0 or 1
		0:
			$Border.modulate = Color.LIGHT_SKY_BLUE                        # players get light blue
		1:
			$Border.modulate = Color.CRIMSON                              # enemies get crimson red

func turn_taken(_taken: bool):
	pass #_animplayer.play("reset")        #fadeout         # fade out animation when turn is taken   
													  # this breaks TQIcon for some fucking reason.

func reset():
	_animplayer.play("reset")
