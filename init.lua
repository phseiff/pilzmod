PILZMOD_TEST_MODE = false

-- myzelium spread musters:
myzelium_conversion = {}
myzelium_conversion["group:spreading_dirt_type"] = "pilzmod:dirt_with_myzelium"
myzelium_conversion["default:grass_1"] = "pilzmod:mushroom_brown"
myzelium_conversion["default:grass_2"] = "pilzmod:mushroom_brown"
myzelium_conversion["default:grass_3"] = "pilzmod:mushroom_brown"
myzelium_conversion["default:grass_4"] = "pilzmod:mushroom_red"
myzelium_conversion["default:grass_5"] = "pilzmod:mushroom_sappling_red"
myzelium_conversion["default:dry_grass_1"] = "pilzmod:mushroom_brown"
myzelium_conversion["default:dry_grass_2"] = "pilzmod:mushroom_brown"
myzelium_conversion["default:dry_grass_3"] = "pilzmod:mushroom_brown"
myzelium_conversion["default:dry_grass_4"] = "pilzmod:mushroom_red"
myzelium_conversion["default:dry_grass_5"] = "pilzmod:mushroom_sappling_red"
myzelium_conversion["group:tree"] = "pilzmod:giant_mushroom_stem"
myzelium_conversion["group:leaves"] = "pilzmod:giant_mushroom_brown"
myzelium_conversion["default:apple"] = "pilzmod:mushroom_brown"
myzelium_conversion["flowers:mushroom_brown"] = "pilzmod:mushroom_sappling_brown"
myzelium_conversion["flowers:mushroom_red"] = "pilzmod:mushroom_sappling_red"
myzelium_conversion["default:junglegrass"] = "pilzmod:mushroom_red"
-- flowers
myzelium_conversion["flowers:chrysanthemum_green"] = "pilzmod:mushroom_pretty_green"
myzelium_conversion["flowers:dandelion_white"] = "pilzmod:mushroom_pretty_white"
myzelium_conversion["flowers:dandelion_yellow"] = "pilzmod:mushroom_pretty_yellow"
myzelium_conversion["flowers:geranium"] = "pilzmod:mushroom_pretty_blue"
myzelium_conversion["flowers:rose"] = "pilzmod:mushroom_pretty_red"
myzelium_conversion["flowers:tulip"] = "pilzmod:mushroom_pretty_orange"
myzelium_conversion["flowers:tulip_black"] = "pilzmod:mushroom_pretty_black"
myzelium_conversion["flowers:viola"] = "pilzmod:mushroom_pretty_pink"

all_myzelium_convertible_blocks = {}
for node, _ in pairs(myzelium_conversion) do
	table.insert(all_myzelium_convertible_blocks, node)
end

-- myzelium block

minetest.register_node("pilzmod:dirt_with_myzelium", {
	description = "Dirt with Myzelium",
	tiles = {"pilzmod_myzelium.png", "default_dirt.png",
		{name = "default_dirt.png^pilzmod_myzelium_side.png",
			tileable_vertical = false}},
	groups = {crumbly = 3, soil = 1, spreading_myzelium_type = 1},
	drop = "default:dirt",
	sounds = default.node_sound_dirt_defaults({
		footstep = {name = "default_grass_footstep", gain = 0.25},
	}),
})

-- craft myzelium block

minetest.register_craft({
	output = "pilzmod:dirt_with_myzelium",
	recipe = {
		{"group:mushroom"},
		{"default:gravel"},
		{"default:dirt"},
	}
})

-- mushroom stem

minetest.register_node("pilzmod:giant_mushroom_stem", {
	description = "Giant Mushroom Stem",
	tiles = {"pilzmod_giant_mushroom_stem_bottom.png", "pilzmod_giant_mushroom_stem_bottom.png", "pilzmod_giant_mushroom_stem_side.png"},
	paramtype2 = "facedir",
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 2, spreading_myzelium_type = 1, mushroom_stem = 1},
	sounds = default.node_sound_wood_defaults(),
	on_place = minetest.rotate_node
})

-- brown giant mushroom

minetest.register_node("pilzmod:giant_mushroom_brown", {
	description = "Giant Mushroom Hat Piece",
	tiles = {"pilzmod_giant_mushroom_brown_top.png", "pilzmod_giant_mushroom_brown_bottom.png", "pilzmod_giant_mushroom_brown_side.png"},
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 2, spreading_myzelium_type = 1, mushroom_hat = 1},
	sounds = default.node_sound_wood_defaults(),
	on_dig = function(pos, node, digger)
		if node.param2 ~= 1 and math.random() < 0.1 then
			minetest.add_entity(pos, "pilzmod:mime_brown")
			minetest.add_node(pos, {name="air"})
		else
			minetest.node_dig(pos, node, digger)
		end
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if node.param2 ~= 1 and placer and placer:is_player() then
			local node = minetest.get_node(pos)
			node.param2 = 1
			minetest.set_node(pos, node)
		end
	end
})

