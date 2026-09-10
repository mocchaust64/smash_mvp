extends Node3D
class_name SmashWorldArt

const BlockScript = preload("res://scripts/block.gd")
const BallScript = preload("res://scripts/ball.gd")
const CannonScript = preload("res://scripts/cannon.gd")

const MATERIAL_COLORS = [Color("e7a14b"), Color("78849a"), Color("6bd6ff")]
const WORLD_SKY = [Color("83d6ff"), Color("62c8f2"), Color("b5e8ff"), Color("ffac7a")]
const WORLD_GROUND = [Color("69b95e"), Color("e7c775"), Color("d7eff7"), Color("8b6ab3")]
const WORLD_TRAY = [Color("f3cf82"), Color("f1bd74"), Color("dceef4"), Color("e7a56a")]

var controller
var environment: Environment
var camera: Camera3D
var camera_base_position := Vector3.ZERO
var deco_root: Node3D
var level_root: Node3D
var fx_root: Node3D
var ground_mesh: MeshInstance3D
var tray_root: Node3D
var tray_meshes: Array = []
var cannon
var camera_shake := 0.0
var kaykit_tree: Mesh = null
var kaykit_rock: Mesh = null

func setup(owner_controller):
	controller = owner_controller
	_load_external_assets()
	_build_world()

func _load_external_assets():
	# Load after Godot has imported resources. Avoid compile-time raw OBJ preloads.
	var tree_res = load("res://assets/vendor/kaykit/tree_single_A.obj")
	if tree_res is Mesh:
		kaykit_tree = tree_res
	var rock_res = load("res://assets/vendor/kaykit/rock_single_A.obj")
	if rock_res is Mesh:
		kaykit_rock = rock_res

func _process(delta):
	if not camera:
		return
	if camera_shake > 0.001:
		camera_shake = max(0.0, camera_shake - delta * 5.5)
		camera.position = camera_base_position + Vector3(randf_range(-1.0,1.0), randf_range(-1.0,1.0), 0.0) * camera_shake
	else:
		camera.position = camera_base_position

func _build_world():
	var world_env = WorldEnvironment.new()
	environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = WORLD_SKY[0]
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color("fff4df")
	environment.ambient_light_energy = 1.25
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	world_env.environment = environment
	add_child(world_env)

	var key = DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-48,-28,0)
	key.light_energy = 1.55
	key.light_color = Color("fff1d2")
	key.shadow_enabled = true
	add_child(key)

	var fill = DirectionalLight3D.new()
	fill.rotation_degrees = Vector3(-30,145,0)
	fill.light_energy = 0.42
	fill.light_color = Color("cfeaff")
	add_child(fill)

	camera = Camera3D.new()
	camera.position = Vector3(0,6.4,13.2)
	camera.fov = 39.0
	camera.current = true
	add_child(camera)
	camera.look_at(Vector3(0,1.05,0), Vector3.UP)
	camera_base_position = camera.position

	deco_root = Node3D.new()
	deco_root.name = "Decor"
	add_child(deco_root)

	_build_ground()
	_build_tray()

	level_root = Node3D.new()
	level_root.name = "Level"
	add_child(level_root)
	fx_root = Node3D.new()
	fx_root.name = "FX"
	add_child(fx_root)

	cannon = CannonScript.new()
	cannon.name = "Cannon"
	add_child(cannon)
	cannon.position = Vector3(0,-2.55,4.45)
	cannon.setup()

func _build_ground():
	var ground = StaticBody3D.new()
	ground.name = "Ground"
	ground.add_to_group("ground")
	ground.collision_layer = 8
	ground.collision_mask = 1 | 2
	ground.position = Vector3(0,-3.3,0)
	add_child(ground)
	ground_mesh = MeshInstance3D.new()
	var box = BoxMesh.new()
	box.size = Vector3(24,0.5,20)
	ground_mesh.mesh = box
	ground_mesh.material_override = make_mat(WORLD_GROUND[0],0.92,0.0)
	ground.add_child(ground_mesh)
	var collision = CollisionShape3D.new()
	var shape = BoxShape3D.new()
	shape.size = box.size
	collision.shape = shape
	ground.add_child(collision)

