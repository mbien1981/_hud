--[[
	I am not happy with how messy this file turned out to be.
	I will implement my own settings menu for this mod in 1.5x
]]

local module = ... or D:module("_hud")

local visibility_nodes = {
	["_hud_use_custom_health_panel"] = {
		"_hud_custom_health_panel_layout",
		"_hud_name_use_peer_color",
		"_hud_long_name_splitting",
		"_hud_display_armor_and_health_values",
		"_hud_inventory_divider",
		"_hud_use_custom_inventory_panel",
	},
	["_hud_use_custom_drop_in_panel"] = {
		"_hud_drop_in_show_peer_info",
		"_hud_mod_list_position",
	},
}

local function _get_item(item_name, node)
	local node_name = "mod_options_" .. module:id()
	if not node then
		node = managers.menu:active_menu().logic:selected_node()
	end
	return node:item(node_name .. "_" .. item_name)
end

local function _hud_option_changed(k, value, old_value, old_value_was_user_set, o, item)
	local items_to_change = visibility_nodes[k]
	if items_to_change then
		for _, key in pairs(items_to_change) do
			local child = _get_item(key)
			if child then
				local previous_visibility = child:visible()
				child:set_visible(value)
				if value ~= previous_visibility then
					managers.menu:active_menu().logic:refresh_node()
				end
			end
		end
	end

	-- update gui
	module.on_option_change_hud_update(k, value, "menu", o and { virtual = o.is_virtual, persist = o.persist })

	return true
end

module:set_default_menu_option_callback(_hud_option_changed)

module:hook("OnModulePostBuildOptions", "OnModulePostBuildOptions__hud", function(node, subnode_name)
	for id, items in pairs(visibility_nodes) do
		local master = _get_item(id, node)
		for _, item_id in pairs(items) do
			local child = _get_item(item_id, node)
			if child then
				child:set_visible(master:value() == "on")
			end
		end
	end
end)

-- scaling settings
module:add_config_option("_hud_scaling", 1.2)
module:add_config_option("_hud_font_scaling", 1.2)

-- health panel
module:add_config_option("_hud_use_custom_health_panel", true)
module:add_config_option("_hud_custom_health_panel_layout", "raid")
module:add_config_option("_hud_name_use_peer_color", false)
module:add_config_option("_hud_long_name_splitting", true)

-- health panel armor
module:add_config_option("_hud_display_armor_and_health_values", false)
-- module:add_config_option("_hud_enable_armor_timer", false)

-- inventory panel
module:add_config_option("_hud_use_custom_inventory_panel", true)

-- custom ammo panel and deployable spy
module:add_config_option("_hud_enable_custom_ammo_panel", true)
module:add_config_option("_hud_enable_deployable_spy", true)

-- custom drop-in panel
module:add_config_option("_hud_use_custom_drop_in_panel", true)
module:add_config_option("_hud_drop_in_show_peer_info", true)
module:add_config_option("_hud_mod_list_position", "righttop")

module:add_config_option("_hud_mod_whitelist", {
	["ovk_193"] = true,
	["crybaby"] = true,
	["overdrill7200"] = true,
	["corpse_despawn"] = true,
	["interact_toggle"] = true,
	["restart_end_job"] = true,
	["restore_deployables"] = true,
})

-- custom colors
module:add_config_option("_hud_name_color", Color("ECECEC"))
module:add_config_option("_hud_vanilla_health_color", Color(0.5, 0.8, 0.4))
module:add_config_option("_hud_health_color", Color("ECECEC"))
module:add_config_option("_hud_hurt_color", Color("b8392e"))
module:add_config_option("_hud_patch_color", Color(0.5, 1, 0.5))
module:add_config_option("_hud_vanilla_armor_color", Color.white)
module:add_config_option("_hud_armor_color", Color("1e90ff"))

-- contours and name labels
module:add_config_option("_hud_peer_contour_colors", false)
module:add_config_option("_hud_ai_contour_color", Color(0.1, 1, 0.5))

module:add_config_option("_hud_use_custom_name_labels", false)

-- menu nodes
module:add_menu_option("_hud_scaling", {
	type = "slider",
	min = 0.5,
	max = 5.0,
	step = 0.05,
	value_accuracy = 2,
	show_value = true,
	text_id = "_hud_scaling",
})
module:add_menu_option("_hud_font_scaling", {
	type = "slider",
	min = 0.5,
	max = 5.0,
	step = 0.05,
	value_accuracy = 2,
	show_value = true,
	text_id = "_hud_font_scaling",
})

