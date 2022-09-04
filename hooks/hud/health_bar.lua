local is_playing = function()
	return BaseNetworkHandler._gamestate_filter.any_ingame_playing[game_state_machine:last_queued_state_name()]
end

local _hud = rawget(_G, "_hud")
if _hud then
	_hud._classes["_health_panel"] = {}

	local _health_panel = _hud._classes["_health_panel"]

	function _health_panel:init()
		if not is_playing() then
			return
		end

		self._initialized = true
		self._visible = false

		self._ws = managers.gui_data:create_fullscreen_workspace()
		self._panel = self._ws:panel():panel({
			visible = true,
			alpha = 1,
			layer = -100,
		})

		self._colors = {
			_black = Color.black,
			_grey = Color("ECECEC"),
			_red = Color("b8392e"),
			_green = Color(0.5, 1, 0.5),
			_armor = Color("1e90ff"), -- dodger blue
		}

		self._current_health = 0
		self._current_armor = 0

		self:setup_panels()
	end

	function _health_panel:setup_panels()
		if not self._initialized then
			self:init()
			return
		end

		self._panel:clear()

		self._hud_ws = self._panel:panel()

		local mugshots = {
			["german"] = 2,
			["american"] = 1,
			["russian"] = 3,
			["spanish"] = 4,
		}

		local peer = managers.network:session():local_peer()
		local character = managers.criminals:local_character_name()
		local mask_set = peer:mask_set()
		local mask_id = mugshots[character]

		local set = tweak_data.mask_sets[mask_set][mask_id]
		local mugshot = set.mask_icon

		local image, rect = tweak_data.hud_icons:get_icon_data(mugshot)

		self._gradient = self._hud_ws:gradient({
			layer = 0,
			gradient_points = {
				0,
				Color(0.4, 0, 0, 0),
				1,
				Color(0, 0, 0, 0),
			},
		})

		self._mugshot = self._hud_ws:bitmap({
			texture = image,
			texture_rect = rect,
			layer = 1,
			x = 4,
			y = 4,
		})

		local icon, texture_rect = tweak_data.hud_icons:get_icon_data("mugshot_in_custody")
		self._state_icon = self._hud_ws:bitmap({
			texture = icon,
			texture_rect = texture_rect,
			visible = false,
			layer = 2,
		})

		self._name = self._hud_ws:text({
			text = peer:name(),
			font = "fonts/font_univers_530_bold",
			font_size = 22,
			x = 4,
			y = 4,
		})

		self._level = self._hud_ws:text({
			text = "0",
			font = "fonts/font_univers_530_bold",
			font_size = 16,
			x = 4,
			y = 4,
		})

		self._downs = self._hud_ws:text({
			text = "0",
			font = "fonts/font_univers_530_bold",
			font_size = 14,
			layer = 2,
		})

		self._armor_timer = self._hud_ws:text({
			text = "0.00s",
			color = self._colors._armor,
			font = "fonts/font_univers_530_bold",
			font_size = 14,
			layer = 2,
			visible = false,
		})

		self._health_bg = self._hud_ws:rect({
			color = self._colors._black,
			h = 8,
		})
		self._health_bar = self._hud_ws:rect({ h = 8, w = 0 })

		self._armor_bar = self._hud_ws:rect({
			color = self._colors._armor,
			w = 0,
			h = 2,
		})

		self:align_panels()
	end

	function _health_panel:align_panels()
		local _, _, w, h = self._name:text_rect()
		self._name:set_w(w)
		self._name:set_h(h)

		local _, _, w, h = self._level:text_rect()
		self._level:set_w(w)
		self._level:set_h(h)

		local _, _, w, h = self._downs:text_rect()
		self._downs:set_w(w)
		self._downs:set_h(h)

		local _, _, w, h = self._armor_timer:text_rect()
		self._armor_timer:set_w(w)
		self._armor_timer:set_h(h)

		self._name:set_left(self._mugshot:right() + 4)

		self._downs:set_top(self._mugshot:top())
		self._downs:set_right(self._mugshot:right() - 2)

		self._hud_ws:set_h(self._mugshot:h() + 8)
		self._hud_ws:set_w(176 * tweak_data.scale.hud_mugshot_multiplier + self._mugshot:w() + 8)

		local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD)
		if not hud then
			return
		end

		self._visible = hud.panel:visible()

		self._hud_ws:set_bottom(hud.panel:bottom())
		self._hud_ws:set_left(hud.health_panel:right() - self._mugshot:w() / 2)

		self._gradient:set_size(self._hud_ws:w(), self._hud_ws:h())

		self._state_icon:set_center(self._mugshot:center())

		self._health_bg:set_w(self._hud_ws:w() - self._mugshot:w() - 12)

		self._health_bg:set_left(self._mugshot:right() + 4)
		self._health_bg:set_top(self._name:bottom())
		--
		self._health_bar:set_left(self._health_bg:left())
		self._health_bar:set_top(self._health_bg:top())
		--
		self._armor_bar:set_left(self._health_bg:left())
		self._armor_bar:set_bottom(self._health_bg:bottom())

		self._armor_timer:set_lefttop(self._armor_bar:leftbottom())

		self._level:set_right(self._health_bg:right())
	end

	function _health_panel:update_info()
		if not self._initialized then
			self:init()
		end

		self._level:set_text(managers.experience:current_level())

		-- * health and armor
		local l_player = managers.player:player_unit()
		if not alive(l_player) then
			return
		end

		local p_damage = l_player:character_damage()

		local current_health = math.ceil((p_damage._health or 0) * 10)
		local max_health = math.ceil((p_damage:_max_health() or 0) * 10)
		local health_percentage = math.clamp(current_health / max_health, 0, 1)

		local current_armor = math.ceil((p_damage._armor or 0) * 10)
		local max_armor = math.ceil((p_damage:_max_armor() or 0) * 10)
		local armor_percentage = math.clamp(current_armor / max_armor, 0, 1)

		if self._current_health ~= current_health then
			local lower = self._current_health > current_health

			self._health_bar:stop()
			self._health_bar:animate(function(o)
				_hud:animate_ui(1, function(p)
					o:set_w(math.lerp(o:w(), self._health_bg:w() * health_percentage, p))

					local health_color = ((health_percentage > 0.25) and self._colors._grey) or self._colors._red
					local damage_color = lower and self._colors._red or self._colors._green
					o:set_color(_hud:blend_colors(health_color, damage_color, p))
				end)
			end)

			self._current_health = current_health
		end

		if self._current_armor ~= current_armor then
			self._armor_bar:animate(function(o)
				_hud:animate_ui(1, function(p)
					o:set_w(math.lerp(o:w(), self._health_bg:w() * armor_percentage, p))
				end)
			end)

			self._current_armor = current_armor
		end

		local regen_timer = p_damage._regenerate_timer
		if regen_timer then
			self._armor_timer:set_text(string.format("%.2fs", regen_timer))
		end

		self._armor_timer:set_visible((type(regen_timer) == "number") and _hud.conf("_hud_enable_armor_timer"))

		-- we use dahm down counter instead of implementing a custom one.
		self._downs:set_text(managers.hud._hud_health_downs:text())

		self:align_panels()
	end

	function _health_panel:update_mugshot()
		local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD)
		if hud then
			hud.health_panel:hide()
		end

		local states = {
			bleed_out = "mugshot_downed",
			incapacitated = "mugshot_downed",
			tased = "mugshot_electrified",
			arrested = "mugshot_cuffed",
			custody = "mugshot_in_custody",
		}

		local state
		local current_state = managers.player:current_state()

		if not alive(managers.player:player_unit()) then
			state = "custody"
		end

		local state_icon = states[state or current_state] or nil

		self._mugshot:set_alpha(state_icon and 0.5 or 1)

		self._state_icon:set_visible(state_icon)

		if not state_icon then
			return
		end

		local icon, texture_rect = tweak_data.hud_icons:get_icon_data(state_icon)
		self._state_icon:set_image(icon, texture_rect[1], texture_rect[2], texture_rect[3], texture_rect[4])
	end

	function _health_panel:anim_take_damage()
		local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD)
		if not hud then
			return
		end

		self._gradient:animate(hud.mugshot_damage_taken)
	end

	function _health_panel:layout_mugshots()
		if not managers.hud then
			return
		end

		local hud = managers.hud:script(PlayerBase.PLAYER_HUD)
		if not hud then
			return
		end

		local mugshots = managers.hud._hud.mugshots
		for i, mugshot in ipairs(mugshots) do
			local panel = mugshot.panel
			local height = panel:h()

			local y = ((i == 1) and (self._hud_ws:world_y() - height - 4))
				or i == 2 and mugshots[1].panel:top() - 2 * tweak_data.scale.hud_health_multiplier
				or i == 3 and mugshots[2].panel:top() - 2 * tweak_data.scale.hud_health_multiplier

			panel:set_bottom(y)
			panel:set_left(self._panel:world_x())
			panel:set_visible(panel:parent():visible())
			panel:set_layer(-1150)
		end
	end

	function _health_panel:update()
		if not self._initialized then
			self:init()
			return
		end

		self:update_info()
		self:update_mugshot()
		self:layout_mugshots()
	end
end

local module = ... or D:module("_hud")

if RequiredScript == "lib/units/beings/player/playerdamage" then
	local PlayerDamage = module:hook_class("PlayerDamage")
	for _, func in pairs({ "damage_bullet", "damage_killzone", "damage_explosion" }) do
		module:post_hook(50, PlayerDamage, func, function(...)
			local _hud = rawget(_G, "_hud")
			if _hud then
				local _health_panel = _hud:get_class("_health_panel")
				if _health_panel then
					_health_panel:anim_take_damage()
				end
			end
		end, false)
	end
end
