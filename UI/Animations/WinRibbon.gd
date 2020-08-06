tool
extends Node2D

var ready = false

export var outlineWidth = 8.0
export var size = Vector2(300, 50) setget sizeChanged
export var slopeSize = Vector2(50, 100) setget turnSlopeChanged
export var tailSize = Vector2(100, 30) setget tailChanged # Width, depth of the cut

export var resultsTimeDelta = 0.2

onready var rowsContainer = $ResultsContainer/Rows
onready var resultRowPrefab = load("res://UI/Prefabs/ResultRow.tscn")

export var results = {
	"Completion Time":"0:00:00",
	"Moves":"0",
	"Undos":"0"
	}

func _ready():
	ready = true
	$AnimationPlayer.play("RibbonWin")
	GameController.DisableInput()
	GameController.animate_screen_tint(Color(0, 0, 0, 0), Color(0, 0, 0, 0.5), 0.35)

func presentResults():
	var timeDelta = 0
	for result in results:
		var row = resultRowPrefab.instance()
		row.name = result + "_Row"
		row.get_node("ResultN/Label").text = result + ":"
		row.get_node("Result/Label").text = str(results[result])
		row.connect("ready", self, "rowReady", [row, timeDelta])
		rowsContainer.add_child(row)
		timeDelta += resultsTimeDelta

func personalBest(row):
	row.get_node("AnimationPlayer").queue("UIGameResultsPB")

func rowReady(row, delay):
	$Tween.interpolate_callback(row.get_node("AnimationPlayer"), delay,
		"play", "UIGameResultsDrop")
	$Tween.start()

func sizeChanged(value):
	size = value
	if not ready:
		return
	var hSize = size/2
	var points = PoolVector2Array()
	
	points.append(-hSize)
	points.append(Vector2(-hSize.x, hSize.y))
	points.append(hSize)
	points.append(Vector2(hSize.x, -hSize.y))
	
	$RibbonMain/Body.polygon = points
	
	points = PoolVector2Array()
	
	points.append(Vector2(-hSize.x - outlineWidth, -hSize.y - outlineWidth))
	points.append(Vector2(-hSize.x - outlineWidth, hSize.y + outlineWidth))
	points.append(Vector2(hSize.x + outlineWidth, hSize.y + outlineWidth))
	points.append(Vector2(hSize.x + outlineWidth, -hSize.y - outlineWidth))
	
	$RibbonMain.polygon = points

func turnSlopeChanged(value):
	slopeSize = value
	if not ready:
		return
	var hSize = size / 2
	
	var points = PoolVector2Array()
	
	points.append(hSize)
	points.append(Vector2(hSize.x, -hSize.y))
	points.append(Vector2(hSize.x - slopeSize.x, -hSize.y + slopeSize.y))
	points.append(Vector2(hSize.x - slopeSize.x, hSize.y + slopeSize.y))
	
	$RibbonTurnL/Body.polygon = points
	$RibbonTurnR/Body.polygon = points
	
	points = PoolVector2Array()
	
	points.append(Vector2(hSize.x + outlineWidth, hSize.y + outlineWidth))
	points.append(Vector2(hSize.x + outlineWidth, -hSize.y - outlineWidth))
	points.append(Vector2(hSize.x - slopeSize.x - outlineWidth, -hSize.y + slopeSize.y - outlineWidth*2.5))
	points.append(Vector2(hSize.x - slopeSize.x - outlineWidth, hSize.y + slopeSize.y + outlineWidth*2.5))
	
	$RibbonTurnL.polygon = points
	$RibbonTurnR.polygon = points

func tailChanged(value):
	tailSize = value
	if not ready:
		return
	var hSize = size / 2
	
	var points = PoolVector2Array()
	
	var pointB = Vector2(hSize.x - slopeSize.x - outlineWidth, hSize.y + slopeSize.y + outlineWidth*2.5)
	var pointA = pointB + Vector2(0, -size.y - outlineWidth*2)
	
	points.append(pointA)
	points.append(pointB)
	points.append(pointB + Vector2(tailSize.x, 0))
	points.append(Vector2(pointA.x + tailSize.y, pointA.y + (pointB.y - pointA.y)/2))
	points.append(pointA + Vector2(tailSize.x, 0))
	
	$RibbonEndL.polygon = points
	$RibbonEndR.polygon = points
	
	points[0] += Vector2(outlineWidth, outlineWidth)
	points[1] += Vector2(outlineWidth, -outlineWidth)
	points[2] += Vector2(-outlineWidth*2, -outlineWidth)
	points[3] += Vector2(-outlineWidth*1.7, 0)
	points[4] += Vector2(-outlineWidth*2, outlineWidth)
	
	$RibbonEndL/Body.polygon = points
	$RibbonEndR/Body.polygon = points

func _on_NewGameButton_clicked():
	if not $"Buttons/Buttons BG/NewGameButton".visible:
		return
	GameController.new_game()
	queue_free()

func _on_MenuButton_clicked():
	if not $"Buttons/Buttons BG/MenuButton".visible:
		return
	GameController.set_game("Game Selection")
	queue_free()

func _notification(what): 
		if what == NOTIFICATION_PREDELETE:
			GameController.animate_screen_tint(null, Color(0, 0, 0, 0), 0.35)
			GameController.EnableInput()
