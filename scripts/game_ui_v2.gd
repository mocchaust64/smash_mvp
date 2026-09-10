extends CanvasLayer

signal play_latest
signal show_levels_requested
signal start_level_requested(index)
signal select_ammo_requested(kind)
signal pause_requested
signal resume_requested
signal restart_requested
signal next_requested
signal home_requested
signal toggle_sound_requested
signal toggle_music_requested

const AMMO_COLORS = [Color("f2a24b"), Color("8792a8"), Color("ff6a49"), Color("ad63ff")]
const AMMO_NAMES = ["WOOD", "STONE", "FIRE", "WILD"]
const AMMO_ICON_PATHS = [
	"res://assets/ui/wood.svg",
	"res://assets/ui/stone.svg",
	"res://assets/ui/fire.svg",
	"res://assets/ui/wild.svg"
]

var root: Control
var hud: Control
var level_label: Label
var balls_label: Label
var ammo_buttons: Array = []
var home_panel: Control
var sound_button: Button
var music_button: Button
var levels_panel: Control
var level_grid: GridContainer
var win_panel: Control
var win_title: Label
var win_stars: Label
var win_stats: Label
var lose_panel: Control
var pause_panel: Control
var toast_layer: Control

func setup():
	_build_ui()

func _build_ui():
	root = Control.new()
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_build_hud()
	_build_home()
	_build_levels()
	_build_win()
	_build_lose()
	_build_pause()

	toast_layer = Control.new()
	toast_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	toast_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(toast_layer)

func _build_hud():
	hud = Control.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(hud)

	var top = PanelContainer.new()
	top.position = Vector2(22,22)
	top.size = Vector2(676,104)
	top.add_theme_stylebox_override("panel", _style(Color(0.07,0.10,0.17,0.82),26))
	hud.add_child(top)
	var row = HBoxContainer.new()
	row.add_theme_constant_override("separation",12)
	top.add_child(row)

	level_label = Label.new()
	level_label.custom_minimum_size = Vector2(360,78)
	level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	level_label.add_theme_font_size_override("font_size",26)
	level_label.add_theme_color_override("font_color",Color.WHITE)
	row.add_child(level_label)

	balls_label = Label.new()
	balls_label.custom_minimum_size = Vector2(188,78)
	balls_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	balls_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	balls_label.add_theme_font_size_override("font_size",24)
	balls_label.add_theme_color_override("font_color",Color("ddecff"))
	row.add_child(balls_label)

	var pause_btn = _button("Ⅱ",Color("5d7392"),Vector2(82,72),30)
	pause_btn.pressed.connect(func(): pause_requested.emit())
	row.add_child(pause_btn)

	var hint = Label.new()
	hint.position = Vector2(90,1005)
	hint.size = Vector2(540,42)
	hint.text = "SELECT AMMO  •  TAP A SUPPORT"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size",19)
	hint.add_theme_color_override("font_color",Color("263850"))
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(hint)

	var ammo_bar = HBoxContainer.new()
	ammo_bar.position = Vector2(28,1055)
	ammo_bar.size = Vector2(664,164)
	ammo_bar.add_theme_constant_override("separation",12)
	hud.add_child(ammo_bar)
	for i in range(4):
		var b = Button.new()
		b.custom_minimum_size = Vector2(157,138)
		b.expand_icon = true
		var icon_res = load(AMMO_ICON_PATHS[i])
		if icon_res is Texture2D:
			b.icon = icon_res
		b.add_theme_font_size_override("font_size",18)
		b.add_theme_color_override("font_color",Color.WHITE)
		b.add_theme_color_override("font_disabled_color",Color(1,1,1,0.42))
		b.add_theme_stylebox_override("focus",StyleBoxEmpty.new())
		b.pressed.connect(_emit_select.bind(i))
		ammo_bar.add_child(b)
		ammo_buttons.append(b)

