extends StaticBody3D

@export var interaction_message: String = "You found an ancient object."

func interact(_player: Node) -> String:
	return interaction_message
