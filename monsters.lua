
-- particle effects

local effect = function(pos, amount, texture, min_size, max_size,
		radius, gravity, glow, fall)

	radius = radius or 2
	min_size = min_size or 0.5
	max_size = max_size or 1
	gravity = gravity or -10
	glow = glow or 0

	if fall == true then
		fall = 0
	elseif fall == false then
		fall = radius
	else
		fall = -radius
	end

	minetest.add_particlespawner({
		amount = amount,
		time = 0.25,
		minpos = pos,
		maxpos = pos,
		minvel = {x = -radius, y = fall, z = -radius},
		maxvel = {x = radius, y = radius, z = radius},
		minacc = {x = 0, y = gravity, z = 0},
		maxacc = {x = 0, y = gravity, z = 0},
		minexptime = 0.1,
		maxexptime = 1,
		minsize = min_size,
		maxsize = max_size,
		texture = texture,
		glow = glow
	})
end

-- mimic monster

for _, color in ipairs({"brown", "red"}) do
local textures
	if color == "red" then
		textures = {
			'pilzmod_giant_mushroom_red.png',	-- +Y
			'pilzmod_giant_mushroom_red_bottom.png',	-- -Y
			'pilzmod_giant_mushroom_red.png',	-- +X
			'pilzmod_giant_mushroom_red.png',	-- -X
			'pilzmod_giant_mushroom_red.png^mimic_mouth.png',	-- +Z
			'pilzmod_giant_mushroom_red.png'	-- -Z
		}
	else
		textures = {
			'pilzmod_giant_mushroom_brown_top.png',	-- +Y
			'pilzmod_giant_mushroom_brown_bottom.png',	-- -Y
			'pilzmod_giant_mushroom_brown_side.png',	-- +X
			'pilzmod_giant_mushroom_brown_side.png',	-- -X
			'pilzmod_giant_mushroom_brown_side.png^mimic_mouth.png',	-- +Z
			'pilzmod_giant_mushroom_brown_side.png'	-- -Z
		}
	end
	mobs:register_mob('pilzmod:mime_' .. color, {
		type = 'monster',
		hp_min = (minetest.PLAYER_MAX_HP_DEFAULT / 2 - 3),
		hp_max = minetest.PLAYER_MAX_HP_DEFAULT / 2,	-- Same as player
		armor = 100,								-- Same as player
		walk_velocity = 1,		-- Nodes per second
		run_velocity = 5,		-- Nodes per second
		jump = true,		-- Required in orded to turn when there's an obstacle
		jump_height = 7,		-- Barely noticeable, required to change direction
		stepheight = 1.1,		-- It can walk onto 1 node
		pushable = true,		-- It can't be moved by pushing
		view_range = 15,		-- Active block
		damage = 4,				-- 1/5 of 20HP, that is 20 hearts
		knock_back = true,		-- It can be knocked back by hits
		fear_height = 100,
		water_damage = 5,
		lava_damage = 20,		-- It dies if it wals into lava
		light_damage = 0,		-- Doesn't take damage from light
		fall_damage = 0,
		suffocation = 0,		-- Doesn't drown
		floats = 1,				-- Doesn't swim
		fly = false,
		fly_in = {},
		reach = 2,
		docile_by_day = false,	-- Attacks regardless of daytime or nighttime
		stand_chance = 70,
		walk_chance = 0,
		attack_chance = 30,
		blood_texture = "tnt_smoke.png",
		attack_monsters = false,
		attack_animals = true,
		attack_npcs = true,
		attack_players = true,
		group_attack = true,
		attack_type = 'dogfight',
		pathfinding = 1,
		makes_footstep_sound = false,
		drops = {
			{name = 'pilzmod:giant_mushroom_' .. color, chance = 1, min = 1, max = 1},
		},
		visual = 'cube',
		visual_size = {x = 1, y = 1, z = 1},
		collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		selectionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
		textures = textures,
		on_spawn = function(self)
			if self.already_randomized then
				return
			else
				self.already_randomized = true
			end
			-- give mob randomized properties
		    self.jump_height = math.random(2, 8)
		    if math.random() < 0.33 then
				self.fly_in = {"air"}
				self.fly = true
			end
			self.damage = math.random(3, 5)
			self.run_velocity = math.random(2, 6)
			self.fall_velocity = math.random(-10, -7)
			if math.random() < 0.2 then
				self.attack_monsters = true
				group_attack = false
			end
			if not self.view_range_already_set then
				self.view_range = math.random(5, 14)
			end
			-- set timer for time spent without being agressive
			self.time_spent_decile = 0
		end,
		
		on_punch = function(self)
		-- extend view range when punched
			self.view_range = 14
		end,
		
		do_custom = function(self, dtime)
			if self.state ~= "attack" then
				self.time_spent_decile = self.time_spent_decile + dtime
			end
			if self.time_spent_decile > 5 then
				local pos = self.object:get_pos()
				if minetest.get_node(pos).name == "air" then
					minetest.set_node(pos, {name='pilzmod:giant_mushroom_' .. color .. '_mimic'})
					self.object:remove()
					-- active_mobs = active_mobs - 1
					-- if active_mobs < 0 then active_mobs = 0 end
					return false -- so the api knows the mob is "dead"
				end
			end
			-- REMOVE AFTER MAKING IMAGES
			-- self.health = math.random(3, 8)
			-- self.damage = 1
			-- self.attack_monsters = true
		end,
	})