func _build_home():
	home_panel = _overlay(Color(0.02,0.04,0.08,0.14))
	root.add_child(home_panel)
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	home_panel.add_child(center)
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(570,710)
	card.add_theme_stylebox_override("panel",_style(Color(1.0,0.98,0.93,0.95),38))
	center.add_child(card)
	var box = VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation",18)
	card.add_child(box)

	var badge = Label.new()
	badge.text = "●   ●   ●"
	badge.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	badge.add_theme_font_size_override("font_size",40)
	badge.add_theme_color_override("font_color",Color("ffad43"))
	box.add_child(badge)
	var title = Label.new()
	title.text = "SMASH DROP"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size",58)
	title.add_theme_color_override("font_color",Color("21324d"))
	box.add_child(title)
	var sub = Label.new()
	sub.text = "SHOOT SMART • DROP THEM ALL"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size",20)
	sub.add_theme_color_override("font_color",Color("637088"))
	box.add_child(sub)
	var space = Control.new()
	space.custom_minimum_size = Vector2(1,32)
	box.add_child(space)
	var play = _button("PLAY",Color("ff983f"),Vector2(430,94),34)
	play.pressed.connect(func(): play_latest.emit())
	box.add_child(play)
	var levels = _button("LEVELS",Color("596f91"),Vector2(430,78),27)
	levels.pressed.connect(func(): show_levels_requested.emit())
	box.add_child(levels)
	var settings = HBoxContainer.new()
	settings.alignment = BoxContainer.ALIGNMENT_CENTER
	settings.add_theme_constant_override("separation",12)
	box.add_child(settings)
	sound_button = _button("SOUND ON",Color("8596ab"),Vector2(205,66),18)
	sound_button.pressed.connect(func(): toggle_sound_requested.emit())
	settings.add_child(sound_button)
	music_button = _button("MUSIC ON",Color("8596ab"),Vector2(205,66),18)
	music_button.pressed.connect(func(): toggle_music_requested.emit())
	settings.add_child(music_button)

func _build_levels():
	levels_panel = _overlay(Color(0.03,0.06,0.12,0.80))
	root.add_child(levels_panel)
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	levels_panel.add_child(center)
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(620,960)
	card.add_theme_stylebox_override("panel",_style(Color("fff8eb"),34))
	center.add_child(card)
	var v = VBoxContainer.new()
	v.add_theme_constant_override("separation",16)
	card.add_child(v)
	var title = Label.new()
	title.text = "CHOOSE LEVEL"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.custom_minimum_size = Vector2(580,76)
	title.add_theme_font_size_override("font_size",34)
	title.add_theme_color_override("font_color",Color("273750"))
	v.add_child(title)
	level_grid = GridContainer.new()
	level_grid.columns = 4
	level_grid.add_theme_constant_override("h_separation",12)
	level_grid.add_theme_constant_override("v_separation",12)
	v.add_child(level_grid)
	var back = _button("BACK",Color("667b97"),Vector2(520,72),22)
	back.pressed.connect(func(): home_requested.emit())
	v.add_child(back)

func _build_win():
	win_panel = _overlay(Color(0.02,0.04,0.08,0.72))
	root.add_child(win_panel)
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	win_panel.add_child(center)
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(570,610)
	card.add_theme_stylebox_override("panel",_style(Color("fff8ea"),36))
	center.add_child(card)
	var v = VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation",16)
	card.add_child(v)
	win_title = _label("LEVEL COMPLETE!",38,Color("273750"))
	v.add_child(win_title)
	win_stars = _label("★★★",64,Color("f7b43d"))
	v.add_child(win_stars)
	win_stats = _label("SHOTS 0",23,Color("66758c"))
	v.add_child(win_stats)
	var next = _button("NEXT LEVEL",Color("ff983f"),Vector2(430,84),27)
	next.pressed.connect(func(): next_requested.emit())
	v.add_child(next)
	var retry = _button("PLAY AGAIN",Color("627793"),Vector2(430,70),21)
	retry.pressed.connect(func(): restart_requested.emit())
	v.add_child(retry)
	var home = _button("HOME",Color("9aa7b7"),Vector2(430,64),19)
	home.pressed.connect(func(): home_requested.emit())
	v.add_child(home)

