extends RigidBody3D
class_name SmashBall

var controller = null
var counted = false

func setup(owner_controller):
	controller = owner_controller
	mass = 0.72
	linear_damp = 0.05
	angular_damp = 0.05
	contact_monitor = true
	max_contacts_reported = 8
	collision_layer = 2
	collision_mask = 1 | 4 | 8
	body_entered.connect(_on_body_entered)
	_build_visual()

func _build_visual():
	var mesh = MeshInstance3D.new()
	var sphere = SphereMesh.new()
	sphere.radius = 0.32
	sphere.height = 0.64
	sphere.radial_segments = 24
	sphere.rings = 12
	mesh.mesh = sphere
	var mat = StandardMaterial3D.new()
	mat.albedo_color = Color(0.98, 0.99, 1.0)
	mat.roughness = 0.22
	mat.metallic = 0.05
	mesh.material_override = mat
	add_child(mesh)

	var ring = MeshInstance3D.new()
	var torus = TorusMesh.new()
	torus.inner_radius = 0.25
	torus.outer_radius = 0.285
	torus.rings = 16
	torus.ring_segments = 8
	ring.mesh = torus
	ring.rotation.x = PI * 0.5
	var ring_mat = StandardMaterial3D.new()
	ring_mat.albedo_color = Color(0.64, 0.74, 0.9)
	ring_mat.roughness = 0.35
	ring.material_override = ring_mat
	add_child(ring)

	var collision = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 0.32
	collision.shape = shape
	add_child(collision)

	var pm = PhysicsMaterial.new()
	pm.bounce = 0.22
	pm.friction = 0.28
	physics_material_override = pm

func _on_body_entered(body):
	if counted:
		return
	if body.is_in_group("ground"):
		counted = true
		if controller:
			controller.on_ball_cleared(global_position)
		queue_free()
