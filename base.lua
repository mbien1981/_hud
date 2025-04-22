local module = DMod:new("_hud", {
	name = "_hud",
	author = "_atom",
	version = "1.7.0",
	dependencies = { "hud", "[drop_in_menu]", "[loadout_dropdowns]", "[holiday_special]" },
	includes = {
		{ "dev/base" },
		{ "mod_hooks" },
		{ "mod_localization", { type = "localization" } },
		{ "mod_options", { type = "menu_options" } },
	},
	update = { id = "_hud", url = "https://raw.githubusercontent.com/mbien1981/dahm-modules/main/version.json" },
})

module:hook_post_require("lib/units/beings/player/playerbase", "hooks/playerbase")
module:hook_post_require("lib/managers/hudmanager", "hooks/hudmanager")

module:hook_post_require("lib/states/ingamewaitingforplayers", "hooks/drop_in")
module:hook_post_require("lib/managers/menumanager", "hooks/drop_in")

module:hook_post_require("lib/managers/hudmanager", "hooks/ammo_panel")

module:hook_post_require("lib/managers/hudmanager", "hooks/state_timer")

module:hook_post_require("lib/managers/hudmanager", "hooks/health_bar", false, 50)
module:hook_post_require("lib/units/beings/player/playerdamage", "hooks/health_bar", false, 50)
module:hook_post_require("lib/managers/hudmanager", "hooks/inventory_panel", false, 51)

module:hook_post_require("lib/units/equipment/ammo_bag/ammobagbase", "hooks/deployable_spy")
module:hook_post_require("lib/units/equipment/doctor_bag/doctorbagbase", "hooks/deployable_spy")
module:hook_post_require("lib/units/equipment/sentry_gun/sentrygunbase", "hooks/deployable_spy")

module:hook_post_require("lib/managers/gameplaycentralmanager", "hooks/peer_contours")
module:hook_post_require("lib/units/interactions/interactionext", "hooks/deployable_contours")
module:hook_post_require("lib/units/weapons/trip_mine/tripminebase", "hooks/deployable_contours")
module:hook_post_require("lib/units/equipment/ammo_bag/ammobagbase", "hooks/deployable_contours")
module:hook_post_require("lib/units/equipment/doctor_bag/doctorbagbase", "hooks/deployable_contours")

module:hook_post_require("lib/managers/hudmanager", "hooks/name_labels")
module:hook_post_require("lib/network/handlers/unitnetworkhandler", "hooks/name_labels")

module:hook_post_require("lib/tweak_data/tweakdata", "hooks/peer_colors")

module:hook_post_require("lib/managers/hudmanager", "hooks/control_panel")

module:hook_post_require("lib/states/ingamewaitingforplayers", "hooks/loadout_dropdowns")
module:hook_post_require("lib/managers/menu/menunodekitgui", "hooks/loadout_dropdowns")
module:hook_post_require("lib/managers/menumanager", "hooks/loadout_dropdowns")

module:hook_post_require("lib/setups/setup", "hooks/mask_selector")
module:hook_post_require("lib/states/ingamewaitingforplayers", "hooks/mask_selector")
module:hook_post_require("lib/managers/menumanager", "hooks/mask_selector")

module:hook_post_require("lib/setups/setup", "classes/toolbox")
module:hook_post_require("lib/setups/setup", "classes/updater")
module:hook_post_require("core/lib/setups/coresetup", "classes/updater")

return module
