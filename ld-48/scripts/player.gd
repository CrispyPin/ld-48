extends Spatial

export var sensitivity_h = 1.0
export var sensitivity_v = 1.0


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		$CameraRoot.rotate_y(-event.relative.x * sensitivity_h * 0.01)
		var angle_v = event.relative.y * sensitivity_v * 0.01
		angle_v = min(PI * 0.5 - $CameraRoot.rotation.x, angle_v)
		angle_v = max(PI *-0.5 - $CameraRoot.rotation.x, angle_v)
		$CameraRoot.rotate_object_local(Vector3(1,0,0), angle_v)

