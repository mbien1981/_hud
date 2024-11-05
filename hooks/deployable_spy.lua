_M.DeployableSpy = rawget(_M, "DeployableSpy") or {}

local DeployableSpy = _M.DeployableSpy
function DeployableSpy:setup()
	if self._ws then
		return
	end

	self._ws = Overlay:newgui():create_screen_workspace()
	self._panel = self._ws:panel():panel({
		name = "deployable_spy_panel",
		layer = -100,
		visible = true,
	})

	self.items = {}
	self.font = {
		path = "fonts/font_univers_530_bold",
		size = 12,
	}

	self._toolbox = _M._hudToolBox
	self._updater = _M._hudUpdater

	self._updater:remove("_hud_deployable_spy_update")
	self._updater:add(callback(self, self, "update"), "_hud_deployable_spy_update")
end

function DeployableSpy:exists(unit)
	if not next(self.items) then
		return false
	end

	for _, item in pairs(self.items) do
		if item.unit == unit then
			return true
		end
	end

	return false
end

function DeployableSpy:add(unit, type)
	self:setup()

	if self:exists(unit) then
		return
	end

	table.insert(self.items, {
		unit = unit,
		type = type,
		text = self._panel:text({
			text = "",
			font = self.font.path,
			font_size = self.font.size,
			visible = false,
			align = "center",
			layer = 5,
		}),
	})
end

function DeployableSpy:remove(index)
	local item = self.items[index]
	self._panel:remove(item.text)

	table.remove(self.items, index)
end

function DeployableSpy:get_vector_angle(vector)
	local player = Vector3()
	local target = Vector3()
	local dir = Vector3()

	mvector3.set(player, managers.viewport:get_current_camera_position())
	mvector3.set(target, vector)
	mvector3.set(dir, player)
	mvector3.subtract(dir, target)
	mvector3.normalize(dir)

	local newx, newy, newz = dir.x, dir.y, dir.z
	if player.x > target.x or (player.x < target.x and newx < 0) then
		newx = newx * -1
	end

	if player.y > target.y or (player.y < target.y and newy < 0) then
		newy = newy * -1
	end

	if player.z > target.z or (player.z < target.z and newz < 0) then
		newz = newz * -1
	end

	mvector3.set(dir, Vector3(newx, newy, newz))

	return dir
end

function DeployableSpy:make_pretty_text(text_obj)
	local _, _, w, h = text_obj:text_rect()
	w, h = w + 2, h + 2

	text_obj:set_w(w)
	text_obj:set_h(h)

	return w, h
end

local vars = { medic_bag = "_amount", ammo_bag = "_ammo_amount" }
function DeployableSpy:get_item_text(unit, unit_type)
	local text = D:conf(string.format("_hud_%s_spy", unit_type))

	if unit_type == "sentry_gun" then
		local ammo = unit:weapon()._ammo_total
		local health = tonumber(unit:character_damage()._health or 0) * 10
		if health <= 0 or (ammo * 10) <= 0 then
			return nil
		end

		return self._toolbox:string_format(text, { AMMO = ammo, AMMO_MAX = unit:weapon()._ammo_max, HEALTH = health })
	end

	local value = unit:base()[vars[unit_type]]
	local charge_str = unit_type == "ammo_bag" and "%.2f" or "%d"

	return self._toolbox:string_format(text, {
		CHARGES = string.format(charge_str, value),
		PERCENT = string.format("%d", value * 100),
	})
end

local world_to_screen = Vector3()
function DeployableSpy:update_item(index, camera)
	local item = self.items[index]
	if not alive(item.unit) or alive(item.unit) and item.unit:base()._empty then
		self:remove(index)
		return
	end

	local position = item.unit:position()
	local camera_position = managers.viewport:get_current_camera_position()
	local camera_rotation = managers.viewport:get_current_camera_rotation()

	local angle = self:get_vector_angle(position)
	if (mvector3.distance(camera_rotation:y(), angle) / 2 * 360) > 180 then
		if item.text:visible() then
			item.text:hide()
		end
		return
	end

	local text = self:get_item_text(item.unit, item.type)

	if not text then
		self:remove(index)
		return
	end

	item.text:set_text(text)

	local owner_id = tablex.get(item.unit:base(), "_server_information", "owner_peer_id")
	self._toolbox:parse_color_tags(item.text, {
		peer_color = owner_id and tweak_data.chat_colors[owner_id] or D:conf("_hud_ai_contour_color"),
	})

	local distance = math.max(math.min(mvector3.distance(camera_position, position), 8000), 20)
	item.text:set_font_size(36 / (distance / 200))

	mvector3.set(world_to_screen, self._ws:world_to_screen(camera, position))
	item.text:set_center(mvector3.x(world_to_screen), mvector3.y(world_to_screen))

	if not item.text:visible() then
		item.text:show()
	end
end

function DeployableSpy:update_items(camera)
	if not next(self.items) then
		return
	end

	for index, _ in pairs(self.items) do
		self:update_item(index, camera)
	end
end

function DeployableSpy:update()
	if not Util:is_in_state("any_ingame_playing") then
		return
	end

	local camera = managers.viewport:get_current_camera()
	if not alive(camera) or not D:conf("_hud_enable_deployable_spy") then
		self._panel:hide()
		return
	end

	self._panel:show()

	self:update_items(camera)
end

local module = ... or D:module("_hud")

if RequiredScript == "lib/units/equipment/ammo_bag/ammobagbase" then
	local AmmoBagBase = module:hook_class("AmmoBagBase")

	for _, func in pairs({ "set_server_information", "_take_ammo", "sync_ammo_taken" }) do
		module:post_hook(50, AmmoBagBase, func, function(self, ...)
			DeployableSpy:add(self._unit, "ammo_bag")
		end)
	end
end

if RequiredScript == "lib/units/equipment/doctor_bag/doctorbagbase" then
	local DoctorBagBase = module:hook_class("DoctorBagBase")

	for _, func in pairs({ "set_server_information", "_take", "sync_taken" }) do
		module:post_hook(50, DoctorBagBase, func, function(self, ...)
			DeployableSpy:add(self._unit, "medic_bag")
		end)
	end
end

-- Host only
if RequiredScript == "lib/units/equipment/sentry_gun/sentrygunbase" then
	local SentryGunBase = module:hook_class("SentryGunBase")
	module:post_hook(50, SentryGunBase, "setup", function(self, ...)
		DeployableSpy:add(self._unit, "sentry_gun")
	end)
end
