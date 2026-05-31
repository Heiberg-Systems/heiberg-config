local M = {}

function M:peek(job)
	local limit = job.area.h
	local child = Command("pdfinfo")
		:arg(tostring(job.file.url))
		:stdout(Command.PIPED)
		:stderr(Command.NULL)
		:spawn()

	if not child then
		return
	end

	local i, lines = 0, ""
	repeat
		local line, event = child:read_line()
		if event ~= 0 then
			break
		end
		i = i + 1
		if i > job.skip then
			lines = lines .. line
		end
	until i >= job.skip + limit

	child:start_kill()
	ya.preview_widget(job, ui.Text(lines):area(job.area))
end

function M:seek(job)
	local h = cx.active.current.hovered
	if h and h.url == job.file.url then
		ya.emit("peek", {
			math.max(0, cx.active.preview.skip + (job.units > 0 and 1 or -1)),
			only_if = job.file.url,
		})
	end
end

return M
