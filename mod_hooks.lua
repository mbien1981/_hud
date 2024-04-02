local module = ... or D:module("_hud")

function module.on_option_change_hud_update(k, value, method, method_args)
	local hud = managers.hud and managers.hud._hud
	if not hud then
		return
	end

	local health_panel = hud.custom_health_panel
	if health_panel then
		health_panel:update_settings()
	end

	local inventory_panel = hud.inventory
	if inventory_panel then
		inventory_panel:update_settings()
	end

	local control_panel = hud.custom_control_panel
	if control_panel then
		control_panel:update_settings()
	end
end
