extends Node


const DEBUG_SETTINGS = false
const SETTINGS_PATH = "user://settings.json"
const SETTINGS_DEF = {
    "fullscreen": {
        "name": "Fullscreen",
        "flags": [],
        "tooltip": "fullscreen",
        "type": "toggle",
        "default": false
    },
    "boid_count": {
        "name": "Fish amount: ",
        "flags": ["main_menu_only"],
        "tooltip": "Number of boids, high performance impact.",
        "type": "choice",
        "default": 1,
        "options": ["256", "512", "1024", "2048", "3072"]
    }
}

var game_loaded = false
var settings_loaded = false
var paused = false
var settings = {}


func _ready() -> void:
    _init_settings()
    load_settings()
    settings_loaded = true
    get_node("/root/Default").queue_free()


func set_setting(key, val):
    settings[key] = val
    if DEBUG_SETTINGS:
        print("Settings changed. ", key, ": ", val)
    save_settings()


func _init_settings():
    for key in SETTINGS_DEF:
        settings[key] = SETTINGS_DEF[key].default
    if DEBUG_SETTINGS:
        print("Default settings: ", settings)


func save_settings():
    var file = File.new()
    file.open(SETTINGS_PATH, File.WRITE)
    file.store_line(to_json(settings))
    file.close()
    OS.window_fullscreen = settings["fullscreen"]


func load_settings() -> void:
    var file = File.new()

    if not file.file_exists(SETTINGS_PATH):
        if DEBUG_SETTINGS:
            print("No settings file exists, using defaults")
        return

    file.open(SETTINGS_PATH, File.READ)
    var new_settings = parse_json(file.get_as_text())
    file.close()

    # in case settings format has changed, this is better than just copying
    for key in new_settings:
        if settings.has(key):
            settings[key] = new_settings[key]
    save_settings()
    if DEBUG_SETTINGS:
        print("Loaded settings from file")
        print(settings)
