local _hud = rawget(_G, "_hud")
if _hud then
	_hud._classes["_kill_feed"] = {}

	local _kill_feed = _hud._classes["_kill_feed"]

	function _kill_feed:init()
		self.initialized = true

		self.row_height = 25
		self.font_size = 25

		self.font = "fonts/font_univers_530_bold"

		self.list_offset_y = 10
		self._current_entries = {}

		self.main_panel = managers.gui_data:create_saferect_workspace():panel({
			visible = true,
			alpha = 1,
			layer = 0,
		})
	end

	function _kill_feed:add_new_entry(params)
		if not self.initialized then
			self:init()
		end

		if #self._current_entries >= _hud.conf("_hud_kill_feed_max_rows") then
			self:animate_panel_x(self._current_entries[#self._current_entries].panel, 0.5, true)
			table.remove(self._current_entries, #self._current_entries)
		end

		local message_panel = self.main_panel:panel({
			alpha = 1,
			x = self.main_panel:right(), -- outside the screen
			y = self.list_offset_y + self.row_height,
			h = self.row_height,
		})
		local text = message_panel:text({
			text = tostring(params.message),
			font = self.font,
			font_size = self.font_size,
			color = Color.white,
			alpha = 1,
			x = message_panel.x,
			layer = 5,
			w = 2000,
		})
		_hud.read_color_tags(text)

		local width = select(3, text:text_rect()) + 8
		message_panel:set_w(width)

		message_panel:rect({
			color = Color.black,
			alpha = 0.5,
			w = width - 3,
			layer = -1,
		})

		local data = {
			text_panel = text,
			panel = message_panel,
			timer = TimerManager:main():time() + (params.time or 5),
		}

		-- table.insert(self._current_entries, 1, data)
		local index = next(self._current_entries) and #self._current_entries or 1
		table.insert(self._current_entries, index, data)

		for i, v in pairs(self._current_entries) do
			self:adjust_panel_height(v.panel, i, 0.5 / (i / 8))
		end
	end

	function _kill_feed:adjust_panel_height(panel, row, time)
		panel:stop()
		panel:animate(function(obj)
			_hud:animate_ui(time or 0, function(p)
				obj:set_y(math.lerp(obj:y(), self.list_offset_y + (self.row_height * row) + 5, p))
				obj:set_right(math.lerp(obj:right(), self.main_panel:right(), p))
			end)
		end)
	end

	function _kill_feed:animate_panel_x(panel, time, remove_on_end)
		panel:stop()
		panel:animate(function(obj)
			_hud:animate_ui(time or 0, function(p)
				obj:set_left(math.lerp(obj:left(), self.main_panel:right(), p))
				obj:set_alpha(math.lerp(1, 0, p))
				obj:set_layer(obj:layer() - 1)
			end)

			if remove_on_end then
				panel:parent():remove(panel)
			end
		end)
	end

	function _kill_feed:update()
		if not self.initialized then
			self:init()
		end

		for i = #self._current_entries, 1, -1 do
			local item = self._current_entries[i]
			if item.timer <= TimerManager:main():time() then
				local panel = item.panel
				table.remove(self._current_entries, i)
				self:animate_panel_x(panel, 0.3, true)

				for ii = i, #self._current_entries, 1 do
					self:adjust_panel_height(self._current_entries[ii].panel, ii, 2)
				end

				break
			end
		end
	end

	local color_str = function(str, color)
		if not str then
			return
		end

		local template = "[color=(%.2f,%.2f,%.2f)]%s[/color]"
		local r, g, b
		if type(color) == "userdata" then
			r, g, b = color.r, color.g, color.b
		else
			r, g, b = unpack(color)
		end

		return template:format(r, g, b, str)
	end

	local module = ... or D:module("_hud")
	local CopDamage = module:hook_class("CopDamage")

	module:post_hook(50, CopDamage, "_on_damage_received", function(self, damage_info)
		if not _hud.conf("_hud_enable_kill_feed") then
			return
		end

		if damage_info.result.type ~= "death" then
			return
		end

		local _unit = self._unit
		local _attacker = damage_info.attacker_unit

		local attacker_color = Color(0.5, 0.5, 0.5) -- team ai
		local victim_color = Color(0.5, 0.5, 0.5) -- regulars

		-- * Figure out who killed the victim
		local attacker_name = _attacker and _attacker:base()._tweak_table
		-- ? is it a bot
		local character_name = managers.criminals:character_name_by_unit(_attacker)
		if character_name then
			attacker_name = managers.localization:text("debug_" .. character_name)
		end

		-- ? is it a player
		if _attacker and (_attacker:base().is_husk_player or _attacker:base().is_local_player) then
			local peer = _attacker:network():peer()
			attacker_name = peer:name()
			attacker_color = tweak_data.chat_colors[peer:id()] -- human players
		end

		if not _attacker then
			attacker_name = "dropped weapon"
			attacker_color = Color(1, 0.5, 0.5)
		end

		-- * make sure we have a weapon unit for reference
		local _weapon_unit = damage_info.weapon_unit
		if not alive(_weapon_unit) and _attacker and _attacker:inventory() then
			_weapon_unit = _attacker:inventory():equipped_unit()
		end

		-- * determine the weapon used to kill the victim
		local weapon_name = _weapon_unit and _weapon_unit:base():get_name_id():gsub("_npc$", "")
		if damage_info.variant == "melee" then
			weapon_name = "melee"
		end

		if not alive(_weapon_unit) and not weapon_name then
			local _debug = _G._tracker
			if _debug then
				_debug:remove_tracker("error")
				_debug:add_tracker("kill feed", "could not determine weapon name", "error")
			end

			return
		end

		-- ? is it a special unit
		local _tweak_table = _unit:base()._tweak_table
		local priority_shout = tweak_data.character[_tweak_table].priority_shout
		if (_tweak_table == "sniper") or priority_shout and priority_shout ~= "Dia_10" then
			victim_color = Color("ffa500") -- specials
		end

		-- * show the feed message
		_kill_feed:add_new_entry({
			message = string.format(
				"%s [%s] %s",
				color_str(DLocalizer:romanize(attacker_name), attacker_color),
				weapon_name:pretty(true),
				color_str(_tweak_table:pretty(true), victim_color)
			),
			time = 5,
		})
	end)
end
