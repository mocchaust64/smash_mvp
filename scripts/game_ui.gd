extends CanvasLayer
class_name SmashGameUI

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
const AMMO_ICONS = [
	preload("res://assets/ui/wood.svg"),
	preload("res://assets/ui/stone.svg"),
	preload("res://assets/ui/fire.svg"),
	preload("res://assets/ui/wild.svg")
]

var hud
var level_label
var balls_label
var ammo_buttons = []
var home_panel
var sound_button
var music_button
var levels_panel
var level_grid
var win_panel
var win_title
var win_stars
var win_stats
var lose_panel
var pause_panel
var toast_layer

func setup():
	_build_ui()

func _build_ui():
	var root = Control.new()
	add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE

	hud = Control.new()
	root.add_child(hud)
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var top_card = PanelContainer.new()
	top_card.position = Vector2(22,22)
	top_card.size = Vector2(676,104)
	top_card.add_theme_stylebox_override("panel",style(Color(0.08,0.11,0.18,0.74),26))
	hud.add_child(top_card)
	var top_h = HBoxContainer.new()
	top_h.add_theme_constant_override("separation",14)
	top_card.add_child(top_h)
	level_label = Label.new()
	level_label.custom_minimum_size = Vector2(300,78)
	level_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	level_label.add_theme_font_size_override("font_size",28)
	level_label.add_theme_color_override("font_color",Color.WHITE)
	top_h.add_child(level_label)
	balls_label = Label.new()
	balls_label.custom_minimum_size = Vector2(210,78)
	balls_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	balls_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	balls_label.add_theme_font_size_override("font_size",25)
	balls_label.add_theme_color_override("font_color",Color("d8ecff"))
	top_h.add_child(balls_label)
	var pause_button = make_button("Ⅱ",Color("536782"),Vector2(84,72),30)
	pause_button.pressed.connect(func(): pause_requested.emit())
	top_h.add_child(pause_button)

	var hint = Label.new()
	hint.position = Vector2(80,1008)
	hint.size = Vector2(560,46)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size",20)
	hint.add_theme_color_override("font_color",Color("25314a"))
	hint.text = "SELECT AMMO • TAP A BLOCK"
	hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(hint)

	var ammo_bar = HBoxContainer.new()
	ammo_bar.position = Vector2(28,1060)
	ammo_bar.size = Vector2(664,160)
	ammo_bar.add_theme_constant_override("separation",12)
	hud.add_child(ammo_bar)
	for i in range(4):
		var button = Button.new()
		button.custom_minimum_size = Vector2(157,132)
		button.icon = AMMO_ICONS[i]
		button.expand_icon = true
		button.icon_max_width = 40
		button.add_theme_font_size_override("font_size",19)
		button.add_theme_color_override("font_color",Color.WHITE)
		button.add_theme_color_override("font_hover_color",Color.WHITE)
		button.add_theme_color_override("font_pressed_color",Color.WHITE)
		button.add_theme_stylebox_override("focus",StyleBoxEmpty.new())
		button.pressed.connect(_emit_select.bind(i))
		ammo_bar.add_child(button)
		ammo_buttons.append(button)

	home_panel = full_overlay(Color(0,0,0,0.06))
	root.add_child(home_panel)
	var home_center = CenterContainer.new()
	home_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	home_panel.add_child(home_center)
	var home_box = VBoxContainer.new()
	home_box.custom_minimum_size = Vector2(520,620)
	home_box.alignment = BoxContainer.ALIGNMENT_CENTER
	home_box.add_theme_constant_override("separation",20)
	home_center.add_child(home_box)
	var dots = Label.new()
	dots.text = "●  ●  ●"
	dots.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dots.add_theme_font_size_override("font_size",42)
	dots.add_theme_color_override("font_color",Color("ffb345"))
	home_box.add_child(dots)
	var title = Label.new()
	title.text = "SMASH DROP"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size",60)
	title.add_theme_color_override("font_color",Color("20304b"))
	home_box.add_child(title)
	var sub = Label.new()
	sub.text = "SHOOT SMART • DROP THEM ALL"
	sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sub.add_theme_font_size_override("font_size",21)
	sub.add_theme_color_override("font_color",Color("52617b"))
	home_box.add_child(sub)
	var spacer = Control.new()
	spacer.custom_minimum_size = Vector2(1,44)
	home_box.add_child(spacer)
	var play_button = make_button("PLAY",Color("ff9d3d"),Vector2(430,92),34)
	play_button.pressed.connect(func(): play_latest.emit())
	home_box.add_child(play_button)
	var levels_button = make_button("LEVELS",Color("586f91"),Vector2(430,80),28)
	levels_button.pressed.connect(func(): show_levels_requested.emit())
	home_box.add_child(levels_button)
	var settings_row = HBoxContainer.new()
	settings_row.alignment = BoxContainer.ALIGNMENT_CENTER
	settings_row.add_theme_constant_override("separation",14)
	home_box.add_child(settings_row)
	sound_button = make_button("SOUND ON",Color("7d91ad"),Vector2(205,68),20)
	sound_button.pressed.connect(func(): toggle_sound_requested.emit())
	settings_row.add_child(sound_button)
	music_button = make_button("MUSIC ON",Color("7d91ad"),Vector2(205,68),20)
	music_button.pressed.connect(func(): toggle_music_requested.emit())
	settings_row.add_child(music_button)

	levels_panel = full_overlay(Color(0.08,0.11,0.18,0.82))
	root.add_child(levels_panel)
	var levels_center = CenterContainer.new()
	levels_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	levels_panel.add_child(levels_center)
	var levels_card = PanelContainer.new()
	levels_card.custom_minimum_size = Vector2(620,950)
	levels_card.add_theme_stylebox_override("panel",style(Color("f7f2e8"),34))
	levels_center.add_child(levels_card)
	var levels_v = VBoxContainer.new()
	levels_v.add_theme_constant_override("separation",18)
	levels_card.add_child(levels_v)
	var levels_title = Label.new()
	levels_title.text = "CHOOSE LEVEL"
	levels_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	levels_title.custom_minimum_size = Vector2(580,84)
	levels_title.add_theme_font_size_override("font_size",36)
	levels_title.add_theme_color_override("font_color",Color("263650"))
	levels_v.add_child(levels_title)
	level_grid = GridContainer.new()
	level_grid.columns = 4
	level_grid.add_theme_constant_override("h_separation",12)
	level_grid.add_theme_constant_override("v_separation",12)
	levels_v.add_child(level_grid)
	var back_button = make_button("BACK",Color("596c86"),Vector2(520,76),24)
	back_button.pressed.connect(func(): home_requested.emit())
	levels_v.add_child(back_button)

	win_panel = full_overlay(Color(0.04,0.06,0.1,0.72))
	root.add_child(win_panel)
	var win_center = CenterContainer.new()
	win_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	win_panel.add_child(win_center)
	var win_card = PanelContainer.new()
	win_card.custom_minimum_size = Vector2(570,620)
	win_card.add_theme_stylebox_override("panel",style(Color("fff8e9"),36))
	win_center.add_child(win_card)
	var win_v = VBoxContainer.new()
	win_v.alignment = BoxContainer.ALIGNMENT_CENTER
	win_v.add_theme_constant_override("separation",16)
	win_card.add_child(win_v)
	win_title = Label.new()
	win_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_title.add_theme_font_size_override("font_size",38)
	win_title.add_theme_color_override("font_color",Color("263650"))
	win_v.add_child(win_title)
	win_stars = Label.new()
	win_stars.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_stars.add_theme_font_size_override("font_size",66)
	win_stars.add_theme_color_override("font_color",Color("f8b63f"))
	win_v.add_child(win_stars)
	win_stats = Label.new()
	win_stats.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	win_stats.add_theme_font_size_override("font_size",24)
	win_stats.add_theme_color_override("font_color",Color("607089"))
	win_v.add_child(win_stats)
	var next_button = make_button("NEXT LEVEL",Color("ff9d3d"),Vector2(430,86),28)
	next_button.pressed.connect(func(): next_requested.emit())
	win_v.add_child(next_button)
	var replay_button = make_button("PLAY AGAIN",Color("637791"),Vector2(430,72),22)
	replay_button.pressed.connect(func(): restart_requested.emit())
	win_v.add_child(replay_button)
	var win_home = make_button("HOME",Color("9aa8b8"),Vector2(430,66),20)
	win_home.pressed.connect(func(): home_requested.emit())
	win_v.add_child(win_home)

	lose_panel = full_overlay(Color(0.04,0.06,0.1,0.72))
	root.add_child(lose_panel)
	var lose_center = CenterContainer.new()
	lose_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	lose_panel.add_child(lose_center)
	var lose_card = PanelContainer.new()
	lose_card.custom_minimum_size = Vector2(550,430)
	lose_card.add_theme_stylebox_override("panel",style(Color("fff8ef"),36))
	lose_center.add_child(lose_card)
	var lose_v = VBoxContainer.new()
	lose_v.alignment = BoxContainer.ALIGNMENT_CENTER
	lose_v.add_theme_constant_override("separation",18)
	lose_card.add_child(lose_v)
	var lose_title = Label.new()
	lose_title.text = "OUT OF AMMO"
	lose_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lose_title.add_theme_font_size_override("font_size",38)
	lose_title.add_theme_color_override("font_color",Color("d44f4a"))
	lose_v.add_child(lose_title)
	var lose_sub = Label.new()
	lose_sub.text = "Try a smarter support shot."
	lose_sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lose_sub.add_theme_font_size_override("font_size",22)
	lose_sub.add_theme_color_override("font_color",Color("637086"))
	lose_v.add_child(lose_sub)
	var retry_button = make_button("RETRY",Color("ff9344"),Vector2(420,82),28)
	retry_button.pressed.connect(func(): restart_requested.emit())
	lose_v.add_child(retry_button)
	var lose_home = make_button("HOME",Color("7689a2"),Vector2(420,68),22)
	lose_home.pressed.connect(func(): home_requested.emit())
	lose_v.add_child(lose_home)

	pause_panel = full_overlay(Color(0.04,0.06,0.1,0.72))
	pause_panel.process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	root.add_child(pause_panel)
	var pause_center = CenterContainer.new()
	pause_center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_panel.add_child(pause_center)
	var pause_card = PanelContainer.new()
	pause_card.custom_minimum_size = Vector2(530,460)
	pause_card.add_theme_stylebox_override("panel",style(Color("fff8ef"),36))
	pause_center.add_child(pause_card)
	var pause_v = VBoxContainer.new()
	pause_v.alignment = BoxContainer.ALIGNMENT_CENTER
	pause_v.add_theme_constant_override("separation",18)
	pause_card.add_child(pause_v)
	var pause_title = Label.new()
	pause_title.text = "PAUSED"
	pause_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	pause_title.add_theme_font_size_override("font_size",42)
	pause_title.add_theme_color_override("font_color",Color("263650"))
	pause_v.add_child(pause_title)
	var resume_button = make_button("RESUME",Color("ff9d3d"),Vector2(420,82),28)
	resume_button.pressed.connect(func(): resume_requested.emit())
	pause_v.add_child(resume_button)
	var pause_retry = make_button("RESTART",Color("657991"),Vector2(420,72),22)
	pause_retry.pressed.connect(func(): restart_requested.emit())
	pause_v.add_child(pause_retry)
	var pause_home = make_button("HOME",Color("9aa8b8"),Vector2(420,66),20)
	pause_home.pressed.connect(func(): home_requested.emit())
	pause_v.add_child(pause_home)

	toast_layer = Control.new()
	toast_layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	toast_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(toast_layer)

