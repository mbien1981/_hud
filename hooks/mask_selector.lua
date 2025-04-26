local module = ... or D:module("_hud")

_M.MaskSelectorGUIClass = _M.MaskSelectorGUIClass or class()

local MaskSelectorGUIClass = _M.MaskSelectorGUIClass
----------
-- Utils
---
function MaskSelectorGUIClass:make_box(panel)
	local panel_w, panel_h = panel:size()
	local align = "grow"
	panel:rect({
		color = Color("0A0A0A"):with_alpha(1.4),
		halign = align,
		valign = align,
		w = panel_w,
		h = panel_h,
	})
	panel:rect({
		color = Color("3C3C3C"):with_alpha(1.4),
		halign = align,
		valign = align,
		x = 1,
		y = 1,
		w = panel_w - 2,
		h = panel_h - 2,
	})
	panel:rect({
		color = Color("0A0A0A"):with_alpha(1.4),
		halign = align,
		valign = align,
		x = 3,
		y = 3,
		w = panel_w - 6,
		h = panel_h - 6,
	})
end

function MaskSelectorGUIClass:animate_ui(total_t, callback)
	local t = 0
	local const_frames = 0
	local count_frames = const_frames + 1
	while t < total_t do
		coroutine.yield()
		t = t + TimerManager:main():delta_time()
		if count_frames >= const_frames then
			callback(t / total_t, t)
			count_frames = 0
		end
		count_frames = count_frames + 1
	end

	callback(1, total_t)
end

function MaskSelectorGUIClass:unhighlight_element()
	if not alive(self.current_highlight) then
		return
	end

	local rect_item = self.current_highlight
	rect_item:stop()
	rect_item:animate(function(o)
		self:animate_ui(5, function(p)
			o:set_alpha(math.lerp(o:alpha(), 0, p))
		end)
		o:set_alpha(0)
		o:parent():remove(o)
	end)

	self.current_highlight = nil
end

function MaskSelectorGUIClass:highlight_element(panel, size, style)
	self:unhighlight_element()
	if alive(self.current_highlight) then
		return
	end

	size = size or {}
	style = style or {}

	local rect_item = panel:rect({
		x = size.x or 0,
		y = size.y or 0,
		w = panel:w() - (size.w or 0),
		h = panel:h() - (size.h or 0),
		layer = size.layer or 100,
		color = style.color,
		alpha = 0,
	})
	rect_item:stop()
	rect_item:animate(function(o)
		self:animate_ui(0.1, function(p)
			o:set_alpha(math.lerp(o:alpha(), style.alpha or 0.2, p))
		end)
	end)

	self.current_highlight = rect_item
end

-------------------
-- Initialization
---
function MaskSelectorGUIClass:init()
	self._ws = Overlay:newgui():create_screen_workspace()
	self._panel = self._ws:panel():panel({ visible = false, alpha = 0, layer = 1151 })

	self.font = { path = "fonts/font_univers_530_bold", sizes = { medium = 24, small = 20 } }

	self._name = "QuickMaskGUI"
	self._controller_id = self._name .. "_controller"

	self._use_controller = true

	self.height_data = {
		["button"] = 56,
	}

	self._toolbox = _M._hudToolBox
	self._updater = _M._hudUpdater

	self:setup()
end

function MaskSelectorGUIClass:setup()
	self:setup_panels()
end

function MaskSelectorGUIClass:setup_panels()
	self.main_panel = self._panel:panel()

	local w, h = self.main_panel:size()
	w, h = w / 2, h / 2

	self.window = self.main_panel:panel({ w = w, h = h, x = w - (w / 2), y = h - (h / 2) })
	self.feature_panel = self.window:panel({
		w = self.window:w() - 10,
		h = self.window:h() - 10,
		x = 5,
		y = 5,
	})

	self.item_container = self.feature_panel:panel({
		w = self.feature_panel:w() - 10,
		h = self.feature_panel:h() - 10,
		x = 5,
		y = 5,
	})

	self:make_box(self.window)
	self:make_box(self.feature_panel)
end