end

-- mushroom stem boss

dofile(minetest.get_modpath("pilzmod").."/monsters_boss_on_hit.lua")

for _, color in ipairs({"brown", "red"}) do
	mobs:register_mob('pilzmod:boss_' .. color, {
		type = 'monster',
		hp_min = 500,
		hp_max = 500,
		armor = 100,
		walk_velocity = 0,
		run_velocity = 0,
		jump = false,		-- Required in orded to turn when there's an obstacle
		pushable = false,		-- It can't be moved by pushing
		view_range = 150,		-- Active block
		damage = 6,
		knock_back = false,		-- It can't be knocked back by hits
		fear_height = 100,
		water_damage = 0,
		lava_damage = 0,		-- It dies if it wals into lava
		light_damage = 0,		-- Doesn't take damage from light
		fall_damage = 0,
		suffocation = 0,		-- Doesn't drown
		fly = true,
		fly_in = {"air", "default:water_source", "default:lava_source", "default:magma_source"},
		floats = false,
		passive = true,
		reach = 2,
		docile_by_day = false,	-- Attacks regardless of daytime or nighttime
		stand_chance = 0,
		walk_chance = 0,
		attack_chance = 100,
		blood_texture = "tnt_smoke.png",
		attack_monsters = false,
		attack_animals = false,
		attack_npcs = false,
		attack_players = true,
		group_attack = false,
		attack_type = 'shoot',
		shoot_interval = 2,
		arrow = 'pilzmod:boss_projectile_' .. color,
		-- dogshoot_switch = 1,			-- Switch to dogfight after shooting
		-- dogshoot_count_max = 3,			-- 3secs for shooting
		-- dogshoot_count2_max = 2,		-- 2secs for melee attacking
		pathfinding = 1,
		-- shoot_interval = 1.5,
		-- shoot_offset = 1.5,
		makes_footstep_sound = false,
		drops = {
			{name = "pilzmod:boss_projectile_decoblock_" .. color, chance = 1, min = 1, max = 1},
			{name = "pilzmod:antidote", chance = 1, min = 1, max = 1},
		},
		collisionbox = {-0.5, -0.5, -0.5, 0.5, 2.5, 0.5},
		visual = "mesh",
		visual_size = {x = 5, y = 5},
		mesh = "mushroom_stem.b3d",
		textures = {
			{"mushroom_boss.png"},
		},
		lifetimer = 2000,
		-- on_step = boss_mob_on_step,
		
		on_spawn = function(self)
			-- only do this function once
			if self.already_did_on_spawn then
				return
			else
				self.already_did_on_spawn = true
			end
			-- initialize fields
			self.running_away = 0
			-- safe spawn pos as home pos
			self.home_pos = self.object:get_pos()
			-- remove unnecessary change velocity function
			self.set_velocity = function() end
			-- fly up
			self.min_goal_height = self.object:get_pos().y + 17
			self.object:set_velocity({x=0, y=2.3, z=0})
			-- set nametag color
			self.object:set_properties({
				nametag_color = "#FFFF00"
			})
		end,
		
		do_punch = function(self, hitter, tflp, tool_capabilities, dir)
			-- fly up and backwards when hit by player
			if hitter:is_player() then
				self.running_away = 6
				self.attack_type = "shoot"
				self.run_velocity = 0
			-- deal damage and knockback to attacker otherwise (this way the boss can defend itself without losing focus on the player(s))
			elseif hitter and hitter:get_luaentity() then
				hitter:punch(self.object, 1.0, {
					full_punch_interval = 1.0,
					damage_groups = {fleshy = 6},
				}, self.object:get_pos())
			end
			return true
		end,
		
		do_custom = function(self, dtime)
			local vel = {x=0, y=0, z=0}
			local pos = self.object:get_pos()
			local yaw = self.object:get_yaw()
			-- live forever
			self.tifetimer = 20000
			self.tamed = true
			-- nametag health update
			self.object:set_properties({
				nametag = "♥ " .. tostring(self.health) .. "/" .. tostring(self.hp_max),
			})
			-- attack players if there is no player to attack atm
			if self.state ~= "attack" then
				local objs = minetest.get_objects_inside_radius(pos, self.view_range)
				for _, obj in ipairs(objs) do
					if obj:is_player() then
						self.attack = obj
						self.state = "attack"
					end
				end
			end
			-- go back to shooting if player we meleed is too far away
			if (not self.attack) or (self.attack and self.attack_type == "dogfight" and vector.distance(self.attack:get_pos(), pos) > 8) then
				self.attack_type = "shoot"
				self.run_velocity = 0
			end
			-- hit everything on your head so you aren't blocked to the up direction
			local headsitters = minetest.get_objects_inside_radius({x=pos.x, y=pos.y+3, z=pos.z}, 0.6)
			for _, obj in ipairs(headsitters) do
				obj:punch(self.object, 1.0, {
					full_punch_interval = 1.0,
					damage_groups = {fleshy = 1},
				}, {x=pos.x+math.sin(yaw) * 0.8, y=pos.y, z=pos.z-math.cos(yaw) * 0.8})
			end
			-- wake sleeping mushroom mimics up so they don't block u
			if math.random() < 0.3 then
				local red_mimics = minetest.find_nodes_in_area(vector.subtract(pos, 4), vector.add(pos, 4), {"pilzmod:giant_mushroom_red_mimic"})
				for _, pos in pairs(red_mimics) do
					minetest.set_node(pos, {name="air"})
					minetest.add_entity(pos, "pilzmod:mime_red")
				end
				local brown_mimics = minetest.find_nodes_in_area(vector.subtract(pos, 4), vector.add(pos, 4), {"pilzmod:giant_mushroom_brown_mimic"})
				for _, pos in pairs(brown_mimics) do
					minetest.set_node(pos, {name="air"})
					minetest.add_entity(pos, "pilzmod:mime_brown")
				end
			end
			-- fly away when player hits - prep
			self.running_away = math.max(0, self.running_away - dtime)
			-- fly up until height goal is reached
			if self.min_goal_height ~= false then
				if self.min_goal_height <= pos.y then
					self.min_goal_height = false
				else
					vel = {x=0, y=2.3, z=0}
				end
			-- actually fly away when player hits
			elseif self.running_away > 0 then
				vel.x =  math.sin(yaw) * 0.8
				vel.z = -math.cos(yaw) * 0.8
				vel.y = 1.35
			-- return towards home location if x-z-distance is too high
			elseif math.sqrt((pos.x - self.home_pos.x)^2 + (pos.z - self.home_pos.z)^2) > 70 then
				local goal_point = {x=self.home_pos.x, y=pos.y, z=self.home_pos.z}
				vel = vector.multiply(vector.round(vector.subtract(pos, goal_point)), 1)
			-- move towards player if it is to far beneath you
			elseif self.attack and pos.y - self.attack:get_pos().y > 38 then
				local player_pos = self.attack:get_pos()
				vel = vector.multiply(vector.round(vector.subtract(pos, player_pos)), 1)
			-- move downwars if home pos if it is too far beneath you
			elseif pos.y - self.home_pos.y > 50 then
				vel = {0, -1, 0}
			-- don't manually set direction if we are already meleeing
			elseif self.attack_type == "dogfight" then
				--
			-- decide to melee if player is within 8 blocks of range
			elseif self.attack and vector.distance(self.attack:get_pos(), pos) <= 8 then
				self.attack_type = "dogfight"
				self.run_velocity = 5
			end
			self.object:set_velocity(vel)
			return vel
		end,
	})
	
	-- boss projectile
	local projectile_texture = "pilzmod_giant_mushroom_brown_top.png"
	if color == "red" then
		projectile_texture = "pilzmod_giant_mushroom_red.png"
	end
	minetest.register_entity("pilzmod:boss_projectile_" .. color, {
		visual = "cube",
		visual_size = {x=0.65, y=0.65},
		textures = {
			projectile_texture .. "^mimic_mouth.png^projectile_frame.png",
			projectile_texture .. "^mimic_mouth.png^projectile_frame.png",
			projectile_texture .. "^mimic_mouth.png^projectile_frame.png",
			projectile_texture .. "^mimic_mouth.png^projectile_frame.png",
			projectile_texture .. "^mimic_mouth.png^projectile_frame.png",
			projectile_texture .. "^mimic_mouth.png^projectile_frame.png"
		},
		
		on_activate = function(self, staticdata, dtime_s)
			-- find out who our boss is
			objs = minetest.get_objects_inside_radius(self.object:get_pos(), 2)
			for _, obj in ipairs(objs) do
				if obj:get_luaentity().name == 'pilzmod:boss_' .. color then
					self.boss = obj:get_luaentity()
					minetest.chat_send_all("found our boss!!")
				end
			end
		end,
		
		on_step = function(self, dtime)
			local pos = self.object:get_pos()
			local pos_above = {x=pos.x, y=pos.y+1, z=pos.z}
			-- rotate
			local new_yaw = self.object:get_yaw() + math.pi * dtime
			if new_yaw > 2 * math.pi then
				new_yaw = new_yaw - 2 * math.pi
			end
			self.object:set_yaw(new_yaw)
			
			-- check if we hit any players
			for _, obj in pairs(minetest.get_objects_inside_radius(pos, 1.0)) do
				if obj:is_player() then
					-- pretend we hit a node
					pos_above = obj:get_pos()
					pos = pos_above
					node = {name = "default:dirt"}
				end
			end
			
			-- check if we need hit a block
			local node = minetest.get_node(pos)
			if minetest.registered_nodes[node.name].walkable then
			
				-- duplicate all waking(!) mushroom mimics inside radius
				-- but don't duplicate if that would cause the number of waking mimics in radius to go above 9
				local objs = minetest.get_objects_inside_radius(pos, 1.7)
				local mushroom_mimics = {}
				local mime_count = 0
				for _, obj in ipairs(objs) do
					local luaent = obj:get_luaentity()
					if luaent and luaent.name == "pilzmod:mime_red" then
						local mushpos = obj:getpos()
						effect(mushpos, 40, "tnt_smoke.png")
						mime_count = mime_count + 1
						if mime_count < 9 then
							minetest.add_entity(mushpos, "pilzmod:mime_red")
							mime_count = mime_count + 1
						end
					elseif luaent and luaent.name == "pilzmod:mime_brown" then
						local mushpos = obj:getpos()
						effect(mushpos, 40, "tnt_smoke.png")
						mime_count = mime_count + 1
						if mime_count < 9 then
							minetest.add_entity(mushpos, "pilzmod:mime_brown")
							mime_count = mime_count + 1
						end
					end
				end
				
				-- get distance to closest player
				local dist_to_closest_player = 25
				if self.boss and self.boss.attack then
					dist_to_closest_player = vector.distance(pos, self.boss.attack:get_pos())
					minetest.chat_send_all(dist_to_closest_player)
				end
				
				-- set above spawn point anew
				local i = 0
				while i < 7 and minetest.get_node(pos_above).name ~= "air" do
					pos_above.y = pos_above.y + 1
				end
				
				local rand_number = math.random()
				if node.name == "pilzmod:giant_mushroom_" .. color .. "_mimic" then
					-- if we hit a mime block make sure the random
					-- number is <= 0.7 so we don't grow mimic trees on mimics.
					rand_number = rand_number * 0.7
				end
				-- explosion chance 1/3:
				if rand_number < 0.3 then
					local mimics_red =  minetest.find_nodes_in_area(vector.subtract(pos, {x=3, y=3, z=3}), vector.add(pos, {x=3, y=3, z=3}), "pilzmod:giant_mushroom_red_mimic")
					local mimics_brown =  minetest.find_nodes_in_area(vector.subtract(pos, {x=3, y=3, z=3}), vector.add(pos, {x=3, y=3, z=3}), "pilzmod:giant_mushroom_brown_mimic")
					for _, mushpos in ipairs(mimics_red) do
						minetest.set_node(mushpos, {name="air"})
						obj = minetest.add_entity(mushpos, "pilzmod:mime_red")
						obj:get_luaentity().view_range = dist_to_closest_player * 2
						obj:get_luaentity().view_range_already_set = true
					end
					for _, mushpos in ipairs(mimics_brown) do
						minetest.set_node(mushpos, {name="air"})
						obj = minetest.add_entity(mushpos, "pilzmod:mime_brown")
						obj:get_luaentity().view_range = dist_to_closest_player * 2
						obj:get_luaentity().view_range_already_set = true
					end
					if mimics_red or mimics_brown then
						tnt.boom(pos, {radius=3, damage_radius=0})
					else
						tnt.boom(pos, {radius=3, damage_radius=4.5})
					end
				-- spawn mimics chance 1/3:
				elseif rand_number <= 0.7 then
					for _ in ipairs({1, 2, 3}) do
						local obj = minetest.add_entity(pos_above, "pilzmod:mime_" .. color)
						obj:get_luaentity().view_range = dist_to_closest_player * 2
						obj:get_luaentity().view_range_already_set = true
						effect(pos_above, 40, "tnt_smoke.png")
					end
				-- spawn mushroom mimic tree chance 1/3:
				else
					grow_giant_mushroom(pos_above, "pilzmod:giant_mushroom_stem", "pilzmod:giant_mushroom_" .. color .. "_mimic", 0, "air")
					effect(pos_above, 40, "tnt_smoke.png")
				end
				
				-- remove projectile
				self.object:remove()
			end
		end,
		velocity = 5,
	})
	
	-- decorative boss projectile block (and boss drop)
	minetest.register_node("pilzmod:boss_projectile_decoblock_" .. color, {
		description = "Mushroom Heart Projectile (Decorative Trophy)",
		tiles = {projectile_texture .. "^mimic_mouth.png^projectile_frame.png"},
		paramtype = "light",
		light_source = 12,
		is_ground_content = false,
		groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 2},
		sounds = default.node_sound_wood_defaults()
	})
