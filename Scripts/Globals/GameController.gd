extends Node2D

const VERSION = "Pre-Alpha 0.3.0"

# Minimum speed for card to reach cursor
const minCardApproach = 1.5
 # Speed to reach cursor proportional to the distance to the point
const cardApproachSpeed = 0.2
# The higher the value the more mouse speed influences card rotation whiel dragging
const movementAngleBySpeedModifier = 400

onready var camera = $Camera2D
onready var root = get_tree().get_root()
onready var UI = $Canvas/UIOff/UI
onready var pieceGfx = $PieceGraphicsController

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
	$"ControlUI/Version Label".text = VERSION
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
			release_pieces(currentDrag)
		elif event.is_pressed() and currentDrag == null:
			var clicked = get_top_group_nodes_at_point(
				get_global_mouse_position(), "Pieces")
			if len(clicked) > 0:
				grab_piece(clicked)
	
	if OS.is_debug_build():
		if event is InputEventKey: # DEBUG
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

func get_top_group_nodes_at_point(point, group):
	var intersects = get_world_2d().direct_space_state.intersect_point(
			point, 128, [], 2147483647, false, true)
	var nodes = []
	
	for i in intersects:
		if i["collider"].is_in_group(group):
			nodes.append(i["collider"].get_parent())
	
	nodes.sort_custom(self, "sort_nodes_by_tree_position")
	return nodes

static func sort_nodes_by_tree_position(a, b):
	return a.is_greater_than(b)

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

func grab_piece(pieces):
	for piece in pieces:
		if currentGameMaster.internal_is_piece_grabbable(piece):
			var dependencies = currentGameMaster.internal_piece_dependencies(piece)
			currentDrag = dependencies
			for p in dependencies:
				dragToPosition = null
				p.z_index += 5
				piece.emit_signal("_on_piece_grabbed", p)
			return

func release_pieces(pieces):
	var deposits = get_top_group_nodes_at_point(
				get_global_mouse_position(), "Piles")
	
	for p in pieces:
		p.z_index -= 5
		$UncancellableTween.interpolate_property(p, "rotation",
			fmod(p.rotation, PI), 0, 0.65, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	$UncancellableTween.start()
	
	var deposited = false
	
	if len(deposits) > 0:
		for deposit in deposits:
			if currentGameMaster.internal_are_pieces_placeable(pieces, deposit):
				deposit.add_pieces(currentDrag)
				deposited = true
				break
	
	if not deposited:
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

func set_zoom(newPlayArea):
	currentPlayArea = newPlayArea
	var vRect = get_viewport_rect()
	var playArea = currentPlayArea.size
	var playAreaAspect = playArea.x / playArea.y
	var r = 1
	var aspectScreen = vRect.size.x / vRect.size.y
	if aspectScreen < playAreaAspect:
		r = playArea.x / vRect.size.x
	else:
		r = playArea.y / vRect.size.y
	
	camera.global_position = currentPlayArea.position + playArea/2
	camera.zoom = Vector2(1, 1) * r
	UI.scale = (Vector2(1, 1) / r) * min(playArea.x / 1280, playArea.y / 720)
	
	$Canvas.offset = get_viewport_rect().size / 2
	#+ playArea / r / 1280

func _on_window_resized():
	set_zoom(currentPlayArea)

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
			"Truco": add_child(load("res://Games/Truco.tscn").instance())
		
		get_tree().get_root().get_node("root/GameSelection").queue_free()

func play_SFX(piece):
	$SFXPlayer.play()

func set_UI(node):
	UI.add_child(node)
	#node.global_position = camera.global_position
