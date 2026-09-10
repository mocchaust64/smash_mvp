extends Node3D

const WorldArtScript = preload("res://scripts/world_art.gd")
const UIScript = preload("res://scripts/game_ui_v2.gd")
const ProjectileScript = preload("res://scripts/projectile.gd")
const LevelData = preload("res://scripts/level_data.gd")
const AudioLabScript = preload("res://scripts/audio_lab.gd")

const WOOD = 0
const STONE = 1
const FIRE = 2
const WILD = 3
const AMMO_COLORS = [Color("f2a24b"), Color("8792a8"), Color("ff6a49"), Color("ad63ff")]

var state = "home"
var current_level = 0
var total_balls = 0
var cleared_balls = 0
var selected_ammo = WOOD
var ammo = [0,0,0,0]
var par_shots = 1
var shots_used = 0
var level_finished = false
var shot_locked = false
var chain_count = 0
var last_chain_time = 0.0
var max_unlocked = 1
var stars_by_level = []
var sound_enabled = true
var music_enabled = true
var world
var ui
var audio_lab

func _ready():
	randomize()
	for i in range(20):
		stars_by_level.append(0)
	_load_save()
	world = WorldArtScript.new()
	world.name = "WorldArt"
	add_child(world)
	world.setup(self)
	ui = UIScript.new()
	ui.name = "UI"
	add_child(ui)
	ui.setup()
	_connect_ui()
	audio_lab = AudioLabScript.new()
	add_child(audio_lab)
	audio_lab.setup(sound_enabled,music_enabled)
	world.apply_world_theme(0)
	_show_home()

func _connect_ui():
	ui.play_latest.connect(_play_latest)
	ui.show_levels_requested.connect(_show_levels)
	ui.start_level_requested.connect(_start_level)
	ui.select_ammo_requested.connect(_select_ammo)
	ui.pause_requested.connect(_pause_game)
	ui.resume_requested.connect(_resume_game)
	ui.restart_requested.connect(_restart_level)
	ui.next_requested.connect(_next_level)
	ui.home_requested.connect(_show_home)
	ui.toggle_sound_requested.connect(_toggle_sound)
	ui.toggle_music_requested.connect(_toggle_music)

func _unhandled_input(event):
	if state != "playing" or level_finished or shot_locked:
		return
	var screen_pos = null
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		screen_pos = event.position
	elif event is InputEventScreenTouch and event.pressed:
		screen_pos = event.position
	if screen_pos != null:
		_try_shoot(screen_pos)

func _start_level(index):
	if get_tree().paused:
		get_tree().paused = false
	current_level = clamp(index,0,19)
	state = "playing"
	level_finished = false
	shot_locked = false
	chain_count = 0
	shots_used = 0
	cleared_balls = 0
	world.clear_level()
	var data = LevelData.get_level(current_level)
	par_shots = int(data["par"])
	ammo = data["ammo"].duplicate()
	total_balls = data["balls"].size()
	selected_ammo = _first_available_ammo()
	world.cannon.set_ammo_color(AMMO_COLORS[selected_ammo])
	world.apply_world_theme(int(data["world"]))
	for item in data["blocks"]:
		world.spawn_block(item)
	for position in data["balls"]:
		world.spawn_ball(position)
	ui.show_hud(current_level,str(data["title"]),cleared_balls,total_balls,ammo,selected_ammo)
	await get_tree().process_frame
	world.sleep_stack()
	if current_level == 0:
		ui.show_toast("TAP WOOD • SHOOT THE CENTER SUPPORT",Color("ff9d3d"),2.5)

func _try_shoot(screen_pos):
	if ammo[selected_ammo] <= 0:
		_play_sfx("wrong",-4)
		ui.show_toast("NO AMMO",Color("d94f4f"),0.8)
		return
	var origin = world.camera.project_ray_origin(screen_pos)
	var end = origin + world.camera.project_ray_normal(screen_pos)*80.0
	var query = PhysicsRayQueryParameters3D.create(origin,end)
	query.collision_mask = 1
	query.collide_with_areas = false
	var hit = world.camera.get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return
	var target = hit["collider"]
	if not target.has_method("shoot"):
		return
	shot_locked = true
	shots_used += 1
	ammo[selected_ammo] -= 1
	ui.update_hud(cleared_balls,total_balls,ammo,selected_ammo)
	world.cannon.aim_at(hit["position"])
	world.cannon.kick()
	_play_sfx("shoot",-4)
	world.spawn_muzzle_flash(world.cannon.get_muzzle_position(),AMMO_COLORS[selected_ammo])
	var projectile = ProjectileScript.new()
	world.fx_root.add_child(projectile)
	projectile.launch(world.cannon.get_muzzle_position(),hit["position"],AMMO_COLORS[selected_ammo],target,selected_ammo,self)
	get_tree().create_timer(0.18).timeout.connect(_unlock_shot)
	if _ammo_total() == 0:
		get_tree().create_timer(4.0).timeout.connect(_check_fail_after_settle)

func _unlock_shot():
	shot_locked = false

