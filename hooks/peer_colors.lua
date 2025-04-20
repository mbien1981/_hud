local module = ... or D:module("_hud")

local TweakData = module:hook_class("TweakData")
module:post_hook(TweakData, "init", function(self)
	self.chat_colors = {
		D:conf("_hud_peer1_color") or Color(0.6, 0.6, 1),
		D:conf("_hud_peer2_color") or Color(1, 0.6, 0.6),
		D:conf("_hud_peer3_color") or Color(0.6, 1, 0.6),
		D:conf("_hud_peer4_color") or Color(1, 1, 0.6),
	}
end, false)
