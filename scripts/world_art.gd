extends Node3D
class_name SmashWorldArt

const BlockScript = preload("res://scripts/block.gd")
const BallScript = preload("res://scripts/ball.gd")
const CannonScript = preload("res://scripts/cannon.gd")
const KAYKIT_CRATE = preload("res://assets/vendor/kaykit/Box_A.obj")
const KAYKIT_ROCK = preload("res://assets/vendor/kaykit/rock_single_A.obj")
const KAYKIT_TREE = preload("res://assets/vendor/kaykit/tree_single_A.obj")

const MATERIAL_COLORS = [Color("e7a14b"), Color("78849a"), Color("6bd6ff")]
const WORLD_SKY = [Color("83d6ff"), Color("62c8f2"), Color("b5e8ff"), Color("ffac7a")]
const WORLD_GROUND = [Color("68b95b"), Color("e9c979"), Color("d7eff7"), Color("8d6bb6")]
const WORLD_TRAY = [Color("f3cf82"), Color("f1bd74"), Color("d9edf4"), Color("e7a56a")]

var controller = null
var environment
var camera
var camera_base_position = Vector3.ZERO
var deco_root
var level_root
var fx_root
var ground_mesh
var tray_meshes = []
var cannon
var camera_shake = 0.0

func setup(owner_controller):
	controller = owner_controller
	_build_world()

func _process(delta):
	if camera_shake > 0.001:
		camera_shake = max(0.0, camera_shake - delta * 6.0)
		camera.position = camera_base_position + Vector3(randf_range(-1.0,1.0), randf_range(-1.0,1.0), 0.0) * camera_shake
	else:
		camera.position = camera_base_position

func _build_world():
	var environment_node = WorldEnvironment.new()
	environment = Environment.new()
	environment.background_mode = Environment.BG_COLOR
	environment.background_color = WORLD_SKY[0]
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	environment.ambient_light_color = Color(1.0,0.98,0.93)
	environment.ambient_light_energy = 1.15
	environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	environment_node.environment = environment
	add_child(environment_node)

	var light = DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-52,-32,0)
	light.light_energy = 1.65
	light.light_color = Color(1.0,0.94,0.84)
	light.shadow_enabled = true
	add_child(light)

	camera = Camera3D.new()
	camera.position = Vector3(0,6.9,12.6)
	camera.fov = 40.0
	camera.current = true
	add_child(camera)
	camera.look_at(Vector3(0,1.25,0), Vector3.UP)
	camera_base_position = camera.position

	deco_root = Node3D.new()
	deco_root.name = "Decor"
	add_child(deco_root)

	var ground = StaticBody3D.new()
	ground.name = "Ground"
	ground.add_to_group("ground")
	ground.collision_layer = 8
	ground.collision_mask = 1 | 2
	ground.position = Vector3(0,-3.35,0)
	add_child(ground)
	ground_mesh = MeshInstance3D.new()
	var ground_box = BoxMesh.new()
	ground_box.size = Vector3(22,0.5,18)
	ground_mesh.mesh = ground_box
	ground_mesh.material_override = make_mat(WORLD_GROUND[0],0.9,0.0)
	ground.add_child(ground_mesh)
	var ground_collision = CollisionShape3D.new()
	var ground_shape = BoxShape3D.new()
	ground_shape.size = Vector3(22,0.5,18)
	ground_collision.shape = ground_shape
	ground.add_child(ground_collision)

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
	cannon.position = Vector3(0,-2.92,4.75)
	cannon.setup()
	_build_cannon_dressing()

