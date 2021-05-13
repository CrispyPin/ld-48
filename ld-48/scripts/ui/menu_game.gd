extends Control


export var pause_game = true


func _on_ResumeButton_pressed() -> void:
    UI.set_menu()

func _on_SettingsButton_pressed() -> void:
    UI.set_menu("Settings")

func _on_ExitButton_pressed() -> void:
    UI.stop_game()
