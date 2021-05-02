extends RigidBody

export var sensitivity_h = 1.0
export var sensitivity_v = 1.0
export var zoom_factor = 1.5
export var zoom_min = 6
export var zoom_max = 50
export var speed = 50
#export var speed = 500

var propspd = 0

var zoom_target = zoom_min
var first_person = false

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
    if event is InputEventMouseMotion:
        if first_person:
            var angle_h = -event.relative.x * sensitivity_h * 0.01
            angle_h = min(PI * 0.5 - $model/FirstPerson.rotation.y, angle_h)
            angle_h = max(PI * -0.5 - $model/FirstPerson.rotation.y, angle_h)
            $model/FirstPerson.rotate_y(angle_h)

            var angle_v = event.relative.y * sensitivity_v * 0.01
            angle_v = min(PI * 0.25 - $model/FirstPerson.rotation.x, angle_v)
            angle_v = max(PI *-0.5 - $model/FirstPerson.rotation.x, angle_v)
            $model/FirstPerson.rotate_object_local(Vector3(1,0,0), angle_v)
        else:
            $CameraRoot.rotate_y(-event.relative.x * sensitivity_h * 0.01)
            var angle_v = event.relative.y * sensitivity_v * 0.01
            angle_v = min(PI * 0.5 - $CameraRoot.rotation.x, angle_v)
            angle_v = max(PI *-0.5 - $CameraRoot.rotation.x, angle_v)
            $CameraRoot.rotate_object_local(Vector3(1,0,0), angle_v)

func _physics_process(delta):
    handle_zoom()

    move_vr(delta)
    ## VR controls:


    if first_person:
        move_fp(delta)
    else:
        move_3p(delta)

func move_fp(delta):
    var dir = Vector3()
    if Input.is_action_pressed("move_forward"):
        dir += $model.transform.basis.z
    if Input.is_action_pressed("move_back"):
        dir -= $model.transform.basis.z
    if Input.is_action_pressed("move_right"):
        dir -= $model.transform.basis.x
    if Input.is_action_pressed("move_left"):
        dir += $model.transform.basis.x
    if Input.is_action_pressed("move_up"):
        dir += Vector3(0, 1, 0)
    if Input.is_action_pressed("move_down"):
        dir += Vector3(0, -1, 0)
    dir = dir.normalized()
    add_force(dir * speed, Vector3())
    var facing = $model.transform.basis.z
    var new_facing = -facing.move_toward(dir, delta*speed/40)
    $model.transform = $model.transform.looking_at(new_facing, Vector3(0,1,0))

func move_vr(delta):
    var dir = Vector3()
    if Input.is_action_pressed("vr_forward"):
        dir += $model.transform.basis.z
    if Input.is_action_pressed("vr_back"):
        dir -= $model.transform.basis.z
    if Input.is_action_pressed("vr_left"):
        dir += $model.transform.basis.x
    if Input.is_action_pressed("vr_right"):
        dir -= $model.transform.basis.x
    if Input.is_action_pressed("vr_up"):
        dir += $model.transform.basis.y
    if Input.is_action_pressed("vr_down"):
        dir -= $model.transform.basis.y

    dir = dir.normalized()
    add_force(dir * speed, Vector3())
    var facing = $model.transform.basis.z
    var new_facing = -facing.move_toward(dir, delta*speed/40)
    $model.transform = $model.transform.looking_at(new_facing, Vector3(0,1,0))

func move_3p(delta):
    var dir = Vector3()

    if Input.is_action_pressed("move_forward"):
        dir += $CameraRoot.transform.basis.z
        dir = dir.rotated($CameraRoot.transform.basis.x,-0.2)
    if Input.is_action_pressed("move_back"):
        dir -= $CameraRoot.transform.basis.z
    if Input.is_action_pressed("move_right"):
        dir -= $CameraRoot.transform.basis.x
    if Input.is_action_pressed("move_left"):
        dir += $CameraRoot.transform.basis.x
    if Input.is_action_pressed("move_up"):
        dir += Vector3(0, 1, 0)
    if Input.is_action_pressed("move_down"):
        dir += Vector3(0, -1, 0)

    dir = dir.normalized()
    var current = $model.transform.basis.z
    var target = dir
    var interpolated = -current.move_toward(target, delta*speed/40)

    propspd = 2 * sign(propspd)
    if dir.length()>0:
        if current.dot(dir)>0:
            add_force(current * speed, Vector3())
            propspd = 15
        else:
            add_force(-current * speed * 10.0/15, Vector3())
            propspd = -10

    var currentUp = $model.transform.basis.y
    var targetUp = Vector3(0,1,0)
    var interpolatedUp = currentUp.move_toward(targetUp, delta*speed/40)

    $model/submarine/propeller.speedTarget = propspd
    $model/submarine/propeller.acceleration = speed/2

    #$model.transform = $model.transform.looking_at(interpolated, Vector3(0,1,0))
    $model.transform = $model.transform.looking_at(interpolated, interpolatedUp)



func handle_zoom():
    if Input.is_action_just_released("zoom_in"):
        zoom_target /= zoom_factor
    if Input.is_action_just_released("zoom_out"):
        zoom_target *= zoom_factor
    first_person = zoom_target < zoom_min
    zoom_target = clamp(zoom_target, zoom_min/zoom_factor, zoom_max)

    $CameraRoot/RayCast.cast_to = Vector3(0, 0, -zoom_target)
    $CameraRoot/RayCast.force_raycast_update()
    var ray_len = ($CameraRoot/RayCast.get_collision_point() - global_transform.origin).length()
    if ray_len > zoom_min:
        $CameraRoot/Camera.translation = Vector3(0, 0, -min(zoom_target, ray_len))

    $CameraRoot/Camera.current = !first_person
    $CameraRoot/Camera.visible = !first_person
    $model/FirstPerson/Camera.current = first_person
    $model/FirstPerson/Camera.visible = first_person