function MaskSelectorGUIClass:setup_controller()
	if self._controller or not self._use_controller then
		return
	end

	managers.menu._input_enabled = false
	for _, menu in ipairs(managers.menu._open_menus) do
		menu.input._controller:disable()
	end

	self._ws:connect_keyboard(Input:keyboard())

	self._controller = managers.controller:create_controller(self._controller_id, nil, false)

	for _, callback_type in pairs({ "confirm", "cancel" }) do
		local callback_name = "keyboard_" .. callback_type
		if type(self[callback_name]) == "function" then
			self._controller:add_trigger(callback_type, callback(self, self, callback_name))
		end
	end

	self._controller:enable()

	local mouse_data = { id = self.menu_mouse_id }
	for _, callback_type in pairs({ "mouse_move", "mouse_press", "mouse_release" }) do
		if type(self[callback_type]) == "function" then
			mouse_data[callback_type] = callback(self, self, callback_type)
		end
	end

	managers.mouse_pointer:use_mouse(mouse_data)
end

--------------------
-- Menu Population
---
function MaskSelectorGUIClass:create_mask_selector(data)
	local item = data.item
	if not item.mask_set then
		return
	end

	local selected_character = data.selected_character or 1
	if self._active_items[data.index] then
		return
	end

	local item_panel = data.parent:panel({
		halign = "grow",
		h = data.height,
		layer = 1,
	})
	local icon_container = item_panel:panel()
	local panel_center = (item_panel:h() / 2)

	-- random mugshot icon
	local image, texture_rect = tweak_data.hud_icons:get_icon_data("mugshot_random")
	icon_container:bitmap({
		name = "random",
		texture = image,
		texture_rect = texture_rect,
		layer = 5,
		alpha = ((selected_character == 1) and 1) or 0.4,
		x = 4,
		y = 4,
		w = texture_rect[3],
		h = texture_rect[4],
	})

	local total_x = texture_rect[3] + 8
	local character_names = { "russian", "american", "german", "spanish" }
	for i, character in ipairs({ 3, 1, 2, 4 }) do
		local set_data = tweak_data.mask_sets[item.mask_set]
		local character_data = set_data and set_data[character]

		local icon = character_data and character_data.mask_icon or "mugshot_random"
		image, texture_rect = tweak_data.hud_icons:get_icon_data(icon)
		icon_container:bitmap({
			name = character_names[i],
			texture = image,
			texture_rect = texture_rect,
			layer = 1,
			alpha = (selected_character == (i + 1) and 1) or 0.4,
			x = total_x,
			y = 4,
			w = texture_rect[3],
			h = texture_rect[4],
		})

		total_x = total_x + texture_rect[3] + 4
	end

	-- resize and center the icon container
	icon_container:set_w(total_x)
	icon_container:set_center_x(item_panel:center_x())

	-- create mask set title
	local text = item_panel:text({
		text = managers.localization:text(item.text_id),
		font = "fonts/font_univers_latin_530_bold",
		font_size = 18,
		align = "left",
		halign = "grow",
		color = Color(0.7, 0.7, 0.7),
		layer = 2,
		x = 5,
	})
	self._toolbox:make_pretty_text(text)
	text:set_center_y(panel_center)

	if data.is_selected_mask then
		self.current_hover = { panel = item_panel, index = data.index, selected_character = data.selected_character }
		self:highlight_element(item_panel, { layer = -1 })
	end

	-- register item
	self._active_items[data.index] = {
		panel = item_panel:parent(),
		icon_container = icon_container,
		target_y = item_panel:parent():y(),
		table_ptr = item,
		index = data.index,
		selected_character = data.selected_character,
	}
end

function MaskSelectorGUIClass:build_feature_panel(data)
	self.item_container:clear()

	self._active_items = {}

	self.scroll_panel = self.item_container:panel({ halign = "grow", h = 2000 })

	local max_h = 0
	local column_panel = self.scroll_panel:panel({
		halign = "grow",
		y = 0,
		alpha = 1,
	})

	local total_h = 0
	for i, item in pairs(data.items or {}) do
		local add_amount = self.height_data.button
		local y_offset = i == 1 and 0 or 2

		item.callback = data.callback or function() end

		local button_panel = column_panel:panel({ halign = "grow" })
		button_panel:set_y(total_h + y_offset)
		button_panel:set_h(add_amount)
		self:make_box(button_panel)

		self:create_mask_selector({
			parent = button_panel,
			height = add_amount,
			item = item,
			index = i,
			is_selected_mask = data.selected_mask_index == i,
			selected_character = data.selected_character_index,
		})

		total_h = total_h + add_amount + y_offset
	end

	if total_h > max_h then
		max_h = total_h
	end

	column_panel:set_h(total_h)

	self.feature_panel:key_press(callback(self, self, "key_press"))

	self.scroll_panel:set_h(max_h)
	self.scroll_target_y = 0

	local selected_index = data.selected_mask_index
	self.scroll_target_y = self:do_scroll(
		self.scroll_panel,
		self.scroll_target_y,
		(-self.height_data.button * (selected_index - 1)) + (-2 * (selected_index - 1))
	)
