local CustomAmmoPanelClass = class()
CustomAmmoPanelClass.colors = {
	default = Color(0.8, 0.8, 0.8),
	full = Color("70FF70"),
	empty = Color("FF7070"),
}

function CustomAmmoPanelClass:init(player_hud)
	self._hud = player_hud

	local ammo_panel = self._hud.ammo_panel
	self.main_panel = self._hud.panel:panel({
		w = ammo_panel:w(),
		h = ammo_panel:h(),
	})

	self.items = {}
	self._cached_conf_vars = {}

	self._toolbox = _M._hudToolBox

	self:layout()
	self:update_settings()
end

function CustomAmmoPanelClass:update_settings()
	local D = D
	local var_cache = self._cached_conf_vars

	local settings_update_wanted, visibility_update_wanted

	local use_ammo_panel = D:conf("_hud_enable_custom_ammo_panel")
	if var_cache.enabled ~= use_ammo_panel then
		var_cache.enabled = use_ammo_panel

		if not use_ammo_panel then
			self.main_panel:set_visible(use_ammo_panel and var_cache.selected_style == "custom")

			settings_update_wanted = true
		end

		visibility_update_wanted = true
	end

	local selected_style = D:conf("_hud_custom_ammo_panel_style")
	if var_cache.selected_style ~= selected_style then
		var_cache.selected_style = selected_style

		if alive(self.main_panel) then
			self.main_panel:set_visible(var_cache.enabled and selected_style == "custom")
		end

		settings_update_wanted = true
		visibility_update_wanted = true
	end

	local show_real_ammo_values = D:conf("_hud_ammo_panel_show_real_ammo")
	if var_cache.show_real_ammo ~= show_real_ammo_values then
		var_cache.show_real_ammo = show_real_ammo_values

		for i = 1, 3 do
			if self.items[i] then
				self:set_ammo_amount(i)
			end
		end
	end

	if settings_update_wanted then
		managers.hud:update_hud_settings()
	end

	if visibility_update_wanted then
		managers.hud:update_hud_visibility()
	end
end

function CustomAmmoPanelClass:layout()
	local icon_size = (32 * tweak_data.scale.hud_equipment_icon_multiplier)
	local font_size_medium = 20 * tweak_data.scale.hud_mugshot_multiplier
	local font_size_small = 12 * tweak_data.scale.hud_mugshot_multiplier

	local ammo_panel = self._hud.ammo_panel

	self.main_panel:set_w(ammo_panel:w())
	self.main_panel:set_h(icon_size * 3)
	self.main_panel:set_top(self._hud.item_panel:bottom() + 2)
	self.main_panel:set_right(self._hud.panel:w())

	for i = 1, 3 do
		local item = self.items[i]
		if item then
			item.panel:set_size(item.panel:parent():w(), icon_size)
			item.icon:set_size(icon_size, icon_size)
			item.total:set_font_size(font_size_medium)
			item.magazine:set_font_size(font_size_small)

			item.icon:set_center_y(item.panel:h() / 2)
			-- item.icon:set_right(item.panel:w())
			item.icon:set_world_center_x(self._hud.item_panel:center_x())

			-- text shouldn't move when ammo values change, so we resize to a 3 character width text rect size.
			local old_total_count = item.total:text()
			item.total:set_text("000")
			self._toolbox:make_pretty_text(item.total)
			item.total:set_text(old_total_count)

			item.total:set_bottom(item.icon:bottom())
			item.total:set_right(item.icon:left() - 6)

			local old_magazine_count = item.magazine:text()
			item.magazine:set_text("000")
			self._toolbox:make_pretty_text(item.magazine)
			item.magazine:set_text(old_magazine_count)

			item.magazine:set_center_y(item.total:center_y())
			item.magazine:set_right(item.total:left() - 4)
		end
	end

	self:arrange_weapons()
end

