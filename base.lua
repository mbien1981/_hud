local module = DMod:new("_hud", {
	name = "_hud",
	author = "_atom",
	version = "1.3.3",
	allow_globals = true,
	dependency = "_sdk",
	includes = {
		{ "mod_localization", { type = "localization" } },
		{ "mod_options", { type = "menu_options" } },
	},
	update = { id = "_hud", url = "https://raw.githubusercontent.com/mbien1981/dahm-modules/main/version.json" },
})

module:hook_post_require("lib/states/ingamewaitingforplayers", "hooks/hud/drop_in")
module:hook_post_require("lib/managers/menumanager", "hooks/hud/drop_in")

module:hook_post_require("lib/managers/hudmanager", "hooks/hud/ammo_panel")

module:hook_post_require("lib/states/ingamewaitingforplayers", "hooks/hud/state_timer")

module:hook_post_require("lib/states/ingamewaitingforplayers", "hooks/hud/health_bar")
module:hook_post_require("lib/units/beings/player/playerdamage", "hooks/hud/health_bar")

module:hook_post_require("lib/states/ingamewaitingforplayers", "hooks/hud/deployable_spy")
module:hook_post_require("lib/units/equipment/ammo_bag/ammobagbase", "hooks/hud/deployable_spy")
module:hook_post_require("lib/units/equipment/doctor_bag/doctorbagbase", "hooks/hud/deployable_spy")
module:hook_post_require("lib/units/equipment/sentry_gun/sentrygunbase", "hooks/hud/deployable_spy")

return module
