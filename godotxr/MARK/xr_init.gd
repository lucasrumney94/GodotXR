extends XROrigin3D


@export var xr_simulator_scene: PackedScene
@export var side_window: PackedScene

var xr_interface : XRInterface
var current_interface_name: String = "OpenXR"

var xr_simulator : XRSimulator

func _ready() -> void:
	%SimulatorButton.toggled.connect(on_simulator_toggled)
	add_side_window()
	
	print(str(XRServer.get_interfaces()))
	initiate_xr_interface("OpenXR")
	#TODO display dialogue with list of xr options
	#Add XR Simulator to list of options
	#If XR simulator selected, initiate_xr_simulator()


func initiate_xr_interface(interface_name: String):
	current_interface_name = interface_name
	xr_interface = XRServer.find_interface(interface_name)
	
	if !xr_interface:
		printerr("XRServer failed to find interface of name " + interface_name)
		initiate_xr_simulator()
		return
	if !xr_interface.is_initialized():
		printerr("NO OpenXR interface initialized! Check headset connection. "+\
		"If using WMR it only supports DirectX, not OpenGL or Vulkan. "+\
		"Also make sure in SteamVR Developer Settings to set 'OpenXR' as the default runtime")
		initiate_xr_simulator()
		return
	
	#IF it makes it this far, should be initializing properly
	print(interface_name + " initialized!")
	
	# Disable v-sync
	## Otherwise limited to monitor frame rate
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

	# Enable XR viewport
	get_viewport().use_xr = true

	# Enable Alpha in viewport to allow for passthrough
	get_viewport().transparent_bg = true

	# TODO: Optional Higher Physics Rate from 60 to 90
	## Engine.physics_ticks_per_second = 90


func initiate_xr_simulator():
	if xr_simulator == null:
		xr_simulator = xr_simulator_scene.instantiate()
		add_child(xr_simulator)
		xr_simulator.position = Vector3.ZERO
		xr_simulator.rotation = Vector3.ZERO
	#Just launch in normal mode
	print("Running godot in normal mode with XR simulator")
	var xr_cam: XRCamera3D = null
	var xr_left: XRController3D = null
	var xr_right: XRController3D = null
	for child in get_children():
		if child is XRCamera3D:
			xr_cam = child
		elif child is XRController3D:
			var hand = child.get_tracker_hand()
			if hand == XRPositionalTracker.TrackerHand.TRACKER_HAND_LEFT:
				xr_left = child
			elif hand == XRPositionalTracker.TrackerHand.TRACKER_HAND_RIGHT:
				xr_right = child
	xr_simulator.setup_simulator(xr_cam, xr_left, xr_right)
	xr_simulator.enable_simulator()


func add_side_window():
	get_viewport().set_embedding_subwindows(false)
	var sw = side_window.instantiate()
	add_child(sw)
	sw.position = Vector2(800, 800)
	sw.title = "Side Piece"
	sw.size = Vector2(300, 200)
	Callable(finish_side_window.bind(sw)).call_deferred()


func finish_side_window(sw: Window):
	%SimulatorButton.get_parent().reparent(sw)


func on_simulator_toggled(is_toggled: bool):
	if is_toggled:
		initiate_xr_simulator()
	else:
		if xr_simulator != null:
			xr_simulator.enable_simulator(false)
		initiate_xr_interface(current_interface_name)
