extends ARVROrigin


func _ready():
    var arvr_interface = ARVRServer.find_interface("OpenVR")
    var did_init = arvr_interface.initialize()
    if arvr_interface and did_init:
        pass

