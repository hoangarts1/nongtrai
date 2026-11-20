## ClearingState - sole saved debris owner, with transient exact-token settlement.
## API: configure(config)->bool; serialize()->Dictionary; deserialize(data)->bool;
## reserve(cell,id)->Dictionary; commit/finish/cancel(token)->bool;
## is_busy/is_cleared/is_candidate/get_count/get_goal/get_candidates.
## signal changed(). Deserialization is silent; locks never serialize.
class_name ClearingState
extends RefCounted
signal changed()
var _context: Dictionary = {}
var _cleared: Dictionary[Vector2i, StringName] = {}
var _token: RefCounted
var _pending_cell: Vector2i
var _pending_id: StringName
var _publishing: bool = false
var _committed: bool = false

func configure(config: ClearingConfig) -> bool:
	if is_busy(): return false
	var context: Dictionary = ClearingRules.compile(config)
	if context.is_empty(): return false
	var checked: Dictionary = ClearingSaveCodec.decode(context,serialize())
	if not checked.ok: return false
	_context = context
	return true

func is_busy() -> bool:
	return _token!=null or _publishing

func get_count() -> int:
	return _cleared.size()

func get_goal() -> int:
	return int(_context.get("goal",0))

func is_cleared(cell: Vector2i, id: StringName) -> bool:
	return _cleared.get(cell,&"")==id and not id.is_empty()

func is_candidate(cell: Vector2i, id: StringName) -> bool:
	return not _context.is_empty() and not _cleared.has(cell) and _context.entries.get(cell,&"")==id and not id.is_empty()

func get_candidates() -> Array[Dictionary]:
	var rows: Array[Dictionary] = []
	for cell: Vector2i in _context.get("entries",{}):
		if not _cleared.has(cell): rows.append({"cell":cell,"asset_id":_context.entries[cell]})
	return rows

func reserve(cell: Vector2i, id: StringName) -> Dictionary:
	if is_busy() or not is_candidate(cell,id):
		return {"ok":false,"reason":&"invalid_or_cleared_target"}
	_token = RefCounted.new()
	_committed = false
	_pending_cell = cell
	_pending_id = id
	return {"ok":true,"token":_token}

func commit(token: RefCounted) -> bool:
	if _publishing or _committed or token==null or token!=_token: return false
	_cleared[_pending_cell] = _pending_id
	_committed = true
	# Hold the token through publication so observers cannot reset/erase the receipt.
	_publishing = true
	changed.emit()
	_publishing = false
	return true

func finish(token: RefCounted) -> bool:
	if _publishing or not _committed or token==null or token!=_token: return false
	_token = null
	_committed = false
	return true

func cancel(token: RefCounted) -> bool:
	if _publishing or _committed or token==null or token!=_token: return false
	_token = null
	return true

func serialize() -> Dictionary:
	var rows: Array[Dictionary] = []
	for cell: Vector2i in _cleared:
		rows.append({"x":cell.x,"y":cell.y,"asset_id":String(_cleared[cell])})
	rows.sort_custom(func(a: Dictionary, b: Dictionary) -> bool: return a.y<b.y or (a.y==b.y and a.x<b.x))
	return {"cleared":rows}

func deserialize(data: Dictionary) -> bool:
	if is_busy() or _context.is_empty(): return false
	var result: Dictionary = ClearingSaveCodec.decode(_context,data)
	if not result.ok: return false
	var next: Dictionary[Vector2i, StringName] = {}
	for row: Dictionary in result.snapshot.cleared:
		next[Vector2i(row.x,row.y)] = StringName(row.asset_id)
	_cleared = next
	return true
