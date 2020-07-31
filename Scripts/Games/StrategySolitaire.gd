extends Game

# SETTINGS

# SETTINGS

var deck
var suitPiles = []
var piles = []

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
	deck = $Deck
	$Deck/DeckGenerator.init("DeckCards")
	
	for i in range(1, 7):
		piles.append(get_node("Pile" + str(i)))
	
	for i in range(1, 5):
		suitPiles.append(get_node("SuitPile" + str(i)))
	
	deck.connect("_piece_taken", self, "deck_card_taken")
	
	deal()

func _is_piece_grabbable(piece):
	var pile = piece.get_pile()
	
	if pile == deck:
		return piece == deck.top()
	elif pile in piles:
		return piece == piece.get_pile().top() and deck.isEmpty()
	elif pile in suitPiles:
		return piece.value == 0
	
	return false

func _are_pieces_placeable(pieces, pile):
	if pile in suitPiles:
		if !deck.isEmpty():
			return pieces[0].value == 0
		return pile.isEmpty() or (pieces[0].suit == pile.top().suit
			and pieces[0].value == pile.top().value + 1)
	elif pile in piles:
		return pieces[0].get_pile() == deck # Card comes from deck
	
	return false

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

func deck_card_taken(pile):
	if !deck.isEmpty():
		deck.top().flip()

func deal():
	blockedPiles += piles
	blockedPiles.append(deck)
	gatherPiecesTo("DeckCards", deck)
	yield(self, "GatherFinished")
	
	for card in deck.pieces:
		card.faceUp = false
		card.update_sprite()
	
	blockedPiles = []
	deck.shuffle()
	deck.top().flip()
