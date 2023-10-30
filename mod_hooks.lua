local module = ... or D:module("_hud")

function module.on_option_change_hud_update(k, value, method, method_args)
	local hudman = managers.hud
	if not hudman then
		return
	end

	local hud_panel = hudman._hud.custom_health_panel
	if hud_panel then
		hud_panel:update_settings()
	end

	local inventory_panel = hudman._hud.inventory
	if inventory_panel then
		inventory_panel:update_settings()
	end
end
