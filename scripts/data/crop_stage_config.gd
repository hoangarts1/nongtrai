## CropStageConfig — data contract for the supplied four crop images.
class_name CropStageConfig
extends Resource

@export var stage_count: int = 4
@export var repeat_stage: int = 3

func validation_errors() -> PackedStringArray:
	var errors: PackedStringArray = []
	if stage_count != 4:
		errors.append("crop stages require the supplied four-image contract")
	if repeat_stage < 1 or repeat_stage >= stage_count:
		errors.append("crop repeat stage must precede the final stage")
	return errors