-- red giant mushroom

minetest.register_node("pilzmod:giant_mushroom_red", {
	description = "Red Mushroom Hat Piece",
	tiles = {"pilzmod_giant_mushroom_red.png", "pilzmod_giant_mushroom_red_bottom.png", "pilzmod_giant_mushroom_red.png"},
	is_ground_content = false,
	groups = {choppy = 2, oddly_breakable_by_hand = 1, flammable = 2, spreading_myzelium_type = 1, mushroom_hat = 1},
	sounds = default.node_sound_wood_defaults(),
	on_dig = function(pos, node, digger)
		if math.random() < 0.1 then
			minetest.add_entity(pos, "pilzmod:mime_red")
			minetest.add_node(pos, {name="air"})
		else
			minetest.node_dig(pos, node, digger)
		end
	end,
	after_place_node = function(pos, placer, itemstack, pointed_thing)
		if placer and placer:is_player() then
			local node = minetest.get_node(pos)
			node.param2 = 1
			minetest.set_node(pos, node)
		end
	end
})

-- make mushrooms fuel

minetest.register_craft({
	type = "fuel",
	recipe = "group:mushroom_hat",
	burntime = 30,
})
minetest.register_craft({
	type = "fuel",
	recipe = "group:mushroom_stem",
	burntime = 30,
})

-- import monster things

dofile(minetest.get_modpath("pilzmod").."/monsters.lua")

-- import function to grow giant mushrooms

dofile(minetest.get_modpath("pilzmod").."/tree_generation.lua")

-- define specific mushrooms

function grow_giant_brown_mushroom(pos)
	grow_giant_mushroom(pos, "pilzmod:giant_mushroom_stem", "pilzmod:giant_mushroom_brown", 0.2, "pilzmod:mushroom_brown")
end       
function grow_giant_red_mushroom(pos)
	grow_giant_mushroom(pos, "pilzmod:giant_mushroom_stem", "pilzmod:giant_mushroom_red", 0.2, "pilzmod:mushroom_red")
end

--
-- Convert nodes to their myzelium version if next to myzelium-spreading block
--

for from_block, to_block in pairs(myzelium_conversion) do
		minetest.register_abm({
			label = "Myzelium spread " .. from_block,
			nodenames = {from_block},
			neighbors = {
				"group:spreading_myzelium_type",
			},
			interval = 6,
			chance = 50,
			catch_up = false,
			action = function(pos, node)
				-- Check for darkness: night, shadow or under a light-blocking node
				-- Only spreads if dark
				local above = {x = pos.x, y = pos.y + 1, z = pos.z}
				local beneath = {x = pos.x, y = pos.y - 1, z = pos.z}
				if (minetest.get_node_light(above) or 0) > 13 and not PILZMOD_TEST_MODE then
					return
				end

				--[[ Look for spreading myzelium-type neighbours
				local spreader = minetest.find_node_near(pos, 1, "group:spreading_myzelium_type")
				if spreader then
					minetest.set_node(pos, {name = to_block, param2 = node.param2})
				else
					return
				end
				--]]
				
				-- if node is dirt with snow or dirt with dry grass, return
				if node.name == "default:dirt_with_snow" or node.name == "default:dirt_with_dry_grass" then
					return
				end
				
				-- if node is junglewood root, do red mushroom stuff instead
				if node.name == "default:jungletree"
				and minetest.get_node(above).name == "air"
				or minetest.get_node(above).name == "flowers:mushroom_red"
				or minetest.get_node(above).name == "flowers:mushroom_brown" then -- and minetest.get_node(beneath).name ~= "default:jungletree" then
					minetest.set_node(pos, {name="pilzmod:giant_mushroom_red"})
					if math.random() < 0.15 then
						minetest.set_node(above, {name="pilzmod:mushroom_red"})
					end
					return
				end
				
				-- if node is jungle leaves, sometimesplace brown mushrooms on them
				if node.name == "default:jungleleaves"
				and minetest.get_node(above).name == "air" then
					minetest.set_node(pos, {name="pilzmod:giant_mushroom_brown"})
					if math.random() < 0.075 then
						minetest.set_node(above, {name="pilzmod:mushroom_brown"})
					end
				end
				
				-- place node
				minetest.set_node(pos, {name = to_block, param2 = node.param2})
				
				-- if newly placed node is a mushroom stem, remove leafedecay from surrounding leaves
				if minetest.registered_nodes[to_block].groups["mushroom_stem"] == 1 then
					local leaf_positions = minetest.find_nodes_in_area(vector.subtract(pos, 3), vector.add(pos, 3), {"group:leafdecay"})
					for _, pos in ipairs(leaf_positions) do
						local node = minetest.get_node(pos)
						node.param2 = 1
						minetest.set_node(pos, node)
					end
				end
			end
		})
