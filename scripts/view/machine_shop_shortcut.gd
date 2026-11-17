## MachineShopShortcut — one exact debug-action policy shared by UI routes.
## API:
##   static func matches(event: InputEvent, debug_build: bool) -> bool
class_name MachineShopShortcut
extends RefCounted

static func matches(event: InputEvent, debug_build: bool) -> bool:
	return debug_build and event != null and event.is_action_pressed(&"toggle_debug_menu", false, true)