end

-- antidote block

minetest.register_node("pilzmod:antidote", {
	description = "Mushroomification Antidote",
	tiles = {"pilzmod_antidote.png"},
	paramtype = "light",
	light_source = 12,
	groups = {crumbly = 3, soil = 1},
	-- drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults({
		footstep = {name = "default_grass_footstep", gain = 0.25},
	}),
})

minetest.register_abm({
	label = "mushroom biome curing",
	nodenames = {"group:spreading_myzelium_type"},
	neighbors = all_myzelium_convertible_blocks,
	interval = 6, -- twice as long as duration for stuff to spread
	chance = 10, -- 5 times as high as chance for stuff to spread
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		if minetest.find_node_near(pos, 2, {"pilzmod:antidote"}) then
			minetest.set_node(pos, {name="pilzmod:antidote"})
		end
	end
})

-- what happens when a player punches a mimic block

function punch_mushroom_mimic_block(pos, node, player, _)
	local mushroom_mimic_block_positions = minetest.find_nodes_in_area(vector.subtract(pos, 10), vector.add(pos,10), {"group:is_mushroom_mimic"})
	local min_y_pos = nil
	local counter_brown = 0
	local counter_red = 0
	for _, pos in pairs(mushroom_mimic_block_positions) do
		if minetest.get_node(pos).name == "pilzmod:giant_mushroom_stem_mimic" then
			local pos2 = vector.subtract(pos, {x=0, y=1, z=0})
			if not min_y_pos or pos.y < min_y_pos.y then
				min_y_pos = pos
			end
			minetest.set_node(pos, {name="air"})
		else
			if minetest.get_node(pos).name == "pilzmod:giant_mushroom_brown_mimic" then
				minetest.add_entity(pos, "pilzmod:mime_brown")
				counter_brown = counter_brown + 1
			else
				minetest.add_entity(pos, "pilzmod:mime_red")
				counter_red = counter_red + 1
			end
			minetest.set_node(pos, {name="air"})
		end
	end
	if min_y_pos then
		local boss
		if counter_red > counter_brown then
			-- minetest.add_entity(vector.new(0, 10, 0), "mobs:sheep", minetest.serialize({naked = true}))
			boss = minetest.add_entity(min_y_pos, "pilzmod:boss_red")
		else
			boss = minetest.add_entity(min_y_pos, "pilzmod:boss_brown")
		end
		if boss then
			local luaent = boss:get_luaentity()
			luaent.attack = player
			luaent.state = "attack"
		end
	end
