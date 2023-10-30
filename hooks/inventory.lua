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

	self:update_settings()
	self:setup_panels()
	_G._updator:remove("teqerasoidjwqe2")
	_G._updator:add(callback(self, self, "update"), "teqerasoidjwqe2")
end

function PlayerInventoryPanel:update_settings()
	local D = D
	local var_cache = self._cached_conf_vars

	var_cache.use_inventory = D:conf("_hud_use_custom_health_panel") and D:conf("_hud_use_custom_inventory_panel")
	var_cache.selected_layout = D:conf("_hud_custom_health_panel_layout")
end

function PlayerInventoryPanel:setup_panels()
	self.main_panel = self._panel:panel({ y = 100 })
	self:create_background()
	self:layout()
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
	local columns, rows = 1, 1
	for i, item in ipairs(self.items) do
		if (columns * item.icon:w()) > (self.main_panel:w() - 8) then
			columns = 1
			rows = rows + 1
		end

		item.icon:set_top(item.icon:h() * (rows - 1))
		item.icon:set_left(columns == 1 and 2 or self.items[i - 1].icon:right())

		columns = columns + 1
	end

	if #self.items > 0 then
		self.main_panel:set_h(self.items[1].icon:h() * rows)
		return
	end

	self.main_panel:set_h(0)
end

function PlayerInventoryPanel:layout()
	local health_panel = self.super._hud.custom_health_panel
	if not health_panel then
		return
	end

	local health_main = health_panel.main_panel
	if self._cached_conf_vars.selected_layout == "vanilla" then
		local info_panels = health_panel.info_panels
		self.main_panel:set_w(
			health_main:w()
				- info_panels.mugshot:w()
				- (health_panel.display_hp_ap and info_panels.base_text:w() or 0)
				- health_panel.armor_health_panels.vanilla.health.background:w()
				- 20
		)
		self.main_panel:set_left(info_panels.mugshot:right() + 4)
		self.main_panel:set_bottom(health_main:bottom() - 4)
		self.main_panel:child("panel_background"):hide()
		return
	end

	self.main_panel:set_w(health_panel.data.workspace_width or health_main:w())
	self.main_panel:set_left(health_main:left())
	self.main_panel:child("panel_background"):set_size(self.main_panel:size())
	self.main_panel:child("panel_background"):show()
	self.main_panel:set_top(health_main:bottom() + 2)
end

function PlayerInventoryPanel:update()
	if not self._cached_conf_vars.use_inventory then
		self.main_panel:hide()
		self._hud.item_panel:set_visible(true)
		self._hud.selected_item_icon:set_visible(true)
		self._hud.special_equipment_panel:set_visible(true)
		return
	end

	self.main_panel:show()
	self._hud.item_panel:set_visible(false)
	self._hud.selected_item_icon:set_visible(false)
	self._hud.special_equipment_panel:set_visible(false)

	self:layout()
end

if RequiredScript == "lib/managers/hudmanager" then
	local HUDManager = module:hook_class("HUDManager")
	-- deployables
	module:post_hook(50, HUDManager, "add_item", function(self, data)
		self._hud.inventory = self._hud.inventory or PlayerInventoryPanel:new(self)

		self._hud.inventory:add({ icon = data.icon, id = 0 }, 1)
	end, false)

	module:post_hook(50, HUDManager, "remove_item", function(self, data)
		self._hud.inventory = self._hud.inventory or PlayerInventoryPanel:new(self)

		self._hud.inventory:remove(0)
	end, false)

	module:post_hook(50, HUDManager, "set_item_amount", function(self, _, amount)
		self._hud.inventory = self._hud.inventory or PlayerInventoryPanel:new(self)

		if amount > 0 then
			return
		end

		local _, item = self._hud.inventory:get(0)
		if item then
			item.icon:set_color(Color(0.5, 0.5, 0.5, 0.5))
		end
	end)

	-- equipment
	module:post_hook(50, HUDManager, "add_special_equipment", function(self, data)
		self._hud.inventory = self._hud.inventory or PlayerInventoryPanel:new(self)

		local last_item = self._hud.special_equipments[#self._hud.special_equipments]
		if not last_item then
			return
		end

		self._hud.inventory:add({ icon = data.icon, id = last_item.id })
	end, false)

	module:post_hook(50, HUDManager, "remove_special_equipment", function(self, id)
		self._hud.inventory = self._hud.inventory or PlayerInventoryPanel:new(self)

		self._hud.inventory:remove(id)
	end, false)
end
