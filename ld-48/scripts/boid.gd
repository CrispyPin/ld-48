extends RigidBody
class_name Boid

enum Type {T1,T2}



var type = -1
var steerTarget #dir to steer towards
var oldSteerTarget #new dir to steer towards

export var models = [
        preload("res://models/fish/fish-1.fbx")
        ]

var rayCasts = []

func init(_type):
    type = _type

    #var rng = RandomNumberGenerator.new()
    #rng.seed=type+1

    var model = models[type].instance()
    mode = MODE_STATIC
    add_child(model)
    addRayCast(model,Vector3(0.5,0,-0.5))
    addRayCast(model,Vector3(0.5,0,0.5))
    addRayCast(model,Vector3(-0.5,0,-0.5))
    addRayCast(model,Vector3(-0.5,0,0.5))

func addMultiRayCast(except,diff):
    addRayCast(except,diff)
    addRayCast(except,diff*2)
    addRayCast(except,diff*4)

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

#func _process(delta):
#    for ray in rayCasts:
#        if ray.is_colliding():
#            print("collide")
