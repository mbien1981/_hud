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
function _hudToolBox:get_longest_word(text)
	local words = {}
	text:gsub("([^%s_%-+]+)", function(w)
		table.insert(words, w)
	end)

	local longest_n, longest_i = 0, 1
	for i = 1, #words do
		local n = #words[i]
		if n > longest_n then
			longest_i = i
			longest_n = n
		end
	end

	return words[longest_i]
end

function _hudToolBox:string_format(text, macros)
	return text:gsub("($([^%s;#]+);?)", function(full_match, macro_name)
		return macros[macro_name:upper()] or full_match
	end)
end

--* Player utils
function _hudToolBox:player_movement_state()
	local unit = self:player()

	return unit and unit:movement():current_state()
end

function _hudToolBox:player_state_name()
	return managers.player and managers.player:current_state()
end
