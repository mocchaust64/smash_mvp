extends "res://scripts/main.gd"

func _ready():
	super._ready()
	await get_tree().process_frame
	_start_level(0)
	# Give imported meshes, UI and renderer time to draw the actual gameplay frame.
	for i in range(45):
		await get_tree().process_frame
	await RenderingServer.frame_post_draw
	var image = get_viewport().get_texture().get_image()
	var err = image.save_png("qa_level1.png")
	if err != OK:
		push_error("QA screenshot save failed: %s" % err)
	get_tree().quit()
