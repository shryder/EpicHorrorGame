extends Control

func _process(delta):
	$DisplayName.text = $'/root/PlayerInfo'.player.display_name;