end


-- mimic blocks

minetest.register_node("pilzmod:giant_mushroom_stem_mimic", {
	description = "Giant Mushroom Stem",
	tiles = {"pilzmod_giant_mushroom_stem_bottom.png", "pilzmod_giant_mushroom_stem_bottom.png", "pilzmod_giant_mushroom_stem_side.png"},
	sounds = default.node_sound_wood_defaults(),
	on_punch = punch_mushroom_mimic_block,
	groups = {is_mushroom_mimic = 1, not_in_creative_inventory = 1},
	on_place = minetest.rotate_node
})

minetest.register_node("pilzmod:giant_mushroom_brown_mimic", {
	description = "Giant Mushroom Hat Piece",
	tiles = {"pilzmod_giant_mushroom_brown_top.png", "pilzmod_giant_mushroom_brown_bottom.png", "pilzmod_giant_mushroom_brown_side.png"},
	sounds = default.node_sound_wood_defaults(),
	on_punch = punch_mushroom_mimic_block,
	groups = {is_mushroom_mimic = 1, not_in_creative_inventory = 1},
})

minetest.register_node("pilzmod:giant_mushroom_red_mimic", {
	description = "Red Mushroom Hat Piece",
	tiles = {"pilzmod_giant_mushroom_red.png", "pilzmod_giant_mushroom_red_bottom.png", "pilzmod_giant_mushroom_red.png"},
	sounds = default.node_sound_wood_defaults(),
	on_punch = punch_mushroom_mimic_block,
	groups = {is_mushroom_mimic = 1, not_in_creative_inventory = 1},
})

