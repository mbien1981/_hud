local PlayerInventoryPanel = class()

function PlayerInventoryPanel:init(super)
	self.super = super

	self._hud = self.super:script(Idstring("guis/player_hud"))
	self._info_hud = self.super:script(PlayerBase.PLAYER_INFO_HUD)
	self._panel = self._info_hud.panel:panel({ layer = -100 })
	self.colors = {
		black = Color.black,
	}

	self._cached_conf_vars = {}
	self.items = {}
	self.rows = 1

	self:update_settings()
	self:setup_panels()
end

function PlayerInventoryPanel:update_settings()
	local D = D
	local var_cache = self._cached_conf_vars

	local use_inventory = D:conf("_hud_use_custom_health_panel") and D:conf("_hud_use_custom_inventory_panel")
	if var_cache.use_inventory ~= use_inventory then
		var_cache.use_inventory = use_inventory

		if alive(self.main_panel) then
			self.main_panel:set_visible(use_inventory)
		end

		if not use_inventory then
			managers.hud:update_hud_settings()
		end

		managers.hud:update_hud_visibility()
	end

	local refresh_wanted
	local selected_layout = D:conf("_hud_custom_health_panel_layout")
	if var_cache.selected_layout ~= selected_layout then
		var_cache.selected_layout = selected_layout

		refresh_wanted = true
	end

	local display_hp_ap = D:conf("_hud_display_armor_and_health_values")
	if var_cache.display_hp_ap ~= display_hp_ap then
		var_cache.display_hp_ap = display_hp_ap

		refresh_wanted = true
	end

	if refresh_wanted and alive(self.main_panel) then
		self:layout()
	end
end

function PlayerInventoryPanel:setup_panels()
	self.main_panel = self._panel:panel({
		visible = self._cached_conf_vars.use_inventory,
		h = 24,
	})
	self:create_background()
	self:layout()
end

function PlayerInventoryPanel:layout()
	local health_panel = self.super._hud.custom_health_panel
	if not health_panel then
		return
	end

	-- now that this panel exists, we need to reposition the health panel.
	health_panel:layout()

	local cached_vars = self._cached_conf_vars

	local health_main = health_panel.main_panel
	local info_panels = health_panel.info_panels
	self.workspace_widths = {
		vanilla = health_main:w()
			- info_panels.mugshot:w()
			- ((cached_vars.display_hp_ap and info_panels.base_text:w()) or 0)
			- health_panel.armor_health_panels.vanilla.health.background:w()
			- 20,
		raid = health_panel.data.workspace_width or health_main:w(),
	}

	if cached_vars.selected_layout == "vanilla" and self.rows <= 1 then
		self.main_panel:set_w(self.workspace_widths.vanilla)
		self.main_panel:set_left(info_panels.mugshot:right() + 4)
		self.main_panel:set_bottom(health_main:bottom() - 4)
		self.main_panel:child("panel_background"):hide()
		return
	end

	self.main_panel:set_w(self.workspace_widths.raid)
	self.main_panel:set_left(health_main:left())
	self.main_panel:child("panel_background"):set_size(self.main_panel:w(), self.main_panel:h())
	self.main_panel:child("panel_background"):show()
	self.main_panel:set_top(health_main:bottom() + 2)
end

function PlayerInventoryPanel:create_background()
	self.main_panel:gradient({
		name = "panel_background",
		gradient_points = { 0, Color(0.4, 0, 0, 0), 1, Color(0, 0, 0, 0) },
		layer = -1,
	})
end

