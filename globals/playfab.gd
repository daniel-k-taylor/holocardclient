extends Node

signal login_success
signal login_error(error_string)

var PlayfabId = ""
var SessionTicket = ""
var _remember_user = false
var ErrorDetails = ""
var Username

func begin_auto_login() -> void:
	_try_auto_login()

func register_user(username: String, email: String, password: String, remember_me : bool):
	_remember_user = remember_me
	
	var http_request = HTTPRequest.new()
	http_request.accept_gzip = false
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

	var url = "https://%s.playfabapi.com/Client/RegisterPlayFabUser" % GlobalSettings.PlayfabTitleId
	var headers = ["Content-Type: application/json"]
	var body = {
		"Username": username,
		"Email": email,
		"Password": password,
		"RequireBothUsernameAndEmail": true,  # Set to true if you require both username and email
		"TitleId": GlobalSettings.PlayfabTitleId
	}

	var err = http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	if err != OK:
		_display_error_details(null, "Error making request: %s" % err)

func _on_request_completed(result: int, response_code: int, _headers: Array, body: PackedByteArray):
	if result == HTTPRequest.Result.RESULT_SUCCESS:
		var response_text = body.get_string_from_utf8()
		var response = JSON.parse_string(response_text)
		if response_code == 200:
			var data = response.data
			_save_session_ticket(data["Username"], data["PlayFabId"], data["SessionTicket"])
			return
		else:
			_display_error_details(response)
	else:
		_display_error_details(null, "Result code: %s" % result)

func login_user(email: String, password: String, remember_me : bool):
	_remember_user = remember_me
	
	var http_request = HTTPRequest.new()
	http_request.accept_gzip = false
	add_child(http_request)
	http_request.request_completed.connect(_on_login_completed)

	var url = "https://%s.playfabapi.com/Client/LoginWithEmailAddress" % GlobalSettings.PlayfabTitleId
	var headers = ["Content-Type: application/json"]
	var body = {
		"Email": email,
		"Password": password,
		"TitleId": GlobalSettings.PlayfabTitleId
	}

	var err = http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	if err != OK:
		_display_error_details(null, "Error making login request: %s" % err)

func _on_login_completed(result: int, response_code: int, _headers: Array, body: PackedByteArray):
	if result == HTTPRequest.Result.RESULT_SUCCESS:
		var response_text = body.get_string_from_utf8()
		var response = JSON.parse_string(response_text)
		if response_code == 200:
			var data = response.data
			_save_session_ticket("", data["PlayFabId"], data["SessionTicket"])
			return
		else:
			_display_error_details(response)
	else:
		_display_error_details(null, "Result code: %s" % result)

func _display_error_details(response, str_details = ""):
	var errors = []
	if str_details:
		errors.append(str_details)
	if response and "errorDetails" in response:
		for key in response["errorDetails"]:
			errors.append("Error: %s - %s" % [key, " ".join(response["errorDetails"][key])])
	ErrorDetails = "\n".join(errors)
	login_error.emit(ErrorDetails)

func _save_session_ticket(username : String, playfab_id : String, session_ticket : String):
	if username:
		Username = username
	PlayfabId = playfab_id
	SessionTicket = session_ticket
	if _remember_user:
		GlobalSettings.save_user_setting(GlobalSettings.PlayfabUsername, username)
		GlobalSettings.save_user_setting(GlobalSettings.PlayfabId, playfab_id)
		GlobalSettings.save_user_setting(GlobalSettings.PlayfabSessionTicket, session_ticket)
	else:
		GlobalSettings.save_user_setting(GlobalSettings.PlayfabUsername, "")
		GlobalSettings.save_user_setting(GlobalSettings.PlayfabId, "")
		GlobalSettings.save_user_setting(GlobalSettings.PlayfabSessionTicket, "")
		
	login_success.emit()

func _try_auto_login():
	PlayfabId = GlobalSettings.get_user_setting(GlobalSettings.PlayfabId)
	SessionTicket = GlobalSettings.get_user_setting(GlobalSettings.PlayfabSessionTicket)
	if SessionTicket:
		_remember_user = true
		_login_with_session_ticket(SessionTicket)
	else:
		login_error.emit("")

func _login_with_session_ticket(session_ticket):
	var http_request = HTTPRequest.new()
	http_request.accept_gzip = false
	add_child(http_request)
	http_request.request_completed.connect(_on_auto_login_completed)

	var url = "https://%s.playfabapi.com/Client/LoginWithSessionTicket" % GlobalSettings.PlayfabTitleId
	var headers = ["Content-Type: application/json"]
	var body = {
		"SessionTicket": session_ticket,
		"TitleId": GlobalSettings.PlayfabTitleId
	}

	var err = http_request.request(url, headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	if err != OK:
		_display_error_details(null, "Error making auto-login request: %s" % err)

func _on_auto_login_completed(result: int, response_code: int, _headers: Array, body: PackedByteArray):
	if result == HTTPRequest.Result.RESULT_SUCCESS:
		var response_text = body.get_string_from_utf8()
		var response = JSON.parse_string(response_text)
		if response_code == 200:
			var data = response.data
			_save_session_ticket(data["Username"], data["PlayFabId"], data["SessionTicket"])
			return
		else:
			_display_error_details(response)
	else:
		_display_error_details(null, "Result code: %s" % result)
