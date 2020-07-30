extends Node2D

class_name Game

signal GatherFinished

var blockedPiles = []
export var dealSpeed = 1.0
export var gatherSpeed = 0.05

func _ready():
	GameController.currentGameMaster = self
	GameController.set_zoom($PlayArea.global_position, $PlayArea2.global_position)
	yield(self, "ready")
	setupGame()
	var allPiles = get_tree().get_nodes_in_group("Piles")
	for __pile in allPiles:
		if is_a_parent_of(__pile):
			__pile.get_parent().connect("_piece_placed", self, "_on_piece_placed")
			__pile.get_parent().connect("_piece_placed", GameController, "play_SFX")

func gatherPiecesTo(group, pile):
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = gatherSpeed
	for piece in get_tree().get_nodes_in_group(group):
		if self.is_a_parent_of(piece) and not pile.is_a_parent_of(piece):
			timer.start()
			yield(timer, "timeout")
			pile.add_piece(piece)
	
	timer.wait_time = 1
	timer.start()
	yield(timer, "timeout")
	timer.queue_free()
	emit_signal("GatherFinished")

func setupGame():
	pass

func _is_piece_grabbable(piece):
	return true

func _are_pieces_placeable(pieces, pile):
	return true

func _piece_dependencies(piece):
	return [piece]

func _on_piece_placed(pile):
	pass

func deal():
	pass

func win(place, results):
	var ribbon = load("res://UI/Prefabs/WinRibbon.tscn").instance()
	ribbon.results = results
	GameController.set_UI(ribbon)
	pass