function PlayerInventoryPanel:add(data, index)
	index = tonumber(index) or (#self.items + 1)

	local icon, texture_rect = tweak_data.hud_icons:get_icon_data(data.icon)
	local bitmap = self.main_panel:bitmap({
		name = "bitmap",
		texture = icon,
		color = Color.white,
		layer = 2,
		texture_rect = texture_rect,
		w = 24,
		h = 24,
	})

	table.insert(self.items, index, { icon = bitmap, id = data.id })

	self:layout_inventory()
end

function PlayerInventoryPanel:get(id)
	for i, item in ipairs(self.items) do
		if item.id == id then
			return i, item
		end
	end
end

function PlayerInventoryPanel:remove(id)
	local index, item = self:get(id)
	if not item then
		return
	end

	self.main_panel:remove(item.icon)
	table.remove(self.items, index)
	self:layout_inventory()
end

function PlayerInventoryPanel:layout_inventory()
	local process_inventory = function(width)
		local columns, rows = 1, 1
		for i, item in ipairs(self.items) do
			if (columns * item.icon:w()) > (width - 8) then
				columns = 1
				rows = rows + 1
			end

			item.icon:set_top(item.icon:h() * (rows - 1))
			item.icon:set_left(columns == 1 and 2 or self.items[i - 1].icon:right())

			columns = columns + 1
		end

		return rows
	end

	local rows = process_inventory(self.main_panel:w())

	self.rows = rows

	if self._cached_conf_vars.selected_layout == "vanilla" and self.rows > 1 then
		rows = process_inventory(self.workspace_widths.raid)
	end

	self.main_panel:set_h(24 * rows)
	self:layout()
end

local module = ... or D:module("_hud")
local HUDManager = module:hook_class("HUDManager")

module:hook("OnSetupHUD", "_hud.init_custom_inventory_panel", function(self)
	module.initialize_panel("custom_inventory_panel", PlayerInventoryPanel, self)
end)

module:hook("OnPlayerHudLayout", "_hud.layout_custom_inventory_panel", function(self)
	local inventory_panel = self._hud.custom_inventory_panel
	if not inventory_panel then
		return
	end

	inventory_panel:layout()
end)

module:hook("OnUpdateHUDVisibility", "_hud.override_item_panel_visibility", function(self)
	local inventory_panel = self._hud.custom_inventory_panel
	if not inventory_panel then
		return
	end

	local dahm_cached_vars = self._cached_conf_vars
	local _hud_cached_vars = inventory_panel._cached_conf_vars

	if _hud_cached_vars.use_inventory then
		dahm_cached_vars.hud_vis_item_panel = false
	end
end)

-- deployables
module:post_hook(50, HUDManager, "add_item", function(self, data)
	if not self._hud.custom_inventory_panel then
		return
	end

	self._hud.custom_inventory_panel:add({ icon = data.icon, id = 0 }, 1)
end, false)

module:post_hook(50, HUDManager, "remove_item", function(self, data)
	if not self._hud.custom_inventory_panel then
		return
	end

	self._hud.custom_inventory_panel:remove(0)
end, false)

module:post_hook(50, HUDManager, "set_item_amount", function(self, _, amount)
	if not self._hud.custom_inventory_panel then
		return
	end

	if amount > 0 then
		return
	end

	local _, item = self._hud.custom_inventory_panel:get(0)
	if item then
		item.icon:set_color(Color(0.5, 0.5, 0.5, 0.5))
	end
end)

-- equipment
module:post_hook(50, HUDManager, "add_special_equipment", function(self, data)
	if not self._hud.custom_inventory_panel then
		return
	end

	local last_item = self._hud.special_equipments[#self._hud.special_equipments]
	if not last_item then
		return
	end

	self._hud.custom_inventory_panel:add({ icon = data.icon, id = last_item.id })
end, false)

module:post_hook(50, HUDManager, "remove_special_equipment", function(self, id)
	if not self._hud.custom_inventory_panel then
		return
	end

	self._hud.custom_inventory_panel:remove(id)
end, false)

module:hook("OnPlayerHudLayout", "layout_inventory_panel", function(self, hud)
	local inventory_panel = self._hud.custom_inventory_panel
	if not inventory_panel then
		return
	end

	inventory_panel._panel:set_size(hud.panel:size())
end)
