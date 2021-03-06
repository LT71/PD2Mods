
Hooks:PostHook(ObjectInteractionManager, "init", "HoloInfoLoot_Init", function(self)
    self.custom = {}
	self.custom.loot_amount = 0
	
	self._loot_bags = {}
	self._tmp_loot_bags = {}
	
	self._loot_adjustments = {
		family = 						{ money = 1, },
		watchdogs_2 = 					{ coke = 10, },
		watchdogs_2_day =				{ coke = 10, },
		framing_frame_3 = 				{ gold = 16, },
		mia_1 = 						{ money = 1, },
		welcome_to_the_jungle_1 =		{ money = 1, gold = 1 },
		welcome_to_the_jungle_1_night =	{ money = 1, gold = 1 },
		mus = 							{ painting = 2 },
		arm_und = 						{ money = 8, },
		ukrainian_job = 				{ money = 3, },
		jewelry_store = 				{ money = 2, },
		chill = 						{ painting = 1, },
		chill_combat = 					{ painting = 1, },
		fish = 							{ mus_artifact = 1 },
		--dah = 							{ money = 8 },
		rvd2 = 							{ money = 1 },
		des = 							{ mus_artifact = 2, painting = 2 }
	}
end)

Hooks:PostHook(ObjectInteractionManager, "update", "HoloInfoLoot_Update", function(self, t, dt)
     for i = #self._tmp_loot_bags, 1, -1 do
		local data = self._tmp_loot_bags[i]
		local unit = data.unit
		if alive(unit) and unit:interaction() and unit:interaction():active() then
			local carry_id = unit:carry_data() and unit:carry_data():carry_id()
			local interact_type = unit:interaction().tweak_data
			if carry_id and not tweak_data.carry[carry_id].skip_exit_secure or interact_type and tweak_data.carry[interact_type] and not tweak_data.carry[carry_id].skip_exit_secure == true then
				self._loot_bags[unit:id()] = true

				local level_id = managers.job:current_level_id()
				if carry_id and level_id and self._loot_adjustments[level_id] and self._loot_adjustments[level_id][carry_id] and self._loot_adjustments[level_id][carry_id] > 0 then
					self._loot_adjustments[level_id][carry_id] = self._loot_adjustments[level_id][carry_id] - 1
				else
					self:update_loot_count(1)
				end
			end
		end
		table.remove(self._tmp_loot_bags, i)
	end
end)

Hooks:PostHook(ObjectInteractionManager, "add_unit", "HoloInfoLoot_AddUnit", function(self, unit)
     table.insert(self._tmp_loot_bags, { unit = unit })
end)

Hooks:PostHook(ObjectInteractionManager, "remove_unit", "HoloInfoLoot_RemoveUnit", function(self, unit)
     if self._loot_bags[unit:id()] then
		self._loot_bags[unit:id()] = nil
		self:update_loot_count(-1)
	end
end)

function ObjectInteractionManager:update_loot_count(update)
	self.custom.loot_amount = (self.custom.loot_amount or 0) + update
	if managers.hud and self.custom.loot_amount >= 0 then
		managers.hud._hud_assault_corner.lootbags = self.custom.loot_amount
	end
end

function ObjectInteractionManager:get_current_loot_count()
	return (self.custom.loot_amount and self.custom.loot_amount >= 0) and self.custom.loot_amount or 0
end