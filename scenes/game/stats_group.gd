class_name StatsGroup
extends GridContainer

@onready var hand = $HandIndicator/HandCount
@onready var archive = $ArchiveIndicator/ArchiveCount
@onready var deck = $DeckIndicator/DeckCount
@onready var life = $LifeIndicator/LifeCount
@onready var cheer = $CheerIndicator/CheerCount
@onready var holopower = $HolopowerIndicator/HolopowerCount
@onready var xoverlay = $LimitedIndicator/XOverlay
@onready var turnxoverlay = $OshiSkillIndicators/Turn/TurnX
@onready var gamexoverlay = $OshiSkillIndicators/Game/GameX

func update_stats(stats_info : Dictionary):
	archive.text = "%s" % stats_info["archive"]
	cheer.text = "%s" % stats_info["cheer"]
	deck.text = "%s" % stats_info["deck"]
	hand.text = "%s" % stats_info["hand"]
	holopower.text = "%s" % stats_info["holopower"]
	life.text = "%s" % stats_info["life"]
	xoverlay.visible = not stats_info["limited_available"]
	turnxoverlay.visible = not stats_info["oshi_turn_available"]
	gamexoverlay.visible = not stats_info["oshi_game_available"]
