local module = DMod:new("_hud", {
	name = "_hud",
	author = "_atom",
	version = 2.2,
	dependency = "_sdk",
	includes = {
		{ "mod_localization", { type = "localization" } },
		{ "mod_options", { type = "menu_options" } },
	},
})

-- * libs
module:hook_pre_require("lib/entry", "hooks/lib/gui_data/gui_data")
module:hook_post_require("lib/setups/setup", "hooks/lib/gui_data/setup")

-- * hud
module:hook_post_require("lib/managers/menumanager", "hooks/hud/drop_in")

module:hook_post_require("lib/states/ingamewaitingforplayers", "hooks/hud/state_timer")

module:hook_post_require("lib/states/ingamewaitingforplayers", "hooks/hud/health_bar")
module:hook_post_require("lib/units/beings/player/playerdamage", "hooks/hud/health_bar")

module:hook_post_require("lib/setups/gamesetup", "hooks/hud/deployable_spy")

return module