func _emit_select(kind):
	select_ammo_requested.emit(kind)

func show_home(sound_enabled,music_enabled=true):
	show_only(home_panel)
	sound_button.text = "SOUND ON" if sound_enabled else "SOUND OFF"
	music_button.text = "MUSIC ON" if music_enabled else "MUSIC OFF"

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
		var color = Color("ff9d3d") if unlocked else Color("aeb6c1")
		var b = make_button(text,color,Vector2(132,120),23)
		b.disabled = not unlocked
		if unlocked:
			b.pressed.connect(_emit_level.bind(i))
		level_grid.add_child(b)
	show_only(levels_panel)

func _emit_level(index):
	start_level_requested.emit(index)

func show_hud(level_index,title,cleared,total,ammo,selected):
	level_label.text = "LEVEL %d  •  %s" % [level_index+1,title]
	balls_label.text = "BALLS  %d/%d" % [cleared,total]
	update_ammo(ammo,selected)
	show_only(hud)

func update_hud(cleared,total,ammo,selected):
	balls_label.text = "BALLS  %d/%d" % [cleared,total]
	update_ammo(ammo,selected)

func update_ammo(ammo,selected):
	var names = ["WOOD","STONE","FIRE","WILD"]
	for i in range(4):
		var button = ammo_buttons[i]
		button.text = names[i] + "\n×" + str(ammo[i])
		var color = AMMO_COLORS[i]
		if i == selected:
			button.add_theme_stylebox_override("normal",outline_style(color.lightened(0.08),Color.WHITE,4))
		else:
			button.add_theme_stylebox_override("normal",style(color if ammo[i] > 0 else color.darkened(0.35),24))
		button.add_theme_stylebox_override("hover",style(color.lightened(0.08),24))
		button.add_theme_stylebox_override("pressed",style(color.darkened(0.08),24))
		button.disabled = ammo[i] <= 0

