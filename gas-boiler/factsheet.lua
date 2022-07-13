-- Freeware modding by Adamo
require("util")

-- Basic utils
adamo = {
	opts = {
		logging = false,
		debugging = false
	},
	logfile = function(str)
		if adamo.opts.log and string_or_bust(str)
		and type(game) == 'table'
		and type(game.write_file) == 'function' then
			game.write_file("adamo.log",str,true)
		end
	end,
	debugfile = function(str)
		if adamo.opts.debugging and string_or_bust(str)
		and type(game) == 'table'
		and type(game.write_file) == 'function' then
			game.write_file("adamo.debug",str,true)
		end
	end,	
	log = function(str)
		if adamo.opts.log and string_or_bust(str) then
			log(str)
		end
	end,	
	debug = function(str)
		if adamo.opts.debugging and string_or_bust(str) then
			log("[DEBUG] "..tostring(str))
		end
	end
}

-- Power production efficiencies.
-- Temps determined to maintain blueprint compatibility.
-- Applied by my physics mod.
boiler_eff = 0.85
gen_eff = 0.5
furnace_eff = 0.65
reactor_eff = 0.80
chem_temp_max = 315
nuke_temp_max = 990
reactor_consump_mult = 2.01
chem_fuel_quotient = boiler_eff*gen_eff
nuke_fuel_quotient = reactor_eff*gen_eff
-- Based on theoretical max throughput
-- of a 3 meter^2 solar panel (5.1kW).
solar_panel_eff = 1/10 -- should be 6 kW
accumulator_power_quotient = 1/solar_panel_eff

adamo.fuel = {
	factors = {
		["topower"] = 1/60,
		["coal"] = 3,
		["light-oil"] = 10,
		["heavy-oil"] = 20,
		["petroleum-gas"] = 20,
		["crude-oil"] = 30,
		["methane"] = 50,
	},
	values = {
		["sulfur"] = "600kJ"
	}
}
adamo.fuel.factors["syngas"] = adamo.fuel.factors["methane"]*2

-- For backward compatibility.
fuelfactors = {
	topower = adamo.fuel.factors.topower
}
fuelfactors["coal"] = adamo.fuel.factors["coal"]
fuelfactors["light-oil"] = adamo.fuel.factors["light-oil"]
fuelfactors["heavy-oil"] = adamo.fuel.factors["heavy-oil"]
fuelfactors["petroleum-gas"] = adamo.fuel.factors["petroleum-gas"]
fuelfactors["crude-oil"] = adamo.fuel.factors["crude-oil"]
fuelfactors["methane"] = adamo.fuel.factors["methane"]
fuelfactors["syngas"] = adamo.fuel.factors["syngas"]

fuelvalues = {
	sulfur = adamo.fuel.values.sulfur
}

-- Chemical constants
adamo.chem = {
	mult = {
		fluid = 10
	},
	fluxables = {
		["iron-ore"] = "iron-plate",
		["copper-ore"] = "copper-plate"
	},
	ratio = {
		lime_per_clinker = 1,
		gypsum_per_clinker = 1/100,
		fluorite_per_clinker = 1/100,
		clinker_per_cement = 10,
		gypsum_per_cement = 1,
		stone_per_concrete = 1,
		cement_per_concrete = 1/10,
		quartz_per_concrete = 1/5,
		quartz_per_redchip = 3/5,
		fluorite_per_HF = 1/20,
		lime_per_battery = 1,
		HF_per_battery = 10,
		sulfur_per_flask = 1,
		redchip_per_flask = 3,
	}
}
adamo.chem.ratio.lime_per_cement =
	adamo.chem.ratio.lime_per_clinker
	* adamo.chem.ratio.clinker_per_cement
adamo.chem.ratio.lime_per_concrete =
	adamo.chem.ratio.lime_per_cement
	* adamo.chem.ratio.cement_per_concrete
adamo.chem.ratio.gypsum_per_lime =
	adamo.chem.ratio.gypsum_per_cement
	/ adamo.chem.ratio.lime_per_cement
adamo.chem.ratio.quart_per_lime = 
	adamo.chem.ratio.quartz_per_concrete
	/ adamo.chem.ratio.lime_per_concrete
adamo.chem.ratio.fluorite_per_lime =
	adamo.chem.ratio.fluorite_per_HF
	* adamo.chem.ratio.HF_per_battery
	/ adamo.chem.ratio.lime_per_battery
adamo.chem.ratio.quartz_per_sulfur =
	adamo.chem.ratio.quartz_per_redchip
	* adamo.chem.ratio.redchip_per_flask
	/ adamo.chem.ratio.sulfur_per_flask


adamo.geo = {
	ore = {},
	abundance = {
		calcite = 0.6,
		quartz,
		gypsum,
		sulfur,
		fluorite,
		coal,
	}
}


-- values must be between 0 and 1
local battery_share = 0.05
local blue_flask_share = 0.1
local coal_recovery = 0.075
adamo.geo.abundance.fluorite = battery_share
	*adamo.geo.abundance.calcite
	*adamo.chem.ratio.fluorite_per_lime
adamo.geo.abundance.gypsum = adamo.geo.abundance.calcite
	*adamo.chem.ratio.gypsum_per_lime
adamo.geo.abundance.quartz = adamo.geo.abundance.calcite
	*adamo.chem.ratio.quart_per_lime
adamo.geo.abundance.sulfur = adamo.geo.abundance.fluorite
	+ (
		blue_flask_share
		*adamo.geo.abundance.quartz
		/adamo.chem.ratio.quartz_per_sulfur
	)
if adamo.geo.abundance.sulfur < 0 then
	adamo.geo.abundance.sulfur = 0
end
local sum = adamo.geo.abundance.calcite
	+adamo.geo.abundance.fluorite
	+adamo.geo.abundance.gypsum
	+adamo.geo.abundance.quartz
	+adamo.geo.abundance.sulfur
adamo.geo.abundance.coal = coal_recovery * (1 - sum)



local quartz_recovery = 1/5
local recover_ratio = 1/2
local ore_mineral_norm = recover_ratio * 1 / (
		adamo.geo.abundance.fluorite
		+ adamo.geo.abundance.quartz
		+ adamo.geo.abundance.sulfur
	)

adamo.geo.ore.mineral_results = {
	["adamo-chemical-fluorite"] = adamo.geo.abundance.fluorite
		* ore_mineral_norm,
	["adamo-chemical-quartz"] = adamo.geo.abundance.quartz
		* ore_mineral_norm,
	["SiSi-quartz"] = quartz_recovery*adamo.geo.abundance.quartz
		* ore_mineral_norm,
	["sulfur"] = adamo.geo.abundance.sulfur
		* ore_mineral_norm,
	["coal"] = adamo.geo.abundance.coal
		* ore_mineral_norm,
}

adamo.geo.ore.impurity_ratio = 1/20

-- Physical quantities
physical_units = { "J", "W", "C" }
metrics = { "K","M","G","T","P","E","Z","Y" }

get_phynum_val = function(phynum)
	local phynum,val = phynum_or_bust(phynum)
	return val
end

phynum_or_bust = function(phynum)
	if type(phynum) == 'string' then
		local val = phynum:match "[0-9%.]+"
		local unit = phynum:match "%a+"
		if val and unit then return val..unit,val,unit end
	end
	return nil,nil,nil
end

energy_or_bust = function(energy)
	if type(energy) == 'number' then
		return energy..'J',energy,'J'
	end
	return phynum_or_bust(energy)
end

power_or_bust = function(power)
	if type(power) == 'number' then
		return power..'W',power,'W'
	end
	return phynum_or_bust(power)
end

energy_to_power = function(energy)
	return energy_mult(energy,fuelfactors.topower)
end

power_to_energy = function(energy)
	return energy_div(energy,fuelfactors.topower)
end

energy_mult = function(energy,mult)
	local energy = energy_or_bust(energy)
	return phynum_mult(energy,mult)
end

energy_div = function(energy,div)
	local energy = energy_or_bust(energy)
	return phynum_div(energy,div)
end

phynum_mult = function(phynum,mult)
	local e,val,unit = phynum_or_bust(phynum)
	if val and unit then e = (val*mult)..unit end
	return e
end

phynum_div = function(phynum,div)
	local e,val,unit = phynum_or_bust(phynum)
	if val and unit then e = (val/div)..unit end
	return e
end

add_prereq_to_tech = function(tech,prereq_name)
	local tech = tech_or_bust(tech)
	local prereq_name = string_or_bust(prereq_name)
	if not tech or not prereq_name then return nil end
	return add_string_to_list(tech.prerequisites,prereq_name)
end

add_prereqs_to_tech = function (tech,prereq_table)
	local prereq_table = table_or_bust(prereq_table)
	if not prereq_table then return false end
	local return_val = true
	for _,prereq_name in pairs(prereq_table) do
		if not add_prereq_to_tech(tech,prereq_name) then
			return_val = false
		end
	end
	return return_val
end

remove_tech = function(old_tech)
	local old_tech = tech_or_bust(old_tech)
	if not old_tech then return false end
	for _,tech in pairs(data.raw.technology) do
		remove_val_from_table(
			tech.prerequisites,
			old_tech.name
		)
	end
	data.raw.technology[old_tech.name] = nil
	return true
end

add_recipe_to_tech = function(tech_name,recipe_name)
	local recipe_name = string_name_or_bust(recipe_name)
	local tech = false
	if type(tech_name) == "table"
	and tech_name.type == "technology" then
		tech = tech_name
	elseif type(tech_name) == "string" then
		tech = data.raw["technology"][tech_name]
	end
	if tech then
		if not tech.effects then
			tech.effects = {{
				type="unlock-recipe",
				recipe=recipe_name
			}}
		else
			table.insert(tech.effects, {
				type="unlock-recipe",
				recipe=recipe_name
			})
		end
		return true
	end
	return false
end

add_tech_recipe = function(tech_name,recipe_name)
	return add_recipe_to_tech(tech_name,recipe_name)
