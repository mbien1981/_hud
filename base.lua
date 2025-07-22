return DMod:new("_hud", {
	name = "_hud",
	author = "_atom",
	version = "1.7.10",
	dependencies = { "hud", "[drop_in_menu]", "[loadout_dropdowns]", "[holiday_special]" },
	includes = {
		{ "dev/base" },
		{ "common" },
		{ "modoptions", { type = "menu_options", lazy_load = true } },
		{ "modlocalization", { type = "localization" } },
	},
	hooks = {
		{ "post_require", "lib/setups/setup", "classes/toolbox" },
		{ "post_require", "lib/setups/setup", "classes/updater" },
		{ "post_require", "core/lib/setups/coresetup", "classes/updater" },

		{ "post_require", "lib/units/beings/player/playerbase", "hooks/playerbase" },
		{ "post_require", "lib/managers/hudmanager", "hooks/hudmanager" },

		{ "post_require", "lib/tweak_data/tweakdata", "hooks/peer_colors" },

		{ "post_require", "lib/managers/hudmanager", "hooks/name_labels" },
		{ "post_require", "lib/network/handlers/unitnetworkhandler", "hooks/name_labels" },

		{ "post_require", "lib/managers/gameplaycentralmanager", "hooks/peer_contours" },
		{ "post_require", "lib/units/interactions/interactionext", "hooks/deployable_contours" },
		{ "post_require", "lib/units/equipment/ammo_bag/ammobagbase", "hooks/deployable_contours" },
		{ "post_require", "lib/units/equipment/doctor_bag/doctorbagbase", "hooks/deployable_contours" },
		{ "post_require", "lib/units/weapons/trip_mine/tripminebase", "hooks/deployable_contours" },

		{ "post_require", "lib/managers/hudmanager", "hooks/health_bar", 50 },
		{ "post_require", "lib/managers/hudmanager", "hooks/inventory_panel", 51 },

		{ "post_require", "lib/states/ingamewaitingforplayers", "hooks/drop_in" },
		{ "post_require", "lib/managers/menumanager", "hooks/drop_in" },

		{ "post_require", "lib/managers/hudmanager", "hooks/ammo_panel" },

		{ "post_require", "lib/managers/hudmanager", "hooks/state_timer" },

		{ "post_require", "lib/units/equipment/ammo_bag/ammobagbase", "hooks/deployable_spy" },
		{ "post_require", "lib/units/equipment/doctor_bag/doctorbagbase", "hooks/deployable_spy" },
		{ "post_require", "lib/units/equipment/sentry_gun/sentrygunbase", "hooks/deployable_spy" },

		{ "post_require", "lib/managers/hudmanager", "hooks/control_panel" },

		-- custom GUI
		{ "post_require", "lib/states/ingamewaitingforplayers", "hooks/loadout_dropdowns" },
		{ "post_require", "lib/managers/menu/menunodekitgui", "hooks/loadout_dropdowns" },
		{ "post_require", "lib/managers/menumanager", "hooks/loadout_dropdowns" },
		{ "post_require", "lib/setups/setup", "hooks/mask_selector" },
		{ "post_require", "lib/states/ingamewaitingforplayers", "hooks/mask_selector" },
		{ "post_require", "lib/managers/menumanager", "hooks/mask_selector" },
	},
	config = {
		-- scaling setings
		{ "_hud_scaling", 1.2 },
		{ "_hud_font_scaling", 1.2 },

		-- player name labels
		{ "_hud_use_custom_name_labels", false },
		{ "_hud_name_label_health_display", "detailed" },

		-- colorcode player and deployable contours
		{ "_hud_peer_contour_colors", false },

		-- hud custom colors
		{ "_hud_name_color", Color("ECECEC") },
		{ "_hud_vanilla_health_color", Color(0.5, 0.8, 0.4) },
		{ "_hud_health_color", Color("ECECEC") },
		{ "_hud_hurt_color", Color("b8392e") },
		{ "_hud_patch_color", Color(0.5, 1, 0.5) },
		{ "_hud_vanilla_armor_color", Color.white },
		{ "_hud_armor_color", Color("1e90ff") },
		{ "_hud_ai_contour_color", Color(0.1, 1, 0.5) },

		-- peer colors
		{ "_hud_peer1_color", Color(0.6, 0.6, 1) }, -- purple (slot 1/host)
		{ "_hud_peer2_color", Color(1, 0.6, 0.6) }, -- red (slot 2)
		{ "_hud_peer4_color", Color(1, 1, 0.6) }, -- yellow (slot 4)
		{ "_hud_peer3_color", Color(0.6, 1, 0.6) }, -- green (slot 3)

		-- loadout dropdowns, enabled by default if using dahm 1.16.1.1 or above.
		{ "_hud_use_loadout_dropdowns", D:version() >= "1.16.1.1" },

		-- health panel
		{ "_hud_use_custom_health_panel", true },
		{ "_hud_custom_health_panel_layout", "raid" },
		{ "_hud_mugshot_name", "steam_username" },
		{ "_hud_custom_mugshot_name", "<name>" },
		{ "_hud_display_name_in_upper_cases", false },
		{ "_hud_name_use_peer_color", false },

		-- health panel armor
		{ "_hud_display_armor_and_health_values", false },
		{ "_hud_display_armor_regen_timer", false },

		-- reposition chat input bar
		{ "_hud_reposition_chat_input", true },

		-- inventory panel
		{ "_hud_use_custom_inventory_panel", true },

		-- custom ammo panel
		{ "_hud_enable_custom_ammo_panel", true },
		{ "_hud_custom_ammo_panel_style", "custom" },
		{ "_hud_ammo_panel_show_real_ammo", true },

		-- deployable spy and its text formats
		{ "_hud_enable_deployable_spy", true },
		{ "_hud_medic_bag_spy", "[peer_color]$CHARGES;[]x" },
		{ "_hud_ammo_bag_spy", "[peer_color]$PERCENT;[]%" },
		{ "_hud_sentry_gun_spy", "$AMMO;/$AMMO_MAX; | [#7FFF7F]$HEALTH;[]%" },

		-- custom drop-in panel
		{ "_hud_use_custom_drop_in_panel", true },
		{ "_hud_drop_in_show_peer_info", true },
		{ "_hud_mod_list_position", "righttop" },

		{ "_hud_shotgun_fire_timer", false },
		{ "_hud_reload_timer", false },

		-- gameplay changing mods exclusion list
		{
			"_hud_mod_whitelist",
			{
				ovk_193 = true,
				crybaby = true,
				overdrill7200 = true,
				corpse_despawn = true,
				interact_toggle = true,
				restart_end_job = true,
				restore_deployables = true,
			},
		},

		-- custom assault panel and scrolling text format
		{ "_hud_use_custom_control_panel", true },
		{ "_hud_assault_text", { { "///", "$ASSAULT_TITLE;", "///", "$DIFFICULTY_NAME;" } } },

		-- custom point of no return panel
		{ "_hud_use_custom_ponr_panel", true },
	},
	update = { id = "_hud", url = "https://raw.githubusercontent.com/mbien1981/dahm-modules/main/version.json" },
})
