-- local _sdk = rawget(_G, "_sdk")
-- local _updator = rawget(_G, "_updator")
-- if not rawget(_G, "CustomHealthPanel") then
-- 	rawset(_G, "CustomHealthPanel", {})
-- 	function CustomHealthPanel:init()
-- 		self._initialized = true
-- 		self._visible = false

-- 		self._ws = managers.gui_data:create_fullscreen_workspace()
-- 		self._panel = self._ws:panel():panel({
-- 			visible = true,
-- 			alpha = 1,
-- 			layer = -100,
-- 		})

-- 		self._colors = {
-- 			_black = Color.black,
-- 			_name = D:conf("_hud_name_color"),
-- 			_health = D:conf("_hud_health_color"),
-- 			_hurt = D:conf("_hud_hurt_color"),
-- 			_patch = D:conf("_hud_patch_color"),
-- 			_armor = D:conf("_hud_armor_color"),
-- 		}

-- 		self._current_health = 0
-- 		self._current_armor = 0

-- 		self:setup_panels()
-- 	end

-- 	function CustomHealthPanel:setup_panels()
-- 		self._panel:clear()

-- 		self._hud_ws = self._panel:panel()

-- 		local mugshots = {
-- 			["german"] = 2,
-- 			["american"] = 1,
-- 			["russian"] = 3,
-- 			["spanish"] = 4,
-- 		}

-- 		local peer = managers.network:session():local_peer()
-- 		self._peer = peer

-- 		local character = managers.criminals:local_character_name()
-- 		local mask_set = peer:mask_set()
-- 		local mask_id = mugshots[character]

-- 		local set = tweak_data.mask_sets[mask_set][mask_id]
-- 		local mugshot = set.mask_icon

-- 		local image, rect = tweak_data.hud_icons:get_icon_data(mugshot)

-- 		self._gradient = self._hud_ws:gradient({
-- 			gradient_points = {
-- 				0,
-- 				Color(0.4, 0, 0, 0),
-- 				1,
-- 				Color(0, 0, 0, 0),
-- 			},
-- 			layer = -1,
-- 		})

-- 		self._mugshot = self._hud_ws:bitmap({
-- 			texture = image,
-- 			texture_rect = rect,
-- 			layer = 1,
-- 			x = 4,
-- 			y = 4,
-- 		})

-- 		local icon, texture_rect = tweak_data.hud_icons:get_icon_data("mugshot_in_custody")
-- 		self._state_icon = self._hud_ws:bitmap({
-- 			texture = icon,
-- 			texture_rect = texture_rect,
-- 			visible = true,
-- 			alpha = 0,
-- 			layer = 2,
-- 		})

-- 		local name = peer:name()
-- 		if D:conf("_hud_long_name_splitting") and utf8.len(name) > 16 then
-- 			local words = {}
-- 			name:gsub("([^%s]+)", function(w)
-- 				table.insert(words, w)
-- 			end)

-- 			table.sort(words, function(a, b)
-- 				return #a > #b
-- 			end)

-- 			name = words[1]
-- 		end

-- 		self._name = self._hud_ws:text({
-- 			text = name,
-- 			font = "fonts/font_univers_530_bold",
-- 			font_size = 22,
-- 			layer = 1,
-- 			x = 4,
-- 			y = 4,
-- 		})

-- 		self._level = self._hud_ws:text({
-- 			text = "0",
-- 			font = "fonts/font_univers_530_bold",
-- 			font_size = 16,
-- 			layer = 1,
-- 			x = 4,
-- 			y = 4,
-- 		})

-- 		self._downs = self._hud_ws:text({
-- 			text = "0",
-- 			font = "fonts/font_univers_530_bold",
-- 			font_size = 14 * tweak_data.scale.hud_mugshot_multiplier,
-- 			layer = 2,
-- 		})

-- 		self._armor_timer = self._hud_ws:text({
-- 			text = "0.00s",
-- 			color = self._colors._armor,
-- 			font = "fonts/font_univers_530_bold",
-- 			font_size = 14 * tweak_data.scale.hud_mugshot_multiplier,
-- 			layer = 1,
-- 			visible = false,
-- 		})

