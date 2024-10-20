extends Node2D

@export var floor_num = 1

# Paths to the folders containing the chunk scenes
var SMALL_CHUNK_FOLDER_PATH = "res://rooms/floors/floor%d/maps/small_chunks/" % floor_num
var MEDIUM_CHUNK_VER_FOLDER_PATH = "res://rooms/floors/floor%d/maps/medium_chunks_ver/" % floor_num
var MEDIUM_CHUNK_HOR_FOLDER_PATH = "res://rooms/floors/floor%d/maps/medium_chunks_hor/" % floor_num
var LARGE_CHUNK_FOLDER_PATH = "res://rooms/floors/floor%d/maps/large_chunks/" % floor_num

# Marker group names for each chunk type
@export var small_marker_group: String = "small_marker"
@export var medium_marker_ver_group: String = "medium_marker_ver"
@export var medium_marker_hor_group: String = "medium_marker_hor"
@export var large_marker_group: String = "large_marker"

@export var chunk_z_index: int = -1  # Z-index for the chunks

# Called when the scene is ready
func _ready():
	randomize()  # Initialize random number generator

	# Handle small chunks
	handle_chunk_placement(SMALL_CHUNK_FOLDER_PATH, small_marker_group)

	# Handle medium vertical chunks
	handle_chunk_placement(MEDIUM_CHUNK_VER_FOLDER_PATH, medium_marker_ver_group)

	# Handle medium horizontal chunks
	handle_chunk_placement(MEDIUM_CHUNK_HOR_FOLDER_PATH, medium_marker_hor_group)

	# Handle large chunks
	handle_chunk_placement(LARGE_CHUNK_FOLDER_PATH, large_marker_group)

# Function to place chunks for a given folder and marker group
func handle_chunk_placement(chunk_folder: String, marker_group: String) -> void:
	# Get all files from the corresponding chunk folder
	var chunk_files = get_chunk_files(chunk_folder)

	# Iterate through all markers in the specified group
	for marker in get_tree().get_nodes_in_group(marker_group):
		# Randomly select a chunk
		var random_chunk = get_random_chunk(chunk_files)

		# Instance the selected chunk
		if random_chunk:
			var chunk_instance = random_chunk.instantiate()
			# Set the chunk's position to the marker's global position
			chunk_instance.position = marker.global_position
			
			chunk_instance.z_index = chunk_z_index
			
			# Add the chunk instance to the scene
			add_child(chunk_instance)

			# Optionally, remove the marker node after replacing it with a chunk
			marker.queue_free()

# Function to get all chunk files from the folder
func get_chunk_files(chunk_folder: String) -> Array:
	var chunk_files = []
	var dir = DirAccess.open(chunk_folder)

	# Check if the directory is successfully opened
	if dir == null:
		print("Error: Could not open directory: ", chunk_folder)
		return []

	dir.list_dir_begin()

	var file_name = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".tscn"):
			chunk_files.append(chunk_folder + file_name)
		# Get the next file
		file_name = dir.get_next()

	return chunk_files

# Function to randomly select a chunk from the available files
func get_random_chunk(chunk_files: Array) -> PackedScene:
	if chunk_files.size() > 0:
		var random_index = randi() % chunk_files.size()
		var random_chunk_path = chunk_files[random_index]
		# Load the randomly selected chunk as a PackedScene
		return load(random_chunk_path) as PackedScene
	return null
