local module = ... or D:module("_hud")

module:add_config_option("_hud_enable_armor_timer", true)
module:add_config_option("_hud_use_custom_drop_in_panel", true)
module:add_config_option("_hud_drop_in_show_peer_info", true)

module:add_menu_option("_hud_enable_armor_timer", {
	type = "boolean",
	text_id = "_hud_enable_armor_timer",
	help_id = "_hud_enable_armor_timer_help",
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
