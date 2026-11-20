extends RigidBody3D

class_name Magnet

"""
Notes:
	Magnet is on Collision Layer 2 to prevent being pulled by itself.
"""

"""
To-Do:
	finish drag mechanism (physics process)


For later: 
	distance tethering to player
	make magnet get pulled into mouse instead of snapping.

Test:
	everything
	if area3D pulls parent, too (it does)
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

##Enum for magnet movement behavior.
enum MagBe {
	##The magnet is affected by dragging.
	Disabled, 
	##The magnet snaps to the mouse's local position when dragged.
	Snap, 
	##The magnet is pulled towards the mouse's local position when dragged.
	Attract
}
##How the magnet will move when dragged.
@export var movement_behavior : MagBe = MagBe.Snap
##How fast the magnet is attracted to the mouse. 
##Only used when movement_behavior is Attract.
@export var attract_speed : int = 200
##Enum for mouse plane location.
enum PlaneLoc {
	##The plane is based on the player's  current position.
	Current_Player, 
	##The plane is based on the player's position when the magnet was first clicked.
	Old_Player,
	##The plane is based on the magnet's current position.
	Current_Magnet, 
	##The plane is based on the magnet's position when it was first clicked.
	Old_Magnet
}
##Where the plane determining local mouse position is based from.
@export var plane_location : PlaneLoc = PlaneLoc.Current_Magnet



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
			ignored_axis = value
			if !topdown: 
				topdown = true
		elif value == axis.Z:
			ignored_axis = value
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
			topdown = value
			if ignored_axis == axis.Z:
				ignored_axis = axis.Y
		else:
			topdown = value
			if ignored_axis == axis.Y:
				ignored_axis = axis.Z
##States whether the magnet should be dragged.
var held : bool = false


func _process(delta: float) -> void:
	#update ignored axis
	_update_ignored_axis()
	

func _physics_process(delta: float) -> void:
	if held:
		#update plane position
		if plane_location == PlaneLoc.Current_Player || plane_location == PlaneLoc.Current_Magnet:
			_update_plane()
		
		#update mouse position for dragging (using plane)
		_update_mouse()
		
		#get dragged
		if (movement_behavior == MagBe.Snap):
			#get snapped
			position = mouse
		elif (movement_behavior == MagBe.Attract):
			#get attracted
			pass
		#if disabled, don't get dragged.
		

func _on_input_event(cam: Node, event: InputEvent, event_position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			held = event.pressed
			freeze = event.pressed
			if plane_location == PlaneLoc.Old_Player || plane_location == PlaneLoc.Old_Magnet:
				_update_plane()


func _update_plane():
	#use ternary if-value operator to determine who to get position from.
	var who : Node3D = self if plane_location == PlaneLoc.Current_Magnet || plane_location == PlaneLoc.Old_Magnet else player
	
	#validation (who is player and player is null)
	if !who:
		print("Magnet._update_plane(): player not set.")
		return
	
	#set plane location
	if ignored_axis == axis.Y:
		mouse_plane = Plane.PLANE_XZ
		mouse_plane.d = who.position.y
	elif ignored_axis == axis.Z:
		mouse_plane = Plane.PLANE_XY
		mouse_plane.d = who.position.z


func _update_ignored_axis():
	if !camera:
		print("Magnet._update_ignored_axis(): camera not set.")
		return
	
	topdown = camera.is_top_down()
	#ignored_axis is updated from set(value) of that variable.


func _update_mouse():
	if !camera:
		print("Magnet._update_mouse(): no camera detected.")
		return
	
	#get mouse position on local plane
	var mou := get_viewport().get_mouse_position()
	var t = mouse_plane.intersects_ray(camera.project_ray_origin(mou), camera.project_ray_normal(mou))
	
	#if no intersection point, don't change mouse and print error.
	if !t:
		print("Magnet._update_mouse(): no intersection detected")
		return
	#Otherwise, intersection point is mouse position.
	mouse = t