-- import function to grow giant mushrooms

dofile(minetest.get_modpath("pilzmod").."/tree_generation.lua")

-- define specific mushrooms

function grow_giant_mimic_boss(pos)
	local color  = "brown"
	if math.random() < 0.4 then
		color = "red"
	end
	grow_giant_mushroom(pos, "pilzmod:giant_mushroom_stem_mimic", "pilzmod:giant_mushroom_" .. color .. "_mimic", 0, "air")
end

function grow_giant_mimic_tree(pos)
	local color  = "brown"
	if math.random() < 0.2 then
		color = "red"
	end
	grow_giant_mushroom(pos, "pilzmod:giant_mushroom_stem", "pilzmod:giant_mushroom_" .. color .. "_mimic", 0, "air")
end

-- automatic giant mushroom spawning

minetest.register_abm({
	label = "spawn_giant_mushroom_mimic",
	nodenames = {"pilzmod:dirt_with_myzelium"},
	interval = 300, -- every 5 minutes
	chance = 100, -- happens only to one block out of a 10x10 block grid
	catch_up = false,
	action = function(pos, node, active_object_count, active_object_count_wider)
		pos_above = {x=pos.x, y=pos.y+1, z=pos.z}
		pos_way_above = {x=pos.y, y=pos.y+20, z=pos.z}
		if minetest.get_node(pos_above).name ~= "air" then
			return
		end
		if (minetest.get_node_light(pos_above)  or 0) > 13 and not PILZMOD_TEST_MODE then
			return
		end
		if minetest.find_node_near(pos_above, 15, {"group:is_mushroom_mimic"}) then
			return
		end
		if minetest.find_node_near(pos_above, 2, {"pilzmod:giant_mushroom_stem"}) then
			return
		end
		if math.random() < .15 and not minetest.find_nodes_in_area(pos_above, pos_way_above, {"pilzmod:giant_mushroom_brown"}) then
			grow_giant_mimic_boss(pos_above) -- grow with 15% chance and never in mushroom halls.
		else
			grow_giant_mimic_tree(pos_above)
		end
	end
})