end

--------------
-- Behaviour
---
function MaskSelectorGUIClass:is_active()
	return self._active
end

function MaskSelectorGUIClass:show()
	if self:is_active() then
		return
	end

	self._panel:stop()
	self._panel:animate(function(o)
		o:set_alpha(0)
		o:show()

		self:animate_ui(1, function(p)
			o:set_alpha(math.lerp(o:alpha(), 1, p))
		end)

		o:set_alpha(1)
	end)

	self:setup_controller()
	self._active = true
end

function MaskSelectorGUIClass:hide()
	if not self:is_active() then
		return
	end

	self._panel:stop()
	self._panel:animate(function(o)
		self:animate_ui(1, function(p)
			o:set_alpha(math.lerp(o:alpha(), 0, p))
		end)

		o:set_alpha(0)
		o:hide()
	end)

	self:destroy_controller()
	self._active = false
end

-----------------
-- Keyboard Input
---
function MaskSelectorGUIClass:keyboard_cancel()
	if not self:is_active() then
		return
	end

	self:hide()
end

function MaskSelectorGUIClass:set_mask_selection_index(amount)
	if not self.current_hover then
		return
	end

	local new_selection = self._active_items[self.current_hover.index + amount]
	if not new_selection then
		return
	end

	local current_selection = self._active_items[self.current_hover.index]
	if current_selection then
		local icon_container = current_selection.icon_container
		for index, child in pairs(icon_container:children()) do
			local selected = index == current_selection.selected_character
			child:set_alpha(selected and 1 or 0.2)
		end
	end

	local icon_container = new_selection.icon_container
	for index, child in pairs(icon_container:children()) do
		local selected = index == self.current_hover.selected_character
		child:set_alpha(selected and 1 or 0.2)
	end

	self.current_hover = {
		panel = new_selection.panel,
		index = new_selection.index,
		selected_character = self.current_hover.selected_character,
	}
	self:highlight_element(new_selection.panel, { layer = 1 })

	if new_selection.panel:world_y() < self.item_container:world_y() then
		self.scroll_target_y =
			self:do_scroll(self.scroll_panel, self.scroll_target_y, self.height_data.button + 4, true)
	elseif new_selection.panel:world_bottom() > self.item_container:world_bottom() then
		self.scroll_target_y =
			self:do_scroll(self.scroll_panel, self.scroll_target_y, -self.height_data.button - 4, true)
	end
end

function MaskSelectorGUIClass:set_character_selection_index(index)
	if not self.current_hover then
		return
	end

	local item = self._active_items[self.current_hover.index]
	if not item then
		return
	end

	local selected_index = self.current_hover.selected_character + index
	if selected_index <= 0 or selected_index >= 6 then
		return
	end

	local icon_container = item.icon_container
	for index, child in pairs(icon_container:children()) do
		local selected = index == selected_index
		child:set_alpha(selected and 1 or 0.2)
	end

	self.current_hover.selected_character = selected_index
end

local IDS_UP = Idstring("up")
local IDS_LEFT = Idstring("left")
local IDS_DOWN = Idstring("down")
local IDS_RIGHT = Idstring("right")
local IDS_ENTER = Idstring("enter")
local IDS_NUM_ENTER = Idstring("num enter")
function MaskSelectorGUIClass:key_press(_, key)
	if managers.hud and managers.hud:showing_stats_screen() then
		return
	end

	local selected = self.current_hover
	if not selected then
		return
	end

	if key == IDS_UP then
		self:set_mask_selection_index(-1)
		return
	end

	if key == IDS_DOWN then
		self:set_mask_selection_index(1)
		return
	end

	if key == IDS_LEFT then
		self:set_character_selection_index(-1)
		return
	end

	if key == IDS_RIGHT then
		self:set_character_selection_index(1)
		return
	end

	if key == IDS_ENTER or key == IDS_NUM_ENTER then
		self:activate_item(self._active_items[selected.index])
	end
