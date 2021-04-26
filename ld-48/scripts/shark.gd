extends RigidBody

export var speed = 10
var target_dir = Vector3(0,-1,1)
var time = 0

func _ready() -> void:
    pass

func _physics_process(delta):
    #add_force(target_dir * speed * delta, Vector3())
    linear_velocity = target_dir*speed
    $shark.look_at(transform.origin - linear_velocity, Vector3.UP)
    $CollisionShape.look_at(transform.origin - linear_velocity, Vector3.UP)
    #time += delta
    #$shark.rotation_degrees.y = sin(time*10)*30

func _process(delta: float) -> void:
    pass

func _on_Shark_body_entered(body: Node) -> void:
    #target_dir = (Vector3(randf(), randf(), randf()) - Vector3(1,1,1)*0.5).normalized()
    target_dir = -target_dir + (Vector3(randf(), randf(), randf()) - Vector3(1,1,1)*0.5).normalized()*0.4
    target_dir = target_dir.normalized()
