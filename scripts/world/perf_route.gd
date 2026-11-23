class_name PerfRouteRunner
extends Node

## Automated 40-second camera flythrough across all 4 zones of Heartwood Hollow
## collecting real Apple Silicon FPS, 1% low FPS, draw calls, and triangle metrics.

@onready var world: WorldDirector = $World
@onready var cam: Camera3D = $FlyCam

const WAYPOINTS: Array[Dictionary] = [
	{"pos": Vector3(0.0, 3.2, 46.0), "look": Vector3(0.0, 2.0, 26.0)},
	{"pos": Vector3(-1.5, 2.8, 12.0), "look": Vector3(0.5, 2.2, -16.0)},
	{"pos": Vector3(-0.2, 2.5, -33.5), "look": Vector3(0.3, 4.2, -90.0)},
	{"pos": Vector3(-0.4, 2.5, -68.2), "look": Vector3(0.3, 1.5, -92.5)},
	{"pos": Vector3(0.0, 3.4, -104.0), "look": Vector3(0.0, 2.0, -142.0)},
	{"pos": Vector3(0.0, 3.2, -135.0), "look": Vector3(0.0, 2.5, -168.0)},
	{"pos": Vector3(0.0, 2.4, -197.5), "look": Vector3(0.0, 4.5, -214.0)},
	{"pos": Vector3(24.0, 14.0, -195.0), "look": Vector3(0.0, 14.0, -226.0)},
]

const TOTAL_DURATION: float = 40.0

var _elapsed: float = 0.0
var _frame_times_ms: Array[float] = []
var _max_draw_calls: int = 0
var _max_primitives: int = 0
var _done: bool = false


func _ready() -> void:
	if world != null and world.menu_director != null:
		world.menu_director.active = false
	if cam != null:
		cam.current = true
		cam.fov = 50.0


func _process(delta: float) -> void:
	if _done:
		return
	_elapsed += delta
	# Skip first 1.0s warmup
	if _elapsed > 1.0:
		_frame_times_ms.append(delta * 1000.0)
		var dc: int = int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
		var prims: int = int(Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME))
		if dc > _max_draw_calls:
			_max_draw_calls = dc
		if prims > _max_primitives:
			_max_primitives = prims

	var t: float = clampf(_elapsed / TOTAL_DURATION, 0.0, 0.9999)
	var seg_f: float = t * float(WAYPOINTS.size() - 1)
	var i0: int = int(floor(seg_f))
	var i1: int = mini(i0 + 1, WAYPOINTS.size() - 1)
	var frac: float = seg_f - float(i0)
	var p0: Vector3 = WAYPOINTS[i0]["pos"] as Vector3
	var p1: Vector3 = WAYPOINTS[i1]["pos"] as Vector3
	var l0: Vector3 = WAYPOINTS[i0]["look"] as Vector3
	var l1: Vector3 = WAYPOINTS[i1]["look"] as Vector3
	if cam != null:
		cam.global_position = p0.lerp(p1, frac)
		cam.look_at(l0.lerp(l1, frac), Vector3.UP)

	if _elapsed >= TOTAL_DURATION:
		_done = true
		_write_report()


func _write_report() -> void:
	if _frame_times_ms.is_empty():
		return
	var sum_ms: float = 0.0
	for ms: float in _frame_times_ms:
		sum_ms += ms
	var avg_ms: float = sum_ms / float(_frame_times_ms.size())
	var avg_fps: float = 1000.0 / maxf(avg_ms, 0.001)
	var sorted_ms: Array[float] = _frame_times_ms.duplicate()
	sorted_ms.sort()
	# 1% low FPS corresponds to the 99th percentile frame time
	var idx_99: int = mini(sorted_ms.size() - 1, int(float(sorted_ms.size()) * 0.99))
	var p99_ms: float = sorted_ms[idx_99]
	var low1_fps: float = 1000.0 / maxf(p99_ms, 0.001)
	var summary: Dictionary = {
		"samples": _frame_times_ms.size(),
		"avg_fps": snappedf(avg_fps, 0.1),
		"low1_fps": snappedf(low1_fps, 0.1),
		"avg_ms": snappedf(avg_ms, 0.01),
		"p99_ms": snappedf(p99_ms, 0.01),
		"max_draw_calls": _max_draw_calls,
		"max_primitives": _max_primitives,
	}
	var f: FileAccess = FileAccess.open("res://docs/evidence/perf_metrics.json", FileAccess.WRITE)
	if f != null:
		f.store_string(JSON.stringify(summary, "  "))
		f.close()
	print("PERF_ROUTE_DONE: ", JSON.stringify(summary))
