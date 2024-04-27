local CustomControlPanel = class()
function CustomControlPanel:create_box(panel, params, config)
	local box_panel = panel:panel(params)
	local color = config and config.color or Color(1, 0, 0, 0)
	local bg_color = config and config.bg_color or Color(1, 0, 0, 0)
	local blend_mode = config and config.blend_mode

	box_panel:rect({
		blend_mode = "normal",
		name = "bg",
		halign = "grow",
		alpha = 0.25,
		layer = -1,
		valign = "grow",
		color = bg_color,
	})

	local left_top = box_panel:panel({ h = box_panel:h() / 3, w = box_panel:h() / 3 })
	left_top:gradient({
		blend_mode = blend_mode,
		orientation = "vertical",
		gradient_points = { 0, color, 0.65, color, 1, Color(0, 0, 0, 0) },
		w = 2,
	})
	left_top:gradient({
		blend_mode = blend_mode,
		orientation = "horizontal",
		gradient_points = { 0, color, 0.65, color, 1, Color(0, 0, 0, 0) },
		h = 2,
	})

	local left_bottom = box_panel:panel({ h = box_panel:h() / 3, w = box_panel:h() / 3 })
	left_bottom:gradient({
		blend_mode = blend_mode,
		orientation = "vertical",
		gradient_points = { 1, color, 0.65, color, 0, Color(0, 0, 0, 0) },
		w = 2,
	})
	left_bottom:gradient({
		blend_mode = blend_mode,
		orientation = "horizontal",
		gradient_points = { 0, color, 0.65, color, 1, Color(0, 0, 0, 0) },
		h = 2,
		y = left_bottom:h() - 2,
	})
	left_bottom:set_bottom(box_panel:h())

	local right_top = box_panel:panel({ h = box_panel:h() / 3, w = box_panel:h() / 3 })
	right_top:gradient({
		blend_mode = blend_mode,
		orientation = "vertical",
		gradient_points = { 0, color, 0.65, color, 1, Color(0, 0, 0, 0) },
		x = right_top:w() - 2,
		w = 2,
	})
	right_top:gradient({
		blend_mode = blend_mode,
		orientation = "horizontal",
		gradient_points = { 1, color, 0.65, color, 0, Color(0, 0, 0, 0) },
		h = 2,
	})

	right_top:set_right(box_panel:w())

	local right_bottom = box_panel:panel({ h = box_panel:h() / 3, w = box_panel:h() / 3 })
	right_bottom:gradient({
		blend_mode = blend_mode,
		orientation = "vertical",
		gradient_points = { 1, color, 0.65, color, 0, Color(0, 0, 0, 0) },
		x = right_bottom:w() - 2,
		w = 2,
	})
	right_bottom:gradient({
		blend_mode = blend_mode,
		orientation = "horizontal",
		gradient_points = { 1, color, 0.65, color, 0, Color(0, 0, 0, 0) },
		y = right_bottom:h() - 2,
		h = 2,
	})

	right_bottom:set_right(box_panel:w())
	right_bottom:set_bottom(box_panel:h())

	return box_panel
end

function CustomControlPanel:_animate_flash_in_out(o) -- pasted from gui files
	while true do
		local n = (math.sin(Application:time() * 750) + 1) / 4
		local grow_value = math.lerp(30, 30 * 1.25, n)

		-- flash effect
		o:set_color(o:color():with_alpha(0.5 + n))

		-- heartbeat effect
		o:set_size(grow_value, grow_value)
		o:set_world_center(o:parent():world_center())

		coroutine.yield()
	end
end

function CustomControlPanel:_animate_ponr_timer(o)
	local t = 0
	while t < 0.5 do
		t = t + coroutine.yield()
		local n = 1 - math.sin(t * 180)
		local r = math.lerp(self._point_of_no_return_color.r, 1, n)
		local g = math.lerp(self._point_of_no_return_color.g, 0.8, n)
		local b = math.lerp(self._point_of_no_return_color.b, 0.2, n)
		o:set_color(Color(r, g, b))
		o:set_font_size(math.lerp(24, 24 * 0.75, n))
	end
end