end

-- register mushrooms:

function merge(t1, t2)
    for k, v in pairs(t2) do
           t1[k] = v
    end
    return t1
end

for _, row in ipairs(dye.dyes) do
	local name = row[1]
	minetest.register_craft({
		output = "dye:" .. name .. " 4",
		recipe = {
			{"group:mushroom,color_" .. name}
		},
	})
end

function register_mushroom(name, description, color, on_use, extra_info)
    extra_info = extra_info or {}
    local color_info = {}
    if color then
		color_info["color_" .. color] = 1
	end
	minetest.register_node("pilzmod:" .. name, merge({
		description = description,
		tiles = {"pilzmod_" .. name .. ".png"},
		inventory_image = "pilzmod_" .. name .. ".png",
		wield_image = "pilzmod_" .. name .. ".png",
		drawtype = "plantlike",
		paramtype = "light",
		sunlight_propagates = true,
		walkable = false,
		buildable_to = false, -- ! important !
		groups = merge({mushroom = 1, snappy = 3, attached_node = 1, flammable = 1}, color_info),
		sounds = default.node_sound_leaves_defaults(),
		on_use = on_use or function(itemstack, player, pointed_thing) end,
		on_create = function(pos)
			-- replace node with air if it is generated above air
			local pos2 = vector.subtract(pos, {x=0, y=1, z=0})
			if minetest.get_node(pos2).name == "air" then
				minetest.set_node(pos, {name="air"})
			end
		end,
		selection_box = {
			type = "fixed",
			fixed = {-4 / 16, -0.5, -4 / 16, 4 / 16, -1 / 16, 4 / 16},
		}
	}, extra_info))
end

-- harmless brown & red mushrooms that don't grow
register_mushroom("mushroom_brown", "Mushroom")
register_mushroom("mushroom_red", "Red Mushroom")
-- giant mushroom saplings
register_mushroom("mushroom_sappling_brown", "Giant Mushroom Sappling")
register_mushroom("mushroom_sappling_red", "Giant Red Mushroom Sappling")
-- pretty decorative saplings
register_mushroom("mushroom_pretty_red", "Boredemia Redealis", "red")
register_mushroom("mushroom_pretty_blue", "Blueish Hatshrudderon", "blue")
register_mushroom("mushroom_pretty_yellow", "Common Butterbottom", "yellow")
register_mushroom("mushroom_pretty_pink", "Pinkish Hang-ear Bloomer", "pink")
register_mushroom("mushroom_pretty_black", "Black Udderhoppling", "black")
register_mushroom("mushroom_pretty_orange", "Clownfish Watershroom", "orange")
register_mushroom("mushroom_pretty_white", "Quicksilvsh Woodhop", "white")
register_mushroom("mushroom_pretty_green", "Helpful Moldshoe", "green")

-- giant mushroom sappling growth
for _, color in ipairs({"red", "brown"}) do
	minetest.register_abm({
		label = color .. " mushroom growth",
		nodenames = {"pilzmod:mushroom_sappling_" .. color},
		neighbors = {"pilzmod:dirt_with_myzelium"},
		interval = 6,
		chance = 50,
		catch_up = true,
		action = function(pos, node)
			-- only grow at night and if on myzelium
			local pos2 = vector.subtract(pos, {x=0, y=1, z=0})
			if not minetest.get_node(pos2).name == "pilzmod:dirt_with_myzelium" then
				return
			end
			if (minetest.get_node_light(pos) or 0) > 13 and not PILZMOD_TEST_MODE then
				return
			end
			if color == "brown" then
				grow_giant_brown_mushroom(pos)
			else
				grow_giant_red_mushroom(pos)
			end
		end
	})
end

-- craft mushroom sapplings
minetest.register_craft({
	output = "pilzmod:mushroom_sappling_red",
	recipe = {
		{"pilzmod:mushroom_red"},
		{"pilzmod:mushroom_red"},
		{"pilzmod:dirt_with_myzelium"},
	}
})
minetest.register_craft({
	output = "pilzmod:mushroom_sappling_brown",
	recipe = {
		{"pilzmod:mushroom_brown"},
		{"pilzmod:mushroom_brown"},
		{"pilzmod:dirt_with_myzelium"},
	}
})

-- make default mushrooms drop our newly registered ones, so the defaults only remain for mapgen purposes
minetest.override_item("flowers:mushroom_brown", {
	drop = "pilzmod:mushroom_brown",
    groups = {mushroom = 1, snappy = 3, attached_node = 1, flammable = 1, not_in_creative_inventory = 1}
})
minetest.override_item("flowers:mushroom_red", {
	drop = "pilzmod:mushroom_red",
    groups = {mushroom = 1, snappy = 3, attached_node = 1, flammable = 1, not_in_creative_inventory = 1}
})
