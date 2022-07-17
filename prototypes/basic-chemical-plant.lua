local util = require("data-util");
local futil = require("util");

data:extend({
  {
    type = "recipe",
    name = "basic-chemical-plant",
    result = "basic-chemical-plant",
    enabled = false,
    ingredients = {
      {"stone-brick", 5},
      {"iron-plate", 4},
      {"copper-plate", 4},
      {"pipe", 6},
    },
  }
})

util.add_ingredient("basic-chemical-plant", "lead-plate", 4)
util.replace_ingredient("basic-chemical-plant", "iron-plate", "aluminum-plate")
util.replace_ingredient("basic-chemical-plant", "copper-plate", "tin-plate")
util.replace_ingredient("basic-chemical-plant", "stone-brick", "silica", 10)

-- item
local plant_i = futil.table.deepcopy(data.raw.item["chemical-plant"])
plant_i.name = "basic-chemical-plant"
plant_i.place_result = "basic-chemical-plant"
plant_i.icon = nil
plant_i.icon_size = nil
plant_i.icons = {
  {icon="__base__/graphics/icons/chemical-plant.png", icon_size=64},
  {icon="__bzgas__/graphics/icons/chemical-plant-overlay.png", icon_size=64},
}

data.raw.item["basic-chemical-plant"] = plant_i
-- end item

-- entity
local plant_e = futil.table.deepcopy(data.raw["assembling-machine"]["chemical-plant"])
plant_e.name = "basic-chemical-plant"
plant_e.minable = {mining_time = 0.5, result = "basic-chemical-plant"}
plant_e.working_visualisations = {plant_e.working_visualisations[1], plant_e.working_visualisations[2]} -- no smoke
plant_e.animation.north.layers[1].filename="__bzgas__/graphics/entity/chemical-plant.png"
plant_e.animation.north.layers[1].hr_version.filename="__bzgas__/graphics/entity/hr-chemical-plant.png"
plant_e.animation.south.layers[1].filename="__bzgas__/graphics/entity/chemical-plant.png"
plant_e.animation.south.layers[1].hr_version.filename="__bzgas__/graphics/entity/hr-chemical-plant.png"
plant_e.animation.east.layers[1].filename="__bzgas__/graphics/entity/chemical-plant.png"
plant_e.animation.east.layers[1].hr_version.filename="__bzgas__/graphics/entity/hr-chemical-plant.png"
plant_e.animation.west.layers[1].filename="__bzgas__/graphics/entity/chemical-plant.png"
plant_e.animation.west.layers[1].hr_version.filename="__bzgas__/graphics/entity/hr-chemical-plant.png"
plant_e.energy_source = {
  type = "burner",
  fuel_inventory_size = 1,
  effectivity = 1,
  fuel_categories = {"chemical"},
  smoke = {
    {
      name = "smoke",
      frequency = 30,
      north_position = {-0.43, -2.3},
      south_position = {0.23, -1.9},
      east_position  = {0.5, -2.15},
      west_position  = {-0.45, -2.0},
      starting_vertical_speed = 0.1,
      starting_frame_deviation = 60,
    },
  },
}
-- NOTE: Saving tint here in case this is needed.
-- local ptint = {r=.7,g=0.7,b=0.9,a=1}
-- plant_e.animation.north.layers[1].tint = ptint
-- plant_e.animation.north.layers[1].hr_version.tint = ptint
-- plant_e.animation.south.layers[1].tint = ptint
-- plant_e.animation.south.layers[1].hr_version.tint = ptint
-- plant_e.animation.east.layers[1].tint = ptint
-- plant_e.animation.east.layers[1].hr_version.tint = ptint
-- plant_e.animation.west.layers[1].tint = ptint
-- plant_e.animation.west.layers[1].hr_version.tint = ptint
data.raw["assembling-machine"]["basic-chemical-plant"] = plant_e
-- end entity

log("BZZZZZZZZZZZ")
log("")
log("")
log(serpent.dump(data.raw.item["basic-chemical-plant"]))
log("")
log("")
log(serpent.dump(data.raw["assembling-machine"]["basic-chemical-plant"]))
log("")
log("")
