extends RigidBody
class_name Boid

enum Type {T1,T2}



var type = -1
var steerTarget #dir to steer towards
var oldSteerTarget #new dir to steer towards

var closestPoint = null
var closestPD = null

var oldClosestPoint = null
var oldClosestPD = null

var isAlive = true

var fishShader = load("res://shaders/fish.shader")

export var models = [
        preload("res://models/fish/fish-1.tscn")
        ]

var rayCasts = []

var material = null

var numTypes=12.0

var model = null

func init(_type):
    reInit(_type)
    mode = MODE_STATIC

func reInit(_type):
    type = int(_type)

    if model != null:
        remove_child(model)

    var model = models[type%len(models)].instance()
    var mesh = model

    #Use when non-uniform scale is applied to mesh.
    #mesh.scale.x = 100*sin(type)
    #mesh.scale.z = 100*cos(type*1.2384388923848829399588)


    material = ShaderMaterial.new()
    material.set_shader(fishShader)
    #material.albedo_color = Color.from_hsv(type/numTypes, 0.5, 0.5)
    if type%3==0:
        material.set_shader_param ( "emission", Color.from_hsv(type/numTypes, 1, 1) )
        material.set_shader_param ( "pulse", true )


    #material.set_shader_param ( "color", Color.from_hsv(type/numTypes, 1, 1) * rand_range(0.6,1) )
    material.set_shader_param ( "color", Color.from_hsv(type/numTypes, 1, 1)  )
    #material.set_shader_param ( "offset", rand_range(0,100) )
    #material.set_shader_param ( "speed", material.get_shader_param( "speed" )*rand_range(0.9,1.1) )
    mesh.set_surface_material(0,material)

    mode = MODE_STATIC
    add_child(model)

func addMultiRayCast(except,diff):
    return
    #addRayCast(except,diff)
    #addRayCast(except,diff/2)
    addDirs(30)

func addRayCast(except,diff):
    var ray = RayCast.new()
    ray.cast_to = Vector3(0,-1,0) + diff
    ray.cast_to = ray.cast_to.normalized()
    ray.cast_to*=20
    add_child(ray)
    ray.enabled = true
    ray.exclude_parent = false
    #ray.transform = transform
    ray.collide_with_bodies=true
    ray.collide_with_areas=true

    rayCasts.append(ray)


func _ready():
    pass

func setActiveEnabled(b):
    for ray in rayCasts:
        ray.enabled = b

func addDirs(n):
    var goldenRatio = (1 + sqrt (5)) / 2
    var angleIncrement = PI * 2 * goldenRatio
    for i in range(0,n):
        var t = i / n
        var inclination = acos (1 - 2 * t)
        var azimuth = angleIncrement * i

        var x = sin (inclination) * cos (azimuth)
        var y = sin (inclination) * sin (azimuth)
        var z = cos (inclination)

        addRayCast(null,Vector3(x,y,z))

#func _process(delta):
#    for ray in rayCasts:
#        if ray.is_colliding():
#            print("collide")
