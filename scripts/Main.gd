extends Node

func _ready() -> void:
    print("Scribe Saga ready")

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        get_tree().quit()
