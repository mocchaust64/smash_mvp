extends RigidBody3D
class_name SmashBlock

const WOOD = 0
const STONE = 1
const ICE = 2
const WILD = 3

var block_type = WOOD
var required_ammo = WOOD
var block_size = Vector3.ONE
var broken = false
var controller = null
var main_color = Color.WHITE

func setup(kind, size, color, ammo_type, owner_controller):
	block_type = kind
	required_ammo = ammo_type
	block_size = size
	main_color = color
	controller = owner_controller
	mass = 1.7 if block_type == STONE else 1.0
	linear_damp = 0.15
	angular_damp = 0.12
	contact_monitor = true
	max_contacts_reported = 8
	collision_layer = 1
	collision_mask = 1 | 2 | 4 | 8
	body_entered.connect(_on_body_entered)
	_build_visual()

func _build_visual():
	var mesh = MeshInstance3D.new()
	mesh.name = "Mesh"
	var box = BoxMesh.new()
	box.size = block_size
	mesh.mesh = box
	mesh.material_override = _material_for_type()
	add_child(mesh)

	var cap = MeshInstance3D.new()
	var cap_box = BoxMesh.new()
	cap_box.size = Vector3(max(0.05, block_size.x - 0.05), 0.035, max(0.05, block_size.z - 0.05))
	cap.mesh = cap_box
	cap.position.y = block_size.y * 0.5 + 0.018
	var cap_mat = StandardMaterial3D.new()
	cap_mat.albedo_color = main_color.lightened(0.18)
	cap_mat.roughness = 0.35
	cap.material_override = cap_mat
	add_child(cap)

	var shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.size = block_size
	shape.shape = box_shape
	add_child(shape)
	_add_material_details()

func _add_material_details():
	if block_type == WOOD:
		for x_factor in [-0.28, 0.28]:
			var band = MeshInstance3D.new()
			var band_box = BoxMesh.new()
			band_box.size = Vector3(max(0.05, block_size.x * 0.08), block_size.y * 0.88, block_size.z + 0.018)
			band.mesh = band_box
			band.position.x = block_size.x * float(x_factor)
			var band_mat = StandardMaterial3D.new()
			band_mat.albedo_color = main_color.darkened(0.18)
			band_mat.roughness = 0.72
			band.material_override = band_mat
			add_child(band)
	elif block_type == STONE:
		for i in range(3):
			var chip = MeshInstance3D.new()
			var chip_mesh = BoxMesh.new()
			chip_mesh.size = Vector3(0.12,0.055,0.035)
			chip.mesh = chip_mesh
			chip.position = Vector3(block_size.x * (-0.25 + i * 0.25), block_size.y * 0.22 - i * 0.09, block_size.z * 0.5 + 0.02)
			chip.rotation.z = -0.25 + i * 0.22
			var chip_mat = StandardMaterial3D.new()
			chip_mat.albedo_color = main_color.darkened(0.18)
			chip_mat.roughness = 0.9
			chip.material_override = chip_mat
			add_child(chip)
	elif block_type == ICE:
		var core = MeshInstance3D.new()
		var core_mesh = PrismMesh.new()
		core_mesh.size = Vector3(min(0.3,block_size.x*0.35), min(0.65,block_size.y*0.5), min(0.28,block_size.z*0.42))
		core.mesh = core_mesh
		core.rotation.z = 0.35
		var core_mat = StandardMaterial3D.new()
		core_mat.albedo_color = Color(0.88,0.98,1.0,0.78)
		core_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		core_mat.roughness = 0.08
		core_mat.emission_enabled = true
		core_mat.emission = Color("61cfff")
		core_mat.emission_energy_multiplier = 0.18
		core.material_override = core_mat
		add_child(core)

func _material_for_type():
	var mat = StandardMaterial3D.new()
	mat.albedo_color = main_color
	mat.roughness = 0.46
	if block_type == STONE:
		mat.roughness = 0.78
	if block_type == ICE:
		mat.albedo_color.a = 0.9
		mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		mat.roughness = 0.16
		mat.metallic = 0.05
	return mat

func can_break_with(ammo_type):
	return ammo_type == required_ammo or ammo_type == WILD

func shoot(ammo_type, hit_position, shot_direction):
	if broken:
		return false
	if not can_break_with(ammo_type):
		sleeping = true
		if controller:
			controller.on_wrong_hit(hit_position, main_color)
		return false
	break_now(hit_position, true)
	return true

func break_now(at_position = Vector3.ZERO, from_shot = false):
	if broken:
		return
	broken = true
	if controller:
		controller.spawn_break_debris(global_position, block_size, main_color, block_type)
		controller.on_block_broken(global_position, block_type, from_shot)
	queue_free()

func _on_body_entered(body):
	if broken:
		return
	if body.is_in_group("ground"):
		break_now(global_position, false)
