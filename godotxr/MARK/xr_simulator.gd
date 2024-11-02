extends Node3D
class_name XRSimulator

@export var camera_point: Node3D
@export var neck: Node3D
@export var left_hand: Node3D
@export var right_hand: Node3D

var enabled: bool = false

var xr_camera: XRCamera3D
var xr_left_hand: XRController3D
var xr_right_hand: XRController3D

var mouse_input: bool = false
var rotation_input: float
var tilt_input: float
var mouse_rotation: Vector3
var tilt_lower_limit: float = -89
var tilt_upper_limit: float = 89


func setup_simulator(xr_cam: XRCamera3D, xr_left: XRController3D, xr_right: XRController3D):
	xr_camera = xr_cam
	xr_left_hand = xr_left
	xr_right_hand = xr_right


func enable_simulator(setting: bool = true):
	enabled = setting
	get_viewport().use_xr = !setting
	if enabled:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	else:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _process(delta):
	if !enabled: return
	
	if xr_camera != null:
		xr_camera.global_position = camera_point.global_position
		xr_camera.global_rotation = camera_point.global_rotation
	if xr_left_hand != null:
		xr_left_hand.global_position = left_hand.global_position
		xr_left_hand.global_rotation = left_hand.global_rotation
	if xr_right_hand != null:
		xr_right_hand.global_position = right_hand.global_position
		xr_right_hand.global_rotation = right_hand.global_rotation


func _input(event):
	if !enabled: return
	
	if event.is_action_pressed("ui_cancel"):
		#TODO add pause menu
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	mouse_input = event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	if mouse_input:
		rotation_input = -event.relative.x# * Settings.mouse_sensitivity_x
		tilt_input = -event.relative.y# * Settings.mouse_sensitivity_y
		update_camera(get_process_delta_time())


func update_camera(delta):
	mouse_rotation.x += tilt_input * delta
	mouse_rotation.x = clamp(mouse_rotation.x, deg_to_rad(tilt_lower_limit), deg_to_rad(tilt_upper_limit))
	#if Settings.invert_look_y:
		#mouse_rotation.x *= -1
	mouse_rotation.y += rotation_input * delta
	
	neck.transform.basis = Basis.from_euler(mouse_rotation)
	#neck.rotation.z = 0.0#lean_rotation#
	
	#shapecast_look_root.rotation.y = camera_rotation_root.rotation.y + PI
	
	rotation_input = 0.0
	tilt_input = 0.0
