extends Node

const LogArea_Menu = "MENU"
const LogArea_Network = "NETWORK"
const LogArea_Game = "GAME"

func log(log_area, message):
	if GlobalSettings.is_logging_enabled():
		print("%s: %s" % [log_area, message])
