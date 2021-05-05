extends Spatial

signal button_down
signal button_up
signal toggled

export var push_dist = 0.05
export var button_height = 0.116
export var button_radius = 0.07
export var toggle = true

export var activate_level = 0.9
export var deactivate_level = 0.7

export var mat_on = preload("res://models/submarine/button_on.material")
export var mat_off = preload("res://models/submarine/button_off.material")

var pressed = false
var state = false
var _prev_pressed = false
var _prev_state = false

func _ready():
    $RayCast.cast_to = Vector3(0, button_height+0.01, 0)

func _physics_process(delta):
    _update_height(delta)

    if $Button.translation.y < activate_level * -push_dist and !pressed:
        pressed = true
        emit_signal("button_down")
    elif $Button.translation.y > deactivate_level * -push_dist and pressed:
        pressed = false
        emit_signal("button_up")

    if toggle:
        if pressed && !_prev_pressed:
            state = !state
            _update_mat()
            emit_signal("toggled", state)
        _prev_pressed = pressed
    else:
        state = pressed
        _update_mat()

func _update_mat():
    if state:
        $Button.set_surface_material(0, mat_on)
    else:
        $Button.set_surface_material(0, mat_off)

func _update_height(delta):
    if $Area.get_overlapping_bodies():
        var col_pos_global = $Area.get_overlapping_bodies()[0].global_transform.origin
        var col_pos = global_transform.xform_inv(col_pos_global)
        col_pos.y = 0
        if col_pos.length() > button_radius:
            var edge_pos : Vector3 = col_pos.normalized() * button_radius
            $RayCast.translation = edge_pos
        else:
            $RayCast.translation = col_pos

        $RayCast.force_raycast_update()
        var ray = $RayCast.get_collision_point() - global_transform.origin
        $Button.translation.y = clamp(ray.length() - button_height, -push_dist, 0)
    else:
        $Button.translate(Vector3(0,1,0) * delta)
        $Button.translation.y = min($Button.translation.y, 0)
