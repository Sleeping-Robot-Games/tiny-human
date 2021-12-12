extends Control

onready var player_sprite: Dictionary = {
	'HairB': $PlayerSprites/HairB,
	'Body': $PlayerSprites/Body,
	'Bottom': $PlayerSprites/Bottom,
	'Arms': $PlayerSprites/Arms,
	'Top': $PlayerSprites/Top,
	'Head': $PlayerSprites/Head,
	'Eyes': $PlayerSprites/Eyes,
	'HairA': $PlayerSprites/HairA,
	'Face': $PlayerSprites/Face
}

onready var palette_sprite_dict: Dictionary = {
	'bottom': [player_sprite['Bottom']],
	'eyes': [player_sprite['Eyes']],
	'skin': [
		player_sprite['Body'],
		player_sprite['Arms'],
		player_sprite['Head'],
		# player_sprite['Face'] ## Will go under accessory
	],
	'hair': [
		player_sprite['HairA'],
		player_sprite['HairB']
	],
	'top': [player_sprite['Top']],
}

var pallete_sprite_state: Dictionary # Gets set in create_random_character()
var player_name: String
var palette_folder_path = "res://characters/player/palettes"

func _ready():
	connect_button_signals()
	populate_color_boxes()
	create_random_character()
	$PlayerSprites/AnimationPlayer.play("idle_right")

func connect_button_signals() -> void:
	# warning-ignore-all:return_value_discarded
	## Skin Color Buttons
	#$Selectors/VBox/Skin/Prev.connect('button_up', self, '_on_Color_Selection_button_up', ['skin', -1])
	#$Selectors/VBox/Skin/Next.connect('button_up', self, '_on_Color_Selection_button_up', ['skin', 1])
	## Eyes Color Buttons
	$Selectors/VBox/Eyes/Prev.connect('button_up', self, '_on_Color_Selection_button_up', ['eyes', -1])
	$Selectors/VBox/Eyes/Next.connect('button_up', self, '_on_Color_Selection_button_up', ['eyes', 1])
	## Hair A Color Buttons
	$Selectors/VBox/HairA/Prev.connect('button_up', self, '_on_Color_Selection_button_up', ['hair', -1])
	$Selectors/VBox/HairA/Next.connect('button_up', self, '_on_Color_Selection_button_up', ['hair', 1])
	## Hair B Color Buttons
	$Selectors/VBox/HairB/Prev.connect('button_up', self, '_on_Color_Selection_button_up', ['hair', -1])
	$Selectors/VBox/HairB/Next.connect('button_up', self, '_on_Color_Selection_button_up', ['hair', 1])
	## Top Color Buttons
	$Selectors/VBox/Top/Prev.connect('button_up', self, '_on_Color_Selection_button_up', ['top', -1])
	$Selectors/VBox/Top/Next.connect('button_up', self, '_on_Color_Selection_button_up', ['top', 1])
	## Bottom Color Buttons
	$Selectors/VBox/Bottom/Prev.connect('button_up', self, '_on_Color_Selection_button_up', ['bottom', -1])
	$Selectors/VBox/Bottom/Next.connect('button_up', self, '_on_Color_Selection_button_up', ['bottom', 1])
	pass


func populate_color_boxes() -> void:
	## Skin Color Boxes
	var palette_folders = files_in_dir(palette_folder_path)
	for folder in palette_folders:
		create_palette_colors(folder)

