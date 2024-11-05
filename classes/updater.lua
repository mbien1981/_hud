if not rawget(_M, "_hudUpdater") then
	rawset(_M, "_hudUpdater", { list_of_funcs = {}, time = 0 })

	local _hudUpdater = _M._hudUpdater

	function _hudUpdater:update()
		local current_time = TimerManager:main():time()
		for i, v in pairs(self.list_of_funcs) do
			if v[2] > 0 then
				if v[3] <= current_time then
					self.list_of_funcs[i][3] = current_time + (v[2] or 0)
					v[1]()
				end
			else
				v[1]()
			end
		end
	end

	function _hudUpdater:update_by_id(id)
		local current_time = TimerManager:main():time()
		local item = self.list_of_funcs[id]
		if item then
			self.list_of_funcs[id][3] = current_time + item[2]
			item[1]()
		end
	end

	function _hudUpdater:add(func, id, interval)
		if self.list_of_funcs[id] then
			return
		end

		local current_time = TimerManager:main():time()
		self.list_of_funcs[id] = { func, interval or 0, current_time }
	end

	function _hudUpdater:set_speed(id, speed)
		if self.list_of_funcs[id] then
			self.list_of_funcs[id][2] = speed
		end
	end

	function _hudUpdater:set_func(id, func)
		if self.list_of_funcs[id] then
			self.list_of_funcs[id][1] = func
		end
	end

	function _hudUpdater:has_id(id)
		return self.list_of_funcs[id] and true or false
	end

	function _hudUpdater:remove(id, call_before_removing)
		if call_before_removing then
			self.list_of_funcs[id][1]()
		end

		self.list_of_funcs[id] = nil
	end

	function _hudUpdater:remove_all(call_before_removing, except)
		local temp = {}
		if except and #except > 0 then
			for i, v in pairs(except) do
				temp[v] = true
			end
		end

		for i, v in pairs(self.list_of_funcs) do
			if call_before_removing then
				self.list_of_funcs[i][1]()
			end

			if except and temp[i] then
			-- log("UpadatorClass:remove_all(...) ignoring " .. i)
			else
				self.list_of_funcs[i] = nil
			end
		end
	end

	function _hudUpdater:func_count()
		local count = 0
		for i, v in pairs(self.list_of_funcs) do
			count = count + 1
		end

		return count
	end
end

local module = ... or D:module("_hud")
if RequiredScript == "lib/setups/setup" then
	local Setup = module:hook_class("Setup")

	module:pre_hook(50, Setup, "quit", function(self)
		_M._hudUpdater:remove_all()
	end, false)

	module:pre_hook(50, Setup, "restart", function(self)
		_M._hudUpdater:remove_all()
	end, false)

	module:pre_hook(50, Setup, "load_start_menu_lobby", function(self)
		_M._hudUpdater:remove_all()
	end, false)

	module:pre_hook(50, Setup, "load_start_menu", function(self)
		_M._hudUpdater:remove_all()
	end, false)
end

if RequiredScript == "core/lib/setups/coresetup" then
	local CoreSetup = module:hook_class("CoreSetup")

	module:pre_hook(50, CoreSetup, "__render", function(self, ...)
		_M._hudUpdater:update()
	end, false)
end
