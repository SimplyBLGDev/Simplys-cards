extends Node2D

const clickSpeedWindow = 180 # Miliseconds

var clickPos = null
var clickGameTime = 0
var slideSpeed = 0
var dragging = false
var currentHoverGame = null

func _ready():
# warning-ignore:return_value_discarded
	$Tween.connect("tween_completed", self, "tween_completed")
	
	$KlondikeSolitaire/AnimationPlayer.play("KlondikeSolitaireIcon")
	$"Strategy+/AnimationPlayer".play("StrategyPlusIcon")
	$PictureGallery/AnimationPlayer.play("PictureGalleryIcon")
	$SpiderSolitaire/AnimationPlayer.play("SpiderSolitaireIcon")
	$PyramidSolitaire/AnimationPlayer.play("PyramidSolitaireIcon", -1, 0.75)
	$Truco/AnimationPlayer.play("TrucoIcon")
	
	# Klondike Solitaire
	klondikeSolitaire_setup()
	
	# Strategy+
	$"Strategy+/Node2D/Sprite".frame_coords = Vector2(Utils.rand_range_i(1, 4), Utils.rand_range_i(1, 5))
	
	# Picture Gallery
	pictureGallery_randomize(false)
	
	# Spider Solitaire
	$SpiderSolitaire/CL/Sprite.frame_coords = Vector2(Utils.rand_range_i(0, 13), Utils.rand_range_i(3, 5))
	$SpiderSolitaire/CR/Sprite.frame_coords = Vector2(Utils.rand_range_i(0, 13), Utils.rand_range_i(3, 5))
	
	# Pyramid Solitaire
	$PyramidSolitaire/PyramidIcon/CardA.frame_coords = Vector2(Utils.rand_range_i(0, 12), Utils.rand_range_i(1, 5))
	$PyramidSolitaire/PyramidIcon/CardB.frame_coords = Vector2(Utils.rand_range_i(0, 12), Utils.rand_range_i(1, 5))
	$PyramidSolitaire/PyramidIcon/CardC.frame_coords = Vector2(Utils.rand_range_i(0, 12), Utils.rand_range_i(1, 5))

# warning-ignore:unused_argument
func _physics_process(delta):
	handle_menu_sliding()

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			clickPos = get_global_mouse_position()
			dragging = true
			$Tween.remove(self, "slideSpeed")
		else:
			dragging = false
			clickPos = null
			$Tween.interpolate_property(self, "slideSpeed", slideSpeed, 25*sign(slideSpeed),
				abs(slideSpeed)/300, Tween.TRANS_CIRC, Tween.EASE_OUT)
			$Tween.start()
	
	if event is InputEventMouseMotion:
		if clickPos != null:
			var delta = (get_global_mouse_position() - clickPos)
			delta.y = 0
			slideSpeed = delta.x
			clickPos = get_global_mouse_position()

