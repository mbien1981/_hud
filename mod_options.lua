local module = ... or D:module("_hud")

module:add_config_option("_hud_scaling", 1.2)
module:add_config_option("_hud_font_scaling", 1.2)

module:add_config_option("_hud_use_custom_health_panel", true)
module:add_config_option("_hud_name_use_peer_color", false)
module:add_config_option("_hud_long_name_splitting", true)
module:add_config_option("_hud_use_alt_armor", false)
module:add_config_option("_hud_enable_armor_timer", false)
module:add_config_option("_hud_enable_raw_armor_text", false)
module:add_config_option("_hud_enable_custom_ammo_panel", true)
module:add_config_option("_hud_enable_deployable_spy", true)
module:add_config_option("_hud_use_custom_drop_in_panel", true)
module:add_config_option("_hud_drop_in_show_peer_info", true)
module:add_config_option("_hud_mod_list_position", "topright")
module:add_config_option("_hud_mod_whitelist", {
	["ovk_193"] = true,
	["crybaby"] = true,
	["overdrill7200"] = true,
	["corpse_despawn"] = true,
	["interact_toggle"] = true,
	["restart_end_job"] = true,
	["restore_deployables"] = true,
})
module:add_config_option("_hud_use_custom_name_labels", true)
module:add_config_option("_hud_peer_contour_colors", true)

-- custom colors
module:add_config_option("_hud_name_color", Color("ECECEC"))
module:add_config_option("_hud_health_color", Color("ECECEC"))
module:add_config_option("_hud_hurt_color", Color("b8392e"))
module:add_config_option("_hud_patch_color", Color(0.5, 1, 0.5))
module:add_config_option("_hud_armor_color", Color("1e90ff"))
module:add_config_option("_hud_ai_contour_color", Color(0.1, 1, 0.5))

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
	help_id = "_hud_use_custom_health_panel_help",
	localize = true,
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

module:add_menu_option("_hud_armor_divider", { type = "divider", size = 15 })
module:add_menu_option("_hud_use_alt_armor", {
	type = "boolean",
	text_id = "_hud_use_alt_armor",
	help_id = "_hud_use_alt_armor_help",
	localize = true,
})
module:add_menu_option("_hud_enable_armor_timer", {
	type = "boolean",
	text_id = "_hud_enable_armor_timer",
	help_id = "_hud_enable_armor_timer_help",
	localize = true,
})
module:add_menu_option("_hud_enable_raw_armor_text", {
	type = "boolean",
	text_id = "_hud_enable_raw_armor_text",
	help_id = "_hud_enable_raw_armor_text_help",
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
