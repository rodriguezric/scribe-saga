extends Control

@onready var start_button: Button = $Center/VBox/StartButton
@onready var select_sfx: AudioStreamPlayer = $SelectSFX
@onready var fade_rect: ColorRect = $FadeRect

@export var fade_multiplier: float = 1.5
@export var min_fade: float = 0.8

func _ready() -> void:
    start_button.pressed.connect(_on_start_pressed)

func _on_start_pressed() -> void:
    start_button.disabled = true
    # Play select sound
    if is_instance_valid(select_sfx):
        if select_sfx.playing:
            select_sfx.stop()
        select_sfx.play()

    # Determine fade duration based on sfx length (fallback if unavailable)
    var duration: float = min_fade
    if is_instance_valid(select_sfx) and select_sfx.stream:
        var l: float = select_sfx.stream.get_length()
        if l > 0.0:
            duration = max(l * fade_multiplier, min_fade)

    # Fade to black, then switch scene
    fade_rect.modulate.a = 0.0
    var tween := create_tween()
    tween.tween_property(fade_rect, "modulate:a", 1.0, duration)
    await tween.finished
    get_tree().change_scene_to_file("res://scenes/Town.tscn")
