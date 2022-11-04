local module = ... or D:module("_hud")

module:add_config_option("_hud_name_use_peer_color", false)
module:add_config_option("_hud_long_name_splitting", true)
module:add_config_option("_hud_use_alt_armor", false)
module:add_config_option("_hud_enable_armor_timer", false)
module:add_config_option("_hud_enable_raw_armor_text", false)
module:add_config_option("_hud_use_custom_drop_in_panel", true)
module:add_config_option("_hud_drop_in_show_peer_info", true)
module:add_config_option("_hud_enable_kill_feed", true)
module:add_config_option("_hud_kill_feed_max_rows", 6)
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
module:add_config_option("_hud_health_color", Color("ECECEC"))
module:add_config_option("_hud_hurt_color", Color("b8392e"))
module:add_config_option("_hud_patch_color", Color(0.5, 1, 0.5))
module:add_config_option("_hud_armor_color", Color("1e90ff"))

-- menu nodes
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