func create_palette_colors(palette_type: String) -> void:
	var folder_path = "res://characters/player/palettes/"+palette_type
	var files = files_in_dir(folder_path)
	files.sort()
	for file in files:
		var palette_num = file.substr(len(file)-7, 3)
		if palette_num == "000":
			continue
		var palette_path = folder_path+"/"+file
		var button_image = "res://menus/character_creator/color_button.png"
		
		# Get pixel color from palette for button
		var palette = load(palette_path)
		var palette_data = palette.get_data()
		palette_data.lock()
		var pixel_x = 3 if palette_type == "eyes" else 2
		var button_color = palette_data.get_pixel(pixel_x, 0)
		palette_data.unlock()
		
		# Create color button
		var button = TextureButton.new()
		button.set_expand(true)
		button.set_stretch_mode(TextureButton.STRETCH_SCALE)
		button.texture_normal = load(button_image)
		button.rect_min_size = Vector2(5, 5)
		button.modulate = button_color
		button.connect("button_up", self, "_on_Color_Box_button_up", [palette_type, palette_num])
		
		# Add button to scene
		if palette_type == "skin":
			$Selectors/VBox/Skin/Colors.add_child(button)
		elif palette_type == "eyes":
			$Selectors/VBox/Eyes/Colors.add_child(button)
		elif palette_type == "hair":
			$Selectors/VBox/HairA/Colors.add_child(button)
		elif palette_type == "top":
			$Selectors/VBox/Top/Colors.add_child(button)
		elif palette_type == "bottom":
			$Selectors/VBox/Bottom/Colors.add_child(button)

func create_random_character() -> void:
	var palette_folders = files_in_dir(palette_folder_path)
	for folder in palette_folders:
		set_random_color(folder)

func files_in_dir(path: String, keyword: String = "") -> Array:
	var files = []
	var dir = Directory.new()
	dir.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif keyword != "" and file.find(keyword) == -1:
			continue
		elif not file.begins_with(".") and not file.ends_with(".import"):
			files.append(file)
	dir.list_dir_end()
	return files

func set_sprite_color(folder, sprite: Sprite, number: String) -> void:
	var palette_path = "res://characters/player/palettes/{folder}/{folder}color_{number}.png".format({
		"folder": folder,
		"number": number
	})
	var gray_palette_path = "res://characters/player/palettes/{folder}/{folder}color_000.png".format({
		"folder": folder
	})
	sprite.material.set_shader_param("palette_swap", load(palette_path))
	sprite.material.set_shader_param("greyscale_palette", load(gray_palette_path))
	make_shaders_unique(sprite)

func make_shaders_unique(sprite: Sprite):
	var mat = sprite.get_material().duplicate()
	sprite.set_material(mat)
	
func random_asset(folder: String, keyword: String = "") -> String:
	var files: Array
	files = files_in_dir(folder, keyword)
	if keyword == "":
		files = files_in_dir(folder)
	if len(files) == 0:
		return ""
	randomize()
	var random_index = randi() % len(files)
	return folder+"/"+files[random_index]
	
func set_random_color(palette_type: String) -> void:
	var random_color = random_asset(palette_folder_path+"/"+palette_type)
	if random_color == "" or "000" in random_color:
		random_color = random_color.replace("000", "001")
	for sprite in palette_sprite_dict[palette_type]:
		var color_num = random_color.substr(len(random_color)-7, 3)
		set_sprite_color(palette_type, sprite, color_num)
		pallete_sprite_state[palette_type] = color_num

func _on_Color_Selection_button_up(palette_sprite: String, direction: int):
	var folder_path = "res://characters/player/palettes/"+palette_sprite
	var files = files_in_dir(folder_path)
	var new_color = int(pallete_sprite_state[palette_sprite]) + direction
	if new_color == 0 and direction == -1:
		new_color = len(files) - 1
	if new_color == len(files) and direction == 1:
		new_color = 1
	for sprite in palette_sprite_dict[palette_sprite]:
		var color_num = str(new_color).pad_zeros(3)
		set_sprite_color(palette_sprite, sprite, color_num)
		pallete_sprite_state[palette_sprite] = color_num

func _on_Color_Box_button_up(palette_type: String, palette_num: String):
	for sprite in palette_sprite_dict[palette_type]:
		set_sprite_color(palette_type, sprite, palette_num)
		pallete_sprite_state[palette_type] = palette_num

func _on_Randomize_button_up():
	create_random_character()