func show_win(level_index,star_count,shots,par):
	win_title.text = "LEVEL %d COMPLETE!" % [level_index+1]
	win_stars.text = "★".repeat(star_count) + "☆".repeat(3-star_count)
	win_stats.text = "SHOTS  %d   •   BEST TARGET  %d" % [shots,par]
	win_panel.visible = true
	spawn_confetti()

func show_lose():
	lose_panel.visible = true

func show_pause():
	pause_panel.visible = true

func hide_pause():
	pause_panel.visible = false

func show_toast(text,color,duration=0.9):
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.position = Vector2(160,210)
	label.size = Vector2(400,84)
	label.add_theme_font_size_override("font_size",32)
	label.add_theme_color_override("font_color",Color.WHITE)
	label.add_theme_stylebox_override("normal",style(Color(color.r,color.g,color.b,0.92),24))
	toast_layer.add_child(label)
	label.scale = Vector2(0.72,0.72)
	label.pivot_offset = label.size*0.5
	var tween = create_tween()
	tween.tween_property(label,"scale",Vector2.ONE,0.14).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_interval(duration)
	tween.tween_property(label,"modulate:a",0.0,0.18)
	tween.tween_callback(label.queue_free)

func spawn_confetti():
	for i in range(36):
		var bit = ColorRect.new()
		bit.mouse_filter = Control.MOUSE_FILTER_IGNORE
		bit.size = Vector2(randf_range(8,15),randf_range(16,28))
		bit.position = Vector2(randf_range(20,700),randf_range(-80,40))
		bit.color = [Color("ff8b4a"),Color("ffcf4a"),Color("58c7ff"),Color("9f63ff"),Color("63d48d")][randi()%5]
		bit.rotation = randf_range(-1.5,1.5)
		toast_layer.add_child(bit)
		var end_pos = bit.position + Vector2(randf_range(-80,80),randf_range(650,1050))
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(bit,"position",end_pos,randf_range(1.4,2.2)).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		tween.tween_property(bit,"rotation",bit.rotation+randf_range(3,7),randf_range(1.4,2.2))
		tween.set_parallel(false)
		tween.tween_callback(bit.queue_free)

