extends Node3D
class_name SmashCannon

var turret = null
var barrel = null
var muzzle = null
var original_barrel_z = -0.72
var accent_ring = null

func setup():
	# Compact foreground silhouette so the cannon stays fully visible above mobile controls.
	scale = Vector3.ONE * 0.72
	_build_model()

func _build_model():
	var base = MeshInstance3D.new()
	var base_mesh = CylinderMesh.new()
	base_mesh.top_radius = 0.75
	base_mesh.bottom_radius = 0.88
	base_mesh.height = 0.38
	base_mesh.radial_segments = 24
	base.mesh = base_mesh
	base.position.y = 0.18
	base.material_override = _mat(Color("2e405e"), 0.42, 0.18)
	add_child(base)

	for side in [-1, 1]:
		var wheel = MeshInstance3D.new()
		var wheel_mesh = CylinderMesh.new()
		wheel_mesh.top_radius = 0.34
		wheel_mesh.bottom_radius = 0.34
		wheel_mesh.height = 0.18
		wheel_mesh.radial_segments = 20
		wheel.mesh = wheel_mesh
		wheel.rotation.z = PI * 0.5
		wheel.position = Vector3(float(side) * 0.62, 0.28, 0.0)
		wheel.material_override = _mat(Color("d9752f"), 0.58, 0.02)
		add_child(wheel)

	turret = Node3D.new()
	turret.name = "Turret"
	add_child(turret)

	var hub = MeshInstance3D.new()
	var hub_mesh = SphereMesh.new()
	hub_mesh.radius = 0.48
	hub_mesh.height = 0.96
	hub.mesh = hub_mesh
	hub.position.y = 0.58
	hub.scale = Vector3(1.0, 0.68, 1.0)
	hub.material_override = _mat(Color("425b7b"), 0.40, 0.14)
	turret.add_child(hub)

	barrel = MeshInstance3D.new()
	var barrel_mesh = CylinderMesh.new()
	barrel_mesh.top_radius = 0.23
	barrel_mesh.bottom_radius = 0.30
	barrel_mesh.height = 1.55
	barrel_mesh.radial_segments = 24
	barrel.mesh = barrel_mesh
	barrel.rotation.x = PI * 0.5
	barrel.position = Vector3(0, 0.67, original_barrel_z)
	barrel.material_override = _mat(Color("1e304c"), 0.38, 0.22)
	turret.add_child(barrel)

	accent_ring = MeshInstance3D.new()
	var ring_mesh = TorusMesh.new()
	ring_mesh.inner_radius = 0.24
	ring_mesh.outer_radius = 0.35
	ring_mesh.rings = 24
	ring_mesh.ring_segments = 10
	accent_ring.mesh = ring_mesh
	accent_ring.rotation.x = PI * 0.5
	accent_ring.position = Vector3(0, 0.67, -1.48)
	accent_ring.material_override = _mat(Color("e6a236"), 0.35, 0.18)
	turret.add_child(accent_ring)

	muzzle = Marker3D.new()
	muzzle.position = Vector3(0, 0.67, -1.58)
	turret.add_child(muzzle)

func aim_at(world_point):
	var delta = world_point - global_position
	var horizontal = Vector2(delta.x, delta.z).length()
	rotation.y = atan2(-delta.x, -delta.z)
	if turret:
		turret.rotation.x = clamp(atan2(delta.y - 0.58, horizontal), deg_to_rad(-8.0), deg_to_rad(42.0))

func set_ammo_color(color):
	if accent_ring:
		var mat = _mat(color, 0.28, 0.18)
		mat.emission_enabled = true
		mat.emission = color
		mat.emission_energy_multiplier = 0.32
		accent_ring.material_override = mat

func get_muzzle_position():
	return muzzle.global_position

func kick():
	if not barrel:
		return
	var tween = create_tween()
	tween.tween_property(barrel, "position:z", original_barrel_z + 0.18, 0.045)
	tween.tween_property(barrel, "position:z", original_barrel_z, 0.10)

func _mat(color, roughness, metallic):
	var mat = StandardMaterial3D.new()
	mat.albedo_color = color
	mat.roughness = roughness
	mat.metallic = metallic
	return mat