function CustomControlPanel:_animate_text(text_panel) -- pasted from payday 2
	local text_index = 0
	local texts = {}
	local padding = 10

	local function create_new_text(text_panel, text_list, text_index, texts)
		if texts[text_index] and texts[text_index].text then
			text_panel:remove(texts[text_index].text)

			texts[text_index] = nil
		end

		local text_id = text_list[text_index]
		local text_string = ""

		if type(text_id) == "string" then
			text_string = managers.localization:exists(text_id) and managers.localization:to_upper_text(text_id)
				or text_id
		end

		local text = text_panel:text({
			text = text_string,
			font = "fonts/font_univers_530_bold",
			font_size = 24,
			color = self:get_assault_color(),
			layer = 1,
			blend_mode = "add",
			align = "center",
			vertical = "center",
		})
		self._toolbox:parse_color_tags(text)

		texts[text_index] = {
			x = text_panel:w() + text:w() * 0.5 + padding * 2,
			text = text,
		}
	end

	local text_list = self:get_assault_text()
	while true do
		local dt = coroutine.yield()
		local last_text = texts[text_index]

		if last_text and last_text.text then
			if last_text.x + last_text.text:w() * 0.5 + padding < text_panel:w() then
				text_index = text_index % #text_list + 1

				create_new_text(text_panel, text_list, text_index, texts)
			end
		else
			text_index = text_index % #text_list + 1

			create_new_text(text_panel, text_list, text_index, texts)
		end

		if text_index == 1 then
			text_list = self:get_assault_text()
		end

		local speed = 90
		for _, data in pairs(texts) do
			if data.text then
				data.x = data.x - dt * speed

				data.text:set_center_x(data.x)
				data.text:set_center_y(text_panel:h() * 0.5)

				if data.x + data.text:w() * 0.5 < 0 then
					text_panel:remove(data.text)

					data.text = nil
				end
			end
		end
	end
end

function CustomControlPanel:init(super)
	self.super = super

	self._hud = self.super:script(PlayerBase.PLAYER_INFO_HUD)
	self._panel = self._hud.panel:panel({ layer = -100 })

	self._toolbox = _M._hudToolBox
	self._updator = _M._hudUpdator

	self:setup_vars()
	self:setup_panels()
	self:update_settings()

	self._updator:remove("control_panel_update")
	self._updator:add(callback(self, self, "update"), "control_panel_update")
end

function CustomControlPanel:setup_vars()
	self._cached_conf_vars = {}

	self.in_assault = false
	self._double_assault = false
	self.in_ponr = false
	self._mutated = false

	if Global.level_data.mutators and tweak_data.mutators and tweak_data.hud.mutators_text_color then
		local has_active_mutators = false
		for _, state in pairs(Global.level_data.mutators) do
			if state > 0 then
				has_active_mutators = true
				break
			end
		end

		self._mutated = has_active_mutators
	end

	self._assault_color = Color.red
	self._mutated_color = tweak_data.hud.mutators_text_color
	self._point_of_no_return_color = Color.red
end

function CustomControlPanel:setup_panels()
	self.main_panel = self._panel:panel({ visible = true })

	self:create_assault_panel()
	self:create_point_of_no_return_panel()
	self:create_hostages_panel()
end

function CustomControlPanel:update_settings()
	local D = D
	local var_cache = self._cached_conf_vars

	var_cache.use_control_panel = D:conf("_hud_use_custom_control_panel")
	var_cache.use_ponr_panel = D:conf("_hud_use_custom_ponr_panel")

	self:update_panel_visibility()
end

function CustomControlPanel:is_in_assault()
	return self.super._hud.in_assault or self._hud.assault_image:visible()
end

function CustomControlPanel:update_panel_visibility()
	local var_cache = self._cached_conf_vars

	-- * Control panel
	self.super._cached_conf_vars.hud_vis_control = not var_cache.use_control_panel
	self._hud.control_panel:set_visible(self.super._cached_conf_vars.hud_vis_control)
	self.main_panel:child("hostages_panel"):set_visible(var_cache.use_control_panel)

	local visible = self.main_panel:child("assault_panel"):visible()
	if var_cache.use_control_panel and self:is_in_assault() and not visible then
		self:start_assault()
	elseif not var_cache.use_control_panel and visible then
		self:end_assault()
	end

	-- * Point of no return panel
	self.super._cached_conf_vars.hud_vis_ponr = not var_cache.use_ponr_panel
	self._hud.point_of_no_return_panel:set_visible(not var_cache.use_ponr_panel and self.super._hud.in_ponr)
	self.main_panel:child("point_of_no_return_panel"):set_visible(self.in_ponr and var_cache.use_ponr_panel)
