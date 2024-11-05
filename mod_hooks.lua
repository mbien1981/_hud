local module = ... or D:module("_hud")

module.registered_custom_panels = {}
function module.initialize_panel(name, class, ...)
	if not tablex.get(managers, "hud", "_hud") then
		return
	end

	if managers.hud._hud[name] then
		return
	end

	managers.hud._hud[name] = class:new(...)

	table.insert(module.registered_custom_panels, name)
end

function module.on_option_change_hud_update(k, value, method, method_args)
	local hud = tablex.get(managers, "hud", "_hud")
	if not hud then
		return
	end

	for _, name in pairs(module.registered_custom_panels) do
		local panel = hud[name]
		if type(tablex.get(panel, "update_settings")) == "function" then
			panel:update_settings()
		end
	end
end
