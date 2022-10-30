if not rawget(_G, "_drop_in") then
	rawset(_G, "_drop_in", {})

	function _drop_in:init()
		self._initialized = true
		self._active = false
		self._peers = {}
		self._peer_mods = {}

		self._ws = managers.gui_data:create_fullscreen_workspace()
		self._panel = self._ws:panel():panel({
			alpha = 1,
			layer = 150,
		})
		self._sound_source = SoundDevice:create_source("_drop_in")

		self._colors = {
			_black = Color.black,
			_white = Color.white,
			_grey = Color("CECECE"),
		}

		self:setup_panels()
	end

	function _drop_in:setup_panels()
		self._panel:clear()

		self._hud_ws = self._panel:panel()

		self._background = self._hud_ws:rect({
			color = self._colors._black,
			visible = false,
			alpha = 0,
			layer = -1,
		})

		self._peer_joining_text = self._hud_ws:text({
			text = "",
			color = self._colors._white,
			halign = "center",
			font = "fonts/font_univers_530_bold",
			font_size = 24,
		})

		self._percentage_text = self._hud_ws:text({
			text = "",
			color = self._colors._grey,
			halign = "center",
			font = "fonts/font_univers_530_bold",
			font_size = 20,
		})

		self._peer_info_text = self._hud_ws:text({
			text = "",
			color = self._colors._grey,
			font = "fonts/font_univers_530_bold",
			font_size = 20,
		})

		self._peer_mod_list = self._hud_ws:text({
			text = "",
			color = self._colors._grey,
			font = "fonts/font_univers_530_bold",
			font_size = 20,
			align = "left",
		})

		self:align_panels()
	end

	function _drop_in:align_panels()
		local _hud = rawget(_G, "_hud")
		_hud.update_text_rect(self._percentage_text)
		_hud.update_text_rect(self._peer_joining_text)
		_hud.update_text_rect(self._peer_info_text)
		_hud.update_text_rect(self._peer_mod_list)

		self._percentage_text:set_center(self._hud_ws:center())

		self._peer_joining_text:set_center(self._percentage_text:center())
		self._peer_joining_text:set_bottom(self._percentage_text:top() - 4)

		self._peer_info_text:set_left(self._peer_joining_text:left())
		self._peer_info_text:set_top(self._percentage_text:bottom() + 24)

		self._peer_mod_list:set_righttop(self._hud_ws:righttop())
	end

	function _drop_in:open(id)
		if not self._initialized then
			self:init()
		end

		self._peers[id] = true
		if self._active then
			return
		end

		self._active = id
		self._sound_source:post_event("menu_enter")

		local peer = managers.network:session():peer(id)
		if not peer then
			self:close(id)
			return
		end

		self._background:stop()
		self._background:animate(function(o)
			o:show()
			_G._hud:animate_ui(1, function(p)
				o:set_alpha(math.lerp(o:alpha(), 0.75, p))
			end)
		end)

		self._peer_joining_text:show()
		self._peer_joining_text:set_text(managers.localization:text("dialog_dropin_title", {
			USER = peer:name(),
		}))

		self:align_panels()
	end

	function _drop_in:update_peer(id, progress, time_left)
		local _hud = rawget(_G, "_hud")
		if not self._active then
			self:open(id)
		end

		if self._active ~= id then
			return
		end

		if not self._background:visible() then
			self._background:stop()
			self._background:animate(function(o)
				o:show()
				_hud:animate_ui(1, function(p)
					o:set_alpha(math.lerp(o:alpha(), 0.75, p))
				end)
			end)
		end

		self._percentage_text:show()
		self._percentage_text:set_text(
			string.format("%s %d%% (%.2fs)", managers.localization:text("dialog_wait"), progress, time_left)
		)

		self._peer_info_text:set_visible(_hud.conf("_hud_drop_in_show_peer_info"))

		local peer = managers.network:session():peer(id)
		local deployable = managers.player:get_synced_kit_selection(peer:id(), "deployable")
		local crew_bonus = managers.player:get_crew_bonus_by_peer(peer:id())
		self._peer_info_text:set_text(
			string.format(
				managers.localization:text("_hud_drop_in_peer_info"),
				peer:level(),
				managers.localization:text("menu_mask_" .. peer:mask_set()):pretty(true),
				deployable and managers.localization:text(tweak_data.equipments[deployable].text_id):pretty(true)
					or "None",
				crew_bonus
						and managers.localization:text(tweak_data.upgrades.definitions[crew_bonus].name_id):pretty(true)
					or "None",
				managers.localization:text(peer:waiting_for_player_ready() and "_hud_yes" or "_hud_no")
			)
		)

		if peer:has_dmf() then
			local mod_list = self._peer_mods[peer:id()]
			if mod_list and (mod_list ~= "") then
				self._peer_mod_list:show()
				self._peer_mod_list:set_text(
					string.format(managers.localization:text("_hud_mod_list_title"), self._peer_mods[peer:id()])
				)
			end
		end

		self:align_panels()
	end

	function _drop_in:close(id)
		local _hud = rawget(_G, "_hud")
		if not self._initialized then
			self:init()
			return
		end

		self._active = nil
		self._peers[id] = nil
		self._peer_mods[id] = nil

		self._background:stop()
		self._background:animate(function(o)
			_hud:animate_ui(1, function(p)
				o:set_alpha(math.lerp(o:alpha(), 0, p))
			end)
			o:hide()
		end)

		self._peer_joining_text:set_text("")
		self._percentage_text:set_text("")
		self._peer_info_text:set_text("")
		self._peer_mod_list:set_text("")
		self._peer_joining_text:hide()
		self._percentage_text:hide()
		self._peer_info_text:hide()
		self._peer_mod_list:hide()
	end
