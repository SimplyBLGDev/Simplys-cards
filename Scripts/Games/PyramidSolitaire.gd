extends Game

# SETTINGS
export var roundLimit = 5
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
	
	if pile in pyramidPiles:
		return piece == pile.top() and is_pyramid_pile_top_accesible(pile)
	if pile == deckFlip:
		return piece == pile.top()
	
	return false

func _are_pieces_placeable(pieces, pile):
	if pile in pyramidPiles and !pile.isEmpty():
		return pieces[0].value + pile.top().value == 11 and is_pyramid_pile_top_accesible(pile)
	elif pile == result:
		return pieces[0].value == 12
	elif pieces[0].get_pile() == deck:
		return pile == deckFlip
	return false

func _piece_dependencies(piece):
	return [piece]

func is_pyramid_pile_top_accesible(pile):
	if pyramidPiles.find(pile) == 6:
		return true
	var prevPile = pyramidPiles[pyramidPiles.find(pile) + 1]
	return len(pile.pieces) > len(prevPile.pieces)

func on_pyramid_pile_click(pile):
	if !pile.isEmpty():
		if pile.top().value == 12 and is_pyramid_pile_top_accesible(pile):
			result.add_piece(pile.top())

func on_deck_click(pile):
	if len(deck.pieces) == 0:
		if !deckFlip.isEmpty() and rounds < roundLimit:
			blockedPiles.append(deck)
			blockedPiles.append(deckFlip)
			
			var flipCards = len(deckFlip.pieces) - 1 # Leave one deckflip
			
			deckFlip.disableSorting = true
			for cCard in flipCards:
				deckFlip.top().flip()
				deck.add_piece(deckFlip.top())
			
			deckFlip.disableSorting = false
			blockedPiles.erase(deck)
			blockedPiles.erase(deckFlip)
			deck.top().flip() # re-reveal top card
			rounds += 1
	else:
		deckFlip.add_piece(deck.top())
		if len(deck.pieces) > 0:
			deck.top().flip()

func _on_piece_placed(pile):
	if pile in pyramidPiles:
		result.add_pieces([pile.top(), pile.pieces[-2]])
	
	if deckFlip.isEmpty() and !deck.isEmpty():
		deckFlip.add_piece(deck.top())
		if !deck.isEmpty():
			deck.top().flip()
	
	var win = true
	
	for pile in pyramidPiles:
		if len(pile.pieces) != 0:
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
	rounds = 1
	moves = 0
	undos = 0

func dealNext(ix):
	if ix == -1:
		deckFlip.add_piece(deck.top())
		deckFlip.top().flip()
	else:
		pyramidPiles[ix].add_piece(deck.top())
		pyramidPiles[ix].top().flip()