end

add_recipe_tech = function(tech_name,recipe_name)
	return add_recipe_to_tech(tech_name,recipe_name)
end

add_recipes_to_tech = function(tech_name,name_table)
	if type(name_table) ~= "table" then return nil end
	for _,name in pairs(name_table) do
		add_recipe_to_tech(tech_name,name)
	end
end

move_recipe_to_tech = function(tech_name,recipe_name)
	if add_tech_recipe(tech_name,recipe_name) then
		remove_recipe_all_techs(recipe_name)
		add_tech_recipe(tech_name,recipe_name)
		return true
	end
	return false
end

move_recipes_to_tech = function(tech_name,name_table)
	if type(name_table) ~= "table" then return false end
	for _,name in pairs(name_table) do
		move_recipe_to_tech(tech_name,name)
	end
end

remove_recipe_all_techs = function(recipe_name)
	for _,tech in pairs(data.raw.technology) do
		remove_tech_recipe(tech.name,recipe_name)
	end
end

remove_tech_recipe = function(tech_name,recipe_name)
	if type(recipe_name) == "table" then
		remove_tech_recipes(recipe_name)
	end
	local recipe_name = string_name_or_bust(recipe_name)
	if not recipe_name then return nil end
	local tech = false
	if type(tech_name) == "table"
	and tech_name.type == "technology" then
		tech = tech_name
	elseif type(tech_name) == "string" then
		tech = data.raw["technology"][tech_name]
	end
	if tech then
		if not tech.effects then
			return false
		elseif type(tech.effects) == "table" then
			return remove_val_from_table(
				tech.effects,
				{
					type="unlock-recipe",
					recipe=recipe_name
				}
			)
		end
		return true
	end
	return false
end

remove_tech_recipes = function(tech_name,name_table)
	if type(name_table) ~= "table" then return nil end
	for _,name in pairs(name_table) do
		remove_tech_recipe(tech_name,name)
	end
end

find_recipe_techs = function(recipe_name)
	local tech_names = {}
	local recipe_name = string_name_or_bust(recipe_name)
	for k,tech in pairs(data.raw.technology) do
		local found_tech = false
		if tech.effects then 
			for l,effect in pairs(tech.effects) do
				if effect.type == "unlock-recipe"
				and effect.recipe == recipe_name then
					table.insert(
						tech_names,
						tech.name
					)
				end
			end
		end
	end
	return tech_names
end

all_recipes_of_category = function(category_str)
	if category_str == "crafting" then
		return smoosh_tables(
			all_prototypes_with_value(
				"recipe",
				"category",
				category_str
			),
			all_prototypes_with_value(
				"recipe",
				"category",
				nil
			)
		)
	end
	return all_prototypes_with_value(
		"recipe",
		"category",
		category_str
	)
end

mirror_recipe_in_techs = function(orig_recipe,new_recipe)
	local tech_names = find_recipe_techs(orig_recipe)
	for _,tech_name in pairs(tech_names) do
		add_recipe_to_tech(tech_name,new_recipe)
	end
end

mult_recipe_energy = function(recipe,mult)
	local recipe = recipe_or_bust(recipe)
	if recipe.normal then
		recipe.normal.energy_required = 
			(recipe.normal.energy_required or 0.5)
			* mult
		if recipe.expensive then
			recipe.expensive.energy_required = 
				(recipe.expensive.energy_required or 0.5)
				* mult
		end
	else
		recipe.energy_required = 
			(recipe.energy_required or 0.5)
			* mult
	end
end

get_recipe_category = function(recipe)
	local recipe = recipe_or_bust(recipe)
	if not recipe then return false end
	if recipe.category then return recipe.category end
	if recipe.expensive and recipe.expensive.category then
		return recipe.expensive.category
	end
	if recipe.normal and recipe.normal.category then
		return recipe.normal.category
	end
	return "crafting"
end

get_recipe_energy = function(recipe)
	local recipe = recipe_or_bust(recipe)
	if not recipe then return nil,0,0 end
	local normal_energy_required = 1
	local expensive_energy_required = 1
	if recipe.normal then
		normal_energy_required =
			recipe.normal.energy_required
		if recipe.expensive then
			expensive_energy_required = 
				recipe.expensive.energy_required
		end
	else
		return (recipe.energy_required or 0.5)
	end
	return normal_energy_required,expensive_energy_required
end

set_recipe_hidden = function(recipe)
	recipe = table_or_bust(recipe)
	if not recipe then return nil end
	if recipe.normal
	and type(recipe.normal) == "table" then
		recipe.normal.hidden = true
	end
	if recipe.expensive
	and type(recipe.expensive) == "table" then
		recipe.expensive.hidden = true
	end
	recipe.hidden = true
	return true
end

mult_recipe_io = function(recipe,mult,name)
	mult_in_recipe(recipe,mult,name)
end

mult_in_recipe = function(recipe,mult,name)
	if name then 
		replace_recipe_io(recipe,name,name,mult)
	else
		local ingredients,results = get_io_names(recipe)
		for _,name in pairs(ingredients) do
			replace_recipe_io(recipe,name,name,mult)
		end
		for _,name in pairs(results) do
			replace_recipe_io(recipe,name,name,mult)
		end
	end
end

replace_in_recipe_io = function(recipe,old_name,new_name,mult)
	io_manip(recipe,old_name,new_name,mult)
end

replace_recipe_io = function(recipe,old_name,new_name,mult)
	replace_in_recipe(recipe,old_name,new_name,mult)
end

replace_in_recipe = function(recipe,old_name,new_name,mult)
	io_manip(recipe,old_name,new_name,mult)
end

io_manip = function(io_handler,old_name,new_name,mult)
	local io_handler = io_handler_or_bust(io_handler)
	local old_name = string_name_or_bust(old_name)
	local new_io_type = get_io_type(new_name)
	local new_name = string_name_or_bust(new_name)
	local new_normal = 0
	local new_expensive = 0
	local new_amount = 0
	if type(new_name) == "number" then
		mult = new_name
		new_name = old_name
	end
	if not io_handler or not old_name
	or not new_name then return false end
	if not new_io_type then new_io_type = "item" end
	local mult = number_or_one(mult)
	if io_handler.normal then
		new_normal = io_manip(
			io_handler.normal,old_name,new_name,mult
		)
	end
	if io_handler.expensive then
		new_expensive = io_manip(
			io_handler.expensive,old_name,new_name,mult
		)
	end
	if io_handler.result then
		if io_handler.result == old_name then
			if new_io_type == "item" then
				io_handler.result = new_name
				adamo.debug(io_handler.result..": "..(io_handler.result_count or 1))
				io_handler.result_count =
					(io_handler.result_count or 1)
					* mult
				new_amount = io_handler.result_count
				adamo.debug("Replaced as simple result. Count: "..new_amount)
			else
				if not io_handler.results then
					io_handler.results = {}
				end
				table.insert(
					io_handler.results,
					{
						name = new_name,
						type = new_io_type,
						amount = (io_handler.result_count or 1)*mult
					}
				)
				io_handler.main_product = new_name
				new_amount = (io_handler.result_count or 1)*mult
				io_handler.result = nil
				io_handler.result_count = nil
				adamo.debug("Moved result to results. Count: "..new_amount)
			end
		end
	end
	for _,ingredient in pairs(io_handler.ingredients or {}) do
		if ingredient.name == old_name then
			ingredient.name = new_name
			ingredient.type = new_io_type
			adamo.debug(ingredient.name..": "..ingredient.amount)
			ingredient.amount =
				(ingredient.amount or ingredient[2] or 1)*mult
			ingredient[2] = nil
			new_amount = ingredient.amount
			adamo.debug("Replaced in table by name. Count: "..new_amount)
		end
		if ingredient[1] == old_name then
			ingredient.name = new_name
			ingredient.amount =
				(ingredient[2] or ingredient.amount or 1)*mult
			ingredient.type = new_io_type
			ingredient[1] = nil
			ingredient[2] = nil
			new_amount = ingredient.amount
			adamo.debug("Replaced in table by index. Count: "..new_amount)
		end
		if ingredient.name == nil
		and ingredient[1] == nil then
			ingredient = nil
		end
	end
	for _,result in pairs(io_handler.results or {}) do
		if result.name == old_name then
			result.name = new_name
			result.type = new_io_type
			adamo.debug(result.name..": "..result.amount)
			result.amount = math.floor(
				(result.amount or result[2] or 1)*mult
			)
			if new_io_type == "fluid" then
				result.amount = 
					result.amount
					*(result.probability or 1)
				result.probability = nil
			end
			result[2] = nil
			new_amount = result.amount
			adamo.debug("Replaced in table by name. Count: "..new_amount)
		end
		if result[1] == old_name then
			result.name = new_name
			result.amount = math.floor(
				(result[2] or result.amount or 1)*mult
			)
			result.type = new_io_type
				if new_io_type == "fluid" then
					result.amount = 
						result.amount
						*(result.probability or 1)
					result.probability = nil
				end
			result[1] = nil
			result[2] = nil
			new_amount = result.amount
			adamo.debug("Replaced in table by index. Count: "..new_amount)
		end
		if result.name == nil
		and result[1] == nil then
			result = nil
		end
	end
	if io_handler.main_product == old_name then
		adamo.debug("Replaced main product.")
		io_handler.main_product = new_name
	end	
	if io_handler.name then
		adamo.debug(
			'Replaced '..(io_handler.name)..' IO: '
			..old_name..' --> '..new_name..' ['..new_io_type..']'
			.." x"..mult.." => {"..new_amount..", "..new_normal..", "..new_expensive.."}"
		)
	end
	return new_amount
end

