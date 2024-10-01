extends MarginContainer


const color_green = Color(0, 1, 0, 0.5)
const color_white = Color(1, 1, 1, 1)
const color_red = Color(1, 0, 0, 0.5)

@onready var username_input = $Login/Username/Input
@onready var email_input = $Login/Email/Input
@onready var password_input = $Login/Password/Input
@onready var error_output = $Login/Output

@onready var stay_logged_in_check = $Login/StayLoggedInCheckbox
@onready var loading_screen = $LoggingInLoader
@onready var login_screen = $Login

func _on_login_button_pressed() -> void:
	var email = email_input.text
	var password = password_input.text
	loading_screen.visible = true
	Playfab.login_user(email, password, stay_logged_in_check.button_pressed)

func _on_register_button_pressed() -> void:
	var username = username_input.text
	var email = email_input.text
	var password = password_input.text
	loading_screen.visible = true
	Playfab.register_user(username, email, password, stay_logged_in_check.button_pressed)

func show_login(logging_in : bool, err : String = "") -> void:
	visible = true
	loading_screen.visible = logging_in
	password_input.text = ""
	if err:
		error_output.text = err