end

----------------
-- Mouse Input
---
function MaskSelectorGUIClass:is_mouse_in_panel(panel)
	if not alive(panel) then
		return false
	end

	return panel:inside(self.menu_mouse_x, self.menu_mouse_y)
end

function MaskSelectorGUIClass:check_item_hover()
	if not self:is_mouse_in_panel(self.feature_panel) then
		return
	end

	if self.current_hover and self:is_mouse_in_panel(self.current_hover.panel) then
		return
	end

	if not self._active_items or self._active_items and not next(self._active_items) then
		return
	end

	for _, item in pairs(self._active_items) do
		if self:is_mouse_in_panel(item.panel) then
			self.current_hover =
				{ panel = item.panel, index = item.index, selected_character = item.selected_character }
			self:highlight_element(item.panel, { layer = 1, x = 4, y = 4, w = 8, h = 8 })
			return
		end
	end
end

function MaskSelectorGUIClass:check_character_hover()
	local bitmaps = { "random", "russian", "american", "german", "spanish" }

	local current_hover = self.current_hover
	local item = self._active_items[current_hover.index]
	if self:is_mouse_in_panel(item.panel) then
		local icon_container = item.icon_container
		if self:is_mouse_in_panel(icon_container) then
			for index, child in pairs(icon_container:children()) do
				local inside = self:is_mouse_in_panel(child)
				if inside then
					current_hover.selected_character = index
				end

				child:set_alpha(inside and 1 or 0.2)
			end
		end
	end

	for _, item in pairs(self._active_items) do
		if not self:is_mouse_in_panel(item.panel) then
			for _, child in pairs(item.icon_container:children()) do
				local selected = child:name() == bitmaps[item.selected_character]
				child:set_alpha(selected and 1 or 0.2)
			end
		end
	end
end

function MaskSelectorGUIClass:mouse_move(o, x, y)
	self.menu_mouse_x, self.menu_mouse_y = x, y

	self:check_item_hover()
	self:check_character_hover()
end

function MaskSelectorGUIClass:do_over_scroll(panel, amount, target, skip_check)
	panel:stop()
	panel:animate(function(o)
		self:animate_ui(0.1, function(p)
			o:set_y(math.lerp(o:y(), target + amount, p))
			if not skip_check then
				self:check_item_hover()
				self:check_character_hover()
			end
		end)

		panel:animate(function(o)
			self:animate_ui(0.1, function(p)
				o:set_y(math.lerp(o:y(), target, p))
				if not skip_check then
					self:check_item_hover()
					self:check_character_hover()
				end
			end)
		end)
	end)
end

function MaskSelectorGUIClass:do_scroll(panel, target, amount, skip_check)
	if panel:parent():h() >= panel:h() then
		return target
	end

	if (target + amount) > 0 then
		if target == 0 then
			self:do_over_scroll(panel, amount, target, skip_check)
			return target
		end

		target = 0
		amount = 0
	end

	if ((target + panel:h()) + amount) < panel:parent():h() then
		if target + panel:h() == panel:parent():h() then
			self:do_over_scroll(panel, amount, target, skip_check)
			return target
		end

		amount = panel:parent():h() - (target + panel:h())
	end

	target = target + amount
	panel:stop()
	panel:animate(function(o)
		self:animate_ui(0.1, function(p)
			o:set_y(math.lerp(o:y(), target, p))
			if not skip_check then
				self:check_item_hover()
				self:check_character_hover()
			end
		end)
	end)

	return target
end

function MaskSelectorGUIClass:activate_item(item)
	local clbk = tablex.get(item, "table_ptr", "callback")
	if type(clbk) == "function" then
		clbk(self)
	end

	self:hide()
end

