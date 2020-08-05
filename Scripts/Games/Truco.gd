extends Game

func setupGame():
	$Deck/DeckGenerator.init("DeckCards")
	deal()
