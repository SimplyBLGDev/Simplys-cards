extends Game

# SETTINGS
enum EmptyPilePlacementMode { OnlyKings, AnyCard}

export var flipAmount = 3
export var emptyPilePlacement = EmptyPilePlacementMode.AnyCard
# SETTINGS

var standardPiles = []
var deck
var deckFlip
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
	$Deck/DeckGenerator.init("DeckCards") # Generate Deck
	
	deck = $Deck
	deckFlip = $DeckFlip
	
	for i in range(1, 8):
		standardPiles.append(find_node("Pile" + str(i), false, true))
	
	for i in range(1, 5):
		suitPiles.append(find_node("SuitPile" + str(i), false, true))
	
	deck.connect("_pile_clicked", self, "_on_deck_click")
	
	for p in standardPiles:
		p.connect("_piece_taken", self, "_on_sPile_card_taken")
	
	deal()

func _on_deck_click(pile):
	if len(deck.pieces) == 0 and len(deckFlip.pieces) > 0:
		flip_deck_flip_cards()
	else:
		for i in flipAmount:
			if len(deck.pieces) > 0:
				deck.top().flip()
				deckFlip.add_piece(deck.top())

func _on_sPile_card_taken(pile):
	if len(pile.pieces) > 0:
		if !pile.top().faceUp:
			pile.top().flip()

func _is_piece_grabbable(piece):
	var pile = piece.get_pile()
	
	if pile in standardPiles:
		return piece.faceUp
	elif pile in suitPiles:
		return pile.top() == piece
	elif pile == deck:
		return false
	elif pile == deckFlip:
		return deckFlip.top() == piece

func _are_pieces_placeable(pieces, pile):
	var pileTopCard = null
	if len(pile.pieces) != 0:
		pileTopCard = pile.top()
	
	if pile in standardPiles:
		if pileTopCard == null:
			match emptyPilePlacement:
				EmptyPilePlacementMode.OnlyKings:
					return pieces[0].value == 12
				EmptyPilePlacementMode.AnyCard:
					return true
			
		var alternateSuitColors = (
			(pieces[0].suit in [1, 2] and pileTopCard.suit in [3, 4]) or
			(pieces[0].suit in [3, 4] and pileTopCard.suit in [1, 2]))
		return (alternateSuitColors and pieces[0].value == pileTopCard.value - 1)
	elif pile in suitPiles:
		if pileTopCard == null:
			return pieces[0].value == 0
		else:
			return pileTopCard.suit == pieces[0].suit and pileTopCard.value == pieces[0].value - 1
	
	return false

func _piece_dependencies(piece):
	var pile = piece.get_pile()
	
	if pile in standardPiles:
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

## DEAL FUNCTIONS

func flip_deck_flip_cards():
	blockedPiles.append(deck)
	blockedPiles.append(deckFlip)
	
	var flipCards = len(deckFlip.pieces)
	
	deckFlip.disableSorting = true
	for cCard in flipCards:
		deckFlip.top().flip()
		deck.add_piece(deckFlip.top())
	
	deckFlip.disableSorting = false
	blockedPiles.erase(deck)
	blockedPiles.erase(deckFlip)

func deal():
	blockedPiles = []
	blockedPiles += standardPiles
	blockedPiles += suitPiles
	blockedPiles.append(deck)
	blockedPiles.append(deckFlip)
	
	gatherPiecesTo("DeckCards", deck)
	yield(self, "GatherFinished")
	
	for card in deck.pieces:
		card.faceUp = false
		card.update_sprite()
	
	shuffle()
	$AnimationPlayer.play("KlondikeSolitaireDeal", 0, dealSpeed)
	yield ($AnimationPlayer, "animation_finished")
	blockedPiles.clear()
	time = 0
	moves = 0
	undos = 0

func shuffle():
	deck.shuffle()

func deal_step(pileIx):
	standardPiles[pileIx].add_piece(deck.top())

func flip_pile_top_card(pileIx):
	standardPiles[pileIx].top().flip()
