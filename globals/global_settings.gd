extends Node

const ReleaseLoggingEnabled = false # If true, log even on release builds.
const UseAzureServerAlways = false # If true, always defaults to the azure server.
const ClientVersionString : String = "240804.1135" # YYMMDD.HHMM

var LoggingEnabled : bool = true

func get_client_version() -> String:
	var prepend = ""
	if OS.is_debug_build():
		prepend = "dev_"
	return prepend + ClientVersionString

func get_server_url() -> String:
	const azure_url = "wss://holocard-hwdegne5cse4hrfy.eastus-01.azurewebsites.net/ws"
	const local_url = "ws://127.0.0.1:8000/ws"

	if UseAzureServerAlways or not OS.is_debug_build():
		return azure_url
	else:
		return local_url

func is_logging_enabled() -> bool:
	if not LoggingEnabled:
		return false
	if ReleaseLoggingEnabled:
		return true
	return OS.is_debug_build()

func load_persistent_settings() -> bool:
	return true

func toggle_logging(toggle_on : bool) -> void:
	LoggingEnabled = toggle_on
