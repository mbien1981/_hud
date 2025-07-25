local module = ... or D:module("_hud")

local visibility_nodes = {
	["_hud_use_custom_name_labels"] = {
		"_hud_name_label_health_display",
	},
	["_hud_use_custom_health_panel"] = {
		"_hud_custom_health_panel_layout",
		"_hud_mugshot_name",
		"_hud_custom_mugshot_name",
		"_hud_display_name_in_upper_cases",
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
		"_hud_custom_ammo_panel_style",
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
			local visible = master:visible() and master:value() == "user_defined"
			local previous_visibility = child:visible()

			child:set_visible(visible)
			if visible ~= previous_visibility then
				refresh_wanted = true
			end
		end
	end

	if items_to_change or k == "_hud_custom_ammo_panel_style" then
		local master = _get_item("_hud_custom_ammo_panel_style")
		local child = _get_item("_hud_ammo_panel_show_real_ammo")
		if child then
			local visible = master:visible() and master:value() ~= "vanilla+"
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

	local dropdowns_toggle = _get_item("_hud_use_loadout_dropdowns", node)
	if dropdowns_toggle then
		dropdowns_toggle:set_enabled(D:version() >= "1.16.1.1")
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

	local ammo_panel_toggle = _get_item("_hud_enable_custom_ammo_panel", node)
	local visible = ammo_panel_toggle and ammo_panel_toggle:value() == "on" or false

	local real_ammo_values_toggle = _get_item("_hud_ammo_panel_show_real_ammo", node)
	if visible and real_ammo_values_toggle then
		real_ammo_values_toggle:set_visible(_get_item("_hud_custom_ammo_panel_style", node):value() ~= "vanilla+")
	end
end)

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
module:add_menu_option("_hud_name_label_health_display", {
	type = "multi_choice",
	text_id = "_hud_name_label_health_display",
	help_id = "_hud_name_label_health_display_help",
	choices = {
		{ "none", "_hud_none" },
		{ "simple", "_hud_simple" },
		{ "detailed", "_hud_detailed" },
	},
	default_value = "detailed",
})
module:add_menu_option("_hud_peer_contour_colors", {
	type = "boolean",
	text_id = "_hud_peer_contour_colors",
	localize = true,
})

module:add_menu_option("_hud_misc_gui_divider", { type = "divider", size = 15 })
module:add_menu_option("_hud_use_loadout_dropdowns", {
	type = "boolean",
	text_id = "_hud_use_loadout_dropdowns",
	help_id = "_hud_use_loadout_dropdowns_help",
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
module:add_menu_option("_hud_display_name_in_upper_cases", {
	type = "boolean",
	text_id = "_hud_display_name_in_upper_cases",
	localize = true,
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
module:add_menu_option("_hud_custom_ammo_panel_style", {
	type = "multi_choice",
	text_id = "_hud_custom_ammo_panel_style",
	choices = {
		{ "vanilla+", "_hud_style_vanilla_plus" },
		{ "custom", "_hud_style_custom" },
	},
	default_value = "custom",
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
	default_value = "$CHARGES;x",
})
module:add_menu_option("_hud_ammo_bag_spy", {
	type = "string",
	input_type = "text",
	text_id = "_hud_ammo_bag_spy",
	help_id = "_hud_ammo_bag_spy_help",
	default_value = "$PERCENT;%",
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

-- load localization file
for _, lang in ipairs({ DLocalizer:system_language(true) or nil, "english" }) do
	if module:load_localization_file(module:path() .. string.format("loc/%s.lua", lang)) then
		break
	end
end
