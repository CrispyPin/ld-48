extends Control

func _ready() -> void:
    pass # Replace with function body.

func play():
    visible = false
    var game = load("res://scenes/game.tscn").instance()
    get_tree().get_root().add_child(game)