func _select_ammo(kind):
	if state != "playing" or ammo[kind] <= 0:
		return
	selected_ammo = kind
	world.cannon.set_ammo_color(AMMO_COLORS[selected_ammo])
	_play_sfx("ui",-9)
	ui.update_ammo(ammo,selected_ammo)

func _first_available_ammo():
	for i in range(4):
		if ammo[i] > 0:
			return i
	return WOOD

func _ammo_total():
	var total = 0
	for value in ammo:
		total += int(value)
	return total

func on_projectile_impact(position,kind):
	world.spawn_impact(position,AMMO_COLORS[kind],10)
	world.shake(0.06)

func on_wrong_hit(position,_color):
	world.spawn_impact(position,Color("fff2b0"),7)
	world.show_world_text("WRONG!",position+Vector3(0,0.45,0),Color("ff665e"))
	_play_sfx("wrong",-4)
	world.shake(0.035)

func spawn_break_debris(position,size,color,kind):
	world.spawn_break_debris(position,size,color,kind)

func on_block_broken(position,kind,from_shot):
	world.wake_all()
	var sound_name = "wood"
	if kind == STONE:
		sound_name = "stone"
	elif kind == FIRE:
		sound_name = "ice"
	_play_sfx(sound_name,-5)
	world.shake(0.09 if from_shot else 0.045)
	var now = Time.get_ticks_msec()/1000.0
	if now-last_chain_time < 1.15:
		chain_count += 1
	else:
		chain_count = 1
	last_chain_time = now
	if chain_count == 3:
		ui.show_toast("NICE!",Color("56b8ff"),0.7)
	elif chain_count == 5:
		ui.show_toast("GREAT!",Color("ffad43"),0.8)
	elif chain_count == 7:
		ui.show_toast("PERFECT!",Color("b965ff"),0.9)

func on_ball_cleared(position):
	if level_finished:
		return
	cleared_balls += 1
	world.spawn_impact(position+Vector3(0,0.25,0),Color.WHITE,8)
	_play_sfx("ball",-10)
	ui.update_hud(cleared_balls,total_balls,ammo,selected_ammo)
	if cleared_balls >= total_balls:
		level_finished = true
		get_tree().create_timer(1.15).timeout.connect(_win_level)

func _check_fail_after_settle():
	if state != "playing" or level_finished:
		return
	if cleared_balls < total_balls and _ammo_total() == 0:
		level_finished = true
		state = "lose"
		_play_sfx("lose",-4)
		ui.show_lose()

func _win_level():
	if state != "playing":
		return
	state = "win"
	var star_count = 1
	if shots_used <= par_shots:
		star_count = 3
	elif shots_used <= par_shots+2:
		star_count = 2
	stars_by_level[current_level] = max(stars_by_level[current_level],star_count)
	max_unlocked = max(max_unlocked,min(20,current_level+2))
	_save_progress()
	_play_sfx("win",-3)
	ui.show_win(current_level,star_count,shots_used,par_shots)

func _restart_level():
	_start_level(current_level)

func _next_level():
	if current_level >= 19:
		_show_home()
	else:
		_start_level(current_level+1)

func _play_latest():
	_start_level(clamp(max_unlocked-1,0,19))

func _pause_game():
	if state != "playing":
		return
	state = "pause"
	ui.show_pause()
	get_tree().paused = true

func _resume_game():
	get_tree().paused = false
	ui.hide_pause()
	state = "playing"

func _show_home():
	if get_tree().paused:
		get_tree().paused = false
	state = "home"
	level_finished = true
	world.clear_level()
	world.apply_world_theme(0)
	ui.show_home(sound_enabled,music_enabled)

func _show_levels():
	state = "levels"
	ui.show_levels(max_unlocked,stars_by_level)

func _play_sfx(name,volume_db=-6):
	if audio_lab:
		audio_lab.play_sfx(name,volume_db)

func _toggle_sound():
	sound_enabled = not sound_enabled
	if audio_lab:
		audio_lab.set_sound(sound_enabled)
	ui.sound_button.text = "SOUND ON" if sound_enabled else "SOUND OFF"
	_save_progress()
	if sound_enabled:
		_play_sfx("ui",-8)

func _toggle_music():
	music_enabled = not music_enabled
	if audio_lab:
		audio_lab.set_music(music_enabled)
	ui.music_button.text = "MUSIC ON" if music_enabled else "MUSIC OFF"
	_save_progress()

func _load_save():
	var config = ConfigFile.new()
	if config.load("user://smash_save.cfg") == OK:
		max_unlocked = int(config.get_value("progress","max_unlocked",1))
		sound_enabled = bool(config.get_value("settings","sound",true))
		music_enabled = bool(config.get_value("settings","music",true))
		for i in range(20):
			stars_by_level[i] = int(config.get_value("stars",str(i),0))

func _save_progress():
	var config = ConfigFile.new()
	config.set_value("progress","max_unlocked",max_unlocked)
	config.set_value("settings","sound",sound_enabled)
	config.set_value("settings","music",music_enabled)
	for i in range(20):
		config.set_value("stars",str(i),stars_by_level[i])
	config.save("user://smash_save.cfg")
