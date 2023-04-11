local module = DMod:new("_hud", {
	name = "_hud",
	author = "_atom",
	version = "1.3.5",
	allow_globals = true,
	dependency = "_sdk",
	includes = {
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

module:hook_post_require("lib/states/ingamewaitingforplayers", "hooks/deployable_spy")
module:hook_post_require("lib/units/equipment/ammo_bag/ammobagbase", "hooks/deployable_spy")
module:hook_post_require("lib/units/equipment/doctor_bag/doctorbagbase", "hooks/deployable_spy")
module:hook_post_require("lib/units/equipment/sentry_gun/sentrygunbase", "hooks/deployable_spy")

return module