func _build_tray():
	tray_root = Node3D.new()
	tray_root.name = "Tray"
	add_child(tray_root)
	var body = StaticBody3D.new()
	body.collision_layer = 4
	body.collision_mask = 1 | 2
	tray_root.add_child(body)
	var tray = MeshInstance3D.new()
	var tray_box = BoxMesh.new()
	tray_box.size = Vector3(7.0,0.42,4.6)
	tray.mesh = tray_box
	tray.position = Vector3(0,-0.12,0)
	tray.material_override = make_mat(WORLD_TRAY[0],0.54,0.0)
	body.add_child(tray)
	tray_meshes.append(tray)
	var c = CollisionShape3D.new()
	var s = BoxShape3D.new()
	s.size = tray_box.size
	c.shape = s
	c.position = tray.position
	body.add_child(c)

	# Rounded-looking toy rim.
	for data in [[0,0.18,-2.22,7.15,0.34,0.22],[0,0.18,2.22,7.15,0.34,0.22],[-3.42,0.18,0,0.26,0.34,4.25],[3.42,0.18,0,0.26,0.34,4.25]]:
		var rim = MeshInstance3D.new()
		var rb = BoxMesh.new()
		rb.size = Vector3(float(data[3]),float(data[4]),float(data[5]))
		rim.mesh = rb
		rim.position = Vector3(float(data[0]),float(data[1]),float(data[2]))
		rim.material_override = make_mat(Color("dfb766"),0.5,0.0)
		tray_root.add_child(rim)

	var pedestal = MeshInstance3D.new()
	var pm = CylinderMesh.new()
	pm.top_radius = 1.5
	pm.bottom_radius = 2.15
	pm.height = 1.05
	pm.radial_segments = 32
	pedestal.mesh = pm
	pedestal.position = Vector3(0,-0.82,0.15)
	pedestal.material_override = make_mat(Color("d1b483"),0.72,0.0)
	tray_root.add_child(pedestal)

func apply_world_theme(world_index):
	var w = clamp(int(world_index),0,3)
	environment.background_color = WORLD_SKY[w]
	ground_mesh.material_override = make_mat(WORLD_GROUND[w],0.9,0.0)
	for mesh in tray_meshes:
		mesh.material_override = make_mat(WORLD_TRAY[w],0.54,0.0)
	for child in deco_root.get_children():
		child.queue_free()
	match w:
		0: _build_meadow()
		1: _build_coast()
		2: _build_ice()
		3: _build_sunset()

func _build_meadow():
	_add_hill(Vector3(-5.4,-2.1,-6.4),Vector3(4.8,2.5,2.5),Color("71c45f"))
	_add_hill(Vector3(4.9,-2.2,-7.0),Vector3(5.2,2.3,2.8),Color("58b255"))
	_add_cloud(Vector3(-4.3,5.6,-7.5),1.05)
	_add_cloud(Vector3(4.6,6.1,-8.0),0.82)
	_add_external_tree(Vector3(-5.3,-3.0,-3.9),2.5,Color("439648"),-0.2)
	_add_external_tree(Vector3(5.2,-3.0,-4.2),2.3,Color("4da251"),0.2)
	_add_external_rock(Vector3(-4.0,-3.03,-2.7),2.0,Color("768895"))

func _build_coast():
	_add_hill(Vector3(-5.3,-2.35,-7.2),Vector3(4.3,1.7,2.6),Color("499c99"))
	_add_hill(Vector3(5.0,-2.4,-7.5),Vector3(4.4,1.6,2.4),Color("3d868e"))
	_add_cloud(Vector3(-4.4,5.8,-7.8),1.0)
	_add_cloud(Vector3(4.5,5.35,-8.4),0.72)
	_add_external_tree(Vector3(5.4,-3.0,-4.6),2.0,Color("2d8c72"),0.25)
	_add_external_rock(Vector3(-5.0,-3.0,-3.0),2.6,Color("577f86"))
	_add_external_rock(Vector3(5.0,-3.0,-3.2),1.8,Color("71969a"))

func _build_ice():
	_add_hill(Vector3(-5.2,-2.15,-7.3),Vector3(4.8,2.4,2.7),Color("b8e8f5"))
	_add_hill(Vector3(5.0,-2.2,-7.0),Vector3(4.6,2.2,2.5),Color("9fd6e8"))
	_add_cloud(Vector3(-4.6,5.9,-7.4),0.9)
	for x in [-5.2,-4.5,4.5,5.3]:
		_add_crystal(Vector3(x,-2.85,-4.0),Color("6fd7ff"))
	_add_external_rock(Vector3(5.0,-3.0,-3.2),2.3,Color("b7e0eb"))

