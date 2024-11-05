local module = ... or D:module("_hud")

local col_to_vec = function(color)
	if not color then
		return Vector3(0.1, 0.4, 0.25)
	end

	local r, g, b = color.r, color.g, color.b
	if r and g and b then
		return Vector3(r, g, b)
	end

	if color.x and color.y and color.z then
		return color
	end

	return Vector3(0.1, 1, 0.5)
end

local GamePlayCentralManager = module:hook_class("GamePlayCentralManager")
module:pre_hook(50, GamePlayCentralManager, "update", function(self)
	if not next(self._contour.units) then
		return
	end

	local data = self._contour.units[self._contour.index]
	if tablex.get(data, "type") ~= "character" then
		return
	end

	if not D:conf("_hud_peer_contour_colors") or managers.game_play_central:contours_disabled() then
		if data.updated_color then
			data.standard_color = tablex.get(tweak_data, "contour", data.type, "standard_color") or col_to_vec(nil)
			data.updated_color = nil
		end

		return
	end

	if data.updated_color then
		return
	end

	if not data.unit:base().is_husk_player then
		data.standard_color = col_to_vec(D:conf("_hud_ai_contour_color"))
		data.updated_color = true
		return
	end

	local peer = data.unit:network():peer()
	if peer then
		data.standard_color = col_to_vec(tablex.get(tweak_data, "chat_colors", peer:id()))
		data.updated_color = true
	end
end)
