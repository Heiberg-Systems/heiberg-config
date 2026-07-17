---
name: yazi-api
description: "Yazi 26.x Lua plugin API — breaking changes from older versions, confirmed by binary analysis"
metadata: 
  node_type: memory
  type: reference
  originSessionId: 7dbccd5b-00f1-4e27-88cb-06bbb2d6db63
---

## Yazi 26.x plugin API (confirmed from binary + working config)

### Renamed/changed functions
- `ya.mgr_emit(...)` → `ya.emit(...)` (deprecated since v25.5.28)
- `ya.preview_widgets(job, { widget })` → `ya.preview_widget(job, widget)` — singular, NO array wrapper
- `child:read_line_with({ timeout = 300 })` → `child:read_line()` — timeout API removed
- `ui.Text.parse(str)` → `ui.Text(str)` — use `ui.Text()` constructor directly
- `upper_bound = ""` → `upper_bound = true` (boolean, not string)
- `only_if = tostring(job.file.url)` → `only_if = job.file.url` (Url object directly)
- `M:seek(job, units)` → `M:seek(job)` — units moved to `job.units`

### Working minimal previewer pattern (pdf.yazi)
```lua
local M = {}
function M:peek(job)
    local child = Command("some-cmd"):arg(tostring(job.file.url)):stdout(Command.PIPED):stderr(Command.NULL):spawn()
    if not child then return end
    local i, lines = 0, ""
    repeat
        local line, event = child:read_line()
        if event ~= 0 then break end
        i = i + 1
        if i > job.skip then lines = lines .. line end
    until i >= job.skip + job.area.h
    child:start_kill()
    ya.preview_widget(job, ui.Text(lines):area(job.area))
end
function M:seek(job)
    local h = cx.active.current.hovered
    if h and h.url == job.file.url then
        ya.emit("peek", { math.max(0, cx.active.preview.skip + (job.units > 0 and 1 or -1)), only_if = job.file.url })
    end
end
return M
```

### Shell script issue: bat() function deadlock in pipelines
When `IFS=$'\n'` is set (as preview.sh does), calling a shell function that uses `$(command -v ...)` inside a pipeline causes a deadlock. Fix: resolve the bat path ONCE at the top level before any pipeline:
```bash
_BAT="$(command -v bat 2>/dev/null || command -v batcat 2>/dev/null)"
bat() { "$_BAT" "$@" --color=always --paging=never ...; }
```

### Working yazi.toml config for md + pdf preview
```toml
[plugin]
prepend_previewers = [
    { mime = "application/pdf", run = "pdf" },
]
```
Markdown uses Yazi's built-in `code` previewer (no custom plugin needed).
