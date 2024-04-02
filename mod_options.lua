local module = ... or D:module("_hud")

local visibility_nodes = {
	["_hud_use_custom_health_panel"] = {
		"_hud_custom_health_panel_layout",
		"_hud_mugshot_name",
		"_hud_custom_mugshot_name",
		"_hud_name_use_peer_color",
		"_hud_display_armor_and_health_values",
		"_hud_inventory_divider",
		"_hud_use_custom_inventory_panel",
		"_hud_display_armor_regen_timer",
		"_hud_reposition_chat_input",
		"_hud_chat_input_divider",
		"_hud_inventory_divider",
	},
	["_hud_use_custom_drop_in_panel"] = {
		"_hud_drop_in_show_peer_info",
		"_hud_mod_list_position",
	},
	["_hud_enable_custom_ammo_panel"] = {
		"_hud_ammo_panel_show_real_ammo",
	},
	["_hud_enable_deployable_spy"] = {
		"_hud_medic_bag_spy",
		"_hud_ammo_bag_spy",
		"_hud_sentry_gun_spy",
	},
}

local _get_item = function(item_name, node)
	local node_name = "mod_options_" .. module:id()
	if not node then
		node = managers.menu:active_menu().logic:selected_node()
	end

	return node:item(node_name .. "_" .. item_name)
end

local function _hud_option_changed(k, value, old_value, old_value_was_user_set, o, item)
	local refresh_wanted = false
	local items_to_change = visibility_nodes[k]
	if items_to_change then
		for _, key in pairs(items_to_change) do
			local child = _get_item(key)
			if child then
				local previous_visibility = child:visible()
				child:set_visible(value)
				if value ~= previous_visibility then
					refresh_wanted = true
				end
			end
		end
	end

	if items_to_change or k == "_hud_custom_health_panel_layout" then
		local master = _get_item("_hud_custom_health_panel_layout")
		local child = _get_item("_hud_display_armor_regen_timer")
		if child then
			local visible = master:visible() and master:value() ~= "vanilla"
			local previous_visibility = child:visible()

			child:set_visible(visible)

			if visible ~= previous_visibility then
				refresh_wanted = true
			end
		end
	end

	if items_to_change or k == "_hud_mugshot_name" then
		local master = _get_item("_hud_mugshot_name")
		local child = _get_item("_hud_custom_mugshot_name")

		if child then
			local visible = master:value() == "user_defined"
			local previous_visibility = child:visible()

			child:set_visible(visible)
			if visible ~= previous_visibility then
				refresh_wanted = true
			end
		end
	end

	if refresh_wanted then
		managers.menu:active_menu().logic:refresh_node()
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

	local health_bar_toggle = _get_item("_hud_use_custom_health_panel", node)
	local visible = health_bar_toggle and health_bar_toggle:value() == "on" or false

	local custom_name_input = _get_item("_hud_custom_mugshot_name", node)
	if visible and custom_name_input then
		custom_name_input:set_visible(_get_item("_hud_mugshot_name", node):value() == "user_defined")
	end

	local armor_timer_toggle = _get_item("_hud_display_armor_regen_timer", node)
	if visible and armor_timer_toggle then
		armor_timer_toggle:set_visible(_get_item("_hud_custom_health_panel_layout", node):value() ~= "vanilla")
	end

	local bcl = D:module("better_chat_location")
	local reposition_chat_input = _get_item("_hud_reposition_chat_input", node)
	if bcl and bcl:enabled() then
		reposition_chat_input:set_enabled(false)
	end
end)

-- scaling settings
module:add_config_option("_hud_scaling", 1.2)
module:add_config_option("_hud_font_scaling", 1.2)

-- health panel
module:add_config_option("_hud_use_custom_health_panel", true)
module:add_config_option("_hud_custom_health_panel_layout", "raid")
module:add_config_option("_hud_mugshot_name", "steam_username")
module:add_config_option("_hud_custom_mugshot_name", "<name>")
module:add_config_option("_hud_name_use_peer_color", false)

-- health panel armor
module:add_config_option("_hud_display_armor_and_health_values", false)
module:add_config_option("_hud_display_armor_regen_timer", false)

module:add_config_option("_hud_reposition_chat_input", true)

-- inventory panel
module:add_config_option("_hud_use_custom_inventory_panel", true)