remove_ingredient = function(recipe,ingred_name)
	local recipe = recipe_or_bust(recipe)
	local ingred_name = 
		string_name_or_bust(ingred_name,count,prob)
	local found_and_removed = false
	if not recipe or not ingred_name
	then return found_and_removed end
	if recipe.expensive then
		for _,ingredient
		in pairs(recipe.expensive.ingredients or {})
		do
			if ingredient.name == ingred_name
			or ingredient[1] == ingred_name then
				recipe.expensive.ingredients[_] = nil
				found_and_removed = true
			end
		end
	end
	if recipe.normal then
		for _,ingredient
		in pairs(recipe.normal.ingredients or {})
		do
			if ingredient.name == ingred_name
			or ingredient[1] == ingred_name then
				recipe.normal.ingredients[_] = nil
				found_and_removed = true
			end
		end
	end
	for _,ingredient
	in pairs(recipe.ingredients or {})
	do
		if ingredient.name == ingred_name
		or ingredient[1] == ingred_name then
			recipe.ingredients[_] = nil
			found_and_removed = true
		end
	end
	return found_and_removed
end

blend_io_if_match = function(io_base,io_counter)
	local io_base = io_prototype_or_bust(io_base)
	local io_counter = io_prototype_or_bust(io_counter)
	if not io_counter or not io_base then return end
	local found_match = false
	if io_base.name == io_counter.name
	and ( io_base.type == io_counter.type
		or (
			io_base.type == "item"
			or io_counter.type == "item"
			)
	) then
		found_match = true
		if io_base.probability or io_counter.probability then
			io_base.probability =
				(
					(io_base.probability or 1)
					*io_base.amount
					+
					(io_counter.probability or 1)
					*io_counter.amount
				)
				/(io_base.amount + io_counter.amount)
			if io_base.probability == 1 then
				io_base.probability = nil
			end
		end
		io_base.amount = io_base.amount + io_counter.amount
	end
	adamo.debug(
		"Blended: "
		..tostring(io_base.name).."["
		..tostring(io_base.amount)..", "
		..tostring(io_base.probability).."] <-> ["
		..tostring(io_counter.name).."["
		..tostring(io_counter.amount)..", "
		..tostring(io_counter.probability).."]"
		)
	return found_match
end

add_ingredient = function(recipe,ingred,count,prob,catalyst_amount)
	if type(count) == "number" and count == 0 then
		return nil
	end
	if type(prob) == "number" and count == 0 then
		return nil
	end
	local recipe = recipe_or_bust(recipe)
	local ingred = io_prototype_or_bust(ingred,count,prob,catalyst_amount)
	if type(prob) ~= "number" then prob = nil end
	if not recipe or not ingred then return nil end
	if uses_ingredient(recipe,ingred.name) then
		if recipe.expensive then
			for _,ingredient
			in pairs(recipe.expensive.ingredients or {})
			do
				blend_io_if_match(ingredient,ingred)
			end
		end
		if recipe.normal then
			for _,ingredient
			in pairs(recipe.normal.ingredients or {})
			do
				blend_io_if_match(ingredient,ingred)
			end
		end
		for _,ingredient
		in pairs(recipe.ingredients or {})
		do
			blend_io_if_match(ingredient,ingred)
		end
	else
		if recipe.expensive then
			local exp_ingred = util.table.deepcopy(ingred)
			if not recipe.expensive.ingredients then
				recipe.expensive.ingredients = {}
			end
			table.insert(recipe.expensive.ingredients,exp_ingred)
		end
		if recipe.normal then
			if not recipe.normal.ingredients then
				recipe.normal.ingredients = {}
			end
			table.insert(recipe.normal.ingredients,ingred)
		end
		if recipe.ingredients then
			table.insert(recipe.ingredients,ingred)
		elseif not recipe.normal and not recipe.expensive
		then
			recipe.ingredients = {}
			table.insert(recipe.ingredients,ingred)
		end
	end
end

add_result = function(recipe,product,count,prob)
	if type(count) == "number" and count == 0 then
		return nil
	end
	if type(prob) == "number" and count == 0 then
		return nil
	end
	local recipe = recipe_or_bust(recipe)
	local product = io_prototype_or_bust(product,count,prob)
	if not recipe or not product then return nil end
	if type(count) ~= "number" then count = nil end
	if type(prob) ~= "number" then prob = nil end
	format_results(recipe)
	if uses_result(recipe,product) then
		if recipe.expensive then
			for _,result
			in pairs(recipe.expensive.results
			or {recipe.expensive.result}
			) do
				blend_io_if_match(result,product)
			end
		end
		if recipe.normal then
			for _,result
			in pairs(recipe.normal.results
			or {recipe.normal.result}
			) do
				blend_io_if_match(result,product)
			end
		end		
		for _,result
		in pairs(recipe.results
		or {recipe.result}
		) do
			blend_io_if_match(result,product)
		end
	else
		if recipe.expensive then
			local exp_product = util.table.deepcopy(product)
			exp_product.amount = (exp_product.amount or 1)*2
			table.insert(recipe.expensive.results,exp_product)
		end
		if recipe.normal then
			table.insert(recipe.normal.results,product)
		end
		if recipe.results then
			table.insert(recipe.results,product)
		elseif not recipe.normal and not recipe.expensive
		then
			recipe.results = {}
			table.insert(recipe.results,product)
		end
	end
end

move_result_to_main_product = function(recipe)
	local recipe = recipe_or_bust(recipe)
	if not recipe then return false end
	if recipe.expensive then
		if not recipe.expensive.results
		or type(recipe.expensive.results) ~= "table"
		then
			if recipe.expensive.result then
				recipe.expensive.results = {{
						type = "item",
						name = recipe.expensive.result,
						amount =
							recipe.expensive.result_count
							or 1
				}}
				if not recipe.expensive.main_product then
					recipe.expensive.main_product =
						recipe.expensive.result
				end
				recipe.expensive.result = nil
				recipe.expensive.result_count = nil
			end
		elseif recipe.expensive.result then
			if not recipe.expensive.main_product then
				recipe.expensive.main_product =
					recipe.expensive.result
			end
			table.insert(
				results,
				{
					type = "item",
					name = recipe.expensive.result,
					amount =
						(recipe.expensive.result_count
						or 1)
				}
			)
			recipe.expensive.result = nil
			recipe.expensive.result_count = nil
		end	
	end
	if recipe.normal then
		if not recipe.normal.results
		or type(recipe.normal.results) ~= "table"
		then
			if recipe.normal.result then
				recipe.normal.results = {{
						type = "item",
						name = recipe.normal.result,
						amount =
							recipe.normal.result_count
							or 1
				}}
				if not recipe.normal.main_product then
					recipe.normal.main_product =
						recipe.normal.result
				end
				recipe.normal.result = nil
				recipe.normal.result_count = nil
			end
		elseif recipe.normal.result then
			if not recipe.normal.main_product then
				recipe.normal.main_product =
					recipe.normal.result
			end
			table.insert(
				results,
				{
					type = "item",
					name = recipe.normal.result,
					amount =
						(recipe.normal.result_count
						or 1)
				}
			)
			recipe.normal.result = nil
			recipe.normal.result_count = nil
		end
	end
	if not recipe.results
	or type(recipe.results) ~= "table"
	then
		if recipe.result then
			recipe.results = {{
					type = "item",
					name = recipe.result,
					amount =
						recipe.result_count
						or 1
			}}
			if not recipe.main_product then
				recipe.main_product =
					recipe.result
			end
			recipe.result = nil
			recipe.result_count = nil
		end
	elseif recipe.result then
		if not recipe.main_product then
			recipe.main_product =
				recipe.result
		end
		table.insert(
			results,
			{
				type = "item",
				name = recipe.result,
				amount =
					(recipe.result_count
					or 1)
			}
		)
		recipe.result = nil
		recipe.result_count = nil
	end
end

format_results = function(recipe)
	local recipe = recipe_or_bust(recipe)
	if not recipe then return false end
	move_result_to_main_product(recipe)
	-- needs to reformat the results table, yet.
end

format_ingredients = function(recipe)
	local recipe = recipe_or_bust(recipe)
	if not recipe then return false end
	if recipe.normal
	and type(recipe.normal) == "table" then
		for _,ingredient
		in pairs(recipe.normal.ingredients or {}) do
			if ingredient[1] then 
				ingredient.name = ingredient[1]
				ingredient[1] = nil
			end
			if ingredient[2] then
				ingredient.amount = ingredient[2]
				ingredient[2] = nil
			end
			if ingredient.name
			and not ingredient.type then
				ingredient.type = "item"
			end
		end
	end
	if recipe.expensive
	and type(recipe.expensive) == "table" then
		for _,ingredient
		in pairs(recipe.expensive.ingredients or {}) do
			if ingredient[1] then 
				ingredient.name = ingredient[1]
				ingredient[1] = nil
			end
			if ingredient[2] then
				ingredient.amount = ingredient[2]
				ingredient[2] = nil
			end
			if ingredient.name
			and not ingredient.type then
				ingredient.type = "item"
			end
		end
	end
	for _,ingredient
	in pairs(recipe.ingredients or {}) do
		if ingredient[1] then 
			ingredient.name = ingredient[1]
			ingredient[1] = nil
		end
		if ingredient[2] then
			ingredient.amount = ingredient[2]
			ingredient[2] = nil
		end
		if ingredient.name
		and not ingredient.type then
			ingredient.type = "item"
		end
	end
	return true
end

set_main_product = function(recipe,name)
	local recipe = recipe_or_bust(recipe)
	local name = string_name_or_bust(name)
	if not recipe or not name then return false end
	if not uses_result(recipe,name) then return false end
	if recipe.normal then
		recipe.normal.main_product = name
	end
	if recipe.expensive then
		recipe.expensive.main_product = name
	end
	if recipe.results or recipe.result then
		recipe.main_product = name
	end
end

