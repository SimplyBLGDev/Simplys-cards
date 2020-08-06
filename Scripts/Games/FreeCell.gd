extends Game

var sPiles = []
var suitPiles = []
var freeCells = []
onready var deck = $Deck

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
	$Deck/DeckGenerator.init("DeckCards")
	
	for i in range(1, 9):
		sPiles.append(get_node("SPile" + str(i)))
	
	for i in range(1, 5):
		suitPiles.append(get_node("SuitPile" + str(i)))
		freeCells.append(get_node("FreeCell" + str(i)))
	
	deal()

func deal():
	blockedPiles += sPiles
	blockedPiles += suitPiles
	blockedPiles += freeCells
	
	gatherPiecesTo("DeckCards", deck)
	yield(self, "GatherFinished")
	
	deck.shuffle()
	
	while not deck.isEmpty():
		for pile in sPiles:
			pile.add_piece(deck.top())
			$DealTimer.start(1.0 / dealSpeed) # Higher dealSpeeds should always be faster
			yield($DealTimer, "timeout")
			if deck.isEmpty():
				break
	
	blockedPiles = []

func _is_piece_grabbable(piece):
	var pile = piece.get_pile()
	
	if pile in suitPiles:
		return piece == pile.top()
	
	if pile in sPiles:
		if len(pile.pieces) < 1 or piece == pile.top():
			return true
		for i in range(pile.positionInPile(piece), len(pile.pieces) - 1):
			if pile.pieces[i+1].value == pile.pieces[i].value - 1:
				var alternateSuitColors = (
					(pile.pieces[i+1].suit in [1, 2] and pile.pieces[i].suit in [3, 4]) or
					(pile.pieces[i+1].suit in [3, 4] and pile.pieces[i].suit in [1, 2]))
				if not alternateSuitColors:
					return false
			else:
				return false
		
		return true
	
	return false

func _are_pieces_placeable(pieces, pile):
	if pile in freeCells:
		return pile.isEmpty() and len(pieces) == 1
	
	if pile in sPiles:
		if pile.isEmpty():
			return true
		var alternateSuitColors = (
			(pieces[0].suit in [1, 2] and pile.top().suit in [3, 4]) or
			(pieces[0].suit in [3, 4] and pile.top().suit in [1, 2]))
		return alternateSuitColors and pile.top().value == pieces[0].value + 1
	
	if pile in suitPiles:
		if len(pieces) > 1:
			return false # Can't drop multiple cards at once
		return ((pile.isEmpty() and pieces[0].value == 0) or
			(pile.top().suit == pieces[0].suit and pile.top().value == pieces[0].value - 1))

func _piece_dependencies(piece):
	var pile = piece.get_pile()
	
	if pile in sPiles:
		var ix = pile.positionInPile(piece)
		var ret = []
		for i in range(ix, len(pile.pieces)):
			ret.append(pile.pieces[i])
		
		return ret
	else:
		return [piece]

func _on_piece_placed(pile):
	moves += 1
	var win = true
	for p in suitPiles:
		if len(p.pieces) != 13 or p.top().value != 12:
			win = false
			break
	
	if win:
		results["Completion Time"] = Utils.format_time(time)
		results["Moves"] = moves
		results["Undos"] = undos
		return win(1, results)
	else:
		var lose = true
