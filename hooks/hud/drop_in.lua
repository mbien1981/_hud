CustomDropInClass = class()

function CustomDropInClass:init()
	self._active = false

	self._ws = managers.gui_data:create_fullscreen_workspace()
	self._panel = self._ws:panel():panel({
		alpha = 1,
		layer = 150,
	})

	self._sound_source = SoundDevice:create_source("_drop_in")
	self.data = {
		peers = {},
		mods = {},
	}
	self.font = {
		path = "fonts/font_univers_530_bold",
		sizes = { medium = 24, small = 20 },
	}
	self.colors = {
		black = Color.black,
		white = Color.white,
		grey = Color("CECECE"),
	}

	self._sdk = _G._sdk

	self:setup_panels()
end

function CustomDropInClass:setup_panels()
	self._panel:clear()

	self.main_panel = self._panel:panel()

	self._background = self.main_panel:rect({
		color = self.colors.black,
		visible = false,
		alpha = 0,
		layer = -1,
	})

	self._peer_name = self.main_panel:text({
		text = "",
		color = self.colors.white,
		font = self.font.path,
		font_size = self.font.sizes.medium,
		align = "center",
	})

	self._progress = self.main_panel:text({
		text = "",
		color = self.colors.grey,
		font = self.font.path,
		font_size = self.font.sizes.small,
		align = "center",
	})

	self._peer_info = self.main_panel:text({
		text = "",
		color = self.colors.grey,
		font = self.font.path,
		font_size = self.font.sizes.small,
	})

	self._peer_mods = self.main_panel:text({
		text = "",
		color = self.colors.grey,
		font = self.font.path,
		font_size = self.font.sizes.small,
		align = "left",
	})

	self:_layout()
end

function CustomDropInClass:_layout()
	self._sdk:update_text_rect(self._progress)
	self._sdk:update_text_rect(self._peer_name)
	self._sdk:update_text_rect(self._peer_info)
	self._sdk:update_text_rect(self._peer_mods)

	self._progress:set_center(self.main_panel:center())

	self._peer_name:set_center(self.main_panel:center())
	self._peer_name:set_bottom(self._progress:top() - 4)

	self._peer_info:set_left(self._peer_name:left())
	self._peer_info:set_top(self._progress:bottom() + 24)

	local setting = D:conf("_hud_mod_list_position")
	if setting == "leftbottom" then
		self._peer_mods:set_leftbottom(self.main_panel:left() + 5, self.main_panel:bottom() - 5)
		return
	end

	if setting == "lefttop" then
		self._peer_mods:set_lefttop(self.main_panel:left() + 5, self.main_panel:top() + 5)
		return
	end

	if setting == "centertop" then
		self._peer_mods:set_top(self.main_panel:top() + 5)
		self._peer_mods:set_center_x(self.main_panel:center_x())
	end

	if setting == "righttop" then
		self._peer_mods:set_righttop(self.main_panel:right() - 5, self.main_panel:top() + 5)
		return
	end

	if setting == "centerright" then
		self._peer_mods:set_center_y(self.main_panel:center_y())
		self._peer_mods:set_right(self.main_panel:right() - 5)
	end

	if setting == "rightbottom" then
		self._peer_mods:set_rightbottom(self.main_panel:right() - 5, self.main_panel:bottom() - 5)
		return
	end

	if setting == "centerbottom" then
		self._peer_mods:set_bottom(self.main_panel:bottom() - 5)
		self._peer_mods:set_center_x(self.main_panel:center_x())
	end
end

function CustomDropInClass:update_peer(peer_id, progress, time_left)
	if not self._active then
		self:show(peer_id)
	end

	if self._active ~= peer_id then
		return
	end

	if not self._background:visible() then
		self._background:stop()
		self._background:animate(function(o)
			o:show()
			self._sdk:animate_ui(1, function(p)
				o:set_alpha(math.lerp(o:alpha(), 0.75, p))
			end)

			o:set_alpha(0.75)
		end)
	end

	self._progress:show()
	self._progress:set_text(
		string.format("%s %d%% (%.2fs)", managers.localization:text("dialog_wait"), progress, time_left)
	)

	self._peer_info:set_visible(D:conf("_hud_drop_in_show_peer_info"))

	local peer = managers.network:session():peer(peer_id)
	local deployable = managers.player:get_synced_kit_selection(peer:id(), "deployable")
	local crew_bonus = managers.player:get_crew_bonus_by_peer(peer:id())
	self._peer_info:set_text(
		string.format(
			managers.localization:text("_hud_drop_in_peer_info"),
			peer:level(),
			managers.localization:text("menu_mask_" .. peer:mask_set()):pretty(true),
			deployable and managers.localization:text(tweak_data.equipments[deployable].text_id):pretty(true) or "None",
			crew_bonus and managers.localization:text(tweak_data.upgrades.definitions[crew_bonus].name_id):pretty(true)
				or "None",
			managers.localization:text(peer:waiting_for_player_ready() and "_hud_yes" or "_hud_no")
		)
	)

	if peer:has_dmf() then
		local mod_list = self.data.mods[peer:id()]
		if mod_list and (mod_list ~= "") then
			self._peer_mods:show()
			self._peer_mods:set_text(string.format(managers.localization:text("_hud_mod_list_title"), mod_list))
		end
	end

	self:_layout()
