extends CenterContainer

signal filter_settings_changed(filter_settings : Dictionary)

@onready var oshi = $FilterPanel/Margin/LayoutVBox/MainFilters/HolomemCardTypes/Oshi
@onready var debut = $FilterPanel/Margin/LayoutVBox/MainFilters/HolomemCardTypes/Debut
@onready var bloom1 = $FilterPanel/Margin/LayoutVBox/MainFilters/HolomemCardTypes/Bloom1
@onready var bloom2 = $FilterPanel/Margin/LayoutVBox/MainFilters/HolomemCardTypes/Bloom2
@onready var spot = $FilterPanel/Margin/LayoutVBox/MainFilters/HolomemCardTypes/Spot
@onready var buzz = $FilterPanel/Margin/LayoutVBox/MainFilters/HolomemCardTypes/Buzz

@onready var event = $FilterPanel/Margin/LayoutVBox/MainFilters/SupportCardTypes/Event
@onready var fan = $FilterPanel/Margin/LayoutVBox/MainFilters/SupportCardTypes/Fan
@onready var item = $FilterPanel/Margin/LayoutVBox/MainFilters/SupportCardTypes/Item
@onready var mascot = $FilterPanel/Margin/LayoutVBox/MainFilters/SupportCardTypes/Mascot
@onready var staff = $FilterPanel/Margin/LayoutVBox/MainFilters/SupportCardTypes/Staff
@onready var tool = $FilterPanel/Margin/LayoutVBox/MainFilters/SupportCardTypes/Tool

@onready var white = $FilterPanel/Margin/LayoutVBox/MainFilters/Colors/White
@onready var red = $FilterPanel/Margin/LayoutVBox/MainFilters/Colors/Red
@onready var blue = $FilterPanel/Margin/LayoutVBox/MainFilters/Colors/Blue
@onready var green = $FilterPanel/Margin/LayoutVBox/MainFilters/Colors/Green
@onready var purple = $FilterPanel/Margin/LayoutVBox/MainFilters/Colors/Purple
@onready var yellow = $FilterPanel/Margin/LayoutVBox/MainFilters/Colors/Yellow
@onready var none = $FilterPanel/Margin/LayoutVBox/MainFilters/Colors/None

@onready var key_check_map = {
	"oshi": oshi,
	"debut": debut,
	"bloom1": bloom1,
	"bloom2": bloom2,
	"spot": spot,
	"buzz": buzz,

	"event": event,
	"fan": fan,
	"item": item,
	"mascot": mascot,
	"staff": staff,
	"tool": tool,

	"white": white,
	"red": red,
	"blue": blue,
	"green": green,
	"purple": purple,
	"yellow": yellow,
	"none": none,
}

var filter_settings = {
	"oshi": true,
	"debut": true,
	"bloom1": true,
	"bloom2": true,
	"spot": true,
	"buzz": true,

	"event": true,
	"fan": true,
	"item": true,
	"mascot": true,
	"staff": true,
	"tool": true,

	"white": true,
	"red": true,
	"blue": true,
	"green": true,
	"purple": true,
	"yellow": true,
	"none": true,
}

var holomem_options = ["oshi", "debut", "bloom1", "bloom2", "spot", "buzz"]
var support_options = ["event", "fan", "item", "mascot", "staff", "tool"]
var color_options = ["white", "red", "blue", "green", "purple", "yellow", "none"]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for key in filter_settings.keys():
		var button : CheckButton = key_check_map[key]
		button.button_pressed = filter_settings[key]
		button.connect("toggled", func(toggled_on : bool):
			filter_settings[key] = toggled_on
			filter_settings_changed.emit(filter_settings)
		)

func _on_fullscreen_close_button_pressed() -> void:
	visible = false

func _on_clear_filters_button_pressed() -> void:
	for key in filter_settings.keys():
		filter_settings[key] = true
		key_check_map[key].button_pressed = true
	filter_settings_changed.emit(filter_settings)


func _on_all_holomem_button_pressed() -> void:
	for key in holomem_options:
		filter_settings[key] = true
		key_check_map[key].button_pressed = true
	filter_settings_changed.emit(filter_settings)

func _on_none_holomem_button_pressed() -> void:
	for key in holomem_options:
		filter_settings[key] = false
		key_check_map[key].button_pressed = false

func _on_all_support_button_pressed() -> void:
	for key in support_options:
		filter_settings[key] = true
		key_check_map[key].button_pressed = true

func _on_none_support_button_pressed() -> void:
	for key in support_options:
		filter_settings[key] = false
		key_check_map[key].button_pressed = false

func _on_all_colors_button_pressed() -> void:
	for key in color_options:
		filter_settings[key] = true
		key_check_map[key].button_pressed = true

func _on_none_colors_button_pressed() -> void:
	for key in color_options:
		filter_settings[key] = false
		key_check_map[key].button_pressed = false
