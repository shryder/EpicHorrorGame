extends Control

func _ready():
	$DisplayName.text = $'/root/PlayerInfo'.player.display_name;
	get_tree().connect("displayname_changed", self, "_displayname_changed");

func _displayname_changed(new_name):
	$DisplayName.text = new_name;