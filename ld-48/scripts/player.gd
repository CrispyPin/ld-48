extends RigidBody

export var sensitivity_h = 1.0
export var sensitivity_v = 1.0
export var zoom_factor = 1.5
export var zoom_min = 5
export var zoom_max = 50
export var speed = 50

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		$CameraRoot.rotate_y(-event.relative.x * sensitivity_h * 0.01)
		var angle_v = event.relative.y * sensitivity_v * 0.01
		angle_v = min(PI * 0.5 - $CameraRoot.rotation.x, angle_v)
		angle_v = max(PI *-0.5 - $CameraRoot.rotation.x, angle_v)
		$CameraRoot.rotate_object_local(Vector3(1,0,0), angle_v)

func _process(_delta):
	handle_zoom()

func _physics_process(_delta):
	var dir = Vector3()
	if Input.is_action_pressed("move_forward"):
		dir += $CameraRoot.transform.basis.z
	if Input.is_action_pressed("move_back"):
		dir -= $CameraRoot.transform.basis.z
	if Input.is_action_pressed("move_right"):
		dir -= $CameraRoot.transform.basis.x
	if Input.is_action_pressed("move_left"):
		dir += $CameraRoot.transform.basis.x

	dir = dir.normalized()
	add_force(dir*speed,Vector3())

	var shark_rot = (-linear_velocity + -$shark.transform.basis.z*10)/11
	$shark.transform = $shark.transform.looking_at(shark_rot, Vector3(0,1,0))




func handle_zoom():
	if Input.is_action_just_released("zoom_in"):
		if -$CameraRoot/Camera.transform.origin.z > zoom_min:
			$CameraRoot/Camera.transform.origin /= zoom_factor
	elif Input.is_action_just_released("zoom_out"):
		if -$CameraRoot/Camera.transform.origin.z < zoom_max:
			$CameraRoot/Camera.transform.origin *= zoom_factor

