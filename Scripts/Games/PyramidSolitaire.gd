extends Game

# SETTINGS
export var roundLimit = 3
# SETTINGS

var deck
var deckFlip
var result
var pyramidPiles = []

var time = 0
var moves = 0
var undos = 0
var rounds = 1
var results = {
	"Completion Time":"",
	"Rounds":"",
	"Moves":"",
	"Undos":""
}

func _process(delta):
	time += delta

func setupGame():
	$Deck/DeckGenerator.init("DeckCards")
	deck = $Deck
	deckFlip = $DeckFlip
	result = $ResultPile
	
	for i in range(1, 8):
		pyramidPiles.append(get_node("Pile" + str(i)))
		pyramidPiles[-1].connect("_pile_clicked", self, "on_pyramid_pile_click")
	
	deck.connect("_pile_clicked", self, "on_deck_click")
	deckFlip.connect("_pile_clicked", self, "on_pyramid_pile_click")
	
	deal()

func _is_piece_grabbable(piece):
	var pile = piece.get_pile()
	if pile in blockedPiles:
		return false
	
	if pile in pyramidPiles or pile == deckFlip:
		return piece == pile.top()
	
	return false

func _are_pieces_placeable(pieces, pile):
	if pile in blockedPiles:
		return false
	
	if pile in pyramidPiles and !pile.isEmpty():
		return pieces[0].value + pile.top().value == 11
	elif pile == result:
		return pieces[0].value == 12
	elif pieces[0].get_pile() == deck:
		return pile == deckFlip
	return false

func _piece_dependencies(piece):
	return [piece]

func on_pyramid_pile_click(pile):
	if !pile.isEmpty():
		if pile.top().value == 12:
			result.add_piece(pile.top())
	
	if deckFlip.isEmpty() and !deck.isEmpty():
		deckFlip.add_piece(deck.top())
		if !deck.isEmpty():
			deck.top().flip()

func on_deck_click(pile):
	if len(deck.cards) == 0:
		if !deckFlip.isEmpty() and rounds < roundLimit:
			for card in deckFlip.pieces:
				deckFlip.top().flip()
				deck.add_piece(deckFlip.top())
				rounds += 1
	else:
		deckFlip.add_piece(deck.top())
		if len(deck.cards) > 0:
			deck.top().flip()

func _on_piece_placed(pile):
	if pile in blockedPiles:
		return
	
	if pile in pyramidPiles:
		result.add_pieces([pile.top(), pile.pieces[-2]])
	
	var win = true
	
	if len(result.pieces) != 52:
		win = false
	
	if win:
		results["Completion Time"] = Utils.format_time(time)
		results["Rounds"] = rounds
		results["Moves"] = moves
		results["Undos"] = undos
		return win(1, results)

func deal():
	blockedPiles.append(deck)
	blockedPiles.append(result)
	blockedPiles += pyramidPiles
	gatherPiecesTo("DeckCards", deck)
	yield(self, "GatherFinished")
	
	for card in deck.pieces:
		card.faceUp = false
		card.update_sprite()
	
	deck.shuffle()
	
	$AnimationPlayer.play("PyramidSolitaireDeal", -1, dealSpeed)
	yield($AnimationPlayer, "animation_finished")
	
	deck.top().flip()
	
	blockedPiles = []
	time = 0
	rounds = 0
	moves = 0
	undos = 0

func dealNext(ix):
	if ix == -1:
		deckFlip.add_piece(deck.top())
		deckFlip.top().flip()
	else:
		pyramidPiles[ix].add_piece(deck.top())
		pyramidPiles[ix].top().flip()
