extends Game

signal dealNextCard

# SETTINGS

# SETTINGS

var deck

var acesPile
var twoPiles = []
var threePiles = []
var fourPiles = []
var handPiles = []

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
	deck = $Deck
	acesPile = $AcesPile
	
	for i in range(1, 9):
		handPiles.append(get_node("HandPile" + str(i)))
		twoPiles.append(get_node("2Pile" + str(i)))
		threePiles.append(get_node("3Pile" + str(i)))
		fourPiles.append(get_node("4Pile" + str(i)))
		handPiles[-1].connect("_piece_taken", self, "_on_hand_card_taken")
	
	#connect("dealNextCard", self, "dealNextCard")
	deal()

func _is_piece_grabbable(piece):
	var pile = piece.get_pile()
	
	if pile in acesPile or pile == deck:
		return false
	elif pile in handPiles:
		return pile.top() == piece
	else:
		return pile.top() == piece

func _are_pieces_placeable(pieces, pile):
	if pile == acesPile:
		return pieces[0].value == 0
	elif pile in handPiles:
		return len(pile.pieces) == 0
	elif pile.isEmpty():
		match pieces[0].value:
			1:
				return pile in twoPiles
			2:
				return pile in threePiles
			3:
				return pile in fourPiles
			_:
				return false
	else:
		if pile.top().suit == pieces[0].suit:
			if ((pile in twoPiles and pile.pieces[0].value != 1) or
				(pile in threePiles and pile.pieces[0].value != 2) or
				(pile in fourPiles and pile.pieces[0].value != 3)):
				return false
			return pile.top().value + 3 == pieces[0].value
	
	return false

func _piece_dependencies(piece):
	return [piece]

func _on_hand_card_taken(pile):
	if len(pile.pieces) == 0 and len(deck.pieces) > 0:
		deck.top().flip()
		pile.add_piece(deck.top())

func _on_piece_placed(pile):
	moves += 1
	var win = true
	for pile in (twoPiles + threePiles + fourPiles):
		if len(pile.pieces) != 4:
			win = false
			break
	
	if win:
		results["Completion Time"] = Utils.format_time(time)
		results["Moves"] = moves
		results["Undos"] = undos
		return win(1, results)

func deal():
	var dealPiles = fourPiles + threePiles + twoPiles + handPiles
	blockedPiles.append(deck)
	blockedPiles.append(acesPile)
	blockedPiles += handPiles
	blockedPiles += dealPiles
	gatherPiecesTo("DeckCards", deck)
	yield(self, "GatherFinished")
	
	for piece in deck.pieces:
		piece.faceUp = false
		piece.update_sprite()
	
	deck.shuffle()
	$AnimationPlayer.play("PictureGalleryDeal", -1, dealSpeed)
	
	for pile in dealPiles:
		deck.top().flip()
		pile.add_piece(deck.top())
		yield(self, "dealNextCard")
	
	blockedPiles = []

func dealNextCard():
	emit_signal("dealNextCard")

func _on_Deck__pile_clicked(pile):
	blockedPiles.append(deck)
	blockedPiles += handPiles
	$AnimationPlayer.play("PictureGalleryDealHand")
	
	for handPile in handPiles:
		yield(self, "dealNextCard")
		if deck.isEmpty():
			break
		deck.top().flip()
		handPile.add_piece(deck.top())
	
	blockedPiles = []
