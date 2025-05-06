local module = ... or D:module("_hud")

if RequiredScript == "lib/managers/hudmanager" then
	local HUDManager = module:hook_class("HUDManager")
	module:post_hook(50, HUDManager, "_add_name_label", function(self, data)
		local name_labels = self._hud.name_labels

		local name_label_data = name_labels[#name_labels]
		if not name_label_data then
			return
		end

		local text = name_label_data.text
		local _, _, w, h = text:text_rect()
		local frame_panel = text:parent():panel({ layer = -5, w = w + 4, h = h })

		name_label_data.label_frame = frame_panel

		name_label_data.background = frame_panel:rect({ color = Color.black:with_alpha(0.4) })

		local is_husk_player = data.unit:base().is_husk_player
		local peer = is_husk_player and data.unit:network():peer()

		local line_color = peer and tweak_data.chat_colors[peer:id()] or D:conf("_hud_ai_contour_color")
		name_label_data.simple_health_bar = frame_panel:rect({
			color = line_color,
			layer = 2,
			y = frame_panel:h() - 2,
			h = 2,
		})

		name_label_data.is_team_ai = not is_husk_player

		if name_label_data.is_team_ai then
			return
		end

		local health_bar_icon, health_bar_rect = tweak_data.hud_icons:get_icon_data("mugshot_health_health")
		local health_bg_icon, health_bg_rect = tweak_data.hud_icons:get_icon_data("mugshot_health_background")
		local armor_bar_icon, armor_bar_rect = tweak_data.hud_icons:get_icon_data("mugshot_health_armor")

		local status_panel = text:parent():panel({ layer = -5, w = armor_bar_rect[3] + 1, h = h })
		name_label_data.health_panel = status_panel

		name_label_data.health_background = status_panel:bitmap({
			texture = health_bg_icon,
			texture_rect = health_bg_rect,
			layer = 1,
			w = health_bg_rect[3] * 0.75,
			h = h,
		})
		name_label_data.health_bar = status_panel:bitmap({
			texture = health_bar_icon,
			color = Color(0.5, 0.8, 0.4),
			texture_rect = health_bar_rect,
			layer = 2,
			w = health_bar_rect[3] * 0.75,
			h = h,
		})
		name_label_data.armor_bar = status_panel:bitmap({
			texture = armor_bar_icon,
			texture_rect = armor_bar_rect,
			layer = 3,
			w = armor_bar_rect[3] * 0.75,
			h = h,
		})

		return data.id
	end, false)

	module:hook(65, HUDManager, "_update_name_label_health", function(self, id, amount)
		local health_display = D:conf("_hud_name_label_health_display")
		if not id or health_display == "none" then
			return
		end

		local data
		for _, label in ipairs(self._hud.name_labels) do
			if label.id == id then
				data = label
				break
			end
		end

		if not data then
			return
		end

		local background = data.health_background
		if health_display == "simple" then
			data.simple_health_bar:set_w(background:w() * amount)
			return
		end

		local health_bar = data.health_bar
		if not alive(health_bar) then
			return
		end

		local color = amount < 0.33 and Color(1, 0, 0) or Color(0.5, 0.8, 0.4)
		health_bar:set_h(color)
		health_bar:set_h(background:h() * amount)
		health_bar:set_bottom(background:bottom())
	end)

	module:hook(65, HUDManager, "_update_name_label_armor", function(self, id, amount)
		if not id or D:conf("_hud_name_label_health_display") ~= "detailed" then
			return
		end

		for _, data in ipairs(self._hud.name_labels) do
			if data.id == id and alive(data.health_panel) then
				local background = data.health_background
				data.armor_bar:set_h(background:h() * amount)
				data.armor_bar:set_bottom(background:bottom())

				break
			end
		end
	end)

	module:post_hook(50, HUDManager, "_update_name_labels", function(self, t, dt)
		if self._name_labels_hidden then
			return
		end

		for _, data in ipairs(self._hud.name_labels) do
			self:_update_custom_name_label(data)
		end
	end, false)

	module:post_hook(50, HUDManager, "_update_custom_name_label", function(_, data)
		local use_custom_label = D:conf("_hud_use_custom_name_labels")

		local frame = data.label_frame
		local detailed_health = data.health_panel

		if not use_custom_label then
			frame:hide()

			if alive(detailed_health) then
				detailed_health:hide()
			end

			return
		end

		local is_visible = data.text:visible()

		frame:set_visible(is_visible)
		frame:set_center(data.text:center())

		local health_display = D:conf("_hud_name_label_health_display")
		if health_display == "none" then
			data.simple_health_bar:hide()

			if alive(detailed_health) then
				detailed_health:hide()
			end

			return
		end

		local is_team_ai = data.is_team_ai
		local show_simple_bar = health_display == "simple" or is_team_ai
		data.simple_health_bar:set_visible(show_simple_bar and is_visible)

		if not alive(detailed_health) or is_team_ai then
			return
		end

		detailed_health:set_visible(health_display == "detailed" and is_visible)
		detailed_health:set_righttop(frame:lefttop())
	end)

	module:pre_hook(50, HUDManager, "_remove_name_label", function(self, id)
		local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)
		if not hud then
			return
		end

		for _, data in ipairs(self._hud.name_labels) do
			if data.id == id then
				hud.panel:remove(data.label_frame)
				if alive(data.health_panel) then
					hud.panel:remove(data.health_panel)
				end
			end
		end
	end)
end

if RequiredScript == "lib/network/handlers/unitnetworkhandler" then
	local UnitNetworkHandler = module:hook_class("UnitNetworkHandler")
	module:post_hook(50, UnitNetworkHandler, "set_health", function(self, unit, percent, sender)
		if
			not alive(unit)
			or not self._verify_gamestate(self._gamestate_filter.any_ingame)
			or not self._verify_sender(sender)
		then
			return
		end

		managers.hud:_update_name_label_health(unit:unit_data().name_label_id, percent / 100)
	end)

	local UnitNetworkHandler = module:hook_class("UnitNetworkHandler")
	module:post_hook(50, UnitNetworkHandler, "set_armor", function(self, unit, percent, sender)
		if
			not alive(unit)
			or not self._verify_gamestate(self._gamestate_filter.any_ingame)
			or not self._verify_sender(sender)
		then
			return
		end

		managers.hud:_update_name_label_armor(unit:unit_data().name_label_id, percent / 100)
	end)
end
