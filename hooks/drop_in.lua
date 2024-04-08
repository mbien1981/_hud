_M.CustomDropInclass = class()
local CustomDropInclass = _M.CustomDropInclass

function CustomDropInclass:string_format(text, macros)
	return text:gsub("($([^%s;#]+);?)", function(full_match, macro_name)
		return macros[macro_name:upper()] or full_match
	end)
end

function CustomDropInclass:init()
	self._ws = Overlay:newgui():create_screen_workspace()
	self._panel = self._ws:panel():panel({ layer = 1151 })

	self._sound_source = SoundDevice:create_source("_drop_in")

	self.data = { peers = {}, mods = {} }
	self.font = {
		path = "fonts/font_univers_530_bold",
		sizes = { medium = 24, small = 20 },
	}
	self.colors = {
		black = Color.black,
		white = Color.white,
		grey = Color("CECECE"),
	}

	self._toolbox = rawget(_M, "_hudToolBox")

	self:setup_panels()
end

function CustomDropInclass:setup_panels()
	self.main_panel = self._panel:panel()

	self.player_container = self.main_panel:panel()

	-- self.background = self.main_panel:rect({
	-- 	color = self.colors.black,
	-- 	visible = true,
	-- 	alpha = 0,
	-- 	layer = -1,
	-- })

	-- self.background:stop()
	-- self.background:animate(function(o)
	-- 	self._toolbox:animate_ui(1, function(p)
	-- 		o:set_alpha(math.lerp(o:alpha(), 0.75, p))
	-- 	end)

	-- 	o:set_alpha(0.75)
	-- end)
end

function CustomDropInclass:get_peer_panel(peer_id)
	for i, data in pairs(self.data.peers) do
		if data.peer_id == peer_id then
			return i
		end
	end
end

function CustomDropInclass:show_person_joining(peer)
	if self:get_peer_panel(peer:id()) then
		return
	end

	self._sound_source:post_event("menu_enter")

	local panel = self.player_container:panel()

	local background = panel:rect({
		name = "background",
		color = Color.black,
		visible = true,
		alpha = 0,
		layer = -1,
	})

	background:animate(function(o)
		self._toolbox:animate_ui(1, function(p)
			o:set_alpha(math.lerp(o:alpha(), 0.75, p))
		end)

		o:set_alpha(0.75)
	end)

	local drop_in_title = panel:text({
		name = "drop_in_title",
		text = managers.localization:text("dialog_dropin_title", { USER = peer:name() }),
		font = self.font.path,
		font_size = self.font.sizes.medium,
		layer = 1,
		color = Color.white,
	})
	self._toolbox:make_pretty_text(drop_in_title)

	local drop_in_progress = panel:text({
		name = "drop_in_progress",
		text = self:string_format("$PLEASE_WAIT; $JOIN_PROGRESS;% ($DROP_IN_TIME;s)", {
			PLEASE_WAIT = managers.localization:text("dialog_wait"),
			JOIN_PROGRESS = 69,
			DROP_IN_TIME = 420,
		}),
		font = self.font.path,
		font_size = self.font.sizes.small,
		visible = false,
		color = self.colors.grey,
	})
	self._toolbox:make_pretty_text(drop_in_progress)

	local peer_info = panel:text({
		name = "peer_info",
		text = managers.localization:text("_hud_drop_in_peer_info"),
		font = self.font.path,
		font_size = self.font.sizes.small,
		visible = false,
		color = self.colors.grey,
	})
	self._toolbox:make_pretty_text(peer_info)

	local mod_list_title = panel:text({
		name = "mod_list_title",
		text = managers.localization:text("_hud_drop_in_mod_list_title"),
		font = self.font.path,
		font_size = self.font.sizes.medium,
		visible = false,
		color = self.colors.grey,
	})
	self._toolbox:make_pretty_text(mod_list_title)

	local mod_list = panel:text({
		name = "mod_list",
		text = "",
		font = self.font.path,
		font_size = self.font.sizes.small,
		color = self.colors.grey,
		visible = false,
		align = "right",
	})
	self._toolbox:make_pretty_text(mod_list)

	table.insert(self.data.peers, {
		peer_id = peer:id(),
		join_start_t = os.clock(),
		panel = panel,
	})

	self:layout()
end

function CustomDropInclass:close_person_joining(peer_id)
	local index = self:get_peer_panel(peer_id)
	if not index then
		return
	end

	local peer_data = self.data.peers[index]

	peer_data.panel:clear()
	self.player_container:remove(peer_data.panel)

	self.data.mods[peer_id] = nil
	table.remove(self.data.peers, index)

	self:layout()
end

function CustomDropInclass:get_peer_level(peer)
	return D:conf("hud_prefer_virtual_reps") and peer:property("virtual_rep_level") or peer:level(1) or "?"