func handle_menu_sliding():
	position.x += slideSpeed
	
	var hoverGame = GameController.get_top_group_node_at_point(Vector2(slideSpeed*10, 0), "Games")
	if hoverGame != null and currentHoverGame != hoverGame.get_parent():
		if currentHoverGame != null: # We had a game hovered
			$Tween.interpolate_property(currentHoverGame, "position:y", -10, 0, 0.4,
				Tween.TRANS_BOUNCE, Tween.EASE_OUT)
			$Tween.interpolate_property(currentHoverGame, "scale", Vector2(1.2, 1.2),
				Vector2(1, 1), 0.4, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
		currentHoverGame = hoverGame.get_parent()
		$Tween.interpolate_property(currentHoverGame, "position:y", 0, -10, 0.4,
			Tween.TRANS_BOUNCE, Tween.EASE_OUT)
		$Tween.interpolate_property(currentHoverGame, "scale", Vector2(1, 1),
				Vector2(1.2, 1.2), 0.4, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
		$Tween.start()

func tween_completed(obj, key):
	if obj == self and key == ":slideSpeed":
		if not dragging:
			slideSpeed = 0
			$Tween.interpolate_property(self, "position:x", position.x, -currentHoverGame.position.x, 
				0.25, Tween.TRANS_BACK, Tween.EASE_OUT)
			$Tween.start()

func klondikeSolitaire_setup():
	var currentValue = Utils.rand_range_i(1, 9)
	var cards = [
		$KlondikeSolitaire/Node2D/Sprite,
		$KlondikeSolitaire/Node2D2/Sprite2,
		$KlondikeSolitaire/Node2D3/Sprite3,
		$KlondikeSolitaire/Node2D4/Sprite4
	]
	
	var lastColor = (Utils.rand_range_i(0, 2) == 1)
	
	for c in cards:
		if lastColor:
			c.frame_coords = Vector2(currentValue, Utils.rand_range_i(1, 3))
		else:
			c.frame_coords = Vector2(currentValue, Utils.rand_range_i(3, 5))
		lastColor = !lastColor
		currentValue += 1

func strategyPlus_randomize():
	var cards = [
		$"Strategy+/Node2D/Sprite/Sprite2/",
		$"Strategy+/Node2D/Sprite/Sprite2/Sprite3",
		$"Strategy+/Node2D/Sprite/Sprite2/Sprite3/Sprite4",
		$"Strategy+/Node2D/Sprite/Sprite2/Sprite3/Sprite4/Sprite5"
	]
	var lastValue  = $"Strategy+/Node2D/Sprite".frame_coords.x
	var usedSuit = [int($"Strategy+/Node2D/Sprite".frame_coords.y)]
	for c in cards:
		var delta = Utils.rand_range_i(0, 5)
		if delta == 0 and len(usedSuit) == 4:
			delta = 1
		lastValue = min(lastValue+delta, 12)
		c.frame_coords.x = lastValue
		
		if delta == 0:
			c.frame_coords.y = Utils.rand_range_i(1, 5)
			while int(c.frame_coords.y) in usedSuit:
				c.frame_coords.y = Utils.rand_range_i(1, 5)
			usedSuit.append(int(c.frame_coords.y))
		else:
			c.frame_coords.y = Utils.rand_range_i(1, 5)
			usedSuit = [int(c.frame_coords.y)]

func pictureGallery_randomize(switch):
	var frameCoordsFace = Vector2(Utils.rand_range_i(10, 13), Utils.rand_range_i(1, 5))
	var frameCoordsBack = Vector2(Utils.rand_range_i(1, 6), 0)
	if switch:
		$PictureGallery/Sprite/Sprite1.frame_coords = frameCoordsBack
		$PictureGallery/Sprite/Sprite2.frame_coords = frameCoordsFace
	else:
		$PictureGallery/Sprite/Sprite1.frame_coords = frameCoordsFace
		$PictureGallery/Sprite/Sprite2.frame_coords = frameCoordsBack

func pyramidSolitaire_randomize(stage):
	var cardA = $PyramidSolitaire/PyramidIcon/CardA.frame_coords.x
	var cardB = $PyramidSolitaire/PyramidIcon/CardB.frame_coords.x
	match stage:
		0:
			$PyramidSolitaire/PyramidIcon/CardD.frame_coords = Vector2(
				11 - cardB, Utils.rand_range_i(1, 5))
		1:
			$PyramidSolitaire/PyramidIcon/CardD.frame_coords = Vector2(
				11 - cardA, Utils.rand_range_i(1, 5))
		2:
			$PyramidSolitaire/PyramidIcon/CardB.frame_coords = (
				$PyramidSolitaire/PyramidIcon/CardC.frame_coords)
			$PyramidSolitaire/PyramidIcon/CardC.frame_coords = Vector2(
				Utils.rand_range_i(0, 12), Utils.rand_range_i(1, 5))
			$PyramidSolitaire/PyramidIcon/CardA.frame_coords = Vector2(
				Utils.rand_range_i(0, 12), Utils.rand_range_i(1, 5))

func _on__GameClicked(event, name):
	if event is InputEventMouseButton:
		if event.is_pressed():
			clickGameTime = OS.get_ticks_msec()
		else:
			if OS.get_ticks_msec() - clickGameTime <= clickSpeedWindow:
				GameController.set_game(name)