-- 		self._raw_armor = self._hud_ws:text({
-- 			text = "0",
-- 			color = self._colors._armor,
-- 			font = "fonts/font_univers_530_bold",
-- 			font_size = 14 * tweak_data.scale.hud_mugshot_multiplier,
-- 			layer = 1,
-- 			visible = false,
-- 		})

-- 		self._health_bg = self._hud_ws:rect({
-- 			color = self._colors._black,
-- 			layer = 1,
-- 			h = 8,
-- 		})
-- 		self._health_bar = self._hud_ws:rect({ layer = 2, h = 8, w = 0 })

-- 		self._armor_bar = self._hud_ws:rect({
-- 			color = self._colors._armor,
-- 			layer = 3,
-- 			w = 0,
-- 			h = 2,
-- 		})

-- 		self._armor_bg = self._hud_ws:rect({
-- 			color = self._colors._black,
-- 			layer = 1,
-- 			h = 8,
-- 		})
-- 		self._alternative_armor_bar = self._hud_ws:rect({
-- 			color = self._colors._armor,
-- 			layer = 2,
-- 			h = 8,
-- 			w = 0,
-- 		})

-- 		self:align_panels()
-- 	end

-- 	function CustomHealthPanel:align_panels()
-- 		_sdk:update_text_rect(self._name)
-- 		_sdk:update_text_rect(self._level)
-- 		_sdk:update_text_rect(self._downs)
-- 		_sdk:update_text_rect(self._armor_timer)
-- 		_sdk:update_text_rect(self._raw_armor)

-- 		self._name:set_left(self._mugshot:right() + 4)

-- 		self._downs:set_top(self._mugshot:top())
-- 		self._downs:set_right(self._mugshot:right() - 2)

-- 		self._hud_ws:set_h(self._mugshot:h() + 8)
-- 		self._hud_ws:set_w(176 * tweak_data.scale.hud_mugshot_multiplier + self._mugshot:w() + 8)

-- 		local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD)
-- 		if not hud then
-- 			return
-- 		end

-- 		self._visible = hud.panel:visible()

-- 		self._hud_ws:set_world_bottom(hud.panel:world_bottom() - 8)
-- 		self._hud_ws:set_world_left(hud.health_panel:world_right() - (self._mugshot:w() / 2))

-- 		self._gradient:set_size(self._hud_ws:w(), self._hud_ws:h())

-- 		self._state_icon:set_center(self._mugshot:center())

-- 		self._health_bg:set_w(self._hud_ws:w() - self._mugshot:w() - 12)

-- 		self._health_bg:set_left(self._mugshot:right() + 4)
-- 		self._health_bg:set_top(self._name:bottom())
-- 		--
-- 		self._health_bar:set_left(self._health_bg:left())
-- 		self._health_bar:set_top(self._health_bg:top())
-- 		--
-- 		self._armor_bar:set_left(self._health_bg:left())
-- 		self._armor_bar:set_bottom(self._health_bg:bottom())

-- 		self._armor_bg:set_w(self._health_bg:w())
-- 		self._armor_bg:set_left(self._health_bg:left())
-- 		self._armor_bg:set_top(self._health_bg:bottom() + 4)

-- 		self._alternative_armor_bar:set_left(self._armor_bg:left())
-- 		self._alternative_armor_bar:set_top(self._armor_bg:top())

-- 		self._armor_timer:set_lefttop(self[self._use_alt_armor and "_armor_bg" or "_armor_bar"]:leftbottom())
-- 		self._raw_armor:set_righttop(self[self._use_alt_armor and "_armor_bg" or "_health_bg"]:rightbottom())

-- 		self._level:set_right(self._health_bg:right())
-- 	end

-- 	function CustomHealthPanel:update_info()
-- 		if not self._initialized then
-- 			self:init()
-- 		end

-- 		local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD)
-- 		if not hud then
-- 			self._panel:hide()
-- 			return
-- 		end