-- custom ammo panel and deployable spy
module:add_config_option("_hud_enable_custom_ammo_panel", true)
module:add_config_option("_hud_ammo_panel_show_real_ammo", true)

module:add_config_option("_hud_enable_deployable_spy", true)
module:add_config_option("_hud_medic_bag_spy", "$CHARGES;x")
module:add_config_option("_hud_ammo_bag_spy", "$PERCENT;%")
module:add_config_option("_hud_sentry_gun_spy", "$AMMO;/$AMMO_MAX; | [#7FFF7F]$HEALTH;[]%")

-- custom drop-in panel
module:add_config_option("_hud_use_custom_drop_in_panel", true)
module:add_config_option("_hud_drop_in_show_peer_info", true)
module:add_config_option("_hud_mod_list_position", "righttop")

-- custom control and point of no return panels
module:add_config_option("_hud_use_custom_control_panel", true)
module:add_config_option("_hud_use_custom_use_ponr_panel", true)

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
module:add_menu_option("_hud_mugshot_name", {
	type = "multi_choice",
	text_id = "_hud_mugshot_name",
	help_id = "_hud_mugshot_name_help",
	choices = {
		{ "character_name", "_hud_character_name" },
		{ "steam_username", "_hud_steam_username" },
		{ "short_username", "_hud_short_username" },
		{ "user_defined", "_hud_custom_username" },
	},
	default_value = "steam_username",
})
module:add_menu_option("_hud_custom_mugshot_name", {
	type = "string",
	input_type = "text",
	text_id = "_hud_custom_mugshot_name",
	default_value = "<name>",
})

module:add_menu_option("_hud_name_use_peer_color", {
	type = "boolean",
	text_id = "_hud_name_use_peer_color",
	help_id = "_hud_name_use_peer_color_help",
	localize = true,
})

module:add_menu_option("_hud_display_armor_and_health_values", {
	type = "boolean",
	text_id = "_hud_display_armor_and_health_values",
	help_id = "_hud_display_armor_and_health_values_help",
	localize = true,
})
module:add_menu_option("_hud_display_armor_regen_timer", {
	type = "boolean",
	text_id = "_hud_display_armor_regen_timer",
	help_id = "_hud_display_armor_regen_timer_help",
	localize = true,
})

module:add_menu_option("_hud_chat_input_divider", { type = "divider", size = 15 })
module:add_menu_option("_hud_reposition_chat_input", {
	type = "boolean",
	text_id = "_hud_reposition_chat_input",
	help_id = "_hud_reposition_chat_input_help",
	localize = true,
})

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
module:add_menu_option("_hud_ammo_panel_show_real_ammo", {
	type = "boolean",
	text_id = "_hud_ammo_panel_show_real_ammo",
	help_id = "_hud_ammo_panel_show_real_ammo_help",
	localize = true,
})

module:add_menu_option("_hud_deployable_stuff_divider", { type = "divider", size = 15 })
module:add_menu_option("_hud_enable_deployable_spy", {
	type = "boolean",
	text_id = "_hud_enable_deployable_spy",
	help_id = "_hud_enable_deployable_spy_help",
	localize = true,
})
module:add_menu_option("_hud_medic_bag_spy", {
	type = "string",
	input_type = "text",
	text_id = "_hud_medic_bag_spy",
	help_id = "_hud_medic_bag_spy_help",
	default_value = "$CHARGES;",
})
module:add_menu_option("_hud_ammo_bag_spy", {
	type = "string",
	input_type = "text",
	text_id = "_hud_ammo_bag_spy",
	help_id = "_hud_ammo_bag_spy_help",
	default_value = "$PERCENT;",
})
module:add_menu_option("_hud_sentry_gun_spy", {
	type = "string",
	input_type = "text",
	text_id = "_hud_sentry_gun_spy",
	help_id = "_hud_sentry_gun_spy_help",
	default_value = "$AMMO;/$AMMO_MAX; | [#7FFF7F]$HEALTH;[]%",
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

module:add_menu_option("_hud_control_panel_divider", { type = "divider", size = 15 })
module:add_menu_option("_hud_use_custom_control_panel", {
	type = "boolean",
	text_id = "_hud_use_custom_control_panel",
	localize = true,
})
module:add_menu_option("_hud_use_custom_ponr_panel", {
	type = "boolean",
	text_id = "_hud_use_custom_ponr_panel",
	localize = true,
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
