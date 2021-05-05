extends Spatial

export var y_on = -0.03

export var mat_on  = preload("res://shaders/button_on.material")
export var mat_off = preload("res://shaders/button_off.material")

var pressed = false

func _ready():
    pass

func _physics_process(_delta):
    if translation.y < y_on:
        pressed = true
    else:
        pressed = false

    if pressed:
        $Button.set_surface_material(0, mat_on)
    else:
        $Button.set_surface_material(0, mat_off)

func _integrate_forces(state):
    translation.y = clamp(translation.y, -0.05, 0)