end

function CustomControlPanel:get_assault_color()
	return self._mutated and self._mutated_color or self._assault_color
end

function CustomControlPanel:create_assault_panel() -- pasted from payday 2
	local size = 200
	local assault_panel = self.main_panel:panel({ name = "assault_panel", visible = false, h = 80, w = size * 2 })
	assault_panel:set_right(self.main_panel:right())

	local image, rect = tweak_data.hud_icons:get_icon_data("assault")
	local icon_container = self:create_box(
		assault_panel,
		{ w = 38, h = 38 },
		{ blend_mode = "add", color = self:get_assault_color() }
	)

	local icon_assaultbox = icon_container:bitmap({
		name = "icon_assaultbox",
		texture = image,
		texture_rect = rect,
		layer = 0,
		blend_mode = "add",
		halign = "right",
		valign = "top",
		w = 30,
		h = 30,
	})
	icon_assaultbox:set_center(icon_container:center())
	icon_container:set_right(icon_container:parent():w())
	icon_assaultbox:animate(callback(self, self, "_animate_flash_in_out"))

	local info_box_container = assault_panel:panel({ name = "info_box_container", w = 50, h = 38 })
	self:create_box(info_box_container, nil, { blend_mode = "add", color = self:get_assault_color() })

	local assault_timer = info_box_container:text({
		name = "assault_timer",
		text = "00:00",
		font = "fonts/font_univers_530_bold",
		font_size = 24,
		layer = 1,
		vertical = "center",
		color = self:get_assault_color(),
		blend_mode = "normal",
		align = "center",
	})
	self._toolbox:make_pretty_text(assault_timer)
	assault_timer:set_center(info_box_container:center())

	info_box_container:set_right(icon_container:left() - 3)

	self.assault_timer = assault_timer

	self._bg_box = self:create_box(
		assault_panel,
		{ x = 0, h = 38, y = 0, w = size * 1.5 - 58 },
		{ blend_mode = "add", color = self:get_assault_color() }
	)
	self._bg_box:set_right(info_box_container:left() - 3)

	self._bg_box:panel({ name = "text_panel", layer = 1 })
end

function CustomControlPanel:create_point_of_no_return_panel()
	local ponr_panel = self.main_panel:panel({ name = "point_of_no_return_panel", visible = false, h = 38 })

	local icon_container = ponr_panel:panel({ w = 38, h = 38 })
	self:create_box(icon_container, nil, { blend_mode = "add", color = self:get_assault_color() })

	local image, rect = tweak_data.hud_icons:get_icon_data("assault")
	local assault_icon = icon_container:bitmap({
		name = "icon_assaultbox",
		texture = image,
		texture_rect = rect,
		color = self:get_assault_color(),
		layer = 0,
		blend_mode = "add",
		halign = "right",
		valign = "top",
		w = 30,
		h = 30,
	})
	assault_icon:set_center(icon_container:center())
	assault_icon:animate(callback(self, self, "_animate_flash_in_out"))

	local info_box_container = ponr_panel:panel({ name = "info_box_container", h = 38 })

	local ponr_title = info_box_container:text({
		name = "ponr_title",
		text = managers.localization:to_upper_text("_hud_ponr_title", { TIME = "" }),
		font = "fonts/font_univers_530_bold",
		font_size = 24,
		color = self._assault_color,
		layer = 1,
		blend_mode = "add",
		valign = "center",
		align = "center",
		vertical = "center",
	})
	self._toolbox:parse_color_tags(ponr_title)

	local ponr_timer = info_box_container:text({
		name = "ponr_timer",
		text = "00:00 ",
		font = "fonts/font_univers_530_bold",
		font_size = 24,
		layer = 1,
		vertical = "center",
		color = self._assault_color,
		blend_mode = "add",
		align = "center",
	})
	self._toolbox:make_pretty_text(ponr_timer)

	self._bg_ponr_box_size = 8 + ponr_title:w() + ponr_timer:w()
	info_box_container:set_w(self._bg_ponr_box_size)
	self:create_box(info_box_container, nil, { blend_mode = "add", color = self._assault_color })

	ponr_timer:set_center_y(info_box_container:center_y())
	ponr_timer:set_right(info_box_container:right() - 4)
	ponr_title:set_center_y(info_box_container:center_y())
	ponr_title:set_right(ponr_timer:left())

	icon_container:set_right(icon_container:parent():w())
	info_box_container:set_right(icon_container:left() - 4)
