local _sdk = rawget(_G, "_sdk")
local _updator = rawget(_G, "_updator")

if not rawget(_G, "CustomReloadPanel") then
	rawset(_G, "CustomReloadPanel", {})
	function CustomReloadPanel:init()
		self._initialized = true

		self._ws = managers.gui_data:create_fullscreen_workspace()
		self._panel = self._ws:panel():panel({
			visible = false,
			alpha = 1,
			layer = 150,
		})

		self:setup_panels()
	end

	function CustomReloadPanel:setup_panels()
		if not self._initialized then
			self:init()
			return
		end

		self._panel:clear()

		self._reload_panel = self._panel:panel({
			w = self._panel:w() / 4,
			h = 12,
		})
		self._reload_panel:rect({
			name = "background",
			color = Color.black,
			alpha = 0.4,
			layer = -1,
		})
		self._reload_panel:rect({
			name = "progress_bar",
			color = Color.white,
			alpha = 0.4,
			layer = -1,
			x = 2,
			y = 2,
			w = self._reload_panel:w() - 4,
			h = self._reload_panel:h() - 4,
		})

		self._reload_panel:set_world_center_x(self._panel:center_x())
		self._reload_panel:set_world_center_y(self._panel:h() * 0.75)

		self._reload_timer = self._panel:text({
			text = "0.00s",
			font = "fonts/font_univers_530_bold",
			font_size = 22,
			x = 4,
			y = 4,
		})
		_sdk:update_text_rect(self._reload_timer)

		self._reload_timer:set_leftbottom(self._reload_panel:lefttop())
	end

	function CustomReloadPanel:update()
		if not self._initialized then
			self:init()
		end

		if not D:conf("_hud_reload_panel") then
			return
		end

		local p_unit = managers.player:player_unit()
		if not alive(p_unit) then
			return
		end

		local state = p_unit:movement():current_state()

		if state._is_reloading and state:_is_reloading() then
			self._panel:show()

			local current_timer = tonumber(state:_is_reloading() - TimerManager:main():time()) or 0
			if not self._reload_t then
				self._reload_t = current_timer
			end

			self._reload_timer:set_text(string.format("%.2fs", current_timer))
			_sdk:update_text_rect(self._reload_timer)

			local reload_percentage = math.clamp(current_timer / self._reload_t, 0, 1)

			local bg = self._reload_panel:child("background")
			local bar = self._reload_panel:child("progress_bar")
			bar:set_w((bg:w() - 4) * reload_percentage)
			return
		end

		self._reload_t = nil
		self._panel:hide()
	end

	_updator:add(function()
		CustomReloadPanel:update()
	end, "_hud_reload_timer_update")
end
