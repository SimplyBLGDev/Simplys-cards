tool
extends Node2D

signal clicked

export var color = Color.white setget updateColor
export var size = Vector2(500, 150) setget updateSize
export var angle = 70 setget updateAngle
export var text = "Button" setget updateText
export var shadowDistance = 10 setget updateShadow

func updateColor(value):
	color = value
	$Polygon.color = color

func updateText(value):
	text = value
	$Polygon/Label.text = text
	$Polygon/Label.rect_pivot_offset = size/2

func updateAngle(value):
	angle = value
	makePolygons()

func updateSize(value):
	size = value
	makePolygons()

func updateShadow(value):
	shadowDistance = value
	$Shadow.position = Vector2(shadowDistance, shadowDistance)

func makePolygons():
	var hSize = size/2
	var polygons = PoolVector2Array()
	
	polygons.append(-hSize)
	polygons.append(Vector2(-hSize.x - angle, hSize.y))
	polygons.append(hSize)
	polygons.append(Vector2(hSize.x + angle, -hSize.y))
	
	$Polygon.polygon = polygons
	$Shadow.polygon = polygons
	$Area2D/CollisionPolygon2D.polygon = polygons
	$Polygon/Label.rect_position = polygons[0]
	$Polygon/Label.rect_size = size

func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.is_pressed():
			$Tween.remove_all()
			$Tween.interpolate_property($Polygon, "position", $Polygon.position,
				$Shadow.position, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
		else:
			$Tween.remove_all()
			$Tween.interpolate_property($Polygon, "position", $Shadow.position,
				Vector2(0, 0), 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN)
			$Tween.start()
			emit_signal("clicked")