-- 		self._panel:set_visible(hud.health_panel:parent():visible())

-- 		local _name_color = D:conf("_hud_name_use_peer_color") and tweak_data.chat_colors[self._peer:id()]
-- 			or self._colors._name
-- 		self._name:set_color(_name_color)

-- 		self._level:set_text(managers.experience:current_virtual_level(true)) --managers.experience:current_level()

-- 		-- * health and armor
-- 		local l_player = managers.player:player_unit()
-- 		if not alive(l_player) then
-- 			return
-- 		end

-- 		local p_damage = l_player:character_damage()

-- 		local current_health = math.ceil((p_damage._health or 0) * 10)
-- 		local max_health = math.ceil((p_damage:_max_health() or 0) * 10)
-- 		local health_percentage = math.clamp(current_health / max_health, 0, 1)

-- 		local current_armor = math.ceil((p_damage._armor or 0) * 10)
-- 		local max_armor = math.ceil((p_damage:_max_armor() or 0) * 10)
-- 		local armor_percentage = math.clamp(current_armor / max_armor, 0, 1)

-- 		if self._current_health ~= current_health then
-- 			local lower = self._current_health > current_health

-- 			self._health_bar:stop()
-- 			self._health_bar:animate(function(o)
-- 				_sdk:animate_ui(1, function(p)
-- 					o:set_w(math.lerp(o:w(), self._health_bg:w() * health_percentage, p))

-- 					local health_color = ((health_percentage > 0.25) and self._colors._health) or self._colors._hurt
-- 					local damage_color = lower and self._colors._hurt or self._colors._patch
-- 					o:set_color(_sdk:blend_colors(health_color, damage_color, p))
-- 				end)

-- 				o:set_w(self._health_bg:w() * health_percentage)
-- 			end)

-- 			self._current_health = current_health
-- 		end

-- 		if self._current_armor ~= current_armor then
-- 			self._armor_bar:animate(function(o)
-- 				_sdk:animate_ui(0.2, function(p)
-- 					o:set_w(math.lerp(o:w(), self._health_bg:w() * armor_percentage, p))
-- 					self._alternative_armor_bar:set_w(math.lerp(o:w(), self._health_bg:w() * armor_percentage, p))
-- 				end)

-- 				o:set_w(self._health_bg:w() * armor_percentage)
-- 			end)

-- 			self._current_armor = current_armor
-- 		end

-- 		self._use_alt_armor = D:conf("_hud_use_alt_armor")

-- 		self._armor_bar:set_visible(not self._use_alt_armor)
-- 		self._armor_bg:set_visible(self._use_alt_armor)
-- 		self._alternative_armor_bar:set_visible(self._use_alt_armor)

-- 		self._raw_armor:set_visible(D:conf("_hud_enable_raw_armor_text"))
-- 		self._raw_armor:set_text(string.format("%.0f", p_damage._armor * 10 or 0))

-- 		local regen_timer = p_damage._regenerate_timer
-- 		if regen_timer then
-- 			self._armor_timer:set_text(string.format("%.2fs", regen_timer))
-- 		end

-- 		self._armor_timer:set_visible((type(regen_timer) == "number") and D:conf("_hud_enable_armor_timer"))

-- 		-- we use dahm down counter instead of implementing a custom one.
-- 		self._downs:set_text(managers.hud._hud_health_downs:text())

-- 		self:align_panels()
-- 	end

-- 	function CustomHealthPanel:update_mugshot()
-- 		self._workspace_width = self._workspace_width or self._hud_ws:w()

-- 		local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD)
-- 		if not hud or not self._panel:visible() then
-- 			return
-- 		end

-- 		hud.health_panel:hide()

-- 		local states = {
-- 			bleed_out = "mugshot_downed",
-- 			incapacitated = "mugshot_downed",
-- 			tased = "mugshot_electrified",
-- 			arrested = "mugshot_cuffed",
-- 			custody = "mugshot_in_custody",
-- 		}

-- 		local state
-- 		local current_state = managers.player:current_state()

