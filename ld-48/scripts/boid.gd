extends KinematicBody
class_name Boid

enum Type {T1,T2}



var type = -1
var steerTarget #dir to steer towards
var oldSteerTarget #new dir to steer towards

export var models = [
        preload("res://models/fish/fish-1.fbx")
        ]

func init(_type):
    type = _type

    #var rng = RandomNumberGenerator.new()
    #rng.seed=type+1

    var model = models[type].instance()
    add_child(model)


func _ready():
	pass