-- item to spawn a mimic giant mushroom

for color, color_name in pairs({brown="Brown", red="Red"}) do
	minetest.register_node("pilzmod:giant_mushroom_mimic_totem_" .. color, {
		description = color_name .. " Mushroom Boss Sapling",
		tiles = {"pilzmod_giant_mushroom_mimic_totem_" .. color .. ".png"},
		inventory_image = "pilzmod_giant_mushroom_mimic_totem_" .. color .. ".png",
		drawtype = "plantlike",
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		buildable_to = false,
		on_construct = function(pos)
			grow_giant_mushroom(pos, "pilzmod:giant_mushroom_stem_mimic", "pilzmod:giant_mushroom_" .. color .. "_mimic", 0, "air")
		end
	})
end

minetest.register_node("pilzmod:giant_mushroom_mimic_tree_totem", {
	description = "Mushroom Mimic Tree Sapling",
	tiles = {"pilzmod_giant_mushroom_mimic_tree_toteem.png"},
	inventory_image = "pilzmod_giant_mushroom_mimic_tree_toteem.png",
	drawtype = "plantlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = false,
	on_construct = function(pos)
		grow_giant_mimic_tree(pos)
	end
})

minetest.register_node("pilzmod:boss_sappling", {
	description = "Mushroom Stem Boss Sapling",
	tiles = {"pilzmod_boss_sappling.png"},
	inventory_image = "pilzmod_boss_sappling.png",
	drawtype = "plantlike",
	paramtype = "light",
	sunlight_propagates = true,
	walkable = false,
	buildable_to = false,
	on_construct = function(pos)
		minetest.add_entity(pos, "pilzmod:boss_red")
		minetest.set_node(pos, {name="air"})
	end
})

