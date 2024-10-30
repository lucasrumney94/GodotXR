extends XROrigin3D

var xr_interface : XRInterface;

func _ready() -> void:
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized!")

		# Disable v-sync
		## Otherwise limited to monitor frame rate
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

		# Enable XR viewport
		get_viewport().use_xr = true

		# Enable Alpha in viewport to allow for passthrough
		get_viewport().transparent_bg = true

		# TODO: Optional Higher Physics Rate from 60 to 90
		## Engine.physics_ticks_per_second = 90
	else:
		print("OpenXR not initialized, please check headset connection.")

func _process(delta: float) -> void:
	pass