end

function CustomControlPanel:get_hostage_count()
	local groupaistate = managers.groupai and managers.groupai:state()
	if not groupaistate then
		return 0
	end

	return groupaistate:hostage_count() or 0
end

function CustomControlPanel:create_hostages_panel()
	local hostages_panel = self.main_panel:panel({ name = "hostages_panel", visible = false, h = 38 })
	hostages_panel:set_top(self.main_panel:child("assault_panel"):bottom() + 4)

	local info_box_container = hostages_panel:panel({ name = "info_box_container", w = 38, h = 38 })
	self:create_box(info_box_container, nil, { blend_mode = "add", color = Color.white })

	local hostage_count = info_box_container:text({
		name = "hostage_count",
		text = tostring(self:get_hostage_count()),
		font = "fonts/font_univers_530_bold",
		font_size = 24,
		layer = 1,
		color = Color("FFA800"),
		blend_mode = "normal",
		align = "center",
		vertical = "center",
	})
	self._toolbox:make_pretty_text(hostage_count)

	hostage_count:set_center(info_box_container:center())

	local image, rect = tweak_data.hud_icons:get_icon_data("wp_trade")
	local hostage_icon = hostages_panel:bitmap({
		name = "hostage_icon",
		texture = image,
		texture_rect = rect,
		layer = 0,
		halign = "right",
		valign = "top",
		w = 30,
		h = 30,
	})

	hostage_icon:set_right(hostage_icon:parent():w())
	info_box_container:set_right(hostage_icon:left() - 4)

	hostage_icon:set_center_y(info_box_container:center_y())
end

function CustomControlPanel:get_assault_string()
	if self._double_assault then
		return "_hud_reinforced_assault_title"
	end

	return "_hud_assault_title"
end

function CustomControlPanel:get_assault_text()
	local assault_title = managers.localization:to_upper_text(self:get_assault_string())
	local difficulty_name = self.super._cached_conf_vars.difficulty_name:upper()

	local streams = D:conf("_hud_assault_text") or { { "///", "$ASSAULT_TITLE;", "///", "$DIFFICULTY_NAME;" } }
	local items = streams[math.random(table.size(streams))]
	local n_items = table.size(items)

	local assault_text = {}
	for i, item in pairs(items) do
		local text = self._toolbox:string_format(item, { ASSAULT_TITLE = assault_title, DIFFICULTY_NAME = difficulty_name })

		assault_text[i] = text
		-- ghetto retarded fix
		-- if the scroll list is too short, assault title gets removed while in bounds
		-- duplicating the contents solves this problem ¯\_(ツ)_/¯
		assault_text[i + n_items] = text -- doing this though a loop freezes the game, yay!
	end

	return assault_text
end

function CustomControlPanel:start_assault()
	if not self._cached_conf_vars.use_control_panel or self.in_ponr then
		return
	end

	if self.in_assault then
		self._double_assault = true
		return
	end

	self.in_assault = true

	self._hud.control_panel:hide()
	self.main_panel:child("assault_panel"):show()

	local box_text_panel = self._bg_box:child("text_panel")
	box_text_panel:stop()
	box_text_panel:clear()
	box_text_panel:animate(callback(self, self, "_animate_text"))
end

function CustomControlPanel:end_assault()
	self.in_assault = false
	self._double_assault = false
	self.main_panel:child("assault_panel"):hide()

	local box_text_panel = self._bg_box:child("text_panel")
	box_text_panel:stop()
	box_text_panel:clear()
end

