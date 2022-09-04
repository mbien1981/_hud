local module = ... or D:module("_hud")

module:add_config_option("_hud_name_use_peer_color", false)
module:add_config_option("_hud_enable_armor_timer", false)
module:add_config_option("_hud_enable_raw_armor_text", false)
module:add_config_option("_hud_use_custom_drop_in_panel", true)
module:add_config_option("_hud_drop_in_show_peer_info", true)

-- custom colors
module:add_config_option("_hud_name_color", Color("ECECEC"))
module:add_config_option("_hud_health_color", Color("ECECEC"))
module:add_config_option("_hud_hurt_color", Color("b8392e"))
module:add_config_option("_hud_patch_color", Color(0.5, 1, 0.5))
module:add_config_option("_hud_armor_color", Color("1e90ff"))

module:add_menu_option("_hud_name_use_peer_color", {
	type = "boolean",
	text_id = "_hud_name_use_peer_color",
	help_id = "_hud_name_use_peer_color_help",
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