end

local module = ... or D:module("_hud")

local MenuManager = module:hook_class("MenuManager")
module:hook(50, MenuManager, "show_person_joining", function(self, id, nick)
	if not _hud or (_hud and not _hud.conf("_hud_use_custom_drop_in_panel")) then
		module:call_orig(MenuManager, "show_person_joining", self, id, nick)
		return
	end

	self.peer_join_start_t = self.peer_join_start_t or {}
	self.peer_join_start_t[id] = os.clock()

	local _drop_in = rawget(_G, "_drop_in")
	if _drop_in then
		_drop_in:open(id)
	end
end, false)

module:hook(50, MenuManager, "close_person_joining", function(self, id)
	if self.peer_join_start_t then
		self.peer_join_start_t[id] = nil
	end

	local _hud = rawget(_G, "_hud")
	if not _hud or (_hud and not _hud.conf("_hud_use_custom_drop_in_panel")) then
		module:call_orig(MenuManager, "close_person_joining", self, id)
		return
	end

	local dlg = managers.system_menu:get_dialog("user_dropin" .. id)
	if dlg then
		managers.system_menu:close("user_dropin" .. id)
		dlg = nil
	end

	local _drop_in = rawget(_G, "_drop_in")
	if _drop_in then
		_drop_in:close(id)
	end
end, false)

module:hook(50, MenuManager, "update_person_joining", function(self, id, progress)
	local _hud = rawget(_G, "_hud")
	local _drop_in = rawget(_G, "_drop_in")

	if not _hud then
		module:call_orig(MenuManager, "update_person_joining", self, id, progress)
		return
	end

	if not _hud.conf("_hud_use_custom_drop_in_panel") then
		if _drop_in and _drop_in._active then
			_drop_in:close(id)

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
		dlg = nil
	end

	if self.peer_join_start_t and self.peer_join_start_t[id] then
		local t = os.clock() - self.peer_join_start_t[id]
		local time_left = (t / progress) * (100 - progress)

		if _drop_in then
			_drop_in:update_peer(id, progress, time_left)
		end
	end
end, false)

-- https://gist.github.com/zneix/fb99059520fe94cfcfaaefe8d02af6db#file-user-lua-L739
D:hook("OnNetworkDataRecv", "OnNetworkDataRecv_hud_drop_in", { "GAMods" }, function(peer, data_type, data)
	local _hud = rawget(_G, "_hud")
	local _drop_in = rawget(_G, "_drop_in")
	if not _hud or not _drop_in or type(data) ~= "table" then
		return
	end

	if not _drop_in._initialized then
		_drop_in:init()
	end

	local mod_list_str = ""

	local whitelist = _hud.conf("_hud_mod_whitelist") or {}
	for k, _ in pairs(data) do
		if not whitelist[k] then
			mod_list_str = string.format("%s\n%s", mod_list_str, k)
		end
	end

	_drop_in._peer_mods[peer:id()] = mod_list_str
end)
