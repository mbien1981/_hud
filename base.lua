local module = DMod:new("_hud", {
	name = "_hud",
	author = "_atom",
	version = "1.4.10",
	allow_globals = true,
	dependencies = { "_sdk", "hud" },
	includes = {
		{ "debug/base" },
		{ "mod_hooks" },
		{ "mod_localization", { type = "localization" } },
		{ "mod_options", { type = "menu_options" } },
	},
	update = { id = "_hud", url = "https://raw.githubusercontent.com/mbien1981/dahm-modules/main/version.json" },
})

module:hook_post_require("lib/states/ingamewaitingforplayers", "hooks/drop_in")
module:hook_post_require("lib/managers/menumanager", "hooks/drop_in")

module:hook_post_require("lib/managers/hudmanager", "hooks/ammo_panel")

module:hook_post_require("lib/states/ingamewaitingforplayers", "hooks/state_timer")

module:hook_post_require("lib/states/ingamewaitingforplayers", "hooks/health_bar")
module:hook_post_require("lib/units/beings/player/playerdamage", "hooks/health_bar")
module:hook_post_require("lib/managers/hudmanager", "hooks/inventory")

module:hook_post_require("lib/states/ingamewaitingforplayers", "hooks/deployable_spy")
module:hook_post_require("lib/units/equipment/ammo_bag/ammobagbase", "hooks/deployable_spy")
module:hook_post_require("lib/units/equipment/doctor_bag/doctorbagbase", "hooks/deployable_spy")

module:hook_post_require("lib/managers/gameplaycentralmanager", "hooks/peer_contours")
module:hook_post_require("lib/units/interactions/interactionext", "hooks/deployable_contours")
module:hook_post_require("lib/units/weapons/trip_mine/tripminebase", "hooks/deployable_contours")
module:hook_post_require("lib/units/equipment/ammo_bag/ammobagbase", "hooks/deployable_contours")
module:hook_post_require("lib/units/equipment/doctor_bag/doctorbagbase", "hooks/deployable_contours")

module:hook_post_require("lib/managers/hudmanager", "hooks/name_labels")
module:hook_post_require("lib/network/handlers/unitnetworkhandler", "hooks/name_labels")

return module
