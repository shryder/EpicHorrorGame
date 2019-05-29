extends Control

signal displayname_changed;

func _ready():
	$Panel/DisplayName.text = $"/root/PlayerInfo".player.display_name;

func _on_QuitButton_pressed():
	# TODO: Send network message
	get_tree().set_network_peer(null);
	get_tree().quit();

func _on_ChangeName_pressed():
	$"/root/PlayerInfo".player.display_name = $Panel/DisplayName.text;
	emit_signal("displayname_changed", $Panel/DisplayName.text);