end

function CustomDropInclass:get_peer_deployable(peer)
	local deployable_id = managers.player:get_synced_kit_selection(peer:id(), "deployable")
	if not deployable_id then
		return managers.localization:text("_hud_none_selected")
	end

	return managers.localization:text(tweak_data.equipments[deployable_id].text_id):pretty(true)
end

function CustomDropInclass:get_peer_crew_bonus(peer)
	local crew_bonus_id = managers.player:get_crew_bonus_by_peer(peer:id())
	if not crew_bonus_id then
		return managers.localization:text("_hud_none_selected")
	end

	return managers.localization:text(tweak_data.upgrades.definitions[crew_bonus_id].name_id):pretty(true)
end

function CustomDropInclass:update_person_joining(peer, join_progress)
	local index = self:get_peer_panel(peer:id())
	if not index then
		self:show_person_joining(peer)
		return
	end

	local peer_data = self.data.peers[index]
	local panel = peer_data.panel
	local progress = panel:child("drop_in_progress")
	local peer_info = panel:child("peer_info")
	local mod_list_title = panel:child("mod_list_title")
	local mod_list = panel:child("mod_list")

	local time_left = math.max(((os.clock() - peer_data.join_start_t) / join_progress) * (100 - join_progress), 0)
	progress:show()
	progress:set_text(self:string_format("$PLEASE_WAIT; $JOIN_PROGRESS;% ($DROP_IN_TIME;s)", {
		PLEASE_WAIT = managers.localization:text("dialog_wait"),
		JOIN_PROGRESS = join_progress,
		DROP_IN_TIME = string.format("%02d", time_left),
	}))

	peer_info:set_visible(D:conf("_hud_drop_in_show_peer_info"))
	peer_info:set_text(managers.localization:text("_hud_drop_in_peer_info", {
		LEVEL = self:get_peer_level(peer),
		MASK = managers.localization:text("menu_mask_" .. peer:mask_set()):pretty(true),
		DEPLOYABLE = self:get_peer_deployable(peer),
		CREW_BONUS = self:get_peer_crew_bonus(peer),
		READY = managers.localization:text(peer:waiting_for_player_ready() and "_hud_yes" or "_hud_no"),
	}))

	if peer:has_dmf() and not mod_list_title:visible() then
		local mod_data = self.data.mods[peer:id()]
		if mod_data and (mod_data ~= "") then
			mod_list_title:show()
			mod_list:show()
			mod_list:set_text(mod_data)
		end
	end

	self._toolbox:parse_color_tags(progress)
	self._toolbox:parse_color_tags(peer_info)
	self._toolbox:parse_color_tags(mod_list_title)
	self._toolbox:parse_color_tags(mod_list)

	self:layout_peer_panel(panel)
end

function CustomDropInclass:layout()
	local n_peers = table.size(self.data.peers)

	local container = self.player_container
	local h = container:h()
	if n_peers > 1 then
		h = container:h() * 0.5
	end

	local w = container:w()
	local widths = {
		n_peers > 2 and w * 0.5 or w,
		n_peers > 2 and w * 0.5 or w,
		w,
	}

	local positions = {
		y = { 0, n_peers == 2 and h or 0, h },
		x = { 0, n_peers > 2 and w * 0.5 or 0, 0 },
	}

	for i, item in pairs(self.data.peers) do
		item.panel:set_h(h)
		item.panel:set_w(widths[i])
		item.panel:set_y(positions.y[i])
		item.panel:set_x(positions.x[i])

		self:layout_peer_panel(item.panel)
	end
end

function CustomDropInclass:layout_peer_panel(panel, setting)
	local progress = panel:child("drop_in_progress")
	local title = panel:child("drop_in_title")
	local peer_info = panel:child("peer_info")

	progress:set_world_center(panel:world_center())
	title:set_bottom(progress:top())
	title:set_center_x(progress:center_x())

	peer_info:set_top(progress:bottom() + 24)
	peer_info:set_x(title:x())

	self:reposition_modlist(panel)
end

