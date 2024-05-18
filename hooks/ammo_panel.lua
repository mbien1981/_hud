CustomAmmoPanelClass = class()

function CustomAmmoPanelClass:init()
	self._hud = managers.hud:script(PlayerBase.PLAYER_HUD)
	self._panel = self._hud.panel:panel()

	self._weapons = {}
	self.colors = {
		default = Color(0.8, 0.8, 0.8),
		full = Color("70FF70"),
		empty = Color("FF7070"),
	}

	self._toolbox = _M._hudToolBox
	self._updator = _M._hudUpdator

	self._updator:remove("ammo_update")
	self._updator:add(callback(self, self, "update"), "ammo_update")
end

function CustomAmmoPanelClass:add_weapon(data)
	local weapon_tweak_data = data.unit:base():weapon_tweak_data()
	local i = weapon_tweak_data.use_data.selection_index
	self:remove_weapon(i)

	local icon, texture_rect = tweak_data.hud_icons:get_icon_data(weapon_tweak_data.hud_icon)
	local bitmap = self._panel:bitmap({
		texture = icon,
		color = Color(0.4, 0.8, 0.8, 0.8),
		layer = 2,
		texture_rect = texture_rect,
		w = 32 * tweak_data.scale.hud_equipment_icon_multiplier,
		h = 32 * tweak_data.scale.hud_equipment_icon_multiplier,
	})

	local total = self._panel:text({
		text = "000",
		font_size = 20 * tweak_data.scale.hud_mugshot_multiplier,
		font = "fonts/font_univers_530_bold",
		color = self.colors.default:with_alpha(data.is_equip and 1 or 0.4),
		align = "right",
		vertical = "center",
		layer = 3,
	})

	local clip = self._panel:text({
		text = "000",
		font = "fonts/font_univers_530_medium",
		font_size = 12 * tweak_data.scale.hud_mugshot_multiplier,
		color = self.colors.default:with_alpha(data.is_equip and 1 or 0.4),
		align = "right",
		vertical = "center",
		layer = 3,
	})

	local previous_item = self._weapons[i - 1]
	if previous_item then
		bitmap:set_right(previous_item.icon:right())
		bitmap:set_top(previous_item.icon:bottom())
	else
		bitmap:set_top(self._hud.item_panel:bottom() + 2)
		bitmap:set_center_x(self._hud.item_panel:center_x())
	end

	self._toolbox:make_pretty_text(total)
	total:set_bottom(bitmap:bottom())
	total:set_right(bitmap:left() - 6)

	self._toolbox:make_pretty_text(clip)
	clip:set_center(total:center())
	clip:set_right(total:left() - 4)

	self._weapons[i] = { icon = bitmap, total = total, clip = clip }
end

function CustomAmmoPanelClass:remove_weapon(i)
	local weapon = self._weapons[i]
	if not weapon then
		return
	end

	weapon.icon:parent():remove(weapon.icon)
	weapon.total:parent():remove(weapon.total)
	weapon.clip:parent():remove(weapon.clip)

	self._weapons[i] = nil
end

function CustomAmmoPanelClass:clear_weapons()
	for i, _ in pairs(self._weapons) do
		self:remove_weapon(i)
	end
end

function CustomAmmoPanelClass:update()
	if not Util:is_in_state("any_ingame_playing") then
		return
	end

	if not self._panel:parent():visible() then
		return
	end

	local config = D:conf("_hud_enable_custom_ammo_panel")
	self._panel:set_visible(config)
	self._hud.weapon_panel:set_visible(not config)
	self._hud.ammo_panel:set_visible(not config)

	if not self._panel:visible() then
		return
	end

	local unit = managers.player:player_unit()
	local selections = alive(unit) and unit:inventory():available_selections()
	if not selections then
		return
	end

	for i, weapon in pairs(self._weapons) do
		if self._weapons[i] then
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
if RequiredScript == "lib/managers/hudmanager" then
	local HUDManager = module:hook_class("HUDManager")
	module:post_hook(HUDManager, "add_weapon", function(self, data)
		if not rawget(_M, "CustomAmmoPanel") then
			rawset(_M, "CustomAmmoPanel", CustomAmmoPanelClass:new())
		end

		_M.CustomAmmoPanel:add_weapon(data)
	end)

	module:post_hook(HUDManager, "clear_weapons", function(self)
		if not rawget(_M, "CustomAmmoPanel") then
			rawset(_M, "CustomAmmoPanel", CustomAmmoPanelClass:new())
		end

		_M.CustomAmmoPanel:clear_weapons()
	end)
end