get_main_result = function(recipe)
	local recipe = recipe_or_bust(recipe)
	if not recipe then return nil,0,0,0 end
	local result_name = nil
	local result_count = nil
	local expensive_result_count = 0
	local normal_result_count = 0
	if recipe.expensive then
		if recipe.expensive.results then
			for _,result
			in pairs(recipe.expensive.results) do
				if result_name == nil then
					result_name = result.name or result[1]
				end
				if (result.name == result_name)
				or (result[1] == result_name) then
					expensive_result_count =
						result.amount
						or result[2]
				end
			end
		elseif recipe.expensive.result then
			if result_name == nil then
				result_name = recipe.expensive.result
			end
			expensive_result_count =
				recipe.expensive.result_count or 1
		end
	end
	if recipe.normal then
		if recipe.normal.results then
			for _,result
			in pairs(recipe.normal.results) do
				if result_name == nil then
					result_name = result.name or result[1]
				end
				if (result.name == result_name)
				or (result[1] == result_name) then
					normal_result_count =
						result.amount
						or result[2]
				end
			end
		elseif recipe.normal.result then
			if result_name == nil then
				result_name = recipe.normal.result
			end
			normal_result_count =
				recipe.normal.result_count or 1
		end
	end
	if recipe.results then
		for _,result
		in pairs(recipe.results) do
			if result_name == nil then
				result_name = result.name or result[1]
			end
			if (result.name == result_name)
			or (result[1] == result_name) then
				result_count =
					result.amount
					or result[2]
			end
		end
	elseif recipe.result then
		result_count = recipe.result_count or 1
		result_name = recipe.result
	end
	if result_count == nil then
		result_count =
			normal_result_count
			or expensive_result_count
			or 0
	end
	return result_name,result_count,expensive_result_count
end

has_ingredients = function(recipe)
	local recipe = recipe_or_bust(recipe)
	if recipe then
		if recipe.normal then
			if recipe.normal.ingredients then
				for _,ingredient
				in pairs(recipe.normal.ingredients) do
					if ingredient.amount
					and ingredient.amount > 0 then
						return true
					end
					if ingredient[2]
					and ingredient[2] > 0 then
						return true
					end
				end
			end
		end
		if recipe.ingredients then
			for _,ingredient in pairs(recipe.ingredients) do
				if ingredient.amount
				and ingredient.amount > 0 then
					return true
				end
				if ingredient[2]
				and ingredient[2] > 0 then
					return true
				end
			end
		end
	end
	return false
end

has_results = function(recipe)
	local recipe = recipe_or_bust(recipe)
	if not recipe then return false end
	if recipe.expensive then
		if recipe.expensive.results then
			for _,result
			in pairs(recipe.expensive.results) do
				if result.amount
				and result.amount > 0 then
					return true
				end
				if result[2]
				and result[2] > 0 then
					return true
				end
			end
		end
		if recipe.normal.result then return true end
	end
	if recipe.normal then
		if recipe.normal.results then
			for _,result
			in pairs(recipe.normal.results) do
				if result.amount
				and result.amount > 0 then
					return true
				end
				if result[2]
				and result[2] > 0 then
					return true
				end
			end
		end
		if recipe.normal.result then return true end
	end
	if recipe.results then
		for _,result in pairs(recipe.results) do
			if result.amount
			and result.amount > 0 then
				return true
			end
			if result[2]
			and result[2] > 0 then
				return true
			end
		end
	end
	if recipe.result then return true end
	return false
end

get_io_names = function(recipe)
	local recipe = recipe_or_bust(recipe)
	if not recipe or recipe.type ~= "recipe" then
		return {}
	end
	local ingredients = {}
	local results = {}
	if recipe.expensive then
		add_strings_to_list(
			ingredients,
			get_table_names(recipe.expensive.ingredients)
		)
		add_strings_to_list(
			results,
			get_table_names(recipe.expensive.results)
		)
		add_string_to_list(
			results,
			recipe.expensive.result
		)
	end
	if recipe.normal then
		add_strings_to_list(
			ingredients,
			get_table_names(recipe.normal.ingredients)
		)
		add_strings_to_list(
			results,
			get_table_names(recipe.normal.results)
		)
		add_string_to_list(
			results,
			recipe.normal.result
		)
	end
	add_strings_to_list(
		ingredients,
		get_table_names(recipe.ingredients)
	)
	add_strings_to_list(
		results,
		get_table_names(recipe.results)
	)
	add_string_to_list(
		results,
		recipe.result
	)
	return ingredients,results
end

recipe_uses = function(recipe,name)
	local name = string_name_or_bust(name)
	local recipe = recipe_or_bust(recipe)
	if not recipe or not name then return false end
	local ingredients,results = get_io_names(recipe)
	for _,ingredient_name in pairs(ingredients) do
		if ingredient_name == name then
			return true
		end
	end
	for _,result_name in pairs(results) do
		if (result_name) == name then
			return true
		end
	end
	return false
end

uses_ingredient = function(recipe,name)
	local name = string_name_or_bust(name)
	local recipe = recipe_or_bust(recipe)
	if not recipe or not name then return false end
	local ingredients,results = get_io_names(recipe)
	for _,ingredient_name in pairs(ingredients) do
		if ingredient_name == name then
			return true
		end
	end
	return false
end

uses_result = function(recipe,name)
	local name = string_name_or_bust(name)
	local recipe = recipe_or_bust(recipe)
	if not recipe or not name then return false end
	local ingredients,results = get_io_names(recipe)
	for _,result_name in pairs(results) do
		if (result_name) == name then
			return true
		end
	end
	return false
end

get_io_type = function(prototype)
	if type(prototype) == "table" then
		local io_type = get_table_type(prototype)
		if io_type == "item" then
			return "item"
		elseif io_type == "fluid" then
			return "fluid"
		end
	end
	if type(prototype) == "string" then
		if data.raw.item[prototype] then
			return "item"
		elseif data.raw.fluid[prototype] then
			return "fluid"
		end
	end
	return nil
end

get_table_type = function(prototype)
	if type(prototype) == "table" then
		return prototype.type
	end
	return nil
end

get_table_names = function(prototable)
	local names = {}
	local prototable = table_or_bust(prototable)
	if not prototable then return end
	for _,prototype in pairs(prototable) do
		prototype = table_or_bust(prototype)
		if prototype then
			if prototype.name
			and type(prototype.name) == "string" then
				table.insert(
					names,
					prototype.name
				)
			elseif prototype[1]
			and type(prototype[1]) == "string" then
				table.insert(
					names,
					prototype[1]
				)
			end
		end
	end
	return names
end

get_ingredient = function(recipe,index)
	local recipe = recipe_or_bust(recipe)
	if type(recipe) ~= "table" then return end
	local ingredient_name = index
	local ingredient_amount = 0
	local expensive_amount = 0
	if not has_ingredients(recipe) then return nil,0,0 end
	if recipe.normal
	and type(recipe.normal.ingredients) == "table" then
		if type(ingredient_name) == "string" then
			for _,ingredient
			in pairs(recipe.normal.ingredients) do
				if (ingredient.name == ingredient_name)
				or (ingredient[1] == ingredient_name)
				then
					ingredient_amount = 
						ingredient.amount
						or ingredient[2]
				end
			end
			if ingredient_amount == 0 then
				return nil,0,0
			end
			if recipe.expensive then
				for _,ingredient
				in pairs(recipe.expensive.ingredients or {}) do
					if (ingredient.name == ingredient_name)
					or (ingredient[1] == ingredient_name)
					then
						expensive_amount = 
							ingredient.amount
							or ingredient[2]
					end
				end
			end
		else
			if type(
				recipe.normal.ingredients[ingredient_name]
			) == "table" then
				ingredient_amount =
					recipe.normal
					.ingredients[ingredient_name].amount
					or recipe.normal
					.ingredients[ingredient_name][2]
				ingredient_name =
					recipe.normal
					.ingredients[ingredient_name].name
					or recipe.normal
					.ingredients[ingredient_name][1]
				if recipe.expensive then
					for _,ingredient
					in pairs(recipe.expensive.ingredients) do
						if (
							ingredient.name
							== ingredient_name
						) or (
							ingredient[1]
							== ingredient_name
						) then
							expensive_amount = 
								ingredient.amount
								or ingredient[2]
						end
					end
				end
			else
				return nil,0,0
			end
		end
	else
		if type(ingredient_name) == "string" then
			for _,ingredient
			in pairs(recipe.ingredients or {}) do
				if (ingredient.name == ingredient_name)
				or (ingredient[1] == ingredient_name)
				then
					ingredient_amount = 
						ingredient.amount
						or ingredient[2]
				end
			end
			if ingredient_amount == 0 then
				return nil,0,0
			end
		else
			if type(recipe.ingredients[ingredient_name])
			== "table" then
				ingredient_amount =
					recipe.ingredients[ingredient_name]
					.amount
					or recipe.ingredients[ingredient_name][2]
				ingredient_name =
					recipe.ingredients[ingredient_name].name
					or recipe.ingredients[ingredient_name][1]
			else
				return nil,0,0
			end
		end
	end
	return ingredient_name,ingredient_amount,expensive_amount
end

-- Might be broken
get_result = function(recipe,index)
	local recipe = recipe_or_bust(recipe)
	if not recipe then return end
	format_results(recipe)
	if not has_results(recipe) then return nil,0,0 end
	local result_name = index
	local result_amount = 0
	local expensive_amount = 0
	if recipe.normal 
	and type(recipe.normal.results) == "table" then
		if type(result_name) == "string" then
			for _,result in pairs(recipe.normal.results) do
				if (result.name == result_name)
				or (result[1] == result_name)
				then
					result_amount = 
						result.amount or result[2]
				end
			end
			if result_amount == 0 then
				return nil,0,0
			end
			if recipe.expensive then
				for _,result
				in pairs(recipe.expensive.results or {}) do
					if (result.name == result_name)
					or (result[1] == result_name)
					then
						expensive_amount = 
							result.amount
							or result[2]
					end
				end
			end
		else
			if type(
				recipe.normal.results[result_name]
			) == "table" then
				result_amount =
					recipe.normal
					.results[result_name].amount
					or recipe.normal
					.results[result_name][2]
				result_name =
					recipe.normal
					.results[result_name].name
					or recipe.normal
					.results[result_name][1]
				if recipe.expensive then
					for _,result
					in pairs(recipe.expensive.results) do
						if (
							result.name
							== result_name
						) or (
							result[1]
							== result_name
						) then
							expensive_amount = 
								result.amount
								or result[2]
						end
					end
				end
			else
				return nil,0,0
			end
		end
	else
		if type(result_name) == "string" then
			for _,result
			in pairs(recipe.results or {}) do
				if (result.name == result_name)
				or (result[1] == result_name)
				then
					result_amount = 
						result.amount
						or result[2]
				end
			end
			if result_amount == 0 then
				return nil,0,0
			end
		else
			if type(recipe.results[result_name])
			== "table" then
				result_amount =
					recipe.results[result_name]
					.amount
					or recipe.results[result_name][2]
				result_name =
					recipe.results[result_name].name
					or recipe.results[result_name][1]
			else
				return nil,0,0
			end
		end
	end
	return result_name,result_amount,expensive_amount