-- 		if not alive(managers.player:player_unit()) then
-- 			state = "custody"
-- 		end

-- 		local state_icon = states[state or current_state] or nil
-- 		if self._state == state_icon then
-- 			return
-- 		end

-- 		self._state = state_icon

-- 		self._state_icon:stop()
-- 		self._hud_ws:stop()

-- 		if state then
-- 			self._hud_ws:animate(function(o)
-- 				_sdk:animate_ui(2, function(p)
-- 					o:set_w(math.lerp(o:w(), self._mugshot:w() + 8, p))
-- 				end)
-- 			end)
-- 		end

-- 		if state_icon then
-- 			local icon, texture_rect = tweak_data.hud_icons:get_icon_data(state_icon)
-- 			self._state_icon:set_image(icon, texture_rect[1], texture_rect[2], texture_rect[3], texture_rect[4])

-- 			self._state_icon:animate(function(o)
-- 				_sdk:animate_ui(2, function(p)
-- 					o:set_alpha(math.lerp(0, 1, p))
-- 					self._mugshot:set_alpha(math.lerp(1, 0.5, p))
-- 				end)
-- 			end)
-- 			return
-- 		end

-- 		self._state_icon:animate(function(o)
-- 			_sdk:animate_ui(2, function(p)
-- 				o:set_alpha(math.lerp(1, 0, p))
-- 				self._mugshot:set_alpha(math.lerp(0.5, 1, p))
-- 			end)
-- 		end)

-- 		self._hud_ws:animate(function(o)
-- 			_sdk:animate_ui(2, function(p)
-- 				o:set_w(math.lerp(o:w(), self._workspace_width, p))
-- 			end)
-- 		end)
-- 	end

-- 	function CustomHealthPanel:anim_take_damage()
-- 		local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD)
-- 		if not hud then
-- 			return
-- 		end

-- 		self._gradient:animate(hud.mugshot_damage_taken)
-- 	end

-- 	function CustomHealthPanel:layout_mugshots()
-- 		if not managers.hud then
-- 			return
-- 		end

-- 		local hud = managers.hud:script(PlayerBase.PLAYER_HUD)
-- 		if not hud then
-- 			return
-- 		end

-- 		local mugshots = managers.hud._hud.mugshots
-- 		for i, mugshot in ipairs(mugshots) do
-- 			local panel = mugshot.panel
-- 			local height = panel:h()

-- 			local y = ((i == 1) and (self._hud_ws:world_y() - height - 4))
-- 				or i == 2 and mugshots[1].panel:top() - 2 * tweak_data.scale.hud_health_multiplier
-- 				or i == 3 and mugshots[2].panel:top() - 2 * tweak_data.scale.hud_health_multiplier

-- 			panel:set_bottom(y)
-- 			panel:set_world_x(self._panel:world_x())
-- 			panel:set_visible(panel:parent():visible())
-- 			panel:set_layer(-1150)
-- 		end
-- 	end

-- 	function CustomHealthPanel:layout_chat()
-- 		if not managers.hud then
-- 			return
-- 		end

-- 		local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD)
-- 		local full_hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)
-- 		if not hud or not full_hud then
-- 			return
-- 		end

-- 		local hud_m = managers.hud
-- 		local mugshots = hud_m._hud.mugshots

-- 		if not next(mugshots) then
-- 			return
-- 		end

