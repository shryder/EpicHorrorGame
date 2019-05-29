extends Control

const MAX_PLAYERS = 8;
const SERVER_IP = "127.0.0.1";
const SERVER_PORT = 1337;

signal displayname_changed(display_name);

func _ready():
	pass;

func _on_UserDisplayName_text_changed(new_text):
	emit_signal("displayname_changed", new_text);
	$"/root/PlayerInfo".player.display_name = new_text;

func _on_Join_pressed():
	var peer = NetworkedMultiplayerENet.new();
	peer.create_client(SERVER_IP, SERVER_PORT);
	get_tree().set_network_peer(peer);
	get_tree().set_meta("network_peer", peer);
	get_tree().change_scene("res://Root.tscn");

func _on_Create_pressed():
	var peer = NetworkedMultiplayerENet.new();
	peer.create_server(SERVER_PORT, MAX_PLAYERS);
	get_tree().set_network_peer(peer);
	get_tree().set_meta("network_peer", peer);
	get_tree().change_scene("res://Root.tscn");

func _on_ServersList_pressed():
	get_tree().change_scene("res://Scenes/GUI/ServerList.tscn");