end

set_productivity_recipe = function(recipe_name)
	local recipe_name = string_name_or_bust(recipe_name)
	if not recipe_name then return end
	for k,v in pairs({
			data.raw.module["productivity-module"],
			data.raw.module["productivity-module-2"],
			data.raw.module["productivity-module-3"]
		}) do
  		if v.limitation then  
      		table.insert(v.limitation, recipe_name) 
		end
	end
end

set_productivity_recipes = function(recipe_names)
	for _,recipe_name in pairs(recipe_names or {}) do
		set_productivity_recipe(recipe_name)
	end
end

add_productivity_recipe = function(recipe_name)
	set_productivity_recipe(recipe_name)
end

add_productivity_recipes = function(recipe_names)
	set_productivity_recipes(recipe_names)
end

is_productivity_recipe = function(recipe_name)
	local recipe_name = string_name_or_bust(recipe_name)
	if not data.raw.recipe[recipe_name] then return false end
	for k,listed_recipe_name in pairs(
		data.raw.module["productivity-module"].limitation
	) do
		if listed_recipe_name == recipe_name then
			return true
		end
	end
	return false
end

find_unused_layer = function()
	local unused_layers = {
		"layer-11",
		"layer-12",
		"layer-13",
		"layer-14",
		"layer-15",
	}
	for i,data_type in pairs(data.raw) do
		for j,data_obj in pairs(data_type) do
			for k,layer
			in pairs(data_obj.collision_mask or {}) do
				for l,unused_layer in pairs(unused_layers) do
					if layer == unused_layer then
						unused_layers[l] = nil
					end
				end
			end
		end
	end
	for _,layer in pairs(unused_layers) do
		return layer
	end
	return nil
end

-- Not really checking if it's an entit,
-- but entity definitely has to have "order".
entity_or_bust = function(entity)
	local entity = table_or_bust(entity)
	return entity
end

get_collision_lengths = function(entity)
	local lengths = {0,0}
	if entity_or_bust(entity) then
		local colbox = entity.collision_box
		if type(colbox) == "table" then
			if type(colbox[1]) == "table" then
				if type(colbox[1][1]) == "number" then
						lengths[1]
						= lengths[1] - colbox[1][1]
				end
				if type(colbox[1][2]) == "number" then
						lengths[2]
						= lengths[2] - colbox[1][2]
				end
			end
			if type(colbox[2]) == "table" then
				if type(colbox[2][1]) == "number" then
						lengths[1]
						= lengths[1] + colbox[2][1]
				end
				if type(colbox[2][2]) == "number" then
						lengths[2]
						= lengths[2] + colbox[2][2]
				end
			end
		end
	end
	return lengths
end

get_collision_hypotenuse = function(entity)
	local len = get_collision_lengths(entity)
	return math.sqrt(len[1]*len[1] + len[2]*len[2])
end

get_collision_area = function(entity)
	local len = get_collision_lengths(entity)
	return len[1]*len[2]
end

set_pipe_distance = function(pipe, dist)
	if data.raw["pipe-to-ground"][pipe] then
		for _,connection in pairs(
			data.raw["pipe-to-ground"][pipe]
			.fluid_box.pipe_connections
		) do
			if connection.max_underground_distance then
				data.raw["pipe-to-ground"][pipe]
				.fluid_box.pipe_connections[_]
				.max_underground_distance = dist
			end
		end
	end
end

set_shift =  function(shift, tab)
	tab.shift = shift
	if tab.hr_version then
		tab.hr_version.shift = shift
	end
	return tab
end

-- probably doesn't work as written: could work
-- with sufficiently large empty image.
empty_animation = function(frames,speed)
	if type(frames) ~= "number" then
		frames = 1
	end
	if type(speed) ~= "number" then
		speed = 1
	end
	return {
		frame_count = frames,
		speed = speed,
		type = "forward-then-backward",
		filename = "__core__/graphics/empty.png",
		priority = "extra-high",
		line_length = 1/math.sqrt(frames),
		width = 1,
		height = 1
	}
end

empty_sprite = function()
	return {
		filename = "__core__/graphics/empty.png",
		priority = "extra-high",
		width = 1,
		height = 1,
		hr_version = {
			filename = "__core__/graphics/empty.png",
			priority = "extra-high",
			width = 1,
			height = 1,
		}
	}
end

emptysprite = function()
	return empty_sprite()
end

centrifuge_idle_layers = function(size,speed)
	local size = number_or_one(size)
	local speed = number_or_one(speed)
	return {{
			filename = 
				"__base__/graphics/entity/"
				.."centrifuge/centrifuge-C.png",
			priority = "extra-high",
			line_length = 8,
			width = 119,
			height = 107,
			scale = size,
			frame_count = 64,
			animation_speed = speed,
			shift =
				util.by_pixel(
					-0.5,
					-26.5
				),
			hr_version = {
				filename = 
					"__base__/graphics/entity/"
					.."centrifuge/hr-centrifuge-C.png",
				priority = "extra-high",
				scale = size*0.5,
				line_length = 8,
				width = 237,
				height = 214,
				frame_count = 64,
				animation_speed = speed,
				shift =
					util.by_pixel(
						-0.25,
						-26.5
					)
			}
		},{
			filename = 
				"__base__/graphics/entity/"
				.."centrifuge/centrifuge-C-shadow.png",
			draw_as_shadow = true,
			priority = "extra-high",
			line_length = 8,
			width = 132,
			height = 74,
			frame_count = 64,
			scale = size,
			animation_speed = speed,
			shift =
				util.by_pixel(
					20,
					-10
				),
			hr_version = {
				filename = 
					"__base__/graphics/entity/"
					.."centrifuge/hr-centrifuge-C-shadow.png",
				draw_as_shadow = true,
				priority = "extra-high",
				scale = size*0.5,
				line_length = 8,
				width = 279,
				height = 152,
				frame_count = 64,
				animation_speed = speed,
				shift =
					util.by_pixel(
						16.75,
						-10
					)
			}
		},{
			filename = 
				"__base__/graphics/entity/"
				.."centrifuge/centrifuge-B.png",
			priority = "extra-high",
			line_length = 8,
			width = 78,
			height = 117,
			scale = size,
			frame_count = 64,
			animation_speed = speed,
			shift =
				util.by_pixel(
					23,
					6.5
				),
			hr_version = {
				filename = 
					"__base__/graphics/entity/"
					.."centrifuge/hr-centrifuge-B.png",
				priority = "extra-high",
				scale = size*0.5,
				line_length = 8,
				width = 156,
				height = 234,
				frame_count = 64,
				animation_speed = speed,
				shift =
					util.by_pixel(
						23,
						6.5
					)
			}
		},{
			filename = 
				"__base__/graphics/entity/"
				.."centrifuge/centrifuge-B-shadow.png",
			draw_as_shadow = true,
			priority = "extra-high",
			line_length = 8,
			width = 124,
			height = 74,
			frame_count = 64,
			scale = size,
			animation_speed = speed,
			shift =
				util.by_pixel(
					63,
					16
				),
			hr_version = {
				filename = 
					"__base__/graphics/entity/"
					.."centrifuge/hr-centrifuge-B-shadow.png",
				draw_as_shadow = true,
				priority = "extra-high",
				scale = size*0.5,
				line_length = 8,
				width = 251,
				height = 149,
				frame_count = 64,
				animation_speed = speed,
				shift =
					util.by_pixel(
						63.25,
						15.25
					)
			}
		},{
			filename = 
				"__base__/graphics/entity/"
				.."centrifuge/centrifuge-A.png",
			priority = "extra-high",
			line_length = 8,
			width = 70,
			height = 123,
			scale = size,
			frame_count = 64,
			animation_speed = speed,
			shift =
				util.by_pixel(
					-26,
					3.5
				),
			hr_version = {
				filename = 
					"__base__/graphics/entity/"
					.."centrifuge/hr-centrifuge-A.png",
				priority = "extra-high",
				scale = size*0.5,
				line_length = 8,
				width = 139,
				height = 246,
				frame_count = 64,
				animation_speed = speed,
				shift =
					util.by_pixel(
						-26.25,
						3.5
					)
			}
		},{
			filename = 
				"__base__/graphics/entity/"
				.."centrifuge/centrifuge-A-shadow.png",
			priority = "extra-high",
			draw_as_shadow = true,
			line_length = 8,
			width = 108,
			height = 54,
			frame_count = 64,
			scale = size,
			animation_speed = speed,
			shift =
				util.by_pixel(
					6,
					27
				),
			hr_version = {
				filename = 
					"__base__/graphics/entity/"
					.."centrifuge/hr-centrifuge-A-shadow.png",
				priority = "extra-high",
				draw_as_shadow = true,
				scale = size*0.5,
				line_length = 8,
				width = 230,
				height = 124,
				frame_count = 64,
				animation_speed = speed,
				shift =
					util.by_pixel(
						8.5,
						23.5
					)
			}
	}}
