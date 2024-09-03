extends GridContainer

@onready var hand = $HandIndicator/HandCount
@onready var archive = $ArchiveIndicator/ArchiveCount
@onready var deck = $DeckIndicator/DeckCount
@onready var life = $LifeIndicator/LifeCount
@onready var cheer = $CheerIndicator/CheerCount
@onready var holopower = $HolopowerIndicator/HolopowerCount

func update_stats(stats_info : Dictionary):
	archive.text = "%s" % stats_info["archive"]
	cheer.text = "%s" % stats_info["cheer"]
	deck.text = "%s" % stats_info["deck"]
	hand.text = "%s" % stats_info["hand"]
	holopower.text = "%s" % stats_info["holopower"]
	life.text = "%s" % stats_info["life"]
