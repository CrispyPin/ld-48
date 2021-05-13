extends Node


export var instant_start = false
export var game_scene = preload("res://scenes/Game.tscn")

var current_menu = "Main"


func _ready():
    set_menu("Main")
    if instant_start:
        call_deferred("start_game")


func _process(_delta):
    if Input.is_key_pressed(KEY_F5):
        start_game()

    if Input.is_action_just_pressed("game_menu") and Global.game_loaded:
        if current_menu == "No":
            set_menu("Game")
            Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
        elif current_menu == "Game":
            set_menu()
            Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func start_game():
    if Global.game_loaded:
        return
    Global.game_loaded = true
    var game = game_scene.instance()
    get_tree().root.add_child(game)
    set_menu()
    $Menus/SettingsMenu.update_menu()


func stop_game():
    if !Global.game_loaded:
        return
    Global.game_loaded = false
    get_node("/root/Game/Boids")._exit_tree()
    get_node("/root/Game").queue_free()
    set_menu("Main")
    $Menus/SettingsMenu.update_menu()


func set_menu(menu_name := "No"):
    for m in $Menus.get_children():
        m.visible = m.name == menu_name + "Menu"
    current_menu = menu_name