end

bulkypipepictures = function()
	local pipe_sprites = pipepictures()
	return {
  		north = set_shift(
  			{0, 1},
  			util.table
  			.deepcopy(pipe_sprites.straight_vertical)
		),
		south = empty_sprite(),
  		east = set_shift(
  			{-1, 0},
  			util.table
  			.deepcopy(pipe_sprites.straight_horizontal)
		),
  		west = set_shift(
  			{1, 0},
  			util.table
  			.deepcopy(pipe_sprites.straight_horizontal)
		)
	}
end

chem_assembling_machine_fluid_boxes = function()
	return {{
			production_type = "input",
			pipe_picture = assembler3pipepictures(),
			pipe_covers = pipecoverspictures(),
			base_area = 1,
			base_level = -1,
			height = 2,
			pipe_connections = {{ type="input-output", position = {0, -2} }},
			secondary_draw_orders = { north = -1 }
		},{
			production_type = "input",
			pipe_picture = assembler3pipepictures(),
			pipe_covers = pipecoverspictures(),
			base_area = 1,
			base_level = -1,
			height = 2,
			pipe_connections = {{ type="input-output", position = {2, 0} }},
			secondary_draw_orders = { north = -1 }
		},{
			production_type = "output",
			pipe_picture = assembler3pipepictures(),
			pipe_covers = pipecoverspictures(),
			base_area = 1,
			base_level = 1,
			pipe_connections = {{ type="output", position = {-2, 0} }},
			secondary_draw_orders = { north = -1 }
		},{
			production_type = "input",
			pipe_picture = assembler3pipepictures(),
			pipe_covers = pipecoverspictures(),
			base_area = 1,
			base_level = -1,
			height = 2,
			pipe_connections = {{ type="input-output", position = {0, 2} }},
			secondary_draw_orders = { north = -1 }
		},
		off_when_no_fluid_recipe = true
	}
end

centrifuge_fluid_boxes = function()
	return {{
			production_type = "input",
			base_area = 1,
			base_level = -1,
			pipe_picture = assembler3pipepictures(),
			pipe_covers = pipecoverspictures(),
			pipe_connections = {{
					position = {
						0,
						2
					},
			}},
			secondary_draw_orders = {
				north = -32,
				west = -32,
				east = -32,
				south = 4
			}
		},{
			production_type = "output",
			base_area = 1,
			base_level = 1,
			pipe_picture = assembler3pipepictures(),
			pipe_covers = pipecoverspictures(),
			pipe_connections = {{
					position = {
						-2,
						0
					},
			}},
			secondary_draw_orders = {
				north = -32,
				west = -32,
				east = -32,
				south = 4
			}
		},{
			production_type = "output",
			base_area = 1,
			base_level = 1,
			pipe_picture = assembler3pipepictures(),
			pipe_covers = pipecoverspictures(),
			pipe_connections = {{
					position = {
						0,
						-2
					},
			}},
			secondary_draw_orders = {
				north = -32,
				west = -32,
				east = -32,
				south = 4
			}
		},{
			production_type = "output",
			base_area = 1,
			base_level = 1,
			pipe_picture = assembler3pipepictures(),
			pipe_covers = pipecoverspictures(),
			pipe_connections = {{
					position = {
						2,
						0
					},
			}},
			secondary_draw_orders = {
				north = -32,
				west = -32,
				east = -32,
				south = 4
			},
		},
		off_when_no_fluid_recipe = true
	}
end

trivial_smoke = function(opts)
	return {
		type = "trivial-smoke",
		name = opts.name,
		duration = opts.duration or 600,
		fade_in_duration = opts.fade_in_duration or 0,
		fade_away_duration =
			opts.fade_away_duration
			or (
				(opts.duration or 600) - (opts.fade_in_duration or 0)
			),
		spread_duration = opts.spread_duration or 600,
		start_scale = opts.start_scale or 0.20,
		end_scale = opts.end_scale or 1.0,
		color = opts.color,
		cyclic = true,
		affected_by_wind = opts.affected_by_wind or true,
		animation = {
			width = 152,
			height = 120,
			line_length = 5,
			frame_count = 60,
			shift = {-0.53125, -0.4375},
			priority = "high",
			animation_speed = 0.25,
			filename = "__base__/graphics/entity/smoke/smoke.png",
			flags = { "smoke" }
		}
	}
end


apply_vanilla_fluid_fuel_stats = function()
	local solid_fuel =
		item_or_bust(data.raw.item["solid-fuel"])
	if not solid_fuel then return false end
	local solid_fuel_value = get_fuel_value(solid_fuel)
	apply_fluid_fuel_stat(
		"light-oil",
		energy_div(
			solid_fuel_value,
			fuelfactors["light-oil"]
		)
	)
	apply_fluid_fuel_stat(
		"heavy-oil",
		energy_div(
			solid_fuel_value,
			fuelfactors["heavy-oil"]
		)
	)
	apply_fluid_fuel_stat(
		"petroleum-gas",
		energy_div(
			solid_fuel_value,
			fuelfactors["petroleum-gas"]
		)
	)
	apply_fluid_fuel_stat(
		"crude-oil",
		energy_div(
			solid_fuel_value,
			fuelfactors["crude-oil"]
		)
	)
end

apply_fluid_fuel_stat = function(fluid,fuel_value,fuel_type)
	local fluid = fluid_or_bust(fluid)
	local fuel_value = string_or_bust(fuel_value)
	if not fluid or not fuel_value then return nil end
	local fuel_type = string_or_bust(fuel_type)
	fluid.fuel_category = fuel_type
	fluid.fuel_value = fuel_value
	return fluid
end

apply_sulfur_fuel_stats = function(sulfur)
	if type(sulfur) ~= "table"
	or sulfur.type ~= "item"
	then
		log("invalid sulfur item received")
		return nil
	end
	local sulfur_fueltype = "sulfur"
	sulfur.fuel_category = sulfur_fueltype
	sulfur.fuel_emissions_multiplier = 12
	sulfur.fuel_value = fuelvalues.sulfur
	sulfur.fuel_acceleration_multiplier = 0.4
	sulfur.fuel_glow_color = {r = 1, g = 0.2, b = 1}
	add_fueltype_to_basic_burners(sulfur_fueltype)
	return sulfur
end

add_fueltype_to_basic_burners = function(fueltype)
	if not data.raw["fuel-category"][fueltype] then
		data:extend({
			{type="fuel-category",name=fueltype}
		})
	end
	add_fuel_type(data.raw.boiler.boiler,fueltype)
	for _,ent in pairs(data.raw.car) do
		if table_incl("chemical",get_fuel_types(ent))
		then
			add_fuel_type(ent,fueltype)
		end
	end
	add_fuel_type(data.raw.furnace["stone-furnace"],fueltype)
	add_fuel_type(data.raw.furnace["steel-furnace"],fueltype)
	for _,ent in pairs(data.raw.reactor) do
		if table_incl("chemical",get_fuel_types(ent))
		then
			add_fuel_type(ent,fueltype)
		end
	end
	for _,ent in pairs(data.raw.lamp) do
		if table_incl("chemical",get_fuel_types(ent))
		then
			add_fuel_type(ent,fueltype)
		end
	end
end

add_fuel_type = function(entity,fuel_type)
	entity = table_or_bust(entity)
	fuel_type = string_or_bust(fuel_type)
	if not entity or not fuel_type then return false end
	local energy_source = get_energy_source(entity)
	if not energy_source then return false end
	if is_burner(energy_source) then
		if not energy_source.fuel_categories then
			if energy_source.fuel_category then
				energy_source
				.fuel_categories = {energy_source.fuel_category}
			else
				energy_source.fuel_categories = {"chemical"}
			end
			energy_source.fuel_category = nil
		end
		add_string_to_list(
			energy_source.fuel_categories,
			fuel_type
		)
	end
end

get_fuel_value = function(prototype)
	local prototype = table_or_bust(prototype)
	local fuel_value = "0kW"
	if not prototype then return fuel_value end
	if prototype.type == "fluid"
	or prototype.type == "item" then
		fuel_value = prototype.fuel_value
	end
	if type(fuel_value) ~= "string" then return "0kW" end
	return fuel_value
end

get_fuel_types = function(entity)
	entity = table_or_bust(entity)
	if not entity then return {} end
	local energy_source = get_energy_source(entity)
	if not energy_source then return {} end
	if is_burner(energy_source) then
		if energy_source.fuel_categories then
			return energy_source.fuel_categories
		end
		if energy_source.fuel_category then
			return {energy_source.fuel_category}
		end
		return ({"chemical"})
	end
	return {}
end

uses_fuel_type = function(name,entity)
	local name = string_name_or_bust(name)
	local entity = table_or_bust(entity)
	if entity and name
	and table_incl(name,get_fuel_types(entity)) then
		return true
	end
	return false
end

is_burner = function(energy_source)
	energy_source = table_or_bust(energy_source)
	if not energy_source then return false end
	if energy_source.type == "burner"
	or not energy_source.type then
		return true
	end
	return false
end

get_energy_source = function(entity)
	entity = entity_or_bust(entity)
	if not entity then return nil end
	if entity.burner then
		return entity.burner
	else
		return entity.energy_source
	end
end

number_or_bust = function(number)
	if type(number) ~= "number" then
		return nil
	end
	return number
end

number_or_one = function(number)
	if type(number) ~= "number" then
		number = 1
	end
	return number
end

number_or_zero = function(number)
	if type(number) ~= "number" then
		number = 0
	end
	return number
end

table_or_bust = function(prototype)
	if type(prototype) == "table" then
		return prototype
	end
	return nil
end

string_or_bust = function(str)
	if type(str) == "string" then
		return str
	end
	return nil
end

fluid_or_bust = function(prototype)
	if type(prototype) == "table"
	and prototype.type == "fluid" then
		return prototype
	end
	if type(prototype) == "string" then
		return fluid_or_bust(data.raw.fluid[prototype])
	end
	return nil
