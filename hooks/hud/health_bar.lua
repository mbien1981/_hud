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
		font_size = 11 * self.scales.hud * self.scales.font, -- 12 is still to big imo
		layer = 1,
		x = 4,
		y = 4,
	})

	self._player_downs = self.main_panel:text({
		text = "0",
		font = self.font,
		font_size = 11 * self.scales.hud * self.scales.font,
		layer = 2,
	})

	--
	self._armor_value = self.main_panel:text({
		text = "0",
		color = self.colors.armor,
		font = self.font,
		font_size = 11 * self.scales.hud * self.scales.font,
		layer = 1,
	})

	self._armor_regen_timer = self.main_panel:text({
		text = "0.00s",
		color = self.colors.armor,
		font = self.font,
		font_size = 11 * self.scales.hud * self.scales.font,
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
		name:gsub("([^%s_%-+]+)", function(w)
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
		name = words[longest_i]
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

	self._player_downs:set_font_size(11 * self.scales.hud * self.scales.font)
	self._player_name:set_font_size(14 * self.scales.hud * self.scales.font)
	self._player_level:set_font_size(11 * self.scales.hud * self.scales.font)
	self._armor_regen_timer:set_font_size(11 * self.scales.hud * self.scales.font)
	self._armor_value:set_font_size(11 * self.scales.hud * self.scales.font)
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

	-- we use the dahm down counter instead of implementing a custom one.
	self._player_downs:set_text(managers.hud._hud_health_downs:text())

	local use_alt_armor = D:conf("_hud_use_alt_armor")

	self._armor_bar:set_visible(not use_alt_armor)
	self._armor_background:set_visible(use_alt_armor)
	self._alternative_armor_bar:set_visible(use_alt_armor)

	self._armor_value:set_visible(D:conf("_hud_enable_raw_armor_text"))
	self._armor_value:set_text(string.format("%.0f", p_damage._armor * 10 or 0))

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
