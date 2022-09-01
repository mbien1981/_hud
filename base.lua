local module = DMod:new("_hud", {
	name = "_hud",
	author = "_atom",
})

-- * libs
module:hook_pre_require("lib/entry", "hooks/lib/gui_data/gui_data")
module:hook_post_require("lib/setups/setup", "hooks/lib/gui_data/setup")

-- * hud
module:hook_post_require("lib/managers/hudmanager", "hooks/hud/_hud")
module:hook_post_require("lib/managers/hudmanager", "hooks/hud/health_bar")
module:hook_post_require("lib/units/beings/player/playerdamage", "hooks/hud/health_bar")

return module
