local module = ... or D:module("_hud")

module:add_config_option("_hud_enable_armor_timer", true)

module:add_menu_option("_hud_enable_armor_timer", {
	type = "boolean",
	text_id = "_hud_enable_armor_timer",
	help_id = "_hud_enable_armor_timer_help",
	localize = true,
})

module:add_localization_string("_hud_enable_armor_timer", {
	english = "Enable armor regen timer",
})
module:add_localization_string("_hud_enable_armor_timer_help", {
	english = "Shows a timer that indicates the time remaining for your armor to regenerate.",
})

-- module:hook("OnMenuSetup", "OnMenuSetup_WTFBMCreateSettings", "menu_main", function(self, menu, nodes)
-- 	self:insert_menu_node(menu, {
-- 		_meta = "node",
-- 		name = "wtfbm_manage_settings",
-- 		topic_id = "mod_mmf_filter_custom_diff",
-- 		-- modifier = "WTFBMSettings",
-- 		legends = {
-- 			"menu_legend_select",
-- 			"menu_legend_back",
-- 		},
-- 		stencil_image = "bg_options",
-- 		stencil_align = "center",
-- 		align_line = "0.5",
-- 	})
-- end)
