if not rawget(_G, "_drop_in") then
	rawset(_G, "_drop_in", {})

	function _drop_in:init()
		self._initialized = true
		self._active = false
		self._peers = {}

		self._ws = managers.gui_data:create_fullscreen_workspace()
		self._panel = self._ws:panel():panel({
			alpha = 1,
			layer = 150,
		})
		self._sound_source = SoundDevice:create_source("hud")

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

		self:align_panels()
	end

	function _drop_in:align_panels()
		local _, _, w, h = self._percentage_text:text_rect()
		self._percentage_text:set_w(w)
		self._percentage_text:set_h(h)

		local _, _, w, h = self._peer_joining_text:text_rect()
		self._peer_joining_text:set_w(w)
		self._peer_joining_text:set_h(h)

		local _, _, w, h = self._peer_info_text:text_rect()
		self._peer_info_text:set_w(w)
		self._peer_info_text:set_h(h)

		self._percentage_text:set_center(self._hud_ws:center())

		self._peer_joining_text:set_center(self._percentage_text:center())
		self._peer_joining_text:set_bottom(self._percentage_text:top() - 4)

		self._peer_info_text:set_left(self._peer_joining_text:left())
		self._peer_info_text:set_top(self._percentage_text:bottom() + 24)
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

		-- self._panel:set_visible(true)
		self._background:animate(function(o)
			o:show()
			_hud:animate_ui(1, function(p)
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
		if not self._active then
			self:open(id)
		end

		if self._active ~= id then
			return
		end

		self._percentage_text:show()
		self._percentage_text:set_text(
			string.format("%s %d%% (%.2fs)", managers.localization:text("dialog_wait"), progress, time_left)
		)

		self._peer_info_text:set_visible(D:conf("_hud_drop_in_show_peer_info"))

		local peer = managers.network:session():peer(id)
		local deployable = managers.player:get_synced_kit_selection(peer:id(), "deployable")
		local crew_bonus = managers.player:get_crew_bonus_by_peer(peer:id()) or { name_id = "debug_none" }
		self._peer_info_text:set_text(
			string.format(
				managers.localization:text("_hud_drop_in_peer_info"),
				peer:level(),
				managers.localization:text("menu_mask_" .. peer:mask_set()):pretty(true),
				managers.localization:text(tweak_data.equipments[deployable].text_id):pretty(true),
				managers.localization:text(tweak_data.upgrades.definitions[crew_bonus].name_id):pretty(true),
				managers.localization:text(peer:waiting_for_player_ready() and "_hud_yes" or "_hud_no")
			)
		)

		self:align_panels()
	end

	function _drop_in:close(id)
		if not self._initialized then
			self:init()
			return
		end

		self._active = nil
		self._peers[id] = nil

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
		self._peer_joining_text:hide()
		self._percentage_text:hide()
		self._peer_info_text:hide()
	end
end

--module:call_orig(HUDManager, "set_crosshair_visible", self, visible)

local module = ... or D:module("_hud")

local MenuManager = module:hook_class("MenuManager")
module:hook(50, MenuManager, "show_person_joining", function(self, id, nick)
	if not D:conf("_hud_use_custom_drop_in_panel") then
		module:call_orig(MenuManager, "set_crosshair_visible", self, id, nick)
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
	if not D:conf("_hud_use_custom_drop_in_panel") then
		module:call_orig(MenuManager, "close_person_joining", self, id)
		return
	end

	if self.peer_join_start_t then
		self.peer_join_start_t[id] = nil
	end

	local _drop_in = rawget(_G, "_drop_in")
	if _drop_in then
		_drop_in:close(id)
	end
end, false)

module:hook(50, MenuManager, "update_person_joining", function(self, id, progress)
	if not D:conf("_hud_use_custom_drop_in_panel") then
		module:call_orig(MenuManager, "update_person_joining", self, id, progress)
		return
	end

	if self.peer_join_start_t and self.peer_join_start_t[id] then
		local t = os.clock() - self.peer_join_start_t[id]
		local time_left = (t / progress) * (100 - progress)

		local _drop_in = rawget(_G, "_drop_in")
		if _drop_in then
			_drop_in:update_peer(id, progress, time_left)
		end
	end
end, false)
