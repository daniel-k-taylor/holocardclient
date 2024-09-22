class_name PopupMessage
extends Node2D

@onready var animation_player : AnimationPlayer = $AnimationPlayer
@onready var popup_message : RichTextLabel = $OuterContainer/OuterMargin/PopupPanelContainer/MarginContainer/CenterContainer/PopupMessage
@onready var message_root = $OuterContainer/OuterMargin/PopupPanelContainer
@onready var icon_root = $OuterContainer/IconMargin

@onready var damage_icon : TextureRect = $OuterContainer/IconMargin/VBoxContainer/MarginContainer/DamageIcon
@onready var heart_icon : TextureRect = $OuterContainer/IconMargin/VBoxContainer/MarginContainer/HeartIcon
@onready var shield_icon : TextureRect = $OuterContainer/IconMargin/VBoxContainer/MarginContainer/ShieldIcon
@onready var number_label = $OuterContainer/IconMargin/MarginContainer/NumberLabel

const MessageDurationSeconds = 2
const FastMessageDurationSeconds = 1.2

enum IconMessageType {
	Damage,
	Heart,
	Shield,
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func play_message(text, fast=false):
	message_root.visible = true
	icon_root.visible = false
	popup_message.text = text
	if fast:
		animation_player.play("play_message_fast")
	else:
		animation_player.play("play_message")

func play_icon_message(text, icon_type : IconMessageType, fast=false):
	message_root.visible = false
	icon_root.visible = true
	number_label.text = str(text)
	damage_icon.visible = icon_type == IconMessageType.Damage
	heart_icon.visible = icon_type == IconMessageType.Heart
	shield_icon.visible = icon_type == IconMessageType.Shield
	if fast:
		animation_player.play("play_message_fast")
	else:
		animation_player.play("play_message")

func message_done():
	get_parent().remove_child(self)
	queue_free()
