extends Node
var camera
var top_down_cam = true
var side_cam = false
var cam_y_offset = 9 #how high above we want the cam to be (have it follow player normally or use player pos + 7)
var cam_z_offset = 9 #same as above just how far to the side

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera = $Camera3D
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Change Perspective"):
		if top_down_cam: #switch to side view
			side_cam = true
			top_down_cam = false
			self.position.y = 0
			self.position.z = cam_z_offset
			self.rotation_degrees.x = 0
		elif side_cam: #switch to top view
			side_cam = false
			top_down_cam = true
			self.position.y = cam_y_offset
			self.position.z = 0
			self.rotation_degrees.x = -90
	pass