func show_only(panel):
	hud.visible = panel == hud
	home_panel.visible = panel == home_panel
	levels_panel.visible = panel == levels_panel
	win_panel.visible = panel == win_panel
	lose_panel.visible = panel == lose_panel
	pause_panel.visible = panel == pause_panel

func full_overlay(color):
	var panel = PanelContainer.new()
	panel.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	panel.add_theme_stylebox_override("panel",style(color,0))
	return panel

func style(color,radius=20):
	var s = StyleBoxFlat.new()
	s.bg_color = color
	s.corner_radius_top_left = radius
	s.corner_radius_top_right = radius
	s.corner_radius_bottom_left = radius
	s.corner_radius_bottom_right = radius
	s.shadow_color = Color(0,0,0,0.16)
	s.shadow_size = 8 if radius > 0 else 0
	s.content_margin_left = 20
	s.content_margin_right = 20
	s.content_margin_top = 12
	s.content_margin_bottom = 12
	return s

func outline_style(color,border_color,width):
	var s = style(color,24)
	s.border_width_left = width
	s.border_width_right = width
	s.border_width_top = width
	s.border_width_bottom = width
	s.border_color = border_color
	return s

func make_button(text,color,min_size,font_size):
	var b = Button.new()
	b.text = text
	b.custom_minimum_size = min_size
	b.add_theme_font_size_override("font_size",font_size)
	b.add_theme_color_override("font_color",Color.WHITE)
	b.add_theme_color_override("font_hover_color",Color.WHITE)
	b.add_theme_color_override("font_pressed_color",Color.WHITE)
	b.add_theme_stylebox_override("normal",style(color,24))
	b.add_theme_stylebox_override("hover",style(color.lightened(0.08),24))
	b.add_theme_stylebox_override("pressed",style(color.darkened(0.06),24))
	b.add_theme_stylebox_override("focus",StyleBoxEmpty.new())
	return b