function CustomAmmoPanelClass:add_weapon(data)
	local slot = data.inventory_index
	self:remove_weapon(slot)

	local icon_size = (32 * tweak_data.scale.hud_equipment_icon_multiplier)
	local panel = self.main_panel:panel({ h = icon_size })

	local alpha = data.is_equip and 1 or 0.4
	local weapon_tweak = data.unit:base():weapon_tweak_data()
	local icon, texture_rect = tweak_data.hud_icons:get_icon_data(weapon_tweak.hud_icon)
	local bitmap = panel:bitmap({
		texture = icon,
		color = Color(0.8, 0.8, 0.8),
		alpha = alpha,
		layer = 2,
		texture_rect = texture_rect,
		w = icon_size,
		h = icon_size,
	})

	local total_ammo = panel:text({
		text = "000",
		font_size = 20 * tweak_data.scale.hud_mugshot_multiplier,
		font = "fonts/font_univers_530_bold",
		color = self.colors.default,
		alpha = alpha,
		align = "right",
		vertical = "center",
		layer = 3,
	})

	local ammo_in_magazine = panel:text({
		text = "000",
		font = "fonts/font_univers_530_medium",
		font_size = 12 * tweak_data.scale.hud_mugshot_multiplier,
		color = self.colors.default,
		alpha = alpha,
		align = "right",
		vertical = "center",
		layer = 3,
	})

	bitmap:set_center_y(panel:h() / 2)
	-- bitmap:set_right(panel:right())
	bitmap:set_world_center_x(self._hud.item_panel:center_x())

	self._toolbox:make_pretty_text(total_ammo)
	total_ammo:set_bottom(bitmap:bottom())
	total_ammo:set_right(bitmap:left() - 6)

	self._toolbox:make_pretty_text(ammo_in_magazine)
	ammo_in_magazine:set_center(total_ammo:center())
	ammo_in_magazine:set_right(total_ammo:left() - 4)

	self.items[slot] = { panel = panel, icon = bitmap, total = total_ammo, magazine = ammo_in_magazine }

	self:arrange_weapons()
	self:set_ammo_amount(slot)
end

function CustomAmmoPanelClass:remove_weapon(slot)
	local item = self.items[slot]
	if not item then
		return
	end

	item.panel:parent():remove(item.panel)

	self.items[slot] = nil
end

function CustomAmmoPanelClass:arrange_weapons()
	for i = 1, 3 do
		local item = self.items[i]
		local previous_item = self.items[i - 1]
		if self.items[i] then
			local y = (previous_item and previous_item.panel:bottom()) or 0
			item.panel:set_top(y)
		end
	end
end

function CustomAmmoPanelClass:set_weapon_selected(slot)
	for i, item in pairs(self.items) do
		if self.items[i] then
			local selected = i == slot
			local color_icon = selected and tweak_data.hud.prime_color or self.colors.default
			local alpha = selected and 1 or 0.4
			item.icon:set_color(color_icon)
			item.icon:set_alpha(alpha)
			item.magazine:set_alpha(alpha)
			item.total:set_alpha(alpha)
		end
	end
end

function CustomAmmoPanelClass:set_ammo_amount(slot)
	local item = self.items[slot]
	if not item then
		return
	end

	local selections = managers.player:player_unit():inventory():available_selections()
	local weapon_base = selections[slot].unit:base()

	local max_clip, current_clip, ammo_amount = weapon_base:ammo_info()
	local ammo_max = weapon_base._ammo_max
	local ammo_total = self._cached_conf_vars.show_real_ammo and ammo_amount - current_clip or ammo_amount

	item.magazine:set_text(tostring(current_clip))
	item.magazine:set_right(item.total:left() - 4)

	item.total:set_text(tostring(ammo_total))
	item.total:set_right(item.icon:left() - 6)

	local color_magazine = self._toolbox:blend_colors(self.colors.full, self.colors.empty, current_clip / max_clip)
	local color_total = self._toolbox:blend_colors(self.colors.full, self.colors.empty, ammo_amount / ammo_max)

	item.magazine:set_color(color_magazine)
	item.total:set_color(color_total)
end

function CustomAmmoPanelClass:set_weapon_ammo_by_unit(unit)
	local weapon_base = unit:base()
	local slot = weapon_base:weapon_tweak_data().use_data.selection_index
	self:set_ammo_amount(slot)
end

function CustomAmmoPanelClass:clear_weapons()
	for i, _ in pairs(self.items) do
		self:remove_weapon(i)
	end
