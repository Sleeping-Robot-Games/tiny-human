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
	'Face': $PlayerSprites/Face,
	'Hat': $PlayerSprites/Hat
}

onready var palette_sprite_dict: Dictionary = {
	'bottom': [player_sprite['Bottom']],
	'eyes': [player_sprite['Eyes']],
	'skin': [
		player_sprite['Body'],
		player_sprite['Arms'],
		player_sprite['Head'],
		player_sprite['Face']
	],
	'hair': [
		player_sprite['HairA'],
		player_sprite['HairB']
	],
	'top': [player_sprite['Top']],
}

var pallete_sprite_state: Dictionary


var player_name: String

var palette_folder_path = "res://characters/player/palettes"

func _ready():
	### Button signals ###
	## Skin Color Buttons
	$ColorContainer/SkinContainer/Left.connect('button_up', self, '_on_Color_Selection_button_up', ['skin', -1])
	$ColorContainer/SkinContainer/Right.connect('button_up', self, '_on_Color_Selection_button_up', ['skin', 1])
	## Eyes Color Buttons
	$ColorContainer/EyesContainer/Left.connect('button_up', self, '_on_Color_Selection_button_up', ['eyes', -1])
	$ColorContainer/EyesContainer/Right.connect('button_up', self, '_on_Color_Selection_button_up', ['eyes', 1])
	## Hair A Color Buttons
	$ColorContainer/HairAContainer/Left.connect('button_up', self, '_on_Color_Selection_button_up', ['hair', -1])
	$ColorContainer/HairAContainer/Right.connect('button_up', self, '_on_Color_Selection_button_up', ['hair', 1])
	## Hair B Color Buttons
	$ColorContainer/HairBContainer/Left.connect('button_up', self, '_on_Color_Selection_button_up', ['hair', -1])
	$ColorContainer/HairBContainer/Right.connect('button_up', self, '_on_Color_Selection_button_up', ['hair', 1])
	## Top Color Buttons
	$ColorContainer/TopContainer/Left.connect('button_up', self, '_on_Color_Selection_button_up', ['top', -1])
	$ColorContainer/TopContainer/Right.connect('button_up', self, '_on_Color_Selection_button_up', ['top', 1])
	## Bottom Color Buttons
	$ColorContainer/BottomContainer/Left.connect('button_up', self, '_on_Color_Selection_button_up', ['bottom', -1])
	$ColorContainer/BottomContainer/Right.connect('button_up', self, '_on_Color_Selection_button_up', ['bottom', 1])
	
	create_random_character()
	
	$PlayerSprites/AnimationPlayer.play("idle_right")
	
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
