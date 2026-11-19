## DogNavigation — derived grid/context only; dog position remains in DogState.
## API: configure(config,dynamic=[]),set_dynamic_obstacles(regions),serialize/deserialize;
## is_walkable(cell),route(origin,target),reachable(origin),get_revision/get_rebuild_count.
class_name DogNavigation
extends RefCounted

const DIRECTIONS: Array[Vector2i] = [Vector2i.UP, Vector2i.LEFT, Vector2i.RIGHT, Vector2i.DOWN]
var _config: DogConfig
var _context: Dictionary = {}
var _grid: AStarGrid2D = AStarGrid2D.new()
var _revision: int = 0
var _rebuilds: int = 0

func configure(config: DogConfig, dynamic: Array[Rect2i] = []) -> bool:
	var decoded: Dictionary = DogNavigationCodec.from_regions(config, dynamic)
	if not decoded.ok: return false
	var copy: DogConfig = config.frozen_copy()
	# A new configuration may change static geometry even with equal dynamics.
	_config = copy
	_rebuild(decoded.context)
	return true

func set_dynamic_obstacles(regions: Array[Rect2i]) -> bool:
	var decoded: Dictionary = DogNavigationCodec.from_regions(_config, regions)
	if not decoded.ok: return false
	if decoded.context != _context: _rebuild(decoded.context)
	return true

func serialize() -> Dictionary:
	return _context.duplicate(true)

func deserialize(raw: Dictionary) -> bool:
	var decoded: Dictionary = DogNavigationCodec.decode(_config, raw)
	if not decoded.ok: return false
	if decoded.context != _context: _rebuild(decoded.context)
	return true

func get_revision() -> int:
	return _revision

func get_rebuild_count() -> int:
	return _rebuilds

func is_walkable(cell: Vector2i) -> bool:
	return _config != null and _grid.region.has_point(cell) and not _grid.is_point_solid(cell)

func route(origin: Vector2i, target: Vector2i) -> Array[Vector2i]:
	if not is_walkable(origin) or not is_walkable(target): return []
	return _grid.get_id_path(origin, target)

func reachable(origin: Vector2i) -> Dictionary:
	if not is_walkable(origin): return {"ok": false, "reason": &"blocked_origin"}
	var cells: Array[Vector2i] = [origin]
	var distances: Dictionary = {}
	distances[origin] = 0
	var head: int = 0
	while head < cells.size():
		var current: Vector2i = cells[head]
		head += 1
		for direction: Vector2i in DIRECTIONS:
			var next: Vector2i = current + direction
			if is_walkable(next) and not distances.has(next):
				distances[next] = int(distances[current]) + 1
				cells.append(next)
	return {"ok": true, "cells": cells, "distances": distances}

func _rebuild(context: Dictionary) -> void:
	_context = context.duplicate(true)
	_grid.region = _config.world.player_region
	_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER
	_grid.update()
	_grid.fill_solid_region(_grid.region, false)
	var regions: Array[Rect2i] = _config.npc_world.locations.get_solid_regions()
	for row: Dictionary in _context.dynamic:
		regions.append(Rect2i(int(row.x), int(row.y), int(row.w), int(row.h)))
	for region: Rect2i in regions:
		var clipped: Rect2i = region.intersection(_grid.region)
		if clipped.has_area(): _grid.fill_solid_region(clipped, true)
	_revision += 1
	_rebuilds += 1