end

function CustomDropInClass:show(peer_id)
	self.data.peers[peer_id] = true
	if self._active then
		return
	end

	self._active = peer_id
	self._sound_source:post_event("menu_enter")

	local peer = managers.network:session():peer(peer_id)
	if not peer then
		self:hide(peer_id)
		return
	end

	self._background:stop()
	self._background:animate(function(o)
		o:show()
		self._sdk:animate_ui(1, function(p)
			o:set_alpha(math.lerp(o:alpha(), 0.75, p))
		end)

		o:set_alpha(0.75)
	end)

	self._peer_name:show()
	self._peer_name:set_text(managers.localization:text("dialog_dropin_title", {
		USER = peer:name(),
	}))

	self:_layout()
end

function CustomDropInClass:hide(peer_id)
	self._active = nil
	self.data.peers[peer_id] = nil
	self.data.mods[peer_id] = nil

	self._background:stop()
	self._background:animate(function(o)
		self._sdk:animate_ui(1, function(p)
			o:set_alpha(math.lerp(o:alpha(), 0, p))
		end)

		o:set_alpha(0)
		o:hide()
	end)

	self._peer_name:set_text("")
	self._peer_name:hide()
	self._progress:set_text("")
	self._progress:hide()
	self._peer_info:set_text("")
	self._peer_info:hide()
	self._peer_mods:set_text("")
	self._peer_mods:hide()
end

local module = ... or D:module("_hud")

-- https://gist.github.com/zneix/fb99059520fe94cfcfaaefe8d02af6db#file-user-lua-L739
D:hook("OnNetworkDataRecv", "OnNetworkDataRecv_hud_drop_in", { "GAMods" }, function(peer, _, data)
	if type(data) ~= "table" then
		return
	end

	local drop_in = rawget(_G, "CustomDropInPanel")
	if not drop_in then
		return
	end

	local mod_list_str = ""
	local whitelist = D:conf("_hud_mod_whitelist") or {}
	for k, _ in pairs(data) do
		if not whitelist[k:lower()] then
			mod_list_str = string.format("%s\n%s", mod_list_str, k)
		end
	end

	drop_in.data.mods[peer:id()] = mod_list_str
end)

if RequiredScript == "lib/states/ingamewaitingforplayers" then
	local IngameWaitingForPlayersState = module:hook_class("IngameWaitingForPlayersState")
	module:post_hook(50, IngameWaitingForPlayersState, "at_exit", function(...)
		rawset(_G, "CustomDropInPanel", CustomDropInClass:new())
	end, false)
end

if RequiredScript == "lib/managers/menumanager" then
	module:hook(50, MenuManager, "update_person_joining", function(self, id, progress)
		local drop_in = rawget(_G, "CustomDropInPanel")
		if not drop_in or not D:conf("_hud_use_custom_drop_in_panel") then
			if drop_in and drop_in._active then
				drop_in:hide(id)

				local dlg = managers.system_menu:get_dialog("user_dropin" .. id)
				if not dlg then
					self:show_person_joining(id, managers.network:session():peer(id):name())
				end
			end

			module:call_orig(MenuManager, "update_person_joining", self, id, progress)
			return
		end

		local dlg = managers.system_menu:get_dialog("user_dropin" .. id)
		if dlg then
			managers.system_menu:close("user_dropin" .. id)
		end

		if self.peer_join_start_t and self.peer_join_start_t[id] then
			local t = os.clock() - self.peer_join_start_t[id]
			local time_left = (t / progress) * (100 - progress)

			drop_in:update_peer(id, progress, time_left)
		end
	end, false)

	local MenuManager = module:hook_class("MenuManager")
	module:hook(50, MenuManager, "show_person_joining", function(self, id, nick)
		local drop_in = rawget(_G, "CustomDropInPanel")

		if not drop_in or not D:conf("_hud_use_custom_drop_in_panel") then
			module:call_orig(MenuManager, "show_person_joining", self, id, nick)
			return
		end

		self.peer_join_start_t = self.peer_join_start_t or {}
		self.peer_join_start_t[id] = os.clock()

		drop_in:show(id)
	end, false)

	module:hook(50, MenuManager, "close_person_joining", function(self, id)
		if self.peer_join_start_t then
			self.peer_join_start_t[id] = nil
		end

		local drop_in = rawget(_G, "CustomDropInPanel")
		if not drop_in or not D:conf("_hud_use_custom_drop_in_panel") then
			module:call_orig(MenuManager, "close_person_joining", self, id)
			return
		end

		local dlg = managers.system_menu:get_dialog("user_dropin" .. id)
		if dlg then
			managers.system_menu:close("user_dropin" .. id)
		end

		drop_in:hide(id)
	end, false)
end