end

item_or_bust = function(prototype)
	if type(prototype) == "table" then
		for _,type in pairs(adamo.item.types) do
			if prototype.type == type then
				return prototype
			end
		end
	end
	if type(prototype) == "string" then
		local item = adamo.get.from_types(adamo.item.types,prototype)
		if item then return item end
	end
	return nil
end

all_prototypes_with_value = function(type_tbl,key,val)
	local type_tbl = prototype_table_or_bust(type_tbl)
	if not type_tbl then return {} end
	local prototypes = {}
	for _,prototype in pairs(type_tbl) do
		if prototype and type(prototype) == "table"
		and prototype[key] == val then
			table.insert(prototypes,prototype)
		end
	end
	return prototypes
end

prototype_table_or_bust = function(prototype_tbl)
	if type(prototype_tbl) == "string" then
		return data.raw[prototype_tbl]
	else
		return table_or_bust(prototype_tbl)
	end
end

io_prototype_or_bust = function(prototype,count,prob,catalyst_amount)
	if type(prototype) == "table" then
		if type(prototype.name) == "string"
		and type(prototype.type) == "string"
		and type(prototype.amount) == "number" then
			return prototype
		end
	end
	local new_prototype = construct_io_prototype(
		prototype,count,prob,catalyst_amount
	)
	if type(new_prototype.name) == "string"
	and type(new_prototype.type) == "string"
	and type(new_prototype.amount) == "number" then
		prototype = new_prototype
		return prototype
	end
	return nil
end

construct_io_prototype = function(
	prototype,count,prob,catalyst_amount
)
	local new_prototype = {}
	if type(prob) == "number" then
		if prob < 0 or prob > 1 then prob = nil end
	end
	if type(count) == "number" then
		if count < 0 then count = nil
		elseif count < 1 then
			prob = (prob or 1)*count
			count = 1
		end
	end
	if type(count) ~= "number" then count = nil end
	if type(prob) ~= "number" then prob = nil end 
	if type(prototype) == "table" then
		new_prototype.name = prototype.name or prototype[1]
		new_prototype.type = prototype.type or "item"
		new_prototype.amount = 
			count or prototype.amount 
			or prototype[2] or 1
		new_prototype.catalyst_amount =
			catalyst_amount
			or prototype.catalyst_amount
		new_prototype.probability =
			prob or prototype.probability
	end
	if type(prototype) == "string" then
		if data.raw.fluid[prototype] then
			new_prototype.name = prototype
			new_prototype.type = "fluid"
			new_prototype.amount = count or 1
			if data.raw.item[prototype] then
				new_prototype.type = "item"
				new_prototype.catalyst_amount =
					catalyst_amount
					or prototype.catalyst_amount
				new_prototype.probability = prob
			end
		else
			new_prototype.name = prototype
			new_prototype.type = "item"
			new_prototype.amount = count or 1
			new_prototype.catalyst_amount =
				catalyst_amount
				or prototype.catalyst_amount
			new_prototype.probability = prob
		end
	end
	if new_prototype.type == "item" then
		if new_prototype.amount < 0 then
		elseif new_prototype.amount < 1 then
			new_prototype.probability =
				(new_prototype.probability or 1)
				*new_prototype.amount
			new_prototype.amount = 1
		end
	elseif new_prototype.type == "fluid" and prob then
		new_prototype.amount = new_prototype.amount*prob
	end
	adamo.debug(
		"Constructed IO Prototype: "
		..new_prototype.name..": "..new_prototype.amount
	)
	return new_prototype
end

tech_or_bust = function(prototype)
	if type(prototype) == "table"
	and prototype.type == "technology" then
		return prototype
	end
	if type(prototype) == "string" then
		return data.raw.technology[prototype]
	end
	return nil
end

recipe_or_bust = function(prototype)
	if type(prototype) == "table"
	and prototype.type == "recipe" then
		return prototype
	end
	if type(prototype) == "string" then
		return data.raw.recipe[prototype]
	end
	return nil
end

io_handler_or_bust = function(io_handler)
	local recipe = recipe_or_bust(io_handler)
	if recipe then return recipe end
	if type(io_handler) == "table" then
		if type(io_handler.result) == "string"
		or type(io_handler.results) == "table"
		or type(io_handler.ingredients) == "table" then
			return io_handler
		end
	end
	return nil
end

string_name_or_bust = function(prototype_name)
	if type(prototype_name) == "string" then
		return prototype_name
	end
	if type(prototype_name) == "table" then
		return prototype_name.name
	end
	return nil
end

add_strings_to_table = function(str_list,new_strings)
	return add_strings_to_list(str_list,new_strings)
end

add_strings_to_list = function(str_list,new_strings)
	if type(new_strings) ~= "table" then
		if type(str_list) == "table" then
			return str_list
		else
			return {}
		end
	end
	for _,str in pairs(new_strings) do
		add_string_to_list(str_list,str)
	end
	if type(str_list) == "table" then
		return str_list
	else
		return {}
	end
end

add_string_to_table = function(str_list,new_str)
	return add_string_to_list(str_list,new_str)
end

add_string_to_list = function(str_list,new_str)
	if type(new_str) == "table" then
		add_strings_to_list(
			str_list,
			new_str
		)
	end
	if type(str_list) ~= "table" then
		if type(new_str) == "string" then
			if type(str_list) == "string" then
				str_list = {
					str_list,
					new_str
				}
			end
			if str_list == nil then
				str_list = {new_str}
			end
			return str_list
		else
			return str_list
		end
	end
	for _,str in pairs(str_list) do
		if str == new_str then
			return str_list
		end
	end
	if type(new_str) == "string" then
		table.insert(str_list,new_str)
	end
	return str_list
end

table_incl = function(val,comp)
	comp = table_or_bust(comp)
	if not val or not comp then return false end
	for _,val_comp in pairs(comp) do
		if val_comp == val then
			return true
		end
	end
	return false
end

remove_val_from_table = function(tbl,val)
	local tbl = table_or_bust(tbl)
	local removed = false
	for _,match in pairs(tbl or {}) do
		if table_match(match,val) then
			tbl[_] = nil
			removed = true
		end
	end
	return removed
end

table_match = function(left_table,right_table)
	if left_table == right_table then return true end
	if type(left_table) == "table"
	and type(right_table) == "table"
	then
		if #(left_table) ~= #(right_table) then
			return false
		end
		for _,val in pairs(left_table) do
			if not right_table[_] then return false end
			if not table_match(right_table[_],val) then
				return false
			end
		end
		return true
	end
	return false
end

smoosh_tables = function(left_table,right_table)
	local left_table = table_or_bust(left_table)
	local right_table = table_or_bust(right_table)
	local new_table = {}
	for _,entry in pairs(left_table or {}) do
		table.insert(new_table,entry)
	end
	for _,entry in pairs(right_table or {}) do
		table.insert(new_table,entry)
	end
	return new_table
end

get_player_index = function(player)
	local player = get_player(player)
	if player then return player.index end
	return nil
end

get_player = function(player_index)
	if type(player_index) == "table" then
		if player_index.index then
			return get_player(player_index.index)
		end
	end
	if game and game.players and type(game.players) == "table"
	and game.players[player_index]
	and type(game.players[player_index]) == "table"
	and game.players[player_index]['valid'] then
		return game.players[player_index]
	end
	return nil
end

get_player_armor_inventory = function(player)
	local player = get_player(player)
	if player then
		return player.get_inventory(defines.inventory.character_armor)
	end
end

dict_to_str = function(dict)
	local str = "{"
	if table_or_bust(dict) then
		str = str.."\n"
		for key,val in pairs(dict) do
			str = str.."\t"..tostring(key)..": "..tostring(val).."\n"
		end
	end
	str = str.."}\n"
	return str
end



adamo.color = {
	clear = {r=0,g=0,b=0,a=0},
	black = {},
	white = {r=1,g=1,b=1},
	red = {r=1,g=0,b=0},
	green = {r=0,g=1,b=0},
	blue = {r=0,g=0,b=1},
	yellow = {r=1,g=1,b=0},
	magenta = {r=1,b=0,g=1},
	cyan = {r=0,g=1,b=1},
	softpink = {r=255,g=150,b=150},
	softgreen = {r=126,g=255,b=126},
	darkgrey = {r=40,g=40,b=40},
	lowgrey = {r=80,g=80,b=80},
	midgrey = {r=127,g=127,b=127},
	highgrey = {r=204,g=204,b=204},
	darkbrown = {r=48,g=26,b=2},
	lowbrown = {r=84,g=50,b=13},
	midbrown = {r=145,g=95,b=41},
	highbrown = {r=222,g=184,b=135},
	hf_base = {r=46,g=51,b=5},
	hf_flow = {r=0.7,g=1,b=0.1},
	sodiumlamp = {r=255,g=223,b=0},
	syngasred = {r=255,g=120, b=110},
	heating_element_core = {r=255,g=50,b=0},
	heating_element_glow = {r=255,g=40,b=20},
	gas_fire_glow = {r=1,g=0.5,b=0.5},
	chemical_fire_glow = {r=255,g=63,b=0},
	is_clear = function(color)
		if not color then return true end
		local color = table_or_bust(color)
		if color then
			--color = util.table.deepcopy(color)
			color = {
				r = color.r or color[1] or 0,
				g = color.g or color[2] or 0,
				b = color.b or color[3] or 0,
				a = color.a or color[4] or 1
			}
		end
		if color.r == 0 and color.g == 0 and color.b == 0 then return true end
		--if adamo.obj.match(color,adamo.color.clear) then
		--	return true
		--end
		return false
	end
}

