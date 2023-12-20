if RequiredScript == "lib/units/interactions/interactionext" then
	local ids_contour_color = Idstring("contour_color")
	local ids_contour_opacity = Idstring("contour_opacity")
	local D

	local BaseInteractionExt = module:hook_class("BaseInteractionExt")
	module:hook(BaseInteractionExt, "_set_contour", function(self, color, opacity)
		D = D or rawget(_G, "D")
		if self._tweak_data.no_contour then
			return
		end

		local contour_id = self._tweak_data.contour or "interactable"
		local material_color = tablex.get(tweak_data, "contour", contour_id, color)
		if D:conf("_hud_peer_contour_colors") and contour_id == "deployable" and color == "standard_color" then
			local server_info = self._unit:base():server_information()
			material_color = server_info and tweak_data.chat_colors[server_info.owner_peer_id] or material_color
		end

		for _, material in ipairs(self._materials) do
			material:set_variable(ids_contour_color, material_color)
			material:set_variable(ids_contour_opacity, self._active and opacity or 0)
		end
	end)
end

local classes = {
	["lib/units/weapons/trip_mine/tripminebase"] = "TripMineBase",
	["lib/units/equipment/ammo_bag/ammobagbase"] = "AmmoBagBase",
	["lib/units/equipment/doctor_bag/doctorbagbase"] = "DoctorBagBase",
}

local class_name = classes[RequiredScript]
if class_name then
	module:post_hook(module:hook_class(class_name), "set_server_information", function(self)
		self._unit:interaction():_set_contour("standard_color", 1)
	end)
end
