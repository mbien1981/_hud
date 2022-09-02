local module = DMod:new("_hud", {
	name = "_hud",
	author = "_atom",
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
module:hook_post_require("lib/managers/menumanager", "hooks/hud/_drop_in")
module:hook_post_require("lib/managers/hudmanager", "hooks/hud/_hud")
module:hook_post_require("lib/managers/hudmanager", "hooks/hud/health_bar")
module:hook_post_require("lib/units/beings/player/playerdamage", "hooks/hud/health_bar")

return module
