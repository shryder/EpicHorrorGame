extends Spatial

var players = {};

var EscMenu = {
	enabled = false,
	node = null
};

var map_info = {};

func get_rand_range(from, to):
	return range(from, to)[randi() % range(from, to).size()];

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

	if get_tree().is_network_server():
		_server_created();

	get_tree().connect("network_peer_connected", self, "_player_connected");
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected");
	get_tree().connect("connected_to_server", self, "_connected_ok");
	get_tree().connect("connection_failed", self, "_connected_fail");
	get_tree().connect("server_disconnected", self, "_server_disconnected");

func _server_created():
	print("Server created hello");
	
	# Pick a random map from maps list
	var maps = $'/root/Maps'.maps;
	map_info = maps[get_rand_range(0, maps.size())];
	
	print("Map ", map_info, " chosen.");
	
	players[1] = {
		client_id = 1,
		display_name = $'/root/PlayerInfo'.player.display_name,
		position = map_info.spawn_points[get_rand_range(0, map_info.spawn_points.size())]
	};
	
	var map_node = load("res://" + map_info.name + ".tscn").instance();
	map_node.set_name("World");
	$'/root/Root'.add_child(map_node);
	
	create_player_node(1, players[1].position, true, true);

func _player_connected(id):
	print("Player ", id, " connected.");

func _player_disconencted(id):
	print("Player ", id, " disconnected.");

func _connected_ok():
	print("Successfully connected to server.");
	rpc("register_player", get_tree().get_network_unique_id(), $'/root/PlayerInfo'.player, true);

func _connected_fail():
	print("Failed to connect to server.");

func _server_disconnected():
	print("Lost connection to server.");

func _process(delta):
	$IngameHUD/FPSCounter.text = "FPS: " + str(Engine.get_frames_per_second());

	if(Input.is_action_just_pressed("ui_cancel")):
		toggleEscMenu();

	if(Input.is_action_just_pressed("restart")):
		get_tree().reload_current_scene();

	if(Input.is_action_just_pressed("fullscreen")):
		OS.set_window_fullscreen(true);

func create_player_node(client_id, position, add_to_world=false, is_self=false):
	print("CREATING CLIENT_ID'S PLAYER NODE =====> ", client_id);
	var player_node = preload("res://Player.tscn").instance();
	player_node.set_name(str(client_id));
	player_node.set_network_master(client_id);
	player_node.translate(position);

	if not is_self:
		# Delete camera node if player is NOT current player.
		player_node.get_node('Head/Camera').queue_free();

	if add_to_world:
		add_player_to_world(player_node);

	return player_node;

func add_player_to_world(node):
	$'/root/Root/World/Players'.add_child(node);

remote func init_game(packet):
	players = packet.players;

	var map_node = load("res://" + packet.map.name + ".tscn").instance();
	map_node.set_name('World');

	# Insert Map Node
	$'/root/Root'.add_child(map_node);

	print("Amount of players: ", players.size());

	# Spawn all players (including own player) 
	for p in players:
		# Check if current iteration is of own player
		var is_own = false;
		if p == get_tree().get_network_unique_id():
			is_own = true;

		create_player_node(p, players[p].position, true, is_own);

	rpc_id(1, "done_loading_game", packet.player.client_id);

sync func _spawn_player(client_id):
	print("Spawning new player   ", client_id, "   ", players[client_id].position);
	players[client_id].done_loading = true;
	create_player_node(client_id, players[client_id].position, true);

remote func done_loading_game(client_id):
	players[client_id].done_loading = true;
	print(client_id, " done loading the game, finna notify everybody else.");
	
	# Spawn that one player on everybody else's screen.
	for peer_id in players:
		if(peer_id != client_id):
			print("notify(", peer_id, ");");
			rpc_id(peer_id, "_spawn_player", client_id);

remote func register_player(id, player, is_new_player=false):
	player.done_loading = false;
	player.client_id = id;
	players[id] = player;

	print("Player with id ", id, " and named ", player.display_name, " added to list of players: ", players);
	if get_tree().is_network_server():
		# Select a random spawnpoint for this new player
		var spawn_point = map_info.spawn_points[get_rand_range(0, map_info.spawn_points.size())];

		players[id] = {
			client_id = id,
			display_name = player.display_name,
			position = spawn_point,
			done_loading = false
		};

		var packet = {
			player = players[id],
			map = map_info,
			players = players
		};

		# Send server info to this new player that connected
		rpc_id(id, "init_game", packet);

		# Send info to rest of players
		for peer_id in players:
			rpc_id(id, "register_player", peer_id, players[peer_id]);

func toggleEscMenu():
	if (!EscMenu.enabled or !(EscMenu.node is Node)):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);

		# Load and insert the Esc Scene if not available
		if(!(EscMenu.node is Node)):
			var menu_node = preload("res://EscMenu.tscn").instance();
			menu_node.set_name('EscMenu');
			get_node('/root/Root').add_child(menu_node);
			EscMenu.node = $EscMenu;

		EscMenu.node.show();
		EscMenu.enabled = true;
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

		EscMenu.node.hide();
		EscMenu.enabled = false;