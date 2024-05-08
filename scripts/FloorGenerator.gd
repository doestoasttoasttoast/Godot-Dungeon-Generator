extends Node3D

var generated_tiles = [1] # seed the dungeon with a single tile
var length = 1
var width = 1
var new_tile_chance = 75
var room_radius = 20
# whether or not we allow the tile to be generated in that direction
var add_left_space = true
var add_right_space = true
var add_top_space = true
var add_bottom_space = true

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_2D_array()
	print_floor_array(generated_tiles)
	place_floor_tiles()

# Called every frame. 'delta' is the elapsed time since the previous frame.
# unused
func _process(_delta):
	pass
	# generate a starting floor
	var floorToBePlaced = preload("res://scenes/floor_tile.tscn").instantiate()
	add_child(floorToBePlaced) # add child to tree before trying to place it
	floorToBePlaced.global_position = Vector3(0, -0.25, 0)

# generate a 2d array, with 1's representing a tile will be placed
#
#	[
#		0, 0, 0, 0, 0, 0,
#		0, 0, 0, 0, 0, 0, length
#		0, 0, 0, 0, 0, 0, 
#		0, 0, 0, 0, 0, 0 
#	]		width
#
func generate_2D_array():
	add_empty_space()
	for i in room_radius:
		populate_2d_array()
		fill_gaps_in_array()
		add_empty_space()

# keep an empty buffer of 0's in each direction
func add_empty_space():
	# add upper and lower empty spaces
	var new_upper_array = []
	var new_lower_array = []
	for i in width:
		if add_top_space:
			new_upper_array = new_upper_array + [0]
		if add_bottom_space:
			new_lower_array = new_lower_array + [0]
	if add_top_space and add_bottom_space:
		length = length + 2
	elif add_top_space or add_bottom_space:
		length = length + 1
	generated_tiles = new_upper_array + generated_tiles + new_lower_array
	# add left and right spaces
	var new_array = []
	for i in length:
		var tmpArray = generated_tiles.slice(i*width, (i+1)*width)
		if add_left_space:
			tmpArray = [0] + tmpArray
		if add_right_space:
			tmpArray = tmpArray + [0]
		new_array = new_array + tmpArray
	if add_left_space and add_right_space:
		width = width + 2
	elif add_left_space or add_right_space:
		width = width + 1
	generated_tiles = new_array
	add_top_space = false
	add_bottom_space = false
	add_left_space = false
	add_right_space = false

# decide on which 0's should upgrade to 1's
func populate_2d_array():
	var total_possible_tiles = length * width
	# begin iterating over every tile
	var new_tiles = [] # tiles which will upgrade have their index added here
	for i in total_possible_tiles:
		if generated_tiles[i] == 0:
			var neighbors = count_neighbors(i)
			if neighbors == 1: # if a 0 has one neighbor, it has a chance to upgrade
				randomize()
				var rand_int = randi_range(1, 100)
				if rand_int < new_tile_chance:
					new_tiles.append(i)
	# begin adding new tiles
	for i in new_tiles.size():
		var index = new_tiles[i]
		generated_tiles[index] = 1 # populate tiles marked for upgrading
		# if tile is placed on a border, mark that border for extra whitespace
		if index - width < 0:
			add_top_space = true
		if index + width >= width * length:
			add_bottom_space = true
		if index % width == 0:
			add_left_space = true
		if (index + 1) % width == 0:
			add_right_space = true

# if there is a 1x1 gap of a 0 surrounded by 3 or 4 1's, fill that gap
func fill_gaps_in_array():
	var total_possible_tiles = length * width
	var new_tiles = []
	for i in total_possible_tiles:
		if generated_tiles[i] == 0:
			var neighbors = count_neighbors(i)
			if neighbors > 2:
				new_tiles.append(i)
	for i in new_tiles.size():
		generated_tiles[new_tiles[i]] = 1

# get the number of neighbors for a given index of an array
func count_neighbors(i):
	var neighbors = 0
	# check for neighbors to the left
	if i % width != 0 and generated_tiles[i - 1] == 1:
		neighbors = neighbors + 1
	# check for neighbors to the right
	if (i + 1) % width != 0 and generated_tiles[i + 1] == 1:
		neighbors = neighbors + 1
	# check for neighbors above
	if i - width >= 0 and generated_tiles[i - width] == 1:
		neighbors = neighbors + 1
	# check for neighbors below
	if i + width < width * length and generated_tiles[i + width] == 1:
		neighbors = neighbors + 1
	return neighbors

# print out the number of neighbors for each tile
func display_neighbors():
	var neighbor_count = generated_tiles.duplicate()
	var total_possible_tiles = length * width
	for i in total_possible_tiles:
		var neighbors = count_neighbors(i)
		neighbor_count[i] = neighbors
	print('Neighbor Count for each tile:')
	print_floor_array(neighbor_count)

# print out the array in a 2d readable format
func print_floor_array(arr):
	print('width x length\n', width, ' x ', length )
	for i in length:
		var tmpArray = arr.slice(i * width, (i + 1) * width)
		print(tmpArray)

# using our 2d numeric array, place tiles in the game world
func place_floor_tiles():
	var total_possible_tiles = width * length
	var first_tile = []
	for i in total_possible_tiles:
		if generated_tiles[i] == 1:
			var floorToBePlaced = preload("res://scenes/floor_tile.tscn").instantiate()
			add_child(floorToBePlaced)
			var array_x_coord = (i % width) + 1
			var array_z_coord = i / width + 1
			var x_coord = (array_x_coord - room_radius) * 5
			var y_coord = -0.25
			var z_cord = (array_z_coord - room_radius) * 5
			first_tile.append(x_coord)
			first_tile.append(z_cord)
			floorToBePlaced.global_position = Vector3(x_coord, y_coord, z_cord)