end

function CustomAmmoPanelClass:update()
	if not Util:is_in_state("any_ingame_playing") then
		return
	end

	if not self.main_panel:parent():visible() then
		return
	end

	local config = D:conf("_hud_enable_custom_ammo_panel")
	self.main_panel:set_visible(config)
	self._hud.weapon_panel:set_visible(not config)
	self._hud.ammo_panel:set_visible(not config)

	if not self.main_panel:visible() then
		return
	end

	local unit = managers.player:player_unit()
	local selections = alive(unit) and unit:inventory():available_selections()
	if not selections then
		return
	end

	for i, weapon in pairs(self.items) do
		if self.items[i] then
			self:update_weapon(weapon, selections[i].unit:base(), managers.hud._hud.selected_weapon == i)
		end
	end
end

function CustomAmmoPanelClass:update_weapon(weapon, weapon_base, selected)
	if not alive(weapon.icon) then
		return
	end

	local ammo_full = weapon_base:ammo_full()
	local clip_full = weapon_base:clip_full()
	local clip_empty = weapon_base:clip_empty()
	local out_of_ammo = weapon_base:out_of_ammo()
	local max_clip, current_clip, ammo_amount = weapon_base:ammo_info()

	weapon.clip:set_text(tostring(current_clip))

	local ammo_total = ammo_amount
	if D:conf("_hud_ammo_panel_show_real_ammo") then
		ammo_total = ammo_amount - current_clip
	end

	weapon.total:set_text(tostring(ammo_total))

	local color_alpha = selected and 1 or 0.4
	local color_icon = selected and tweak_data.hud.prime_color or self.colors.default
	local color_clip = clip_full and self.colors.full or clip_empty and self.colors.empty or self.colors.default
	local color_total = ammo_full and self.colors.full or out_of_ammo and self.colors.empty or self.colors.default

	weapon.icon:set_color(color_icon:with_alpha(color_alpha))
	weapon.clip:set_color(color_clip:with_alpha(color_alpha))
	weapon.total:set_color(color_total:with_alpha(color_alpha))
end

local module = ... or D:module("_hud")
module:hook("OnSetupHUD", "_hud.init_custom_weapon_panel", function(self, panels)
	module.initialize_panel("custom_weapon_panel", CustomAmmoPanelClass, panels.PLAYER_HUD)
end, false)

module:hook("OnPlayerHudLayout", "_hud.layout_custom_ammo_panel", function(self, panels)
	local weapon_panel = self._hud.custom_weapon_panel
	if not weapon_panel then
		return
	end

	weapon_panel:layout()
end, false)

module:hook("OnPreUpdateHUDVisibility", "_hud.override_ammo_panel_visibility", function(self)
	local weapon_panel = self._hud.custom_weapon_panel
	if not weapon_panel then
		return
	end

	local dahm_cached_vars = self._cached_conf_vars
	local _hud_cached_vars = weapon_panel._cached_conf_vars

	if _hud_cached_vars.enabled and _hud_cached_vars.selected_style == "custom" then
		dahm_cached_vars.hud_vis_ammo_panel = false
		dahm_cached_vars.hud_vis_weapon_panel = false

		local weapons = self._hud.weapons
		for i = 1, 3 do
			local data = weapons[i]
			if data and alive(data.b2) then
				data.b2:stop()
				data.b2:parent():remove(data.b2)
				data.b2 = nil
			end
		end
	end
end, false)

module:hook("OnUpdateHUDVisibility", "_hud.set_vanilla_magazine_counter_visibility", function(self)
	local cached_vars = self._cached_conf_vars

	local setting = D:conf("_hud_enable_custom_ammo_panel")
		and D:conf("_hud_custom_ammo_panel_style") == "vanilla+"

	if cached_vars.show_vanilla_magazine_indicator ~= setting then
		cached_vars.show_vanilla_magazine_indicator = setting

		local weapons = self._hud.weapons
		for i = 1, 3 do
			local data = weapons[i]
			if data and alive(data.magazine) then
				data.magazine:set_visible(setting)
			end
		end
	end
end)

