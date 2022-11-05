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

rawset(_G, "_hud_path", ModPath)

D:register_keybind("_hud_debug", "f2", function()
	dofile(_hud_path .. "binds/debug.lua")
end)

-- * libs
module:hook_pre_require("lib/entry", "hooks/lib/gui_data/gui_data")
module:hook_post_require("lib/setups/setup", "hooks/lib/gui_data/setup")

-- * hud
module:hook_post_require("lib/managers/menumanager", "hooks/hud/drop_in")

module:hook_post_require("lib/managers/hudmanager", "hooks/hud/cooldown_timers")

module:hook_post_require("lib/managers/hudmanager", "hooks/hud/health_bar")
module:hook_post_require("lib/units/beings/player/playerdamage", "hooks/hud/health_bar")

module:hook_post_require("lib/setups/gamesetup", "hooks/hud/deployable_spy")

return module