module:add_menu_option("_hud_label_divider", { type = "divider", size = 15 })
module:add_menu_option("_hud_use_custom_name_labels", {
	type = "boolean",
	text_id = "_hud_use_custom_name_labels",
	localize = true,
})
module:add_menu_option("_hud_peer_contour_colors", {
	type = "boolean",
	text_id = "_hud_peer_contour_colors",
	localize = true,
})

module:add_menu_option("_hud_health_divider", { type = "divider", size = 15 })
module:add_menu_option("_hud_use_custom_health_panel", {
	type = "boolean",
	text_id = "_hud_use_custom_health_panel",
	localize = true,
})
module:add_menu_option("_hud_custom_health_panel_layout", {
	type = "multi_choice",
	text_id = "_hud_custom_health_panel_layout",
	choices = {
		{ "vanilla", "_hud_vanilla_style" },
		{ "raid", "_hud_raid_style" },
		{ "raid_alt", "_hud_raid_alt_style" },
	},
	default_value = "raid",
})
module:add_menu_option("_hud_name_use_peer_color", {
	type = "boolean",
	text_id = "_hud_name_use_peer_color",
	help_id = "_hud_name_use_peer_color_help",
	localize = true,
})
module:add_menu_option("_hud_long_name_splitting", {
	type = "boolean",
	text_id = "_hud_long_name_splitting",
	help_id = "_hud_long_name_splitting_help",
	localize = true,
})

-- module:add_menu_option("_hud_armor_divider", { type = "divider", size = 15 })
module:add_menu_option("_hud_display_armor_and_health_values", {
	type = "boolean",
	text_id = "_hud_display_armor_and_health_values",
	help_id = "_hud_display_armor_and_health_values_help",
	localize = true,
})
-- module:add_menu_option("_hud_enable_armor_timer", {
-- 	type = "boolean",
-- 	text_id = "_hud_enable_armor_timer",
-- 	help_id = "_hud_enable_armor_timer_help",
-- 	localize = true,
-- })

module:add_menu_option("_hud_inventory_divider", { type = "divider", size = 15 })
module:add_menu_option("_hud_use_custom_inventory_panel", {
	type = "boolean",
	text_id = "_hud_use_custom_inventory_panel",
	localize = true,
})

module:add_menu_option("_hud_ammo_panel_divider", { type = "divider", size = 15 })
module:add_menu_option("_hud_enable_custom_ammo_panel", {
	type = "boolean",
	text_id = "_hud_enable_custom_ammo_panel",
	localize = true,
})
module:add_menu_option("_hud_enable_deployable_spy", {
	type = "boolean",
	text_id = "_hud_enable_deployable_spy",
	help_id = "_hud_enable_deployable_spy_help",
	localize = true,
})

module:add_menu_option("_hud_drop_in_divider", { type = "divider", size = 15 })
module:add_menu_option("_hud_use_custom_drop_in_panel", {
	type = "boolean",
	text_id = "_hud_use_custom_drop_in_panel",
	localize = true,
})

module:add_menu_option("_hud_drop_in_show_peer_info", {
	type = "boolean",
	text_id = "_hud_drop_in_show_peer_info",
	help_id = "_hud_drop_in_show_peer_info_help",
	localize = true,
})
module:add_menu_option("_hud_mod_list_position", {
	type = "multi_choice",
	text_id = "_hud_mod_list_position",
	choices = {
		{ "leftbottom", "_hud_leftbottom" },
		{ "lefttop", "_hud_lefttop" },
		{ "centertop", "_hud_centertop" },
		{ "righttop", "_hud_righttop" },
		{ "centerright", "_hud_centerright" },
		{ "rightbottom", "_hud_rightbottom" },
		{ "centerbottom", "_hud_centerbottom" },
	},
	default_value = "righttop",
})

module:add_menu_option("_hud_reload_panel_divider", { type = "divider", size = 15 })
module:add_menu_option("_hud_reload_timer", {
	type = "boolean",
	text_id = "_hud_reload_timer",
	localize = true,
})

module:add_menu_option("_hud_shotgun_fire_timer", {
	type = "boolean",
	text_id = "_hud_shotgun_fire_timer",
	localize = true,
})