local Util = _G["Util"]
function CustomControlPanel:update_assault_timer()
	-- author: DorentuZ`, pasted from mods/hud/hudmanager.lua
	local assault_t = managers.groupai:state() and managers.groupai:state()._assault_start_t
	if not assault_t then
		return
	end

	local text = Util:seconds_to_hms_text(Application:time() - assault_t, { no_days = true, no_hours = true })

	local assault_timer = self.assault_timer
	if assault_timer:text() == text then
		return
	end

	assault_timer:set_text(text)
	self._toolbox:make_pretty_text(assault_timer)
	assault_timer:animate(callback(self, self, "_animate_ponr_timer"))

	assault_timer:set_world_center(assault_timer:parent():world_center()) -- fucking diesel retarded shit
end

function CustomControlPanel:show_point_of_no_return_timer()
	self.in_ponr = true
	self:end_assault()

	if not self._cached_conf_vars.use_ponr_panel then
		return
	end

	self._hud.point_of_no_return_panel:hide()
	self.main_panel:child("point_of_no_return_panel"):show()
end

function CustomControlPanel:feed_point_of_no_return_timer(is_inside)
	local ponr_panel = self.main_panel:child("point_of_no_return_panel")
	local info_box_container = ponr_panel:child("info_box_container")
	local ponr_timer = info_box_container:child("ponr_timer")

	ponr_timer:set_text(self._hud.point_of_no_return_timer:text())

	local color = is_inside and Color.green or Color.red
	if self._point_of_no_return_color ~= color then
		self._point_of_no_return_color = color
		ponr_timer:set_color(self._point_of_no_return_color)
	end
end

function CustomControlPanel:flash_point_of_no_return_timer()
	local ponr_panel = self.main_panel:child("point_of_no_return_panel")
	local info_box_container = ponr_panel:child("info_box_container")
	local ponr_timer = info_box_container:child("ponr_timer")

	ponr_timer:animate(callback(self, self, "_animate_ponr_timer"))
end

function CustomControlPanel:set_control_info(data)
	local hostages_panel = self.main_panel:child("hostages_panel")
	local hostage_count = hostages_panel:child("info_box_container"):child("hostage_count")

	hostage_count:set_text(data.nr_hostages)
	self._toolbox:make_pretty_text(hostage_count)

	hostage_count:set_world_center(hostage_count:parent():world_center()) -- fucking diesel retarded shit
end

function CustomControlPanel:update()
	local hud = self.super._hud
	if hud.in_assault and not hud.in_ponr and not self.in_assault then
		self:start_assault()
	end

	if hud.in_ponr and not self.in_ponr then
		self:show_point_of_no_return_timer()
	end

	self:update_panel_visibility()
end

function CustomControlPanel:destroy()
	self._panel:clear()
	self._panel:parent():remove(self._panel)
end

local module = ... or D:module("_hud")

if RequiredScript == "lib/units/beings/player/playerbase" then
	local PlayerBase = module:hook_class("PlayerBase")
	module:post_hook(50, PlayerBase, "_setup_hud", function(...)
		if not managers.hud._hud.custom_control_panel then
			managers.hud._hud.custom_control_panel = CustomControlPanel:new(managers.hud)
		end
	end, false)
end

if RequiredScript == "lib/managers/hudmanager" then
	local HUDManager = module:hook_class("HUDManager")
	module:post_hook(HUDManager, "sync_start_assault", function(self)
		self._hud.in_assault = true
		if not self._hud.custom_control_panel then
			return
		end

		self._hud.custom_control_panel:start_assault()
	end, false)

	module:post_hook(HUDManager, "sync_end_assault", function(self)
		self._hud.in_assault = false
		if not self._hud.custom_control_panel then
			return
		end

		self._hud.custom_control_panel:end_assault()
	end, false)

	module:post_hook(50, HUDManager, "update_timers", function(self, t, dt)
		if not self._hud.custom_control_panel then
			return
		end

		self._hud.custom_control_panel:update_assault_timer()
	end)

	module:post_hook(HUDManager, "show_point_of_no_return_timer", function(self)
		self._hud.in_ponr = true

		if not self._hud.custom_control_panel then
			return
		end

		self._hud.custom_control_panel:show_point_of_no_return_timer()
	end)

	module:post_hook(HUDManager, "feed_point_of_no_return_timer", function(self, _, is_inside)
		if not self._hud.custom_control_panel then
			return
		end

		self._hud.custom_control_panel:feed_point_of_no_return_timer(is_inside)
	end)

	module:post_hook(HUDManager, "flash_point_of_no_return_timer", function(self)
		if not self._hud.custom_control_panel then
			return
		end

		self._hud.custom_control_panel:flash_point_of_no_return_timer()
	end)

	module:post_hook(HUDManager, "set_control_info", function(self, data)
		if not self._hud.custom_control_panel then
			return
		end

		self._hud.custom_control_panel:set_control_info(data)
	end)
end