func _build_sunset():
	_add_hill(Vector3(-5.3,-2.05,-7.4),Vector3(5.0,2.5,2.6),Color("8460a3"))
	_add_hill(Vector3(5.0,-2.15,-7.1),Vector3(4.8,2.3,2.5),Color("704e91"))
	_add_cloud(Vector3(-4.7,5.7,-7.4),0.88,Color("ffe0cf"))
	var sun = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 1.05
	sphere.height = 2.1
	sun.mesh = sphere
	sun.position = Vector3(4.8,5.2,-9.5)
	var mat = make_mat(Color("ffd06a"),0.2,0.0)
	mat.emission_enabled = true
	mat.emission = Color("ffb34a")
	mat.emission_energy_multiplier = 1.25
	sun.material_override = mat
	deco_root.add_child(sun)
	_add_external_tree(Vector3(-5.6,-3.0,-4.8),2.3,Color("503b70"),-0.15)
	_add_external_rock(Vector3(5.1,-3.0,-3.2),2.2,Color("765e8c"))

func _add_hill(pos,scale_value,color):
	var mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 1.0
	sphere.height = 2.0
	sphere.radial_segments = 20
	sphere.rings = 10
	mesh.mesh = sphere
	mesh.position = pos
	mesh.scale = scale_value
	mesh.material_override = make_mat(color,0.9,0.0)
	deco_root.add_child(mesh)

func _add_cloud(pos,scale_value,tint=Color.WHITE):
	var cloud = Node3D.new()
	cloud.position = pos
	deco_root.add_child(cloud)
	for d in [[-0.55,0.0,0.52],[0.0,0.16,0.68],[0.56,0.0,0.48]]:
		var puff = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = float(d[2])
		sphere.height = float(d[2])*2.0
		puff.mesh = sphere
		puff.position = Vector3(float(d[0]),float(d[1]),0)
		puff.scale = Vector3(scale_value,scale_value*0.72,scale_value)
		puff.material_override = make_mat(tint,0.9,0.0)
		cloud.add_child(puff)

func _add_crystal(pos,color):
	var mesh = MeshInstance3D.new()
	var prism = PrismMesh.new()
	prism.size = Vector3(0.55,1.45,0.55)
	mesh.mesh = prism
	mesh.position = pos + Vector3(0,0.72,0)
	mesh.rotation.z = randf_range(-0.2,0.2)
	var mat = make_mat(color,0.16,0.03)
	mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	mat.albedo_color.a = 0.88
	mesh.material_override = mat
	deco_root.add_child(mesh)

func _add_external_tree(pos,scale_value,color,yaw=0.0):
	if kaykit_tree:
		var m = MeshInstance3D.new()
		m.mesh = kaykit_tree
		m.position = pos
		m.scale = Vector3.ONE * scale_value
		m.rotation.y = yaw
		m.material_override = make_mat(color,0.82,0.0)
		deco_root.add_child(m)
	else:
		_add_fallback_tree(pos,scale_value,color)

func _add_fallback_tree(pos,scale_value,color):
	var root = Node3D.new()
	root.position = pos
	root.scale = Vector3.ONE * (scale_value*0.7)
	deco_root.add_child(root)
	var trunk = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.12
	cyl.bottom_radius = 0.18
	cyl.height = 1.0
	trunk.mesh = cyl
	trunk.position.y = 0.5
	trunk.material_override = make_mat(Color("8b5f3c"),0.85,0.0)
	root.add_child(trunk)
	var crown = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.55
	sphere.height = 1.1
	crown.mesh = sphere
	crown.position.y = 1.25
	crown.material_override = make_mat(color,0.84,0.0)
	root.add_child(crown)

func _add_external_rock(pos,scale_value,color):
	if kaykit_rock:
		var m = MeshInstance3D.new()
		m.mesh = kaykit_rock
		m.position = pos
		m.scale = Vector3.ONE * scale_value
		m.rotation.y = randf_range(-PI,PI)
		m.material_override = make_mat(color,0.9,0.0)
		deco_root.add_child(m)
	else:
		var rock = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = 0.5
		sphere.height = 0.75
		rock.mesh = sphere
		rock.position = pos
		rock.scale = Vector3(scale_value,scale_value*0.65,scale_value*0.8)
		rock.material_override = make_mat(color,0.92,0.0)
		deco_root.add_child(rock)

func clear_level():
	for child in level_root.get_children():
		child.queue_free()
	for child in fx_root.get_children():
		child.queue_free()

func spawn_block(item):
	var kind = int(item["m"])
	var block = BlockScript.new()
	block.setup(kind,item["s"],MATERIAL_COLORS[kind],kind,controller)
	level_root.add_child(block)
	block.position = item["p"]
	block.rotation.z = float(item.get("r",0.0))
	block.sleeping = true

