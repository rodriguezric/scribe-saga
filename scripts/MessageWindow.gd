extends Panel

@export var type_speed_chars_per_sec: float = 40.0
@export var entries: PackedStringArray = [
    """
    In the ancient halls where stories are forged,
    ink flows like rivers and words shape the world.

    You are the Scribe — keeper of lore, binder of fates.
    Your quill carries the whisper of old gods and new dreams.
    """,
    """
    Tonight, a tale calls to be written.
    Will you answer?
    """
]

@onready var label: RichTextLabel = $Margin/RichText
@onready var prompt: Label = $Prompt
@onready var sfx: AudioStreamPlayer = $TypeSFX

var _elapsed: float = 0.0
var _visible_chars: int = 0
var _total_chars: int = 0
var _blink_elapsed: float = 0.0

var _typing: bool = true
var _page_done: bool = false
var _all_done: bool = false

var _entry_index: int = 0
var _entry_text: String = ""
var _entry_char_index: int = 0
var _two_line_height: float = 0.0

func _ready() -> void:
    prompt.visible = false
    # Ensure the label doesn't expand beyond our window; we'll clip to area
    label.fit_content = false
    # Compute approx height of two lines for pagination cutoff
    var fnt: Font = label.get_theme_font("normal_font")
    var fsz: int = label.get_theme_font_size("normal_font_size")
    var line_h: float = 0.0
    if fnt:
        line_h = fnt.get_height(fsz)
    _two_line_height = line_h * 2.0 + 2.0

    _load_entry(0)
    _start_next_page()

func _process(delta: float) -> void:
    if _typing and not _all_done:
        _elapsed += delta
        var inc: int = int(type_speed_chars_per_sec * _elapsed)
        if inc > 0:
            _elapsed = 0.0
            var revealed_non_ws: bool = false
            for i in inc:
                if _visible_chars >= _total_chars:
                    break
                _visible_chars += 1
                label.visible_characters = _visible_chars
                var ch: String = label.text.substr(_visible_chars - 1, 1)
                if ch != " " and ch != "\n" and ch != "\t":
                    revealed_non_ws = true
                # Check if we overflow two lines visually; if so, rollback last char and end page
                if label.get_content_height() > _two_line_height:
                    # Roll back to the previous whitespace to avoid breaking words
                    var cut: int = _find_prev_whitespace(_visible_chars)
                    if cut >= 0:
                        _visible_chars = cut
                    else:
                        _visible_chars = maxi(_visible_chars - 1, 0)
                    label.visible_characters = _visible_chars
                    _typing = false
                    _page_done = true
                    prompt.visible = true
                    _blink_elapsed = 0.0
                    break

            if revealed_non_ws and not sfx.playing:
                sfx.play()

            if _visible_chars >= _total_chars and not _page_done:
                _typing = false
                _page_done = true
                prompt.visible = true
                _blink_elapsed = 0.0
    elif _page_done:
        # Blink the prompt when done
        _blink_elapsed += delta
        if _blink_elapsed >= 0.5:
            _blink_elapsed = 0.0
            prompt.visible = not prompt.visible

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_ENTER or event.keycode == KEY_KP_ENTER:
            if _page_done:
                prompt.visible = false
                _advance_or_next_entry()
                get_viewport().set_input_as_handled()

func _load_entry(index: int) -> void:
    _entry_index = index
    # Prepare entry and clear window
    _entry_text = _normalize_whitespace(entries[_entry_index])
    _entry_char_index = 0
    label.text = ""
    label.visible_characters = 0
    _visible_chars = 0
    _total_chars = 0

func _start_next_page() -> void:
    # Start typing from current position within the entry; show only the remaining text
    var remaining_text: String = _entry_text.substr(_entry_char_index)
    label.text = remaining_text
    label.visible_characters = 0
    _visible_chars = 0
    _total_chars = label.get_total_character_count()
    _typing = true
    _page_done = false
    prompt.visible = false

func _find_prev_whitespace(from_index: int) -> int:
    var i: int = from_index
    while i > 0:
        var ch: String = label.text.substr(i - 1, 1)
        if ch == " " or ch == "\n" or ch == "\t":
            return i - 1
        i -= 1
    return -1

func _normalize_whitespace(text: String) -> String:
    var re: RegEx = RegEx.new()
    re.compile("\\s+")
    var s: String = re.sub(text, " ", true)
    return s.strip_edges()

func _advance_or_next_entry() -> void:
    # Advance within current entry or move to next entry; clear between entries
    if _entry_char_index + _visible_chars >= _entry_text.length():
        if _entry_index + 1 < entries.size():
            _load_entry(_entry_index + 1)
            _start_next_page()
        else:
            _all_done = true
            _typing = false
            _page_done = true
            prompt.visible = true
    else:
        _entry_char_index += _visible_chars
        _start_next_page()
