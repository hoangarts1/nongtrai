## LifeDogSnapshot - detached values for a read-only panel quote.
class_name LifeDogSnapshot
extends RefCounted
static func capture(main: Node) -> Dictionary:
	return {"name":main.dog_state.get_name(),"revision":main.dog_state.get_revision(),"maximum":main.dog_runtime.CONFIG.name_max_length}
