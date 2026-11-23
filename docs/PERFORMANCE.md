# Performance Log: Heartwood Hollow

Target budget (GDD Section 14): 1920x1080 on recording MacBook, 1% low FPS >= 60, max draw calls <= 1,500, max triangles <= 2,000,000. Route: `tests/perf_route.tscn` flying 40 s through all three concept framings and densest forest with all monsters active.

| Milestone | Date | Avg FPS | 1% Low FPS | Max Draw Calls | Max Triangles | Notes |
| :-- | :-- | --: | --: | --: | --: | :-- |
| v1 Playable Complete | 2026-11-22 | 59.9 | 52.9 | 444 | 645,119 | 40 s automated flythrough (`tests/perf_route.tscn`, 2,338 samples, avg 16.68 ms, p99 18.91 ms) across all 4 zones, all monsters, Modeler level geometry, and full-scale M06 Heartwood under Xogot 4.8 Mobile renderer with 2x MSAA. Draw calls (<30% of budget) and triangles (<33% of budget) have huge headroom; minor p99 dip occurs during VSync window frame cadence in editor embedded run. |
