extends Game

signal dealNextCard

# SETTINGS
export var allowAnySuit = false
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
	var lastCard = null
	if len(pile.pieces) != 0:
		lastCard = pile.top()
	
	if pile == acesPile:
		return pieces[0].value == 0
	elif pile in handPiles:
		return len(pile.pieces) == 0
	elif pile.isEmpty() or lastCard.suit == pieces[0].suit or allowAnySuit:
		if pile in twoPiles:
			match int(pieces[0].value):
				1:
					return len(pile.pieces) == 0
				4:
					return len(pile.pieces) == 1 and lastCard.value == 1
				7:
					return len(pile.pieces) == 2 and lastCard.value == 4
				10:
					return len(pile.pieces) == 3 and lastCard.value == 7
		elif pile in threePiles:
			match int(pieces[0].value):
				2:
					return len(pile.pieces) == 0
				5:
					return len(pile.pieces) == 1 and lastCard.value == 2
				8:
					return len(pile.pieces) == 2 and lastCard.value == 5
				11:
					return len(pile.pieces) == 3 and lastCard.value == 8
		elif pile in fourPiles:
			match int(pieces[0].value):
				3:
					return len(pile.pieces) == 0
				6:
					return len(pile.pieces) == 1 and lastCard.value == 3
				9:
					return len(pile.pieces) == 2 and lastCard.value == 6
				12:
					return len(pile.pieces) == 3 and lastCard.value == 9
	
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
