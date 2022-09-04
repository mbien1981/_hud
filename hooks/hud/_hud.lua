if not rawget(_G, "_hud") then
	rawset(_G, "_hud", {
		_classes = {},
	})

	-- https://github.com/zReko/zMenuPub/blob/main/menu/main.lua#L11
	function _hud:debug_panel_fill(panel, colorr)
		panel:rect({ color = colorr, visible = true, alpha = 0.5, layer = 10000 })
	end

	-- https://github.com/zReko/zMenuPub/blob/main/menu/main.lua#L14
	function _hud:debug_panel_outline(panel, colorr, layer)
		panel:rect({
			valign = "grow",
			halign = "grow",
			h = 1,
			color = colorr,
			visible = true,
			alpha = 0.5,
			layer = layer or 1000,
		})
		panel:rect({
			valign = "grow",
			halign = "grow",
			y = panel:h() - 1,
			h = 1,
			color = colorr,
			visible = true,
			alpha = 0.5,
			layer = layer or 1000,
		})
		panel:rect({
			valign = "grow",
			halign = "grow",
			w = 1,
			color = colorr,
			visible = true,
			alpha = 0.5,
			layer = layer or 1000,
		})
		panel:rect({
			valign = "grow",
			halign = "grow",
			x = panel:w() - 1,
			w = 1,
			color = colorr,
			visible = true,
			alpha = 0.5,
			layer = layer or 1000,
		})
	end

	-- https://github.com/zReko/zMenuPub/blob/main/tools/Tools.lua#L158
	function _hud:animate_ui(TOTAL_T, callback)
		local t = 0
		local const_frames = 0
		local count_frames = const_frames + 1
		while t < TOTAL_T do
			coroutine.yield()
			t = t + TimerManager:main():delta_time()
			if count_frames >= const_frames then
				callback(t / TOTAL_T, t)
				count_frames = 0
			end
			count_frames = count_frames + 1
		end
		callback(1, TOTAL_T)
	end

	function _hud.blend_colors(c1, c2, blend)
		local result = {
			r = (c1.r * blend) + (c2.r * (1 - blend)),
			g = (c1.g * blend) + (c2.g * (1 - blend)),
			b = (c1.b * blend) + (c2.b * (1 - blend)),
		}

		return Color(result.r, result.g, result.b)
	end

	function _hud.update_text_rect(text)
		local _, _, w, h = text:text_rect()
		text:set_w(w)
		text:set_h(h)
	end

	function _hud:get_class(class)
		return self._classes[class]
	end

	function _hud:update()
		for _, class in pairs(self._classes) do
			if class.update then
				class:update()
			end
		end
	end

	function _hud.conf(setting)
		return D:conf(setting)
	end
end

local module = ... or D:module("_hud")
if RequiredScript == "lib/managers/hudmanager" then
	local HUDManager = module:hook_class("HUDManager")
	module:post_hook(50, HUDManager, "update", function(self)
		local _hud = rawget(_G, "_hud")
		if _hud then
			_hud:update()
		end
	end, false)
end