func _build_lose():
	lose_panel = _overlay(Color(0.02,0.04,0.08,0.72))
	root.add_child(lose_panel)
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lose_panel.add_child(center)
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(550,430)
	card.add_theme_stylebox_override("panel",_style(Color("fff8ee"),36))
	center.add_child(card)
	var v = VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation",18)
	card.add_child(v)
	v.add_child(_label("OUT OF AMMO",38,Color("d9524e")))
	v.add_child(_label("Try a smarter support shot.",21,Color("66758a")))
	var retry = _button("RETRY",Color("ff9344"),Vector2(420,82),27)
	retry.pressed.connect(func(): restart_requested.emit())
	v.add_child(retry)
	var home = _button("HOME",Color("788aa1"),Vector2(420,68),21)
	home.pressed.connect(func(): home_requested.emit())
	v.add_child(home)

func _build_pause():
	pause_panel = _overlay(Color(0.02,0.04,0.08,0.72))
	pause_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	root.add_child(pause_panel)
	var center = CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_panel.add_child(center)
	var card = PanelContainer.new()
	card.custom_minimum_size = Vector2(530,460)
	card.add_theme_stylebox_override("panel",_style(Color("fff8ee"),36))
	center.add_child(card)
	var v = VBoxContainer.new()
	v.alignment = BoxContainer.ALIGNMENT_CENTER
	v.add_theme_constant_override("separation",18)
	card.add_child(v)
	v.add_child(_label("PAUSED",42,Color("273750")))
	var resume = _button("RESUME",Color("ff983f"),Vector2(420,82),27)
	resume.pressed.connect(func(): resume_requested.emit())
	v.add_child(resume)
	var restart = _button("RESTART",Color("667b97"),Vector2(420,70),21)
	restart.pressed.connect(func(): restart_requested.emit())
	v.add_child(restart)
	var home = _button("HOME",Color("9aa7b7"),Vector2(420,64),19)
	home.pressed.connect(func(): home_requested.emit())
	v.add_child(home)

func _emit_select(kind):
	select_ammo_requested.emit(kind)

func show_home(sound_on,music_on):
	_show_only(home_panel)
	sound_button.text = "SOUND ON" if sound_on else "SOUND OFF"
	music_button.text = "MUSIC ON" if music_on else "MUSIC OFF"

func show_levels(max_unlocked,stars_by_level):
	for child in level_grid.get_children():
		child.queue_free()
	for i in range(20):
		var unlocked = i < max_unlocked
		var text = str(i+1)
		if unlocked and stars_by_level[i] > 0:
			text += "\n" + "★".repeat(stars_by_level[i])
		elif not unlocked:
			text = "LOCK"
		var b = _button(text,Color("ff9b42") if unlocked else Color("aeb6c1"),Vector2(132,120),22)
		b.disabled = not unlocked
		if unlocked:
			b.pressed.connect(_emit_level.bind(i))
		level_grid.add_child(b)
	_show_only(levels_panel)

func _emit_level(index):
	start_level_requested.emit(index)

func show_hud(level_index,title,cleared,total,ammo,selected):
	level_label.text = "LEVEL %d  •  %s" % [level_index+1,title]
	balls_label.text = "BALLS  %d/%d" % [cleared,total]
	update_ammo(ammo,selected)
	_show_only(hud)

func update_hud(cleared,total,ammo,selected):
	balls_label.text = "BALLS  %d/%d" % [cleared,total]
	update_ammo(ammo,selected)

func update_ammo(ammo,selected):
	for i in range(4):
		var b: Button = ammo_buttons[i]
		b.text = AMMO_NAMES[i] + "\n×" + str(ammo[i])
		var c = AMMO_COLORS[i]
		if i == selected:
			b.add_theme_stylebox_override("normal",_outline_style(c.lightened(0.06),Color.WHITE,4))
		else:
			b.add_theme_stylebox_override("normal",_style(c if ammo[i] > 0 else c.darkened(0.42),24))
		b.add_theme_stylebox_override("hover",_style(c.lightened(0.08),24))
		b.add_theme_stylebox_override("pressed",_style(c.darkened(0.08),24))
		b.disabled = ammo[i] <= 0

