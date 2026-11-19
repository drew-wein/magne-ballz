extends RigidBody3D

class_name Magnet

"""
To-Do:
	finish drag mechanism (physics process)

For later: 
	distance tethering to player
	make magnet get pulled into mouse instead of snapping.
"""

##Enum for axis being ignored.
enum axis {
	##The y-axis (up).
	Y, 
	##The z-axis (right).
	Z
}

##The player node.
@export var player : Node3D = null
##The camera node.
@export var camera : Camera3D = null

##The position of the mouse. 
##Updates during dragging.
var mouse : Vector3
##The plane the mouse is cast on while dragging. 
##Updates during dragging.
var mouse_plane : Plane
##The axis the camera is facing along (AKA not really visible). 
##Linked with topdown.
var ignored_axis : axis = axis.Y:
	set(value):
		if value == axis.Y:
			if !topdown: 
				topdown = true
		elif value == axis.Z:
			if topdown: 
				topdown = false
		else:
			print("Magnet.ignored_axis.set(value): value not recognized.")
		ignored_axis = value
##States whether the camera is in top-down perspectice. 
##Linked with ignored_axis.
var topdown : bool = true:
	set(value):
		if value == true:
			if ignored_axis == axis.Z:
				ignored_axis = axis.Y
		else:
			if ignored_axis == axis.Y:
				ignored_axis = axis.Z
		topdown = value
##States whether the magnet should be dragged.
var held : bool = false


func _process(delta: float) -> void:
	#update ignored axis
	_update_ignored_axis()
	

func _physics_process(delta: float) -> void:
	if held:
		#update plane position
		_update_plane()
		
		#update mouse position for dragging (using plane)
		_update_mouse()
		
		#get dragged
		#for now, can snap
		

func _on_input_event(cam: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			held = event.pressed


func _update_plane():
	if !player:
		print("Magnet._update_plane(): player not set.")
		return
	
	if ignored_axis == axis.Y:
		mouse_plane = Plane.PLANE_XZ
		mouse_plane.d = position.y
	elif ignored_axis == axis.Z:
		mouse_plane = Plane.PLANE_XY
		mouse_plane.d = position.z


func _update_ignored_axis():
	if !camera:
		print("Magnet._update_ignored_axis(): camera not set.")
		return
	
	topdown = camera.is_top_down()
	#ignored_axis is updated from set(value) of that variable.


func _update_mouse():
	var mou := get_viewport().get_mouse_position()
	
	#get mouse position on local plane
	var t = mouse_plane.intersects_ray(camera.project_ray_origin(mou), camera.project_ray_normal(mou))
	
	#if no intersection point, don't change mouse and print error.
	if !t:
		print("Magnet._update_mouse(): no intersection detected")
		return
	#Otherwise, intersection point is mouse position.
	mouse = t
