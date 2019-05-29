extends Control

const ServerItem = preload("ServerItem.tscn");

var listIndex = 0;

func addServer(name, ping):
	var server = ServerItem.instance();
	listIndex += 1;
	server.get_node("ID").text = str(listIndex);
	server.get_node("Name").text = name;
	server.get_node("Ping").text = str(ping) + 'ms';
	server.rect_min_size = Vector2(900, 30);
	
	$Panel/ScrollContainer/Servers.add_child(server);

func _ready():
	addServer("epic", 16);
	addServer("yeet", 10);
	addServer("ayyayya", 10);
	addServer("Official Shibe Server online 24/7", 5);
	pass