func _build_tray():
	var tray_root = Node3D.new()
	tray_root.name = "Tray"
	add_child(tray_root)
	for side in [-1,1]:
		var body = StaticBody3D.new()
		body.collision_layer = 4
		body.collision_mask = 1 | 2
		body.position = Vector3(float(side)*1.72,0,0)
		body.rotation.z = deg_to_rad(3.6) * float(side)
		tray_root.add_child(body)
		var mesh = MeshInstance3D.new()
		var box = BoxMesh.new()
		box.size = Vector3(3.55,0.38,4.45)
		mesh.mesh = box
		mesh.material_override = make_mat(WORLD_TRAY[0],0.58,0.0)
		body.add_child(mesh)
		tray_meshes.append(mesh)
		var collision = CollisionShape3D.new()
		var shape = BoxShape3D.new()
		shape.size = Vector3(3.55,0.38,4.45)
		collision.shape = shape
		body.add_child(collision)
	var back_lip = MeshInstance3D.new()
	var lip_mesh = BoxMesh.new()
	lip_mesh.size = Vector3(7.2,0.42,0.18)
	back_lip.mesh = lip_mesh
	back_lip.position = Vector3(0,0.31,-2.18)
	back_lip.material_override = make_mat(Color("d9a85a"),0.6,0.0)
	tray_root.add_child(back_lip)
	var pedestal = MeshInstance3D.new()
	var ped_mesh = CylinderMesh.new()
	ped_mesh.top_radius = 1.45
	ped_mesh.bottom_radius = 2.0
	ped_mesh.height = 1.15
	ped_mesh.radial_segments = 32
	pedestal.mesh = ped_mesh
	pedestal.position = Vector3(0,-0.78,0.15)
	pedestal.material_override = make_mat(Color("d3b989"),0.72,0.0)
	tray_root.add_child(pedestal)

func apply_world_theme(world_index):
	var w = clamp(world_index,0,3)
	environment.background_color = WORLD_SKY[w]
	ground_mesh.material_override = make_mat(WORLD_GROUND[w],0.86,0.0)
	for mesh in tray_meshes:
		mesh.material_override = make_mat(WORLD_TRAY[w],0.56,0.0)
	for child in deco_root.get_children():
		child.free()
	if w == 0:
		_meadow()
	elif w == 1:
		_coast()
	elif w == 2:
		_ice_world()
	else:
		_sunset()

func _meadow():
	_add_hill(Vector3(-5.5,-2.0,-6.5),Vector3(4.8,2.4,2.4),Color("72c65f"))
	_add_hill(Vector3(4.8,-2.1,-7.2),Vector3(5.0,2.2,2.8),Color("5bb657"))
	_add_cloud(Vector3(-4.2,5.6,-7.0),1.1)
	_add_cloud(Vector3(4.8,6.2,-8.0),0.9)
	for x in [-5.4,-4.6,4.8,5.6]:
		_add_tree(Vector3(x,-2.9,-3.6+randf_range(-0.5,0.5)),Color("4a9f4d"))
	_add_external_tree(Vector3(-6.4,-3.0,-5.2),2.2,Color("3f9445"),-0.22)
	_add_external_tree(Vector3(6.2,-3.0,-5.8),2.0,Color("58aa50"),0.18)
	_add_external_rock(Vector3(-4.2,-3.05,-3.0),2.1,Color("6e8391"))
	_add_external_rock(Vector3(4.0,-3.05,-3.1),1.7,Color("8192a0"))

func _coast():
	_add_hill(Vector3(-5.0,-2.5,-7.0),Vector3(4.2,1.7,2.5),Color("4aa3a1"))
	_add_hill(Vector3(5.0,-2.4,-7.5),Vector3(4.0,1.5,2.4),Color("3f8c93"))
	_add_cloud(Vector3(-4.5,6.0,-7.0),1.0)
	_add_cloud(Vector3(4.2,5.4,-8.0),0.75)
	for x in [-5.3,5.1]:
		_add_tree(Vector3(x,-2.85,-4.0),Color("2f9f78"))
	_add_external_rock(Vector3(-5.0,-3.0,-3.0),2.5,Color("557f86"))
	_add_external_rock(Vector3(5.2,-3.0,-3.6),2.0,Color("6e9392"))
	_add_external_tree(Vector3(6.0,-3.0,-5.5),1.8,Color("2a8a71"),0.3)