adamo.item = {
	types = {
	    "ammo",
	    "armor",
	    "blueprint",
	    "blueprint-book",
	    "capsule",
	    "copy-paste-tool",
	    "deconstruction-item",
	    "gun",
	    "item",
	    "item-with-entity-data",
	    "item-with-inventory",
	    "item-with-label",
	    "item-with-tags",
	    "mining-tool",
	    "module",
	    "rail-planner",
	    "repair-tool",
	    "selection-tool",
	    "tool",
	    "upgrade-item",
	},
	color = {
		['chemical-science-pack'] = {
			base_color = {r=90,g=200,b=220},
			flow_color = adamo.color.cyan
		},
		['coal'] = {
			base_color = adamo.color.black,
			flow_color = adamo.color.darkgrey
		},
		['adamo-chemical-fluorite'] = {
			base_color = adamo.color.midgrey,
			flow_color = adamo.color.hf_flow
		},
		['adamo-chemical-gypsum'] = {
			base_color = adamo.color.highgrey,
			flow_color = adamo.color.darkgrey
		},
		['adamo-chemical-calcite'] = {
			base_color = adamo.color.highgrey,
			flow_color = adamo.color.midgrey
		},
		by_item = function(item)
			local item = item_or_bust(item)
			if item then return
				adamo.shape.item_color(adamo.item.color[item.name])
			end
			return adamo.shape.item_color()
		end
	},
	manifest = {
		pu238 = {
			"adamo-nuclear-Pu238-oxide",
			"plutonium-238",
			"pu-238"
		},
		HF = {
			"adamo-chemical-hydrofluoric-acid"
		}
	},
	-- Returns first item found.
	find = function(name)
		if string_or_bust(name) and adamo.item.manifest[name] then
			for _,item_name in pairs(adamo.item.manifest[name]) do
				local item = item_or_bust(item_name)
				if item then return item end
				local fluid = fluid_or_bust(item_name)
				if fluid then return fluid end
			end
		end
		return nil
	end
}
adamo.finditem = function(name)
	return adamo.item.find(name)
end

adamo.get = {
	from_types = function(types,name)
		if not table_or_bust(types) or not string_or_bust(name) then
			return nil
		end
		for _,category in pairs(types) do
			if data.raw[category] and data.raw[category][name] then
				return data.raw[category][name]
			end
		end
		return nil
	end,
	recipe_tint = function(recipe)
		local recipe = recipe_or_bust(recipe)
		local tint = recipe.crafting_machine_tint
		if recipe then 
			return adamo.shape.crafting_machine_tint(tint)
		end
		return {
			primary = adamo.color.clear,
			secondary = adamo.color.clear,
			tertiary = adamo.color.clear,
			quaternary = adamo.color.clear
		}
	end
}

adamo.shapes = {
	color = {["r"] = 0,["g"] = 0,["b"] = 0,["a"] = 255}
}

adamo.shape = {
	color = function(color) 
		local shape = util.table.deepcopy(adamo.shapes.color)
		local color = table_or_bust(color)
		if not color then return adamo.color.clear end
		for field,val in pairs(adamo.shapes.color) do
			if color[field] > 0 and color[field] < 1 then
				shape[field] = shape[field]*255
			elseif color[field] then
				shape[field] = color[field]
			end
		end
		return shape
	end,
	item_color = function(item_color)
		local item_color = table_or_bust(item_color)
		if not item_color then return {
			base_color = adamo.color.clear,
			flow_color = adamo.color.clear
		} end
		return {
			base_color = item_color.base_color or adamo.color.clear,
			flow_color = item_color.flow_color or adamo.color.clear
		}
	end,
	crafting_machine_tint = function(primary,secondary,tertiary,quaternary)
		if not adamo.test.is_color(primary) then

		end
		local crafting_machine_tint = primary
		local tint = tint_or_bust(crafting_machine_tint)
		if tint then
			if type(tint.crafting_machine_tint) ~= "table" then
				tint.crafting_machine_tint =
					adamo.shape.crafting_machine_tint()
			end
			tint = tint.crafting_machine_tint
		else
			tint = table_or_bust(crafting_machine_tint)
		end
		if type(tint) ~= "table" then return {
			primary = adamo.color.clear,
			secondary = adamo.color.clear,
			tertiary = adamo.color.clear,
			quaternary = adamo.color.clear
		} end
		return {
			primary = adamo.shape.color(tint.primary),
			secondary = adamo.shape.color(tint.secondary),
			tertiary = adamo.shape.color(tint.tertiary),
			quaternary = adamo.shape.color(tint.quaternary),
		}
	end
}

adamo.obj = {
	match = function(obj1,obj2)
		if type(obj1) ~= type(obj2) then return false end
		if type(obj1) == "table" then
			local internals_match = true
			local tab1 = next(obj1)
			local tab2 = next(obj2)
			if not tab1 and not tab2 then return true end
			if (tab1 and not tab2)
			or (not tab1 and tab2) then
				return false
			end
			for k,v in pairs(obj1) do
				if obj2[k] then
					if not adamo.obj.match(v,obj2[k]) then
						internals_match = false
					end
				else return false
				end
			end
			for k,v in pairs(obj2) do
				if obj1[k] then
					if not adamo.obj.match(v,obj1[k]) then
						internals_match = false
					end
				else return false
				end
			end
			return internals_match
		else
			return obj1 == obj2
		end
	end,
	stringify = function(obj,ml_mode,lead_str)
		if type(obj) == "table" then
			result = "{"
			if (ml_mode) then result = result.."\n" end
			for k,v in pairs(obj) do
				if (ml_mode) then
					result = result..(lead_str or "\t")
				end
				result = result
					..tostring(k)..": "
					..adamo.obj.stringify(
						v,ml_mode,(lead_str or "\t").."\t"
					)
					..","
				if (ml_mode) then result = result.."\n" end
			end
			result = result.."}"
		else
			result = tostring(obj)
		end
		return result
	end
}

colors = adamo.color

adamo.recipe = {
	-- Ingredient/result-based colors
	tint = {
		-- adamo.recipe.tint.apply
		apply = function(recipe)
			local recipe = recipe_or_bust(recipe)
			if not recipe then return end
			local tint = recipe.crafting_machine_tint
			if not tint then
				recipe.crafting_machine_tint = {}
				tint = recipe.crafting_machine_tint
			end
			local old_tint = util.table.deepcopy(tint)
			local ingredients,results = get_io_names(recipe)
			adamo.debug("Applying tint to recipe "..recipe.name)

			local fields = {"quaternary","tertiary"}
			for _,name in pairs(ingredients) do
				adamo.debug("Checking flow_color "..name)
				adamo.recipe.tint.fill(tint,name,"flow_color",fields)
			end
			
			fields = {"primary","secondary"}
			for _,name in pairs(results) do
				adamo.debug("Checking base_color"..name)
				adamo.recipe.tint.fill(tint,name,"base_color",fields)
			end

			fields = {"secondary","primary"}
			for _,name in pairs(ingredients) do
				adamo.debug("Checking base_color "..name)
				adamo.recipe.tint.fill(tint,name,"base_color",fields)
			end			

			fields = {"quaternary","tertiary","primary","secondary"}
			for _,name in pairs(results) do
				adamo.debug("Checking flow_color"..name)
				adamo.recipe.tint.fill(tint,name,"flow_color",fields)
			end
			for _,name in pairs(ingredients) do
				adamo.debug("Checking base_color "..name)
				adamo.recipe.tint.fill(tint,name,"base_color",fields)
			end

			fields = {"secondary","primary"}
			for _,name in pairs(results) do
				adamo.debug("Checking flow_color"..name)
				adamo.recipe.tint.fill(tint,name,"flow_color",fields)
			end
			for _,name in pairs(ingredients) do
				adamo.debug("Checking flow_color "..name)
				adamo.recipe.tint.fill(tint,name,"flow_color",fields)
			end

			if not adamo.obj.match(old_tint,tint) then
				adamo.debug("Tint changed on recipe "..recipe.name..".")
				adamo.debug("Old tint: "..adamo.obj.stringify(old_tint))
				--adamo.debug("New tint: "..adamo.obj.stringify(tint))
				--recipe.crafting_machine_tint = tint
				adamo.debug(
					"Recipe tint: "
					..adamo.obj.stringify(recipe.crafting_machine_tint)
				)
			end
		end,
		fill = function(tint,name,color_type,fields)
			local fluid = fluid_or_bust(name)
			local item = item_or_bust(name)
			if not table_or_bust(tint)
			or not string_or_bust(color_type)
			or not table_or_bust(fields) then
				return
			end
			if fluid and fluid[color_type] then
				for _,field in pairs(fields) do
					if adamo.color.is_clear(tint[field]) then
						adamo.debug(
							"Applying {"
							..tostring(fluid[color_type].r)
							..", "
							..tostring(fluid[color_type].b)
							..", "
							..tostring(fluid[color_type].g)
							..", "
							..tostring(fluid[color_type].a)
							.. "} to "
							.. tostring(field)
						)
						tint[field] = util.table.deepcopy(fluid[color_type])
						break
					end
				end
			elseif item then
				local item_colors = adamo.item.color.by_item(item) 
				for _,field in pairs(fields) do
					if adamo.color.is_clear(tint[field]) then
						adamo.debug(
							"Applying {"
							..tostring(item_colors[color_type].r)
							..", "
							..tostring(item_colors[color_type].b)
							..", "
							..tostring(item_colors[color_type].g)
							..", "
							..tostring(item_colors[color_type].a)
							.. "} to "
							.. tostring(field)
						)
						tint[field] = util.table.deepcopy(item_colors[color_type])
						break
					end
				end
			end
		end
	}
}


adamo.test = {
	unit ={
		recipe = {
			tint = {
				apply = function()
					local tint
						-- = adamo.example.recipe.tint
				end
			}
		}
	}
}

adamo.example = {
	recipe = {
--		["crafting_machine_tint"] = {
--			["primary"] = adamo.shapes.color,
--			["secondary"] =,
--			["tertiary"] =,
--			["quaternary"] =
--
--		},
--		["tinted"] = {
--			name = "test-recipe",
--			type = "recipe",
--			flow_color = 
--		}
	}
}