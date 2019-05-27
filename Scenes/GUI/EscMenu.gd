extends Control

func _ready():
	$DisplayName.text = $"/root/PlayerInfo".player.display_name;

func _on_QuitButton_pressed():
	# send network message
	get_tree().set_network_peer(null);
	get_tree().quit();

func _on_ChangeName_pressed():
	if($DisplayName.visible):
		$DisplayName.hide();
	else:
		$DisplayName.show();

func _on_DisplayName_text_changed(new_text):
	$"/root/PlayerInfo".player.display_name = new_text;
	emit_signal("displayname_changed", new_text);