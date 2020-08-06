extends Node2D

class_name Game

signal GatherFinished

var allPiles = []
var blockedPiles = []
export var dealSpeed = 1.0
export var gatherSpeed = 0.05

func _ready():
	GameController.currentGameMaster = self
	
	yield(self, "ready")
	setupGame()
	allPiles = get_tree().get_nodes_in_group("Piles")
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

func get_all_childs_in_group(group):
	var entireGroup = get_tree().get_nodes_in_group(group)
	var r = []
	for node in entireGroup:
		if self.is_a_parent_of(node):
			r.append(node)
	
	return r

func setupGame():
	pass

func isPileBlocked(pile):
	return pile in blockedPiles

func internal_is_piece_grabbable(piece):
	if piece.get_pile() in blockedPiles:
		return false
	
	return _is_piece_grabbable(piece)

func internal_are_pieces_placeable(pieces, pile):
	if pile in blockedPiles:
		return false
	for piece in pieces:
		if piece.get_pile() in blockedPiles:
			return false
	
	return _are_pieces_placeable(pieces, pile)

func internal_piece_dependencies(piece):
	if piece.get_pile() in blockedPiles:
		return false
	
	return _piece_dependencies(piece)

func internal_on_piece_placed(pile):
	if pile in blockedPiles:
		return false
	
	return _on_piece_placed(pile)

# warning-ignore:unused_argument
func _is_piece_grabbable(piece):
	return true

# warning-ignore:unused_argument
# warning-ignore:unused_argument
func _are_pieces_placeable(pieces, pile):
	return true

# returns an array of all the pieces that grabbing 'piece' would require
func _piece_dependencies(piece):
	return [piece]

# warning-ignore:unused_argument
func _on_piece_placed(pile):
	pass

func deal():
	pass

# warning-ignore:unused_argument
func win(place, results):
	var ribbon = load("res://UI/Prefabs/WinRibbon.tscn").instance()
	ribbon.results = results
	GameController.set_UI(ribbon)
	pass
