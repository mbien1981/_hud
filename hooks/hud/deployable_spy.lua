if not rawget(_G, "DeployableSpy") then
	rawset(_G, "DeployableSpy", {})

	function DeployableSpy:alive()
		return alive(managers.player:player_unit())
	end

	function DeployableSpy:is_playing()
		return BaseNetworkHandler._gamestate_filter.any_ingame_playing[game_state_machine:last_queued_state_name()]
	end

	function DeployableSpy:get_camera()
		local player = managers.player:player_unit()
		if alive(player) then
			return player:camera()
		end

		return nil
	end

	function DeployableSpy:get_vec_angle(v)
		local p_unit = managers.player:player_unit()
		if not alive(p_unit) then
			return nil
		end

		local player = Vector3()
		local enemy = Vector3()
		local dir = Vector3()
		mvector3.set(player, p_unit:camera():position())
		mvector3.set(enemy, v)
		mvector3.set(dir, player)
		mvector3.subtract(dir, enemy)
		mvector3.normalize(dir)

		local newx, newy, newz = dir.x, dir.y, dir.z
		if player.x > enemy.x or (player.x < enemy.x and newx < 0) then
			newx = newx * -1
		end

		if player.y > enemy.y or (player.y < enemy.y and newy < 0) then
			newy = newy * -1
		end

		if player.z > enemy.z or (player.z < enemy.z and newz < 0) then
			newz = newz * -1
		end

		mvector3.set(dir, Vector3(newx, newy, newz))

		return dir
	end

	function DeployableSpy:init()
		if self._ws or self._panel then
			return
		end

		self._initialized = true
		self._ws = managers.gui_data:create_fullscreen_workspace()
		self._panel = self._ws:panel():panel({
			name = "bag_spy_panel",
			layer = 0,
			alpha = 1,
			visible = true,
		})

		self._deployables = {}

		_updator:add(function()
			self:update()
		end, "deployable_spy_update")
	end

	function DeployableSpy:register_new_deployable(unit, var_name)
		if not self._initialized then
			self:init()
		end

		local camera = self:get_camera()
		if not camera then
			return
		end

		local world_positon = Vector3()
		local world_to_screen = Vector3()

		mvector3.set(world_positon, unit:position())
		mvector3.set(world_to_screen, self._ws:world_to_screen(camera._camera_object, world_positon))

		local sequence_text = self._panel:text({
			text = "",
			font_size = 12,
			x = world_to_screen.x,
			y = world_to_screen.y,
			align = "left",
			font = "fonts/font_univers_latin_530_bold",
			color = Color.white,
			alpha = 0,
			layer = 5,
		})

		local item = {
			text = sequence_text,
			unit = unit,
			var_name = var_name,
			source_pos = world_positon,
		}

		table.insert(self._deployables, item)
	end

	function DeployableSpy:unregister_deployable(index, item)
		item.text:parent():remove(item.text)
		table.remove(self._deployables, index)
	end

	function DeployableSpy:update_text(index, item)
		if not alive(item.unit) or item.unit:base()._empty then
			self:unregister_deployable(index, item)
			return
		end

		local camera = self:get_camera()
		if not camera then
			return
		end

		local angle = self:get_vec_angle(item.source_pos)
		if (mvector3.distance(camera:forward(), angle) / 2 * 360) > 200 then
			item.text:set_alpha(0)
			return
		end

		local strings = {
			["_amount"] = "%.0fx",
			["_ammo_amount"] = "%.2fx",
			["sentry_gun"] = "%d (hp: %.2f%%)",
		}

		local text = strings[item.var_name]
		local amount = item.unit:base()[item.var_name]
		local health = 0
		if item.var_name == "sentry_gun" then
			amount = item.unit:weapon()._ammo_total
			health = tonumber(item.unit:character_damage()._health or 0) * 10

			if health <= 0 or (amount * 10) <= 0 then
				self:unregister_deployable(index, item)
				return
			end
		end

		local world_to_screen = Vector3()

		local distance = math.max(math.min(mvector3.distance(camera:position(), item.source_pos), 8000), 20)
		item.text:set_font_size(36 / (distance / 200))

		mvector3.set(world_to_screen, self._ws:world_to_screen(camera._camera_object, item.source_pos))
		item.text:set_text(text:format(tonumber(amount), health))

		local width = select(3, item.text:text_rect())
		item.text:set_x(world_to_screen.x - (width / 2))
		item.text:set_y(world_to_screen.y)
		item.text:set_alpha(1)
	end

	function DeployableSpy:update()
		if not (self:get_camera()) then
			return
		end

		if not next(self._deployables) then
			return
		end

		for index, item in pairs(self._deployables) do
			self:update_text(index, item)
		end
	end
end

local module = ... or D:module("_hud")
local AmmoBagBase = module:hook_class("AmmoBagBase")
module:post_hook(50, AmmoBagBase, "setup", function(self, ...)
	DeployableSpy:register_new_deployable(self._unit, "_ammo_amount")
end)

local DoctorBagBase = module:hook_class("DoctorBagBase")
module:post_hook(50, DoctorBagBase, "setup", function(self, ...)
	DeployableSpy:register_new_deployable(self._unit, "_amount")
end)

local SentryGunBase = module:hook_class("SentryGunBase")
module:post_hook(50, SentryGunBase, "setup", function(self, ...)
	DeployableSpy:register_new_deployable(self._unit, "sentry_gun")
end)
