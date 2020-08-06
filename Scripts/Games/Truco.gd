extends Game

const trucoValues = {
[0, 4]: 0,
[0, 5]: 4,
[0, 6]: 8,
[0, 7]: 12,
[0, 10]: 14,
[0, 11]: 18,
[0, 12]: 22,
[0, 1]: 26,
[0, 2]: 28,
[0, 3]: 32,
[1, 7]: 36, # 7 coins
[3, 7]: 37, # 7 swords
[4, 1]: 38, # 1 clubs
[3, 1]: 39 # 1 sword
}

onready var deck = $Deck
var playPiles = []

func setupGame():
	$Deck/DeckGenerator.init("DeckCards")
	playPiles = get_all_childs_in_group("PlayPiles")
	deal()

func deal():
	gatherPiecesTo("DeckCards", deck)
	deck.shuffle()
	
	playPiles[0].add_piece(deck.top())
	playPiles[0].add_piece(deck.top())
	playPiles[0].add_piece(deck.top())
	
	playPiles[1].add_piece(deck.top())
	playPiles[1].add_piece(deck.top())
	playPiles[1].add_piece(deck.top())

func calculateEnvido(hand):
	var cards = Utils.sort_v2_pieces_by_value(Utils.get_pieces_as_Vector2(hand))
	
	var score = 0
	
	score = cards[0] # Highest
	
	if cards[0].suit == cards[1].suit:
		score += 20
		score += cards[1]
	elif cards[0].suit == cards[2].suit:
		score += 20
		score += cards[2]
	elif cards[1].suit == cards[2].suit:
			score = 20 + cards[1].value + cards[2].value

func trucoValue(card):
	if not card in trucoValues:
		return trucoValues[[0, card[1]]] # generic suit
	
	return trucoValues[card]
