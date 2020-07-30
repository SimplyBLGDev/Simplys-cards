extends Game

signal dealNextCard

enum Mode { OneSuit, TwoSuits, FourSuits}

# SETTINGS
export var mode = Mode.OneSuit
# SETTINGS

var deck
var standardPiles = []
var suitPiles = []

var time = 0
var moves = 0
var undos = 0
var results = {
	"Completion Time":"0",
	"Moves":"0",
	"Undos":"0"
}

func _process(delta):
	time += delta

func setupGame():
	match mode:
		Mode.OneSuit:
			$Deck/DeckGenerator.suits += [3, 3, 3, 3, 3, 3, 3, 3]
		Mode.TwoSuits:
			$Deck/DeckGenerator.suits += [3, 3, 3, 3, 1, 1, 1, 1]
		Mode.FourSuits:
			$Deck/DeckGenerator.suits += [1, 1, 2, 2, 3, 3, 4, 4]
	
	$Deck/DeckGenerator.init("DeckCards")
	deck = $Deck
	
	for i in range(1, 11):
		standardPiles.append(get_node("SPile" + str(i)))
	
	for i in range(1, 9):
		suitPiles.append(get_node("SuitPile" + str(i)))
	
	deck.connect("_pile_clicked", self, "_on_deck_click")
	
	for p in standardPiles:
		p.connect("_piece_taken", self, "_on_sPile_card_taken")
	
	deal()

func _is_piece_grabbable(piece):
	var pile = piece.get_pile()
	
	if pile in standardPiles:
		if piece.faceUp == false:
			return false
		var cardIx = pile.pieces.find(piece)
		var lastValue = piece.value
		for i in range(cardIx+1, len(pile.pieces)):
			if pile.pieces[i].suit != piece.suit or pile.pieces[i].value != lastValue-1:
				return false
			lastValue = pile.pieces[i].value
		return true
	
	return false

func _are_pieces_placeable(pieces, pile):
	if pile in standardPiles:
		return pile.isEmpty() or pile.top().value == pieces[0].value + 1
	elif pile in suitPiles:
		return pieces[0].value == 12 and len(pieces) == 13
	
	return false

func _piece_dependencies(piece):
	var pile = piece.get_pile()
	
	# The only grabbable pieces are in standardPiles but anyways
	if pile in standardPiles:
		var ix = pile.pieces.find(piece)
		var ret = []
		for i in range(ix, len(pile.pieces)):
			ret.append(pile.pieces[i])
		
		return ret
	
	return [piece]

func _on_deck_click(pile):
	if deck in blockedPiles:
		return
	blockedPiles.append(deck)
	blockedPiles += standardPiles
	$AnimationPlayer.play("SpiderSolitaireDealHand")
	
	for sPile in standardPiles:
		yield(self, "dealNextCard")
		if deck.isEmpty():
			break
		deck.top().flip()
		sPile.add_piece(deck.top())
	
	blockedPiles = []

func _on_piece_placed(pile):
	moves += 1
	var win = true
	
	for pile in suitPiles:
		if len(pile.pieces) != 13:
			win = false
			break
	
	if win:
		results["Completion Time"] = Utils.format_time(time)
		results["Moves"] = moves
		results["Undos"] = undos
		return win(1, results)

func dealNextCard():
	emit_signal("dealNextCard")

func _on_sPile_card_taken(pile):
	if !pile.isEmpty():
		if !pile.top().faceUp:
			pile.top().flip()

func deal():
	gatherPiecesTo("DeckCards", deck)
	yield(self, "GatherFinished")
	
	for card in deck.pieces:
		card.faceUp = false
		card.update_sprite()
	
	deck.shuffle()
	blockedPiles += standardPiles
	blockedPiles.append(deck)
	
	$AnimationPlayer.play("SpiderSolitaireDeal")
	yield($AnimationPlayer, "animation_finished")
	
	blockedPiles = []

func deal_next(pileIx):
	standardPiles[pileIx].add_piece(deck.top())

func flip_pile_top_card(pileIx):
	standardPiles[pileIx].top().flip()
