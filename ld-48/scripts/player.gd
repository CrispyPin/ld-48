extends RigidBody

export var energy_max = 100
export var energy = 100
export var energy_loss = 5
export var energy_gain = 5

export var sensitivity_h = 1.0
export var sensitivity_v = 1.0
export var zoom_factor = 1.5
export var zoom_min = 6
export var zoom_max = 50
export var speed = 50

var propspd = 0

var zoom_target = -zoom_min

func _ready():
    Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
    if event is InputEventMouseMotion:
        $CameraRoot.rotate_y(-event.relative.x * sensitivity_h * 0.01)
        var angle_v = event.relative.y * sensitivity_v * 0.01
        angle_v = min(PI * 0.5 - $CameraRoot.rotation.x, angle_v)
        angle_v = max(PI *-0.5 - $CameraRoot.rotation.x, angle_v)
        $CameraRoot.rotate_object_local(Vector3(1,0,0), angle_v)

func _process(delta):
    energy -= energy_loss * delta

func _physics_process(_delta):
    handle_zoom()
    var dir = Vector3()
    if Input.is_action_pressed("move_forward"):
        dir += $CameraRoot.transform.basis.z
    if Input.is_action_pressed("move_back"):
        dir -= $CameraRoot.transform.basis.z
    if Input.is_action_pressed("move_right"):
        dir -= $CameraRoot.transform.basis.x
    if Input.is_action_pressed("move_left"):
        dir += $CameraRoot.transform.basis.x
    if Input.is_action_pressed("move_up"):
        dir += $CameraRoot.transform.basis.y
        #dir += Vector3(0, 1, 0)
    if Input.is_action_pressed("move_down"):
        #dir += Vector3(0,-1, 0)
        dir -= $CameraRoot.transform.basis.y

    dir = dir.normalized()
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
    zoom_target = clamp(zoom_target, -zoom_max, -zoom_min)

    var space_state = get_world().direct_space_state
    var target_pos = $CameraRoot.transform.xform_inv(Vector3(0,0,-zoom_target))
    var ray = space_state.intersect_ray(global_transform.origin, target_pos, [self])
    if ray:
        #print(ray)
        var ray_len = (global_transform.origin - ray.position).length()
        $CameraRoot/Camera.translation = Vector3(0,0,1) * clamp(zoom_target, -ray_len, -zoom_min)
    else:
        $CameraRoot/Camera.translation = Vector3(0,0,1) * zoom_target
    #$RayCast.cast_to = $CameraRoot.transform.xform_inv(Vector3(0,0,-zoom_target))
    #if $RayCast.cast_to.length() > 0:
    #    $RayCast.force_raycast_update()
    #var ray_len = ($RayCast.get_collision_point() - $RayCast.translation).length()
    #if ray_len:
    #    $CameraRoot/Camera.translation = Vector3(0,0,1)* clamp(zoom_target, -ray_len, -zoom_min)



func _on_Player_body_entered(body: Node) -> void:
    if body.is_in_group("boids"):
        body.isAlive = false
        energy += energy_gain
