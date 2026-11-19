## DirectorLifecycle - prepare the whole pair before silently replacing either owner.
## API: restore(activity_owner,director_owner,profile,config,activity,director,context,legacy=false).
class_name DirectorLifecycle
extends RefCounted

static func restore(activity_owner: DirectorActivityState, director_owner: DirectorState, profile: DirectorProfile, config: DirectorActivityConfig, activity: Variant, director: Variant, context: Dictionary, legacy: bool = false) -> Dictionary:
	if activity_owner == null or director_owner == null or activity_owner.is_busy() or director_owner.is_busy():
		return {"ok": false, "reason": &"director_lifecycle_busy"}
	var result: Dictionary = DirectorSaveCodec.normalize(profile, config, activity, director, context, legacy)
	if not result.ok:
		return result
	# Codecs and both configurations are complete before these callback-free operations.
	var day: int = int(context.day_index)
	if not activity_owner.configure(config, day) or not activity_owner.deserialize(result.director_activity) or not director_owner.configure(profile, day) or not director_owner.deserialize(result.director):
		return {"ok": false, "reason": &"director_restore_rejected"}
	return result