func _ice_world():
	_add_hill(Vector3(-5.3,-2.2,-7.5),Vector3(4.8,2.5,2.5),Color("b8e8f5"))
	_add_hill(Vector3(5.0,-2.25,-7.0),Vector3(4.5,2.2,2.6),Color("9fd6e8"))
	_add_cloud(Vector3(-4.4,5.8,-7.0),0.95)
	_add_cloud(Vector3(4.7,6.2,-7.5),0.85)
	for x in [-5.0,-4.1,4.3,5.4]:
		_add_crystal(Vector3(x,-2.85,-4.2),Color("76d6ff"))
	_add_external_rock(Vector3(-5.5,-3.0,-3.1),2.4,Color("b7dfeb"))
	_add_external_rock(Vector3(5.0,-3.0,-3.5),2.1,Color("9fcfe2"))

func _sunset():
	_add_hill(Vector3(-5.2,-2.0,-7.5),Vector3(4.8,2.5,2.6),Color("8561a5"))
	_add_hill(Vector3(5.0,-2.1,-7.0),Vector3(4.7,2.2,2.5),Color("704f92"))
	_add_cloud(Vector3(-4.6,5.7,-7.0),0.9,Color(1,0.87,0.79))
	var sun = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 1.15
	sphere.height = 2.3
	sun.mesh = sphere
	sun.position = Vector3(4.6,5.4,-10.0)
	var mat = make_mat(Color("ffd36f"),0.2,0.0)
	mat.emission_enabled = true
	mat.emission = Color("ffb44c")
	mat.emission_energy_multiplier = 1.4
	sun.material_override = mat
	deco_root.add_child(sun)
	_add_external_tree(Vector3(-5.8,-3.0,-5.0),2.2,Color("553d76"),-0.15)
	_add_external_rock(Vector3(5.1,-3.05,-3.4),2.2,Color("755d8f"))

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
	for data in [[-0.55,0,0.55],[0,0.18,0.72],[0.58,0,0.48]]:
		var puff = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = float(data[2])
		sphere.height = float(data[2])*2.0
		puff.mesh = sphere
		puff.position = Vector3(float(data[0]),float(data[1]),0)
		puff.scale = Vector3(scale_value,scale_value*0.72,scale_value)
		puff.material_override = make_mat(tint,0.9,0.0)
		cloud.add_child(puff)

func _add_tree(pos,leaf_color):
	var tree = Node3D.new()
	tree.position = pos
	deco_root.add_child(tree)
	var trunk = MeshInstance3D.new()
	var cyl = CylinderMesh.new()
	cyl.top_radius = 0.12
	cyl.bottom_radius = 0.16
	cyl.height = 1.0
	trunk.mesh = cyl
	trunk.position.y = 0.5
	trunk.material_override = make_mat(Color("91613f"),0.82,0.0)
	tree.add_child(trunk)
	var crown = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.55
	sphere.height = 1.1
	crown.mesh = sphere
	crown.position.y = 1.2
	crown.scale = Vector3(1.0,1.15,0.9)
	crown.material_override = make_mat(leaf_color,0.82,0.0)
	tree.add_child(crown)

func _add_crystal(pos,color):
	var crystal = MeshInstance3D.new()
	var prism = PrismMesh.new()
	prism.size = Vector3(0.55,1.4,0.55)
	crystal.mesh = prism
	crystal.position = pos + Vector3(0,0.7,0)
	crystal.rotation.z = randf_range(-0.25,0.25)
	crystal.material_override = make_mat(color,0.18,0.05)
	deco_root.add_child(crystal)

func _build_cannon_dressing():
	for data in [[-1.15,-3.17,4.95,-0.12],[1.20,-3.17,5.05,0.16]]:
		var crate = MeshInstance3D.new()
		crate.mesh = KAYKIT_CRATE
		crate.position = Vector3(float(data[0]),float(data[1]),float(data[2]))
		crate.scale = Vector3(1.25,1.25,1.25)
		crate.rotation.y = float(data[3])
		crate.material_override = make_mat(Color("d9984b"),0.72,0.0)
		add_child(crate)

func _add_external_rock(pos,scale_value,color):
	var mesh = MeshInstance3D.new()
	mesh.mesh = KAYKIT_ROCK
	mesh.position = pos
	mesh.scale = Vector3.ONE * scale_value
	mesh.rotation.y = randf_range(-PI,PI)
	mesh.material_override = make_mat(color,0.92,0.0)
	deco_root.add_child(mesh)