minetest.register_node("pilzmod:red_mushroom_mimic_spawnegg", {
		description = "Red Mushroom Mimic",
		tiles = {
			'pilzmod_giant_mushroom_red.png',	-- +Y
			'pilzmod_giant_mushroom_red_bottom.png',	-- -Y
			'pilzmod_giant_mushroom_red.png^mimic_mouth.png',	-- +X
			'pilzmod_giant_mushroom_red.png',	-- -X
			'pilzmod_giant_mushroom_red.png',	-- +Z
			'pilzmod_giant_mushroom_red.png'	-- -Z
		},
		on_construct = function(pos)
			minetest.set_node(pos, {name="pilzmod:giant_mushroom_red_mimic"})
		end
	})

minetest.register_node("pilzmod:brown_mushroom_mimic_spawnegg", {
		description = "Brown Mushroom Mimic",
		tiles = {
			'pilzmod_giant_mushroom_brown_top.png',	-- +Y
			'pilzmod_giant_mushroom_brown_bottom.png',	-- -Y
			'pilzmod_giant_mushroom_brown_side.png^mimic_mouth.png',	-- +X
			'pilzmod_giant_mushroom_brown_side.png',	-- -X
			'pilzmod_giant_mushroom_brown_side.png',	-- +Z
			'pilzmod_giant_mushroom_brown_side.png'	-- -Z
		},
		on_construct = function(pos)
			minetest.set_node(pos, {name="pilzmod:giant_mushroom_brown_mimic"})
		end
	})
