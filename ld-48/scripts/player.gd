extends RigidBody

export var sensitivity_h = 1.0
export var sensitivity_v = 1.0
export var zoom_factor = 1.5
export var zoom_min = 6
export var zoom_max = 100
export var speed = 50
#export var speed = 500

var propspd = 0

var zoom_target = zoom_min

var lights = true

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
    if event is InputEventMouseMotion:
        $CameraRoot.rotate_y(-event.relative.x * sensitivity_h * 0.01)
        var angle_v = event.relative.y * sensitivity_v * 0.01
        angle_v = min(PI * 0.5 - $CameraRoot.rotation.x, angle_v)
        angle_v = max(PI *-0.5 - $CameraRoot.rotation.x, angle_v)
        $CameraRoot.rotate_object_local(Vector3(1,0,0), angle_v)

func _process(delta: float) -> void:
    if Input.is_action_just_pressed("light"):
        lights = !lights
        $model/SpotLight.visible = lights
        $model/SpotLight2.visible = lights
        if lights:
            $model.set_surface_material(2, preload("res://models/submarine/light.material"))
        else:
            $model.set_surface_material(2, preload("res://models/submarine/light_off.material"))

func _physics_process(_delta):
    handle_zoom()
    var dir = Vector3()
    if Input.is_action_pressed("move_forward"):
        dir += $CameraRoot.transform.basis.z
        dir = dir.rotated($CameraRoot.transform.basis.x,-0.2)
        #dir = Vector3(0,1,0)
    if Input.is_action_pressed("move_back"):
        dir -= $CameraRoot.transform.basis.z
    if Input.is_action_pressed("move_right"):
        dir -= $CameraRoot.transform.basis.x
    if Input.is_action_pressed("move_left"):
        dir += $CameraRoot.transform.basis.x
    if Input.is_action_pressed("move_up"):
        #dir += $CameraRoot.transform.basis.y
        dir += Vector3(0, 1, 0)
    if Input.is_action_pressed("move_down"):
        dir += Vector3(0,-1, 0)
        #dir -= $CameraRoot.transform.basis.y

    dir = dir.normalized()
    #if dir.is_equal_approx(Vector3()):

    #add_force(dir*speed,Vector3())

    var current = $model.transform.basis.z
    var target = dir
    var interpolated = -current.move_toward(target,_delta*speed/40)


    #if current.dot(target)>0:
    #translation += dir

    propspd = 2 * sign(propspd)
    if dir.length()>0:
        #translation += current
        #add_force(dir * speed, Vector3())
        if current.dot(dir)>0:
            add_force(current * speed, Vector3())
            propspd = 15
        else:
            add_force(-current * speed * 10.0/15, Vector3())
            propspd = -10

    #add_force(current * speed * propspd/15, Vector3())
    var currentUp = $model.transform.basis.y
    #var targetUp = $model.transform.basis.x
    var targetUp = Vector3(0,1,0)
    var interpolatedUp = currentUp.move_toward(targetUp,_delta*speed/40)
    #var interpolatedUp = currentUp.move_toward(targetUp,_delta*speed/80*$model/propeller.current)

    $model/propeller.speedTarget = propspd
    $model/propeller.acceleration = speed/2

    #$model.transform = $model.transform.looking_at(interpolated, Vector3(0,1,0))
    $model.transform = $model.transform.looking_at(interpolated, interpolatedUp)

    if linear_velocity.length() > 0:
        pass
        #var shark_rot = (-linear_velocity + -$model.transform.basis.z)/2
        #$model.transform = $model.transform.looking_at(shark_rot, Vector3(0,1,0))
        #$model.transform = $model.transform.looking_at(interpolated, Vector3(0,1,0))


func handle_zoom():
    if Input.is_action_just_released("zoom_in"):
        zoom_target /= zoom_factor
    if Input.is_action_just_released("zoom_out"):
        zoom_target *= zoom_factor
    zoom_target = clamp(zoom_target, zoom_min, zoom_max)

    $CameraRoot/RayCast.cast_to = Vector3(0, 0, -zoom_target)
    $CameraRoot/RayCast.force_raycast_update()
    var ray_len = ($CameraRoot/RayCast.get_collision_point() - global_transform.origin).length()
    if ray_len > zoom_min:
        $CameraRoot/Camera.translation = Vector3(0, 0, -min(zoom_target, ray_len))