function CustomDropInclass:reposition_modlist(panel) -- yandev code :(
	local setting = D:conf("_hud_mod_list_position")

	local mod_list_title = panel:child("mod_list_title")
	local mod_list = panel:child("mod_list")

	if setting == "leftbottom" then
		mod_list:set_world_x(panel:world_x() + 2)
		mod_list:set_world_bottom(panel:world_bottom())
		mod_list:set_align("left")

		mod_list_title:set_world_x(mod_list:world_x())
		mod_list_title:set_world_bottom(mod_list:world_top())
		return
	end

	if setting == "lefttop" then
		mod_list_title:set_world_x(panel:world_x())
		mod_list_title:set_world_top(panel:world_top())

		mod_list:set_align("left")
		mod_list:set_world_x(mod_list_title:world_x() + 2)
		mod_list:set_world_top(mod_list_title:world_bottom())
	end

	if setting == "centertop" then
		local title = panel:child("drop_in_title")

		mod_list_title:set_world_top(panel:world_top())
		mod_list:set_world_top(mod_list_title:world_bottom())

		local align = "center"
		local title_x = panel:world_center_x() - mod_list_title:w() * 0.5
		local list_x = panel:world_center_x() - mod_list:w() * 0.5
		if mod_list:world_bottom() >= (title:world_top() - title:h()) then
			align = "left"
			title_x = panel:world_x()
			list_x = title_x + 2
		end

		mod_list:set_align(align)
		mod_list_title:set_world_x(title_x)
		mod_list:set_world_x(list_x)
		return
	end

	if setting == "righttop" then
		mod_list_title:set_world_right(panel:world_right())
		mod_list_title:set_world_top(panel:world_top())

		mod_list:set_align("right")
		mod_list:set_world_right(panel:world_right() - 2)
		mod_list:set_world_top(mod_list_title:world_bottom())
		return
	end

	if setting == "rightbottom" then
		mod_list:set_align("right")
		mod_list:set_world_right(panel:world_right() - 2)
		mod_list:set_world_bottom(panel:world_bottom())

		mod_list_title:set_world_right(panel:world_right())
		mod_list_title:set_world_bottom(mod_list:world_top())

		return
	end

	if setting == "centerbottom" then
		local peer_info = panel:child("peer_info")

		mod_list:set_world_bottom(panel:world_bottom())
		mod_list_title:set_world_bottom(mod_list:world_top())

		local align = "center"
		local title_x = panel:world_center_x() - mod_list_title:w() * 0.5
		local list_x = panel:world_center_x() - mod_list:w() * 0.5
		if peer_info:world_bottom() > mod_list_title:world_top() then
			align = "left"
			title_x = panel:world_x()
			list_x = title_x + 2
		end

		mod_list:set_align(align)
		mod_list_title:set_world_x(title_x)
		mod_list:set_world_x(list_x)

		return
	end
end

function CustomDropInclass:destroy()
	if not alive(self._panel) then
		return
	end

	self._panel:parent():clear()
	self._ws:gui():destroy_workspace(self._ws)
end

local module = ... or D:module("_hud")

-- https://gist.github.com/zneix/fb99059520fe94cfcfaaefe8d02af6db#file-user-lua-L739
D:hook("OnNetworkDataRecv", "OnNetworkDataRecv_hud_drop_in", { "GAMods" }, function(peer, _, data)
	if type(data) ~= "table" then
		return
	end

	local drop_in = rawget(_M, "CustomDropInPanel")
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
		rawset(_M, "CustomDropInPanel", CustomDropInclass:new())
	end, false)
end

if RequiredScript == "lib/managers/menumanager" then
	local MenuManager = module:hook_class("MenuManager")
	module:hook(50, MenuManager, "show_person_joining", function(self, peer_id, nick)
		local drop_in = rawget(_M, "CustomDropInPanel")
		if not drop_in or not D:conf("_hud_use_custom_drop_in_panel") then
			module:call_orig(MenuManager, "show_person_joining", self, peer_id, nick)
			return
		end

		drop_in:show_person_joining(managers.network:session():peer(peer_id))
	end, false)

	module:hook(50, MenuManager, "close_person_joining", function(self, peer_id)
		local drop_in = rawget(_M, "CustomDropInPanel")
		if not drop_in or not D:conf("_hud_use_custom_drop_in_panel") then
			module:call_orig(MenuManager, "close_person_joining", self, peer_id)
			return
		end

		if managers.system_menu:get_dialog("user_dropin" .. peer_id) then
			managers.system_menu:close("user_dropin" .. peer_id)
		end

		drop_in:close_person_joining(peer_id)
	end, false)

	module:hook(50, MenuManager, "update_person_joining", function(self, peer_id, progress)
		local peer = managers.network:session():peer(peer_id)

		local drop_in = rawget(_M, "CustomDropInPanel")
		if not drop_in or not D:conf("_hud_use_custom_drop_in_panel") then
			if drop_in and drop_in:get_peer_panel(peer_id) then
				drop_in:close_person_joining(peer_id)

				if managers.system_menu:get_dialog("user_dropin" .. peer_id) then
					self:show_person_joining(peer_id, peer:name())
				end
			end

			module:call_orig(MenuManager, "update_person_joining", self, peer_id, progress)
			return
		end

		if managers.system_menu:get_dialog("user_dropin" .. peer_id) then
			managers.system_menu:close("user_dropin" .. peer_id)
		end

		drop_in:update_person_joining(peer, progress)
	end, false)
end
