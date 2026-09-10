extends Node
class_name SmashAudioLab

var enabled = true
var music_enabled = true
var cache = {}
var music_player

func setup(sound_on=true, music_on=true):
	enabled = sound_on
	music_enabled = music_on
	music_player = AudioStreamPlayer.new()
	music_player.stream = _make_music()
	music_player.volume_db = -22
	add_child(music_player)
	if music_enabled:
		music_player.play()

func set_sound(value):
	enabled = value

func set_music(value):
	music_enabled = value
	if not music_player:
		return
	if music_enabled:
		if not music_player.playing:
			music_player.play()
	else:
		music_player.stop()

func play_sfx(name, volume_db=-6.0):
	if not enabled:
		return
	if not cache.has(name):
		cache[name] = _make_sfx(name)
	var player = AudioStreamPlayer.new()
	player.stream = cache[name]
	player.volume_db = volume_db
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()

func _make_sfx(name):
	var rate = 16000
	var duration = 0.18
	var freq = 500.0
	var noise = 0.0
	var decay = 18.0
	if name == "shoot":
		duration = 0.20; freq = 145.0; noise = 0.55; decay = 19.0
	elif name == "wood":
		duration = 0.32; freq = 175.0; noise = 0.48; decay = 13.0
	elif name == "stone":
		duration = 0.38; freq = 92.0; noise = 0.40; decay = 8.0
	elif name == "ice":
		duration = 0.40; freq = 1700.0; noise = 0.16; decay = 13.0
	elif name == "wrong":
		duration = 0.25; freq = 760.0; noise = 0.0; decay = 15.0
	elif name == "ball":
		duration = 0.14; freq = 1050.0; noise = 0.0; decay = 24.0
	elif name == "win":
		duration = 0.85; freq = 523.0; noise = 0.0; decay = 2.6
	elif name == "lose":
		duration = 0.55; freq = 290.0; noise = 0.0; decay = 3.0
	elif name == "ui":
		duration = 0.10; freq = 620.0; noise = 0.0; decay = 24.0
	var count = int(rate * duration)
	var bytes = PackedByteArray()
	bytes.resize(count * 2)
	for i in range(count):
		var t = float(i) / float(rate)
		var env = exp(-t * decay)
		var f = freq
		if name == "lose":
			f = max(100.0, freq - 180.0 * t)
		var sample = sin(TAU * f * t) * 0.55
		if name == "win":
			var step = int(t / 0.18)
			var mult = [1.0, 1.25, 1.5, 2.0][min(step,3)]
			sample = sin(TAU * freq * mult * t) * 0.45
		if name == "ice":
			sample += sin(TAU * 2400.0 * t) * 0.20
		if noise > 0.0:
			sample += randf_range(-1.0,1.0) * noise
		sample *= env
		var value = int(clamp(sample,-1.0,1.0) * 32767.0)
		bytes[i*2] = value & 0xff
		bytes[i*2+1] = (value >> 8) & 0xff
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.stereo = false
	stream.data = bytes
	return stream

func _make_music():
	var rate = 8000
	var duration = 2.0
	var count = int(rate * duration)
	var bytes = PackedByteArray()
	bytes.resize(count * 2)
	var notes = [261.63,329.63,392.0]
	for i in range(count):
		var t = float(i) / float(rate)
		var sample = 0.0
		for f in notes:
			sample += sin(TAU * float(f) * t) * 0.045
		var pulse_t = fmod(t,0.5)
		var pulse_note = float(notes[int(t / 0.5) % 3]) * 2.0
		sample += sin(TAU * pulse_note * pulse_t) * 0.055 * exp(-pulse_t*5.0)
		var value = int(clamp(sample,-1.0,1.0) * 32767.0)
		bytes[i*2] = value & 0xff
		bytes[i*2+1] = (value >> 8) & 0xff
	var stream = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.stereo = false
	stream.data = bytes
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = count
	return stream
