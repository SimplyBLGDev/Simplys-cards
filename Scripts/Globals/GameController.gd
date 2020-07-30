extends Node2D

# Minimum speed for card to reach cursor
const minCardApproach = 1.5
 # Speed to reach cursor proportional to the distance to the point
const cardApproachSpeed = 0.2
# The higher the value the more mouse speed influences card rotation whiel dragging
const movementAngleBySpeedModifier = 400

onready var camera = $Camera2D
onready var root = get_tree().get_root()
onready var UI = $UIOff/UI

var playerId = 0
var teamId = 0

var currentSelected = []
var currentDrag
var dragToPosition
var subsequentDragOffset = Vector2(0, 20)

var currentPlayArea = Rect2(0, 0, 0, 0)

var currentGameMaster

func _ready():
	get_tree().get_root().connect("size_changed", self, "_on_window_resized")
	randomize()

func _physics_process(delta):
	if currentDrag != null and dragToPosition != null:
		process_piece_dragging()

func _input(event):
	if event is InputEventMouseMotion:
		if currentDrag != null:
			dragToPosition = get_global_mouse_position()
	elif event is InputEventMouseButton:
		if !event.is_pressed() and currentDrag != null:
			on_piece_release(currentDrag)
		elif event.is_pressed() and currentDrag == null:
			var clicked = get_top_group_node_at_point(
				get_global_mouse_position(), "Pieces")
			if clicked != null:
				grab_piece(clicked.get_parent())
	elif event is InputEventKey:
		if !event.is_pressed():
			if event.scancode == 87: #W
				currentGameMaster.win(1, currentGameMaster.results)

func get_top_group_node_at_point(point, group):
	var minNode = null
	var intersects = get_world_2d().direct_space_state.intersect_point(
			point, 128, [], 2147483647, false, true)
	
	for i in intersects:
		if i["collider"].is_in_group(group):
			if minNode == null or i["collider"].is_greater_than(minNode):
				minNode = i["collider"] # Filter lowest node in tree
	return minNode

func process_piece_dragging():
	for i in len(currentDrag):
		var from = currentDrag[i].global_position
		var to = dragToPosition + i*subsequentDragOffset
		var posDelta = from.distance_to(to)
		var approachSpeed = max(minCardApproach, posDelta*cardApproachSpeed)
		var newPosition = Vector2(
		move_toward(from.x, to.x,
			max(minCardApproach, abs(from.x-to.x)*cardApproachSpeed)
			),
			move_toward(from.y, to.y,
			max(minCardApproach, abs(from.y-to.y)*cardApproachSpeed)))
		
		var newAngle = (to-from).angle()
		
		currentDrag[i].global_position = newPosition
		currentDrag[i].rotation = lerp_angle(0, newAngle + PI/2,
			posDelta/movementAngleBySpeedModifier)

func grab_piece(piece):
	if currentGameMaster._is_piece_grabbable(piece):
		var dependencies = currentGameMaster._piece_dependencies(piece)
		currentDrag = dependencies
		for p in dependencies:
			dragToPosition = null
			p.z_index += 5
			piece.emit_signal("_on_piece_grabbed", p)

func on_piece_release(pieces):
	var deposit = get_top_group_node_at_point(
				get_global_mouse_position(), "Piles")
	
	if deposit != null:
		deposit = deposit.get_parent()
	
	for p in pieces:
		p.z_index -= 5
		$UncancellableTween.interpolate_property(p, "rotation",
			fmod(p.rotation, PI), 0, 0.65, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$UncancellableTween.start()
	
	if deposit != null and currentGameMaster._are_pieces_placeable(pieces, deposit):
		deposit.add_pieces(currentDrag)
	else:
		pieces[0].get_pile().sort_pieces()
	
	currentDrag = null
	dragToPosition = null

func take_held_piece():
	if currentDrag == null:
		return null
	currentDrag.z_index -= 5
	var r = currentDrag
	currentDrag = null
	dragToPosition = null
	r.emit_signal("_on_piece_taken", r)
	return r

func set_zoom(playAreaA, playAreaB):
	var vRect = get_viewport_rect()
	var playArea = playAreaB - playAreaA
	currentPlayArea = Rect2(playAreaA.x, playAreaA.y, playArea.x, playArea.y)
	var playAreaAspect = playArea.x / playArea.y
	var r = 1
	var aspectScreen = get_viewport_rect().size.x / get_viewport_rect().size.y
	if aspectScreen < playAreaAspect:
		r = playArea.x / get_viewport_rect().size.x
	else:
		r = playArea.y /  get_viewport_rect().size.y
	
	camera.global_position = playAreaA + playArea/2
	camera.zoom = Vector2(1, 1) * r
	if playAreaAspect < 1:
		$UIOff.scale = Vector2(1, 1) * playArea.y / 720
	else:
		$UIOff.scale = Vector2(1, 1) * playArea.x / 1280
	$UIOff.global_position = camera.global_position

func on_window_resized():
	set_zoom(currentPlayArea.position, currentPlayArea.position + currentPlayArea.size)

func new_game():
	currentGameMaster.deal()

func set_game(game):
	if game == "Game Selection":
		root.add_child(load("res://UI/GameSelection.tscn").instance())
	else:
		match game:
			"Klondike Solitaire": add_child(load("res://Games/KlondikeSolitaire.tscn").instance())
			"Strategy+": add_child(load("res://Games/StrategySolitaire.tscn").instance())
			"Picture Gallery": add_child(load("res://Games/PictureGallery.tscn").instance())
			"Shogi": add_child(load("res://Games/Shogi.tscn").instance())
			"Spider Solitaire": add_child(load("res://Games/SpiderSolitaire.tscn").instance())
			"Pyramid Solitaire": add_child(load("res://Games/PyramidSolitaire.tscn").instance())
			"Free Cell": add_child(load("res://Games/FreeCell.tscn").instance())
		
		get_tree().get_root().get_node("root/GameSelection").queue_free()

func play_SFX(piece):
	$SFXPlayer.play()

func set_UI(node):
	UI.add_child(node)
