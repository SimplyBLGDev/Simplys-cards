extends Pile

class_name ShowPile

export var showCardsAmount = 3
export var showCardsSeparation = Vector2(5, 5)

func sort_pieces():
	$Tween.stop_all()
	var s = maxCardSeparation
	
	if len(pieces) > showCardsAmount:
		var l = len(pieces) - showCardsAmount
		if abs(size.x/l) < abs(maxCardSeparation.x):
			s.x = size.x/l
		if abs(size.y/l) < abs(maxCardSeparation.y):
			s.y = size.y/l
	
	for i in len(pieces):
		var p
		if i < len(pieces) - showCardsAmount:
			p = s * i
		else:
			p = showCardsSeparation * (showCardsAmount - (len(pieces) - i)) + s * (len(pieces) - showCardsAmount)
		
		$Tween.interpolate_property(pieces[i], "position", pieces[i].position,
			p, cardPosAnimationLength, Tween.TRANS_BACK, Tween.EASE_OUT)
	$Tween.start()