func _add_external_tree(pos,scale_value,color,yaw=0.0):
	var mesh = MeshInstance3D.new()
	mesh.mesh = KAYKIT_TREE
	mesh.position = pos
	mesh.scale = Vector3.ONE * scale_value
	mesh.rotation.y = yaw
	mesh.material_override = make_mat(color,0.84,0.0)
	deco_root.add_child(mesh)

func clear_level():
	for child in level_root.get_children():
		child.free()
	for child in fx_root.get_children():
		child.free()

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
				var direction = -1.0 if body.position.x < 0 else 1.0
				if abs(body.position.x) < 0.2:
					direction = -1.0 if randf() < 0.5 else 1.0
				body.apply_central_impulse(Vector3(direction*0.12,0.03,0))

func shake(amount):
	camera_shake = max(camera_shake,amount)

func spawn_break_debris(position,size,color,kind):
	var count = 8 if kind != 1 else 7
	for i in range(count):
		var piece = RigidBody3D.new()
		piece.collision_layer = 0
		piece.collision_mask = 8
		piece.mass = 0.08
		var mesh = MeshInstance3D.new()
		var box = BoxMesh.new()
		var sx = max(0.10,min(0.30,size.x*randf_range(0.14,0.25)))
		var sy = max(0.10,min(0.28,size.y*randf_range(0.10,0.20)))
		var sz = max(0.10,min(0.24,size.z*randf_range(0.18,0.30)))
		box.size = Vector3(sx,sy,sz)
		mesh.mesh = box
		var mat = make_mat(color.lightened(randf_range(0.0,0.15)),0.48 if kind != 1 else 0.78,0.0)
		if kind == 2:
			mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mat.albedo_color.a = 0.82
		mesh.material_override = mat
		piece.add_child(mesh)
		var collision = CollisionShape3D.new()
		var shape = BoxShape3D.new()
		shape.size = Vector3(sx,sy,sz)
		collision.shape = shape
		piece.add_child(collision)
		fx_root.add_child(piece)
		piece.global_position = position + Vector3(randf_range(-0.18,0.18),randf_range(-0.12,0.22),randf_range(-0.18,0.18))
		piece.linear_velocity = Vector3(randf_range(-3,3),randf_range(1.5,4),randf_range(-2,2))
		piece.angular_velocity = Vector3(randf_range(-7,7),randf_range(-7,7),randf_range(-7,7))
		var tween = create_tween()
		tween.tween_interval(0.8+randf_range(0.0,0.35))
		tween.tween_property(piece,"scale",Vector3(0.05,0.05,0.05),0.22)
		tween.tween_callback(piece.queue_free)

func spawn_impact(position,color,count=10):
	var holder = Node3D.new()
	holder.global_position = position
	fx_root.add_child(holder)
	for i in range(count):
		var mote = MeshInstance3D.new()
		var sphere = SphereMesh.new()
		sphere.radius = randf_range(0.035,0.075)
		sphere.height = sphere.radius*2.0
		mote.mesh = sphere
		var mat = make_mat(color.lightened(randf_range(0.0,0.16)),0.25,0.0)
		mat.emission_enabled = true
		mat.emission = mat.albedo_color
		mat.emission_energy_multiplier = 1.4
		mote.material_override = mat
		holder.add_child(mote)
		var target = Vector3(randf_range(-0.65,0.65),randf_range(-0.5,0.75),randf_range(-0.35,0.35))
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(mote,"position",target,randf_range(0.18,0.32))
		tween.tween_property(mote,"scale",Vector3(0.05,0.05,0.05),randf_range(0.18,0.32))
	var timer = get_tree().create_timer(0.38)
	timer.timeout.connect(holder.queue_free)

func spawn_muzzle_flash(position,color):
	var flash = OmniLight3D.new()
	flash.light_color = color
	flash.light_energy = 5.0
	flash.omni_range = 3.0
	fx_root.add_child(flash)
	flash.global_position = position
	var mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.16
	sphere.height = 0.32
	mesh.mesh = sphere
	var mat = make_mat(color,0.1,0.0)
	mat.emission_enabled = true
	mat.emission = color
	mat.emission_energy_multiplier = 3.0
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
