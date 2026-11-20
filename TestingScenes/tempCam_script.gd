extends Camera3D

##Created by Kate for purpose of testing Magnet


@export var topdown : bool = false
@export var player_pos : Vector3 = Vector3(0,1,0)
enum DistCalc {Current, Fixed}
@export var distance_setting : DistCalc = DistCalc.Current
@export var camera_dist : float = 8

func _ready() -> void:
	if distance_setting == DistCalc.Current:
		camera_dist = player_pos.distance_to(position)
	position.x = player_pos.x

func is_top_down() -> bool:
	return topdown

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Change Perspective"):
		topdown = !topdown
	rotation_degrees.x = -90*int(topdown)
	position.y = camera_dist*int(topdown)+player_pos.y
	position.z = camera_dist*int(!topdown)+player_pos.z
