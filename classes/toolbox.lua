if rawget(_M, "_hudToolBox") then
	return
end

rawset(_M, "_hudToolBox", {})

local _hudToolBox = _M._hudToolBox -- so vscode shuts up

--* Time utils
function _hudToolBox:current_time()
	return TimerManager:main():time()
end

function _hudToolBox:current_delta()
	return TimerManager:main():delta_time()
end

function _hudToolBox:current_game_time()
	return TimerManager:game():time()
end

function _hudToolBox:current_game_delta()
	return TimerManager:game():delta_time()
end

function _hudToolBox:ease_in_out_sine(time, start, final, delta)
	return -final / 2 * (math.cos(math.pi * time / delta) - 1) + start
end

--* GUI Object utils
function _hudToolBox:debug_panel_fill(panel, color)
	panel:rect({ color = color, visible = true, alpha = 0.5, layer = 10000 })
end

function _hudToolBox:debug_panel_outline(panel, color, layer)
	panel:rect({
		valign = "grow",
		halign = "grow",
		h = 1,
		color = color,
		visible = true,
		alpha = 0.5,
		layer = layer or 1000,
	})
	panel:rect({
		valign = "grow",
		halign = "grow",
		y = panel:h() - 1,
		h = 1,
		color = color,
		visible = true,
		alpha = 0.5,
		layer = layer or 1000,
	})
	panel:rect({
		valign = "grow",
		halign = "grow",
		w = 1,
		color = color,
		visible = true,
		alpha = 0.5,
		layer = layer or 1000,
	})
	panel:rect({
		valign = "grow",
		halign = "grow",
		x = panel:w() - 1,
		w = 1,
		color = color,
		visible = true,
		alpha = 0.5,
		layer = layer or 1000,
	})
end

function _hudToolBox:make_pretty_text(text_obj)
	local _, _, w, h = text_obj:text_rect()
	w, h = w + 2, h + 2

	text_obj:set_size(w, h)
	text_obj:set_position(math.round(text_obj:x()), math.round(text_obj:y()))

	return w, h
end

function _hudToolBox:parse_color_tags(text_obj, color_tbl)
	local text, colors = StringUtils:parse_color_string_utf8(text_obj:text(), color_tbl)
	text_obj:set_text(text)
	self:make_pretty_text(text_obj)

	if not colors then
		return
	end

	for i = 1, #colors do
		local c = colors[i]
		text_obj:set_range_color(c.i - 1, c.j, c.color)
	end
end

function _hudToolBox:animate_ui(total_t, callback)
	local t = 0
	local const_frames = 0
	local count_frames = const_frames + 1
	while t < total_t do
		coroutine.yield()
		t = t + TimerManager:main():delta_time()
		if count_frames >= const_frames then
			callback(t / total_t, t)
			count_frames = 0
		end
		count_frames = count_frames + 1
	end

	callback(1, total_t)
end

function _hudToolBox:animate_inf_ui(callback, framerate)
	framerate = tonumber(framerate)
	local const_frames = (framerate and (1 / framerate)) or 0
	local count_frames = const_frames + 1
	while true do
		coroutine.yield()
		if count_frames >= const_frames then
			callback()
			count_frames = 0
		end
		count_frames = count_frames + 1
	end

	callback()
end

--* Color utils
function _hudToolBox:rgb255(...)
	local items = { ... }
	local num = #items
	if num == 4 then
		return Color(items[1] / 255, items[2] / 255, items[3] / 255, items[4] / 255)
	end

	if num == 3 then
		return Color(items[1] / 255, items[2] / 255, items[3] / 255)
	end

	return Color.white
end

function _hudToolBox:blend_colors(current, target, blend)
	local result = {
		r = (current.r * blend) + (target.r * (1 - blend)),
		g = (current.g * blend) + (target.g * (1 - blend)),
		b = (current.b * blend) + (target.b * (1 - blend)),
	}

	return Color(result.r, result.g, result.b)
end

--* string stuff
function _hudToolBox:read_color_tags(text_panel_obj)
	local string_data = {}

	local splitString = function(s, i)
		i = (i or 0) + 1
		local j = s:sub(i, i)
		if j == "" then
			return
		end
		j = s:find(j == "[" and "]" or ".%f[[%z]", i) or #s
		table.insert(string_data, { i, j, s:sub(i, j) })
		return j
	end

	for k, v in splitString, text_panel_obj:text() do
		-- nothing
	end

	local start_count = 0
	local commands = {}
	local command_count = 0
	local real_text = ""
	for i, v in pairs(string_data) do
		if string.lower(v[3]):find("color=") then
			command_count = command_count + 1
			local temp = {}
			for word in string.gmatch(v[3]:match("%(([^%)]+)"), "([^,]+)") do
				table.insert(temp, tonumber(word))
			end
			table.insert(commands, { start = start_count, ending = 0, color = temp })
		elseif string.lower(v[3]):find("/color") then
			commands[command_count].ending = start_count
		else
			start_count = start_count + utf8.len(v[3])
			real_text = real_text .. v[3]
		end
	end

	text_panel_obj:set_text(real_text)

	for _, v in pairs(commands) do
		text_panel_obj:set_range_color(v.start, v.ending, Color(unpack(v.color)))
	end

	-- in case we need it back.
	return text_panel_obj
end

--* Player utils
function _hudToolBox:player_movement_state()
	local unit = self:player()

	return unit and unit:movement():current_state()
end

function _hudToolBox:player_state_name()
	return managers.player and managers.player:current_state()
end
