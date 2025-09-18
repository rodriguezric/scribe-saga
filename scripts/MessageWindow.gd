extends Panel

signal continue_available(available: bool)

@export var type_speed_chars_per_sec: float = 40.0
@export var entries: PackedStringArray = []

@onready var label: RichTextLabel = get_node_or_null("Margin/RichText") as RichTextLabel
@onready var prompt: Label = get_node_or_null("Prompt") as Label
@onready var sfx: AudioStreamPlayer = get_node_or_null("TypeSFX") as AudioStreamPlayer

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
var _line_height: float = 0.0
var _max_lines: int = 2
var _max_content_height: float = 0.0
var _static_prefix: String = ""

func _ready() -> void:
    visible = false
    _ensure_refs()
    if prompt:
        prompt.visible = false
    # Ensure the label doesn't expand beyond our window; we'll clip to area
    if label:
        label.fit_content = false
    # Compute approx height of two lines for pagination cutoff
    _recalc_line_height()

func _ensure_refs() -> void:
    # In some instancing cases, @onready lookups may fail; resolve dynamically
    if label == null:
        label = get_node_or_null("Margin/RichText") as RichTextLabel
        if label == null:
            label = find_child("RichText", true, false) as RichTextLabel
    if prompt == null:
        prompt = get_node_or_null("Prompt") as Label
        if prompt == null:
            prompt = find_child("Prompt", true, false) as Label
    if sfx == null:
        sfx = get_node_or_null("TypeSFX") as AudioStreamPlayer
        if sfx == null:
            sfx = find_child("TypeSFX", true, false) as AudioStreamPlayer

func _recalc_line_height() -> void:
    var line_h: float = 0.0
    if label:
        var fnt: Font = label.get_theme_font("normal_font")
        var fsz: int = label.get_theme_font_size("normal_font_size")
        if fnt:
            line_h = fnt.get_height(fsz)
    _line_height = line_h
    _max_content_height = _line_height * float(_max_lines) + 2.0

    # Do not start automatically; await explicit start_with() call

func _process(delta: float) -> void:
    if label == null or prompt == null:
        return
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
                if label.get_content_height() > _max_content_height:
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
                    continue_available.emit(true)
                    break

            if revealed_non_ws and not sfx.playing:
                sfx.play()

            if _visible_chars >= _total_chars and not _page_done:
                _typing = false
                _page_done = true
                prompt.visible = true
                _blink_elapsed = 0.0
                continue_available.emit(true)
    elif _page_done:
        # Blink the prompt when done
        _blink_elapsed += delta
        if _blink_elapsed >= 0.5:
            _blink_elapsed = 0.0
            prompt.visible = not prompt.visible

## Enter key handling removed; use Continue button instead.

func start_with(new_entries: PackedStringArray) -> void:
    _ensure_refs()
    _max_lines = 2
    _recalc_line_height()
    entries = new_entries
    _entry_index = 0
    _entry_char_index = 0
    _all_done = false
    _static_prefix = ""
    visible = true
    _load_entry(0)
    _start_next_page()

func start_with_title(title: String, new_entries: PackedStringArray) -> void:
    _ensure_refs()
    _max_lines = 3
    _recalc_line_height()
    _static_prefix = title.strip_edges() + "\n"
    entries = new_entries
    _entry_index = 0
    _entry_char_index = 0
    _all_done = false
    visible = true
    _load_entry(0)
    _start_next_page()

func _load_entry(index: int) -> void:
    _entry_index = index
    # Prepare entry and clear window
    _entry_text = _normalize_whitespace(entries[_entry_index])
    _entry_char_index = 0
    if label:
        label.text = ""
        label.visible_characters = 0
    _visible_chars = 0
    _total_chars = 0

func _start_next_page() -> void:
    # Start typing from current position within the entry; show only the remaining text
    var remaining_text: String = _entry_text.substr(_entry_char_index)
    # If starting this page with whitespace, skip it so pages don't begin with spaces
    var skip: int = 0
    while skip < remaining_text.length():
        var ch: String = remaining_text.substr(skip, 1)
        if ch == " " or ch == "\n" or ch == "\t":
            skip += 1
        else:
            break
    if skip > 0:
        _entry_char_index += skip
        remaining_text = remaining_text.substr(skip)
    if label:
        label.text = _static_prefix + remaining_text
        label.visible_characters = _static_prefix.length()
        _visible_chars = label.visible_characters
        _total_chars = label.get_total_character_count()
    else:
        _visible_chars = 0
        _total_chars = 0
    _typing = true
    _page_done = false
    if prompt:
        prompt.visible = false
    continue_available.emit(false)

func _find_prev_whitespace(from_index: int) -> int:
    if label == null:
        return -1
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
            continue_available.emit(true)
    else:
        _entry_char_index += _visible_chars
        _start_next_page()

func has_more() -> bool:
    var at_end_of_entry: bool = (_entry_char_index + _visible_chars) >= _entry_text.length()
    var at_last_entry: bool = (_entry_index + 1) >= entries.size()
    return not (at_end_of_entry and at_last_entry)

func advance() -> void:
    if _page_done:
        _advance_or_next_entry()