func spawn_ball(position):
	var ball = BallScript.new()
	ball.setup(controller)
	level_root.add_child(ball)
	ball.position = position
	ball.sleeping = true

func sleep_stack():
	for body in level_root.get_children():
		if body is RigidBody3D:
			body.sleeping = true

func wake_all():
	for body in level_root.get_children():
		if body is RigidBody3D:
			body.sleeping = false
			if body is SmashBall:
				var dir = -1.0 if body.position.x < 0 else 1.0
				if abs(body.position.x) < 0.2:
					dir = -1.0 if randf() < 0.5 else 1.0
				body.apply_central_impulse(Vector3(dir*0.13,0.03,0))

func shake(amount):
	camera_shake = max(camera_shake,float(amount))

func spawn_break_debris(position,size,color,kind):
	var count = 8 if kind != 1 else 7
	for i in range(count):
		var piece = RigidBody3D.new()
		piece.collision_layer = 0
		piece.collision_mask = 8
		piece.mass = 0.07
		var mesh = MeshInstance3D.new()
		var shape_mesh: PrimitiveMesh
		if kind == 2:
			var prism = PrismMesh.new()
			prism.size = Vector3(randf_range(0.12,0.26),randf_range(0.16,0.34),randf_range(0.12,0.24))
			shape_mesh = prism
		else:
			var box = BoxMesh.new()
			box.size = Vector3(randf_range(0.12,0.30),randf_range(0.10,0.26),randf_range(0.12,0.25))
			shape_mesh = box
		mesh.mesh = shape_mesh
		var mat = make_mat(color.lightened(randf_range(0.0,0.14)),0.5 if kind != 1 else 0.82,0.0)
		if kind == 2:
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.albedo_color.a = 0.8
		mesh.material_override = mat
		piece.add_child(mesh)
		fx_root.add_child(piece)
		piece.global_position = position + Vector3(randf_range(-0.18,0.18),randf_range(-0.1,0.2),randf_range(-0.15,0.15))
		piece.linear_velocity = Vector3(randf_range(-3.2,3.2),randf_range(1.5,4.0),randf_range(-1.6,1.6))
		piece.angular_velocity = Vector3(randf_range(-8,8),randf_range(-8,8),randf_range(-8,8))
		var tween = create_tween()
		tween.tween_interval(randf_range(0.7,1.05))
		tween.tween_property(piece,"scale",Vector3(0.02,0.02,0.02),0.22)
		tween.tween_callback(piece.queue_free)

func spawn_impact(position,color,count=10):
	var holder = Node3D.new()
	holder.global_position = position
	fx_root.add_child(holder)
	for i in range(count):
		var mote = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = randf_range(0.035,0.07)
		sphere.height = sphere.radius*2.0
		mote.mesh = sphere
		var mat = make_mat(color.lightened(randf_range(0.0,0.15)),0.25,0.0)
		mat.emission_enabled = true
		mat.emission = mat.albedo_color
		mat.emission_energy_multiplier = 1.25
		mote.material_override = mat
		holder.add_child(mote)
		var target = Vector3(randf_range(-0.6,0.6),randf_range(-0.4,0.75),randf_range(-0.3,0.3))
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(mote,"position",target,randf_range(0.18,0.3))
		tween.tween_property(mote,"scale",Vector3(0.04,0.04,0.04),randf_range(0.18,0.3))
	get_tree().create_timer(0.36).timeout.connect(holder.queue_free)

func spawn_muzzle_flash(position,color):
	var flash = OmniLight3D.new()
	flash.light_color = color
	flash.light_energy = 4.5
	flash.omni_range = 2.8
	fx_root.add_child(flash)
	flash.global_position = position
	var mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.15
	sphere.height = 0.3
	mesh.mesh = sphere
	var mat = make_mat(color,0.1,0.0)
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 2.7
	mesh.material_override = mat
	flash.add_child(mesh)
	var tween = create_tween()
	tween.tween_property(flash,"light_energy",0.0,0.09)
	tween.tween_callback(flash.queue_free)

func show_world_text(text,position,color):
	var label = Label3D.new()
	label.text = text
	label.font_size = 44
	label.modulate = color
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.no_depth_test = true
	fx_root.add_child(label)
	label.global_position = position
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label,"global_position",position+Vector3(0,0.8,0),0.65)
	tween.tween_property(label,"modulate:a",0.0,0.65)
	tween.set_parallel(false)
	tween.tween_callback(label.queue_free)

func make_mat(color,roughness=0.5,metallic=0.0):
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
	return mat