-- 		local state = full_hud:chat_output_state()
-- 		if state == "default" then
-- 			full_hud.panel
-- 				:child("textscroll")
-- 				:set_bottom(mugshots[#mugshots].panel:top() + hud_m._saferect_size.y * hud_m._workspace_size.h - 12)
-- 		else
-- 			full_hud.panel
-- 				:child("textscroll")
-- 				:set_bottom(hud.health_panel:bottom() + hud_m._saferect_size.y * hud_m._workspace_size.h - 4)
-- 		end
-- 	end

-- 	function CustomHealthPanel:update()
-- 		if not self._initialized then
-- 			self:init()
-- 			return
-- 		end

-- 		self:update_info()
-- 		self:update_mugshot()
-- 		self:layout_mugshots()
-- 		self:layout_chat()
-- 	end

-- 	_updator:add(function()
-- 		if not _sdk:is_playing() then
-- 			return
-- 		end

-- 		CustomHealthPanel:update()
-- 	end, "_hud_health_update")
-- end

-- local module = ... or D:module("_hud")

-- if RequiredScript == "lib/units/beings/player/playerdamage" then
-- 	local PlayerDamage = module:hook_class("PlayerDamage")
-- 	for _, func in pairs({ "damage_bullet", "damage_killzone", "damage_explosion" }) do
-- 		module:post_hook(50, PlayerDamage, func, function(...)
-- 			CustomHealthPanel:anim_take_damage()
-- 		end, false)
-- 	end
-- end

TestHealthPanel = class()
function TestHealthPanel:init()
	self._ws = managers.gui_data:create_fullscreen_workspace()
	self._panel = self._ws:panel():panel({
		alpha = 1,
		layer = -100,
	})

	self.visible = false
	self.font = "fonts/font_univers_530_bold"
	self.colors = {
		black = Color.black,
		name = D:conf("_hud_name_color"),
		health = D:conf("_hud_health_color"),
		hurt = D:conf("_hud_hurt_color"),
		patch = D:conf("_hud_patch_color"),
		armor = D:conf("_hud_armor_color"),
	}

	self.data = {
		peer = managers.network:session():local_peer(),
		current_health = 0,
		current_armor = 0,
	}

	local hud_scale = D:conf("_hud_scaling")
	local font_scale = D:conf("_hud_font_scaling")
	self.scales = {
		hud = hud_scale,
		font = hud_scale,
		panel = hud_scale * font_scale * 0.75,
	}

	self:setup_panels()

	_G._updator:add(function()
		if not _G._sdk:is_playing() then
			return
		end

		self:update()
	end, "_hud_health_update")
end

function TestHealthPanel:setup_panels()
	self.main_panel = self._panel:panel()
	self:create_background()
	self:create_mugshot()
	self:create_mugshot_status()
	self:create_player_data()
	self:create_health_and_armor()
	self:_layout()
end

function TestHealthPanel:create_background()
	self._background = self.main_panel:gradient({
		gradient_points = { 0, Color(0.4, 0, 0, 0), 1, Color(0, 0, 0, 0) },
		layer = -1,
	})
end

function TestHealthPanel:create_mugshot()
	local mugshot_ids = {
		["american"] = 1,
		["german"] = 2,
		["russian"] = 3,
		["spanish"] = 4,
	}

	local mask_id = mugshot_ids[managers.criminals:local_character_name()]
	local mask_set = tweak_data.mask_sets[self.data.peer:mask_set()][mask_id]
	local image, texture_rect = tweak_data.hud_icons:get_icon_data(mask_set.mask_icon)
	self._mugshot = self.main_panel:bitmap({
		texture = image,
		texture_rect = texture_rect,
		layer = 1,
		x = 4,
		y = 4,
		w = texture_rect[3] * self.scales.panel,
		h = texture_rect[4] * self.scales.panel,
	})

	self.data.mugshot_rect = texture_rect
end

function TestHealthPanel:create_mugshot_status()
	local icon, texture_rect = tweak_data.hud_icons:get_icon_data("mugshot_in_custody")
	self._mugshot_status = self.main_panel:bitmap({
		texture = icon,
		texture_rect = texture_rect,
		alpha = 0,
		layer = 2,
		w = texture_rect[3] * self.scales.panel,
		h = texture_rect[4] * self.scales.panel,
	})

	self.data.mugshot_status_rect = texture_rect
end

function TestHealthPanel:create_player_data()
	self._player_name = self.main_panel:text({
		text = "simon andersson",
		font = self.font,
		font_size = 14 * self.scales.hud * self.scales.font,
		layer = 1,
		x = 4,
		y = 4,
	})

	self._player_level = self.main_panel:text({
		text = "0",
		font = self.font,
		font_size = 14 * self.scales.hud * self.scales.font,
		layer = 1,
		x = 4,
		y = 4,
	})

	self._player_downs = self.main_panel:text({
		text = "0",
		font = self.font,
		font_size = 14 * self.scales.hud * self.scales.font,
		layer = 2,
	})

	--
	self._armor_value = self.main_panel:text({
		text = "0",
		color = self.colors.armor,
		font = self.font,
		font_size = 14 * self.scales.hud * self.scales.font,
		layer = 1,
	})

	self._armor_regen_timer = self.main_panel:text({
		text = "0.00s",
		color = self.colors.armor,
		font = self.font,
		font_size = 14 * self.scales.hud * self.scales.font,
		layer = 1,
	})
end

function TestHealthPanel:create_health_and_armor()
	self._health_bar = self.main_panel:rect({
		layer = 2,
		h = 8,
		w = 0,
	})
	self._health_background = self.main_panel:rect({
		color = self.colors.black,
		layer = 1,
		h = 8,
	})

	self._armor_bar = self.main_panel:rect({
		color = self.colors.armor,
		layer = 3,
		h = 2,
		w = 0,
	})

	--

	self._alternative_armor_bar = self.main_panel:rect({
		color = self.colors.armor,
		layer = 2,
		h = 8,
		w = 0,
	})
	self._armor_background = self.main_panel:rect({
		color = self.colors.black,
		layer = 1,
		h = 8,
	})
end

function TestHealthPanel:_layout()
	_G._sdk:update_text_rect(self._player_downs)
	_G._sdk:update_text_rect(self._player_name)
	_G._sdk:update_text_rect(self._player_level)
	_G._sdk:update_text_rect(self._armor_regen_timer)
	_G._sdk:update_text_rect(self._armor_value)

	self.main_panel:set_w((self._mugshot:w() + 8) + (176 * self.scales.panel))
	self.main_panel:set_h(self._mugshot:h() + 8)
	-- _sdk:debug_panel_outline(self.main_panel)

	self._background:set_size(self.main_panel:size())

	-- self._player_downs:set_righttop(self._mugshot:righttop())
	self._player_downs:set_top(self._mugshot:top())
	self._player_downs:set_right(self._mugshot:right() - 2)
	self._mugshot_status:set_center(self._mugshot:center())

	self._player_name:set_left(self._mugshot:right() + 4)
	self._player_name:set_top(self._mugshot:top())

	self._player_level:set_top(self._player_name:top())
	self._player_level:set_right(self.main_panel:w() - 4) -- main_panel:right() is out of bounds? wtf

	self._health_background:set_top(self._player_name:bottom() + 2)
	self._health_background:set_left(self._mugshot:right() + 4)
	self._health_background:set_w(self.main_panel:w() - self._mugshot:w() - 12)

	self._health_bar:set_leftbottom(self._health_background:leftbottom())

	self._armor_bar:set_leftbottom(self._health_background:leftbottom())

	self._armor_background:set_top(self._health_background:bottom() + 2)
	self._armor_background:set_left(self._health_background:left())
	self._armor_background:set_w(self._health_background:w())

	self._alternative_armor_bar:set_leftbottom(self._armor_background:leftbottom())

	self._armor_regen_timer:set_top(self._armor_background:bottom())
	self._armor_regen_timer:set_left(self._armor_background:left())

	self._armor_value:set_top(self._armor_regen_timer:top())
	self._armor_value:set_right(self._player_level:right())
end

function TestHealthPanel:get_player_name()
	local name = self.data.peer:name()
	if D:conf("_hud_long_name_splitting") and utf8.len(name) > 16 then
		local words = {}
		name:gsub("([^%s]+)", function(w)
			table.insert(words, w)
		end)

		table.sort(words, function(a, b)
			return #a > #b
		end)

		name = words[1]
	end

	return name
end

function TestHealthPanel:get_name_color()
	if D:conf("_hud_name_use_peer_color") then
		return tweak_data.chat_colors[self.data.peer:id()]
	end

	return self.colors.name
end

function TestHealthPanel:update_scaling()
	local hud_scale = D:conf("_hud_scaling")
	local font_scale = D:conf("_hud_font_scaling")

	self.scales = {
		hud = hud_scale,
		font = hud_scale,
		panel = hud_scale * font_scale * 0.75,
	}

	self._mugshot:set_w(self.data.mugshot_rect[3] * self.scales.panel)
	self._mugshot:set_h(self.data.mugshot_rect[4] * self.scales.panel)

	self._mugshot_status:set_w(self.data.mugshot_status_rect[3] * self.scales.panel)
	self._mugshot_status:set_h(self.data.mugshot_status_rect[4] * self.scales.panel)

	self._player_downs:set_font_size(14 * self.scales.hud * self.scales.font)
	self._player_name:set_font_size(14 * self.scales.hud * self.scales.font)
	self._player_level:set_font_size(14 * self.scales.hud * self.scales.font)
	self._armor_regen_timer:set_font_size(14 * self.scales.hud * self.scales.font)
	self._armor_value:set_font_size(14 * self.scales.hud * self.scales.font)
end

function TestHealthPanel:update_player_data()
	self._player_name:set_text(self:get_player_name())
	self._player_name:set_color(self:get_name_color())

	self._player_level:set_text(managers.experience:current_virtual_level(true))
end

function TestHealthPanel:update_health_and_armor()
	local p_unit = managers.player:player_unit()
	if not alive(p_unit) then
		return
	end

	local p_damage = p_unit:character_damage()

	local current_health = math.ceil((p_damage._health or 0) * 10)
	local max_health = math.ceil((p_damage:_max_health() or 0) * 10)
	local health_percentage = math.clamp(current_health / max_health, 0, 1)

	local current_armor = math.ceil((p_damage._armor or 0) * 10)
	local max_armor = math.ceil((p_damage:_max_armor() or 0) * 10)
	local armor_percentage = math.clamp(current_armor / max_armor, 0, 1)

	if self.data.current_health ~= current_health then
		local lower = self.data.current_health > current_health

		self._health_bar:stop()
		self._health_bar:animate(function(o)
			_G._sdk:animate_ui(1, function(p)
				o:set_w(math.lerp(o:w(), self._health_background:w() * health_percentage, p))

				local health_color = ((health_percentage > 0.25) and self.colors.health) or self.colors.hurt
				local damage_color = lower and self.colors.hurt or self.colors.patch
				o:set_color(_G._sdk:blend_colors(health_color, damage_color, p))
			end)

			o:set_w(self._health_bg:w() * health_percentage)
		end)

		self.data.current_health = current_health
	end

	if self.data.current_armor ~= current_armor then
		self._armor_bar:animate(function(o)
			_G._sdk:animate_ui(0.2, function(p)
				o:set_w(math.lerp(o:w(), self._armor_background:w() * armor_percentage, p))
				self._alternative_armor_bar:set_w(math.lerp(o:w(), self._armor_background:w() * armor_percentage, p))
			end)

			o:set_w(self._armor_background:w() * armor_percentage)
		end)

		self.data.current_armor = current_armor
	end

	local use_alt_armor = D:conf("_hud_use_alt_armor")

	self._armor_bar:set_visible(not use_alt_armor)
	self._armor_background:set_visible(use_alt_armor)
	self._alternative_armor_bar:set_visible(use_alt_armor)

	self._armor_value:set_visible(D:conf("_hud_enable_raw_armor_text"))
	self._armor_value:set_text(string.format("%.02f", p_damage._armor * 10 or 0))

	local regen_timer = p_damage._regenerate_timer
	if regen_timer then
		self._armor_regen_timer:set_text(string.format("%.2fs", regen_timer))
	end

	self._armor_regen_timer:set_visible((type(regen_timer) == "number") and D:conf("_hud_enable_armor_timer"))
end

function TestHealthPanel:update_mugshot()
	self.data.width = self.data.width or self.main_panel:w()

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
	if self.data.current_state == state_icon then
		return
	end

	self.data.current_state = state_icon

	self._mugshot_status:stop()
	self.main_panel:stop()

	if state then
		self.main_panel:animate(function(o)
			_G._sdk:animate_ui(2, function(p)
				o:set_w(math.lerp(o:w(), self._mugshot:w() + 8, p))
			end)
		end)
	end

	if state_icon then
		local icon, texture_rect = tweak_data.hud_icons:get_icon_data(state_icon)
		self._mugshot_status:set_image(icon, texture_rect[1], texture_rect[2], texture_rect[3], texture_rect[4])

		self._mugshot_status:animate(function(o)
			_G._sdk:animate_ui(2, function(p)
				o:set_alpha(math.lerp(0, 1, p))
				self._mugshot:set_alpha(math.lerp(1, 0.5, p))
			end)
		end)
		return
	end

	self._mugshot_status:animate(function(o)
		_G._sdk:animate_ui(2, function(p)
			o:set_alpha(math.lerp(1, 0, p))
			self._mugshot:set_alpha(math.lerp(0.5, 1, p))
		end)
	end)

	self.main_panel:animate(function(o)
		_G._sdk:animate_ui(2, function(p)
			o:set_w(math.lerp(o:w(), self._workspace_width, p))
		end)
	end)
end

function TestHealthPanel:layout_team_mugshots()
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

		local y = ((i == 1) and (self.main_panel:world_y() - height - 4))
			or i == 2 and mugshots[1].panel:top() - 2 * tweak_data.scale.hud_health_multiplier
			or i == 3 and mugshots[2].panel:top() - 2 * tweak_data.scale.hud_health_multiplier

		panel:set_bottom(y)
		panel:set_world_x(self._panel:world_x())
		panel:set_visible(panel:parent():visible())
		panel:set_layer(-1150)
	end
end

function TestHealthPanel:layout_vanilla_chat()
	if not managers.hud then
		return
	end

	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD)
	local full_hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)
	if not hud or not full_hud then
		return
	end

	local hud_m = managers.hud
	local mugshots = hud_m._hud.mugshots

	if not next(mugshots) then
		return
	end

	local state = full_hud:chat_output_state()
	if state == "default" then
		full_hud.panel
			:child("textscroll")
			:set_bottom(mugshots[#mugshots].panel:top() + hud_m._saferect_size.y * hud_m._workspace_size.h - 12)
	else
		full_hud.panel
			:child("textscroll")
			:set_bottom(hud.health_panel:bottom() + hud_m._saferect_size.y * hud_m._workspace_size.h - 4)
	end
end

function TestHealthPanel:update()
	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD)
	if not hud then
		return self._panel:hide()
	end

	hud.health_panel:hide()

	self._panel:set_visible(hud.health_panel:parent():visible())
	self.main_panel:set_world_bottom(hud.panel:world_bottom() - 8)
	self.main_panel:set_world_left(hud.health_panel:world_right() - (self._mugshot:w() / 2))

	self:update_scaling()
	self:update_player_data()
	self:update_health_and_armor()
	self:_layout()

	self:layout_team_mugshots()
	self:layout_vanilla_chat()

	if not self._panel:visible() then
		return
	end

	self:update_mugshot()
end

function TestHealthPanel:anim_take_damage()
	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD)
	if not hud then
		return
	end

	self._background:animate(hud.mugshot_damage_taken)
end

local module = ... or D:module("_hud")
if RequiredScript == "lib/states/ingamewaitingforplayers" then
	local IngameWaitingForPlayersState = module:hook_class("IngameWaitingForPlayersState")
	module:post_hook(50, IngameWaitingForPlayersState, "at_exit", function(...)
		rawset(_G, "CustomHealthPanel", TestHealthPanel:new())
	end, false)
end

if RequiredScript == "lib/units/beings/player/playerdamage" then
	local PlayerDamage = module:hook_class("PlayerDamage")
	for _, func in pairs({ "damage_bullet", "damage_killzone", "damage_explosion" }) do
		module:post_hook(50, PlayerDamage, func, function(...)
			CustomHealthPanel:anim_take_damage()
		end, false)
	end
end
