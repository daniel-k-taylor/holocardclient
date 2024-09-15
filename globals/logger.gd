extends Node

const LogArea_Menu = "MENU"
const LogArea_Network = "NETWORK"
const LogArea_Game = "GAME"

func log(log_area, message):
	if GlobalSettings.is_logging_enabled():
		print("%s: %s" % [log_area, message])

func log_menu(message):
	self.log(LogArea_Menu, message)
	
func log_game(message):
	self.log(LogArea_Game, message)

func log_net(message):
	self.log(LogArea_Network, message)
	
