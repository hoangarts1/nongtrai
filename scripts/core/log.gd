## Log — contextual diagnostics; no player data, state, sink or autoload.
class_name Log
extends RefCounted

static func format_message(level: StringName, context: StringName, message: String) -> String:
	return "[%s][%s] %s" % [String(level).to_upper(),String(context),message]

static func debug(context: StringName, message: String) -> void:
	if OS.is_debug_build(): print(format_message(&"debug",context,message))

static func warn(context: StringName, message: String) -> void:
	push_warning(format_message(&"warn",context,message))

static func error(context: StringName, message: String) -> void:
	push_error(format_message(&"error",context,message))
