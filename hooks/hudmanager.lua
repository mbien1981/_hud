local module = ... or D:module("_hud")

local HUDManager = module:hook_class("HUDManager")

module:post_hook(HUDManager, "_player_hud_layout", function(self)
	if not self:alive(PlayerBase.PLAYER_INFO_HUD) then
		return
	end

	D:call_hooks("OnPlayerHudLayout", self, self:script(PlayerBase.PLAYER_INFO_HUD))
end)

module:pre_hook(HUDManager, "update_hud_visibility", function(self, name)
	D:call_hooks("OnUpdateHUDVisibility", self)
end)
