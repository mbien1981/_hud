local module = ... or D:module("_hud")

local HUDManager = module:hook_class("HUDManager")
module:post_hook(50, HUDManager, "_add_name_label", function(self, data)
	local name_labels = self._hud.name_labels
	local name_label_data = name_labels[#name_labels]

	local peer
	local is_husk_player = data.unit:base().is_husk_player
	if is_husk_player then
		peer = data.unit:network():peer()
	end

	local text = name_label_data.text
	local panel = text:parent():panel({
		layer = -5,
		w = text:w() + 4,
		h = text:h(),
	})

	name_label_data.name_frame = panel

	name_label_data.background = panel:rect({
		color = Color.black:with_alpha(0.4),
	})

	local line_color = peer and tweak_data.chat_colors[peer:id()] or D:conf("_hud_ai_contour_color")
	name_label_data.line_1 = panel:rect({
		color = line_color,
		layer = 2,
		w = 2,
		h = panel:h() - 2,
	})
	name_label_data.line_1 = panel:rect({
		color = line_color,
		layer = 2,
		y = panel:h() - 2,
		h = 2,
	})
end, false)

module:post_hook(50, HUDManager, "_update_name_labels", function(self, t, dt)
	if self._name_labels_hidden then
		return
	end

	for _, data in ipairs(self._hud.name_labels) do
		data.name_frame:set_visible(D:conf("_hud_use_custom_name_labels") and data.text:visible())
		data.name_frame:set_center(data.text:center())
	end
end, false)

module:pre_hook(50, HUDManager, "_remove_name_label", function(self, id)
	local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN)
	if not hud then
		return
	end

	for i, data in ipairs(self._hud.name_labels) do
		if data.id == id then
			hud.panel:remove(data.name_frame)
		end
	end
end)