local ids_left_click = Idstring("0")
local ids_right_click = Idstring("0")
local ids_wheel_up = Idstring("mouse wheel up")
local ids_wheel_down = Idstring("mouse wheel down")
function MaskSelectorGUIClass:mouse_press(_, button, x, y)
	self.menu_mouse_x, self.menu_mouse_y = x, y

	if button == ids_left_click then
		if not self:is_mouse_in_panel(self.feature_panel) then
			self:hide()
			return
		end

		for _, item in pairs(self._active_items) do
			if self:is_mouse_in_panel(item.panel) then
				self:activate_item(item)
				return
			end
		end

		return
	end

	if button == ids_right_click then
		return
	end

	if button == ids_wheel_up then
		self.scroll_target_y = self:do_scroll(self.scroll_panel, self.scroll_target_y, self.height_data.button)
		return
	end

	if button == ids_wheel_down then
		self.scroll_target_y = self:do_scroll(self.scroll_panel, self.scroll_target_y, -self.height_data.button)

		return
	end
end

---------------------
-- Deinitialization
---
function MaskSelectorGUIClass:destroy()
	if not alive(self._panel) then
		return
	end

	self:destroy_controller()

	self._panel:parent():remove(self._panel)
	Overlay:gui():destroy_workspace(self._ws)
end

function MaskSelectorGUIClass:destroy_controller()
	if not self._controller then
		return
	end

	self._ws:disconnect_keyboard()
	managers.mouse_pointer:remove_mouse(self.menu_mouse_id)

	self._controller:destroy()
	self._controller = nil

	setup:add_end_frame_clbk(function()
		managers.menu._input_enabled = true

		for _, menu in ipairs(managers.menu._open_menus) do
			menu.input._controller:enable()
		end
	end)
end

if RequiredScript == "lib/setups/setup" then
	local Setup = module:hook_class("Setup")
	module:post_hook(50, Setup, "init_managers", function()
		rawset(_M, "QuickMaskMenu", MaskSelectorGUIClass:new())
	end)
end

if RequiredScript == "lib/states/ingamewaitingforplayers" then
	local IngameWaitingForPlayersState = module:hook_class("IngameWaitingForPlayersState")

	module:post_hook(IngameWaitingForPlayersState, "at_exit", function()
		local QuickMaskMenu = rawget(_M, "QuickMaskMenu")
		if not QuickMaskMenu then
			return
		end

		QuickMaskMenu:hide()
		-- QuickMaskMenu:destroy()
		-- _M.QuickMaskMenu = nil
	end)
end

if RequiredScript == "lib/managers/menumanager" then
	local QuickMaskMenu

	local MenuManager = module:hook_class("MenuManager")
	module:hook(MenuManager, "toggle_menu_state", function(self)
		QuickMaskMenu = QuickMaskMenu or rawget(_M, "QuickMaskMenu")
		if QuickMaskMenu and QuickMaskMenu:is_active() then
			return
		end

		module:call_orig(MenuManager, "toggle_menu_state", self)
	end, false)

	local MaskOptionInitiator = module:hook_class("MaskOptionInitiator")
	module:post_hook(MaskOptionInitiator, "modify_node", function(_, node)
		local character_select_item = node:item("choose_character")
		local mask_select_item = node:item("choose_mask")
		if not character_select_item or not mask_select_item then
			return
		end

		mask_select_item:set_parameter("item_confirm_callback", function(item)
			QuickMaskMenu = QuickMaskMenu or rawget(_M, "QuickMaskMenu")
			if not QuickMaskMenu then
				return
			end

			local items = {}
			-- add item for every mask available
			for _, mask_item in ipairs(item._all_options) do
				local params = mask_item:parameters()
				table.insert(items, { text_id = params.text_id, mask_set = params.value })
			end

			QuickMaskMenu:show()
			QuickMaskMenu:build_feature_panel({
				items = items,
				selected_mask_index = mask_select_item._current_index or 1,
				selected_character_index = character_select_item._current_index or 1,
				callback = function(self)
					local selected_item = self.current_hover
					local item = self._active_items[selected_item.index]
					mask_select_item:set_value(item.table_ptr.mask_set)
					mask_select_item:trigger()

					local character_names = { "random", "russian", "american", "german", "spanish" }
					character_select_item:set_value(character_names[selected_item.selected_character])
					character_select_item:trigger()
				end,
			})
		end)
	end, false)
end
