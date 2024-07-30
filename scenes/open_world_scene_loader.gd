extends Node3D

var chunk_size_x := 10
var chunk_list : PackedStringArray = [
	"res://scenes/sub scenes/camp.tscn",
	"res://scenes/sub scenes/cave.tscn",
	"res://scenes/sub scenes/desert.tscn",
	"res://scenes/sub scenes/fild.tscn",
	"res://scenes/sub scenes/florest.tscn",
	"res://scenes/sub scenes/tundra.tscn",
	]

var chunk_nodes := {
	0: null,
	1: null,
	2: null,
	3: null,
	4: null,
	5: null,
}

func load_node_now(no):
	if chunk_nodes.has(no) and not chunk_nodes[no]:
		chunk_nodes[no] = load(chunk_list[no]).instantiate()
		
		chunk_nodes[no].position.x = chunk_size_x * no
		add_child(chunk_nodes[no])
		

var chunk_lode_progress := {
	0: [0],
	1: [0],
	2: [0],
	3: [0],
	4: [0],
	5: [0],
}

func load_node(no):
	if chunk_nodes.has(no) and not chunk_nodes[no]:
		ResourceLoader.load_threaded_get_status(chunk_list[no],chunk_lode_progress[no]) 
		if chunk_lode_progress[no][0] == 0:
			ResourceLoader.load_threaded_request(chunk_list[no])
		elif chunk_lode_progress[no][0] == 1:
			chunk_nodes[no] = ResourceLoader.load_threaded_get(chunk_list[no]).instantiate()
			chunk_nodes[no].position.x = chunk_size_x * no
			add_child(chunk_nodes[no])
		$ProgressBar.visible = chunk_lode_progress[no][0] < 1
		$ProgressBar.value = chunk_lode_progress[no][0] * 100

func unload_node(no):
	if chunk_nodes.has(no) and not chunk_nodes[no] == null:
		chunk_nodes[no].queue_free()
		chunk_nodes[no] = null
		chunk_lode_progress[no][0] = 0


func sceane_is_near(no,key) -> bool:
	return key == no or key == no - 1 or key == no + 1

func manage_sceanes(current_no):
	for key in chunk_nodes:
		if sceane_is_near(current_no,key):
			load_node(key)
		else:
			unload_node(key)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var scene_id := int(($Player.position.x + (chunk_size_x / 2.0)) / chunk_size_x)
	manage_sceanes(scene_id)
	