func show_win(level_index,star_count,shots,par):
	win_title.text = "LEVEL %d COMPLETE!" % [level_index+1]
	win_stars.text = "★".repeat(star_count) + "☆".repeat(3-star_count)
	win_stats.text = "SHOTS  %d   •   TARGET  %d" % [shots,par]
	win_panel.visible = true
	_spawn_confetti()

func show_lose():
	lose_panel.visible = true

func show_pause():
	pause_panel.visible = true

func hide_pause():
	pause_panel.visible = false

func show_toast(text,color,duration=0.9):
	var label = Label.new()
	label.text = text
	label.position = Vector2(150,210)
	label.size = Vector2(420,82)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size",31)
	label.add_theme_color_override("font_color",Color.WHITE)
	label.add_theme_stylebox_override("normal",_style(Color(color.r,color.g,color.b,0.94),24))
	toast_layer.add_child(label)
	label.scale = Vector2(0.75,0.75)
	label.pivot_offset = label.size*0.5
	var tw = create_tween()
	tw.tween_property(label,"scale",Vector2.ONE,0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_interval(duration)
	tw.tween_property(label,"modulate:a",0.0,0.18)
	tw.tween_callback(label.queue_free)

func _spawn_confetti():
	for i in range(30):
		var bit = ColorRect.new()
		bit.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bit.size = Vector2(randf_range(7,13),randf_range(14,24))
		bit.position = Vector2(randf_range(20,700),randf_range(-70,30))
		bit.color = [Color("ff8b4a"),Color("ffcf4a"),Color("58c7ff"),Color("9f63ff"),Color("63d48d")][randi()%5]
		toast_layer.add_child(bit)
		var tw = create_tween()
		tw.set_parallel(true)
		tw.tween_property(bit,"position",bit.position+Vector2(randf_range(-70,70),randf_range(700,1050)),randf_range(1.3,2.0))
		tw.tween_property(bit,"rotation",randf_range(3.0,7.0),randf_range(1.3,2.0))
		tw.set_parallel(false)
		tw.tween_callback(bit.queue_free)

func _show_only(panel):
	hud.visible = panel == hud
	home_panel.visible = panel == home_panel
	levels_panel.visible = panel == levels_panel
	win_panel.visible = panel == win_panel
	lose_panel.visible = panel == lose_panel
	pause_panel.visible = panel == pause_panel

func _overlay(color):
	var p = PanelContainer.new()
	p.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	p.add_theme_stylebox_override("panel",_style(color,0))
	return p

func _label(text,font_size,color):
	var l = Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size",font_size)
	l.add_theme_color_override("font_color",color)
	return l

func _style(color,radius=20):
	var s = StyleBoxFlat.new()
	s.bg_color = color
	s.corner_radius_top_left = radius
	s.corner_radius_top_right = radius
	s.corner_radius_bottom_left = radius
	s.corner_radius_bottom_right = radius
	s.shadow_color = Color(0,0,0,0.16)
	s.shadow_size = 8 if radius > 0 else 0
	s.content_margin_left = 18
	s.content_margin_right = 18
	s.content_margin_top = 11
	s.content_margin_bottom = 11
	return s

func _outline_style(color,border,width):
	var s = _style(color,24)
	s.border_width_left = width
	s.border_width_right = width
	s.border_width_top = width
	s.border_width_bottom = width
	s.border_color = border
	return s

func _button(text,color,min_size,font_size):
	var b = Button.new()
	b.text = text
	b.custom_minimum_size = min_size
	b.add_theme_font_size_override("font_size",font_size)
	b.add_theme_color_override("font_color",Color.WHITE)
	b.add_theme_color_override("font_hover_color",Color.WHITE)
	b.add_theme_color_override("font_pressed_color",Color.WHITE)
	b.add_theme_stylebox_override("normal",_style(color,24))
	b.add_theme_stylebox_override("hover",_style(color.lightened(0.08),24))
	b.add_theme_stylebox_override("pressed",_style(color.darkened(0.07),24))
	b.add_theme_stylebox_override("focus",StyleBoxEmpty.new())
	return b
