extends Control

var playing = false

func _ready() -> void:
<<<<<<< HEAD
    pass#play()


func play():
    if playing:
        return
    playing = true
    visible = false
    var game = preload("res://scenes/game.tscn").instance()
    get_tree().get_root().add_child(game)

func _process(delta: float) -> void:
    if Input.is_action_just_pressed("quit"):
        get_tree().quit()
    if !playing:
        play()
    #if Input.is_action_just_pressed("move_forward"):
    #    play()
    #if Input.is_action_just_pressed("debug_on"):
    #    debug_on()
=======
	pass # Replace with function body.

func play():
	if playing:
		return
	playing = true
	visible = false
	var game = load("res://scenes/game.tscn").instance()
	get_tree().get_root().add_child(game)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("move_forward"):
		play()
	if Input.is_action_just_pressed("debug_on"):
		debug_on()
>>>>>>> 90f6859b73cbfa94d21e814e875f063f0c5dfd31

func debug_on():
	if !playing:
		return
	get_node("/root/Game/Player/CameraRoot/Camera").environment = preload("res://default_env.tres")
	get_node("/root/Game/Player/CollisionShape").disabled = true