local HUDManager = module:hook_class("HUDManager")
function HUDManager:add_vanilla_magazine_indicator(data)
	local hud = self:script(PlayerBase.PLAYER_HUD)
	local ammo_panel = hud.ammo_panel
	local magazine = ammo_panel:text({
		text = "[000/000]",
		font = "fonts/font_univers_530_bold",
		font_size = 16,
		visible = self._cached_conf_vars.show_vanilla_magazine_indicator,
		align = "center",
		layer = data.bitmap:layer() + 1,
	})
	_M._hudToolBox:make_pretty_text(magazine)

	data.magazine = magazine

	self:set_vanilla_magazine_indicator_amount(data)
end

function HUDManager:arrange_vanilla_magazine_indicators()
	local weapons = self._hud.weapons
	for i = 1, 3 do
		local data = weapons[i]
		if data and alive(data.magazine) then
			data.magazine:set_world_center_x(data.bitmap:world_center_x())
			data.magazine:set_world_bottom(data.bitmap:world_y())
		end
	end
end

function HUDManager:set_vanilla_magazine_indicator_amount_by_unit(unit)
	local weapon_base = unit:base()
	local slot = weapon_base:weapon_tweak_data().use_data.selection_index

	self:set_vanilla_magazine_indicator_amount(self._hud.weapons[slot])
end

function HUDManager:set_vanilla_magazine_indicator_amount(data)
	if not tablex.get(data, "magazine") then
		return
	end

	local weapon_base = data.unit:base()

	local max_clip, current_clip, _ = weapon_base:ammo_info()

	data.magazine:set_text(string.format("[%s/%s]", current_clip, max_clip))
	_M._hudToolBox:make_pretty_text(data.magazine)

	local colors = CustomAmmoPanelClass.colors
	local color_magazine = _M._hudToolBox:blend_colors(colors.full, colors.empty, current_clip / max_clip)
	data.magazine:set_color(color_magazine)

	data.magazine:set_world_center_x(data.bitmap:world_center_x())
	data.magazine:set_world_bottom(data.bitmap:world_y())
end

module:post_hook(HUDManager, "add_weapon", function(self, data)
	local weapon_hud_data = self._hud.weapons[data.inventory_index]

	self:add_vanilla_magazine_indicator(weapon_hud_data)

	local panel = self._hud.custom_weapon_panel
	if not panel then
		return
	end

	local var_cache = panel._cached_conf_vars
	if alive(weapon_hud_data.b2) and var_cache.enabled and var_cache.selected_style == "custom" then
		weapon_hud_data.b2:stop()
		weapon_hud_data.b2:parent():remove(weapon_hud_data.b2)
		weapon_hud_data.b2 = nil
	end

	self._hud.custom_weapon_panel:add_weapon(data)
end)

module:post_hook(HUDManager, "_arrange_weapons", function(self)
	self:arrange_vanilla_magazine_indicators()
end)

module:pre_hook(HUDManager, "clear_weapons", function(self)
	for _, data in pairs(self._hud.weapons or {}) do
		if alive(data.magazine) then
			data.magazine:parent():remove(data.magazine)
		end
	end
end)

module:post_hook(HUDManager, "clear_weapons", function(self)
	if not self._hud.custom_weapon_panel then
		return
	end

	self._hud.custom_weapon_panel:clear_weapons()
end)

module:post_hook(HUDManager, "_set_weapon_selected", function(self, id)
	if not self._hud.custom_weapon_panel then
		return
	end

	self._hud.custom_weapon_panel:set_weapon_selected(id)
end)

module:post_hook(HUDManager, "set_weapon_ammo_by_unit", function(self, unit)
	self:set_vanilla_magazine_indicator_amount_by_unit(unit)

	if not self._hud.custom_weapon_panel then
		return
	end

	self._hud.custom_weapon_panel:set_weapon_ammo_by_unit(unit)
end)

module:post_hook(HUDManager, "set_ammo_amount", function(self)
	local _hud = self._hud

	self:set_vanilla_magazine_indicator_amount(_hud.weapons[_hud.selected_weapon])

	if not self._hud.custom_weapon_panel then
		return
	end

	self._hud.custom_weapon_panel:set_ammo_amount(_hud.selected_weapon)
end)
