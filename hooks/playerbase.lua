local module = ... or D:module("_hud")

local PlayerBase = module:hook_class("PlayerBase")
module:post_hook(PlayerBase, "_setup_hud", function()
	D:call_hooks("OnSetupHUD", managers.hud, {
		PLAYER_HUD = managers.hud:script(PlayerBase.PLAYER_HUD),
		PLAYER_INFO_HUD_FULLSCREEN = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN),
		XP_HUD = managers.hud:script(PlayerBase.XP_HUD),
		PLAYER_INFO_HUD = managers.hud:script(PlayerBase.PLAYER_INFO_HUD),
		PLAYER_DOWNED_HUD = managers.hud:script(PlayerBase.PLAYER_DOWNED_HUD),
	})
end)
