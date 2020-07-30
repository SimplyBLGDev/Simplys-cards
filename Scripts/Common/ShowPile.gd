extends Pile

class_name ShowPile

export var showCardsModeAmount = 3

func sort_pieces():
	$Tween.stop_all()
	var separation = maxCardSeparation
	
	for i in len(pieces):
		var p
		if i < len(pieces) - showCardsModeAmount:
			p = Vector2(0, 0)
		else:
			p = separation * (showCardsModeAmount - (len(pieces) - i))
		
		$Tween.interpolate_property(pieces[i], "position", pieces[i].position,
			p, cardPosAnimationLength, Tween.TRANS_BACK, Tween.EASE_OUT)
	$Tween.start()
