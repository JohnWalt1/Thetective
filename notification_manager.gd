extends CanvasLayer

const NOTIFICATION_LIFETIME := 2.5
const FADE_IN_DURATION := 0.2
const FADE_OUT_DURATION := 0.4
const CORNER_MARGIN := 150.0
const ENTRY_SEPARATION := 8

var _container: VBoxContainer

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100  # tinggi, biar di atas UI lain termasuk minigame

	var root_control := Control.new()
	root_control.set_anchors_preset(Control.PRESET_FULL_RECT)
	root_control.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root_control)

	_container = VBoxContainer.new()
	_container.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, CORNER_MARGIN)
	_container.add_theme_constant_override("separation", ENTRY_SEPARATION)
	_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root_control.add_child(_container)

func show_notification(text: String, icon: Texture2D = null) -> void:
	var entry: PanelContainer = _build_entry(text, icon)
	_container.add_child(entry)

	entry.modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.tween_property(entry, "modulate:a", 1.0, FADE_IN_DURATION)
	tween.tween_interval(NOTIFICATION_LIFETIME)
	tween.tween_property(entry, "modulate:a", 0.0, FADE_OUT_DURATION)
	tween.tween_callback(entry.queue_free)

func _build_entry(text: String, icon: Texture2D) -> PanelContainer:
	var panel := PanelContainer.new()
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.12, 0.85)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(10)
	panel.add_theme_stylebox_override("panel", style)

	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 8)
	panel.add_child(hbox)

	if icon:
		var tex_rect := TextureRect.new()
		tex_rect.texture = icon
		tex_rect.custom_minimum_size = Vector2(28, 28)
		tex_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		tex_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		hbox.add_child(tex_rect)

	var label := Label.new()
	label.text = text
	label.add_theme_color_override("font_color", Color.WHITE)
	hbox.add_child(label)

	return panel
