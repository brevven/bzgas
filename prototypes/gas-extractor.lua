local util = require("data-util");
local futil = require("util")

local ge_ingredients = {
  {"iron-plate", 10},
  {"pipe", 10},
  {"stone-brick", 4},
}
local ge_prereq = {"automation"}
if mods.bzlead then table.insert(ge_ingredients, {"lead-plate", 4}) end
if mods.Krastorio2 or mods["aai-industry"] then
  table.insert(ge_ingredients, {"sand", 10})
  ge_prereq = {"sand"}
elseif data.raw.item["silica"] and data.raw.technology["silica-processing"] then
  table.insert(ge_ingredients, {"silica", 20})
  ge_prereq = {"silica-processing"}
end

data:extend({
  {
    type = "item",
    name = "gas-extractor",
    icon = "__bzgas__/graphics/icons/gas-extractor.png",
    icon_size = 128,
    subgroup = "extraction-machine",
    order = "b[fluids]-b[gas-extractor]",
    place_result = "gas-extractor",
    stack_size = 20,
  },
  {
    type = "recipe",
    name = "gas-extractor",
    result = "gas-extractor",
    enabled = false, -- TODO change
    ingredients = ge_ingredients,
  },
  {
    type = "technology",
    name = "gas-extraction",
    icon = "__bzgas__/graphics/technology/gas-processing.png",
    icon_size = 256,
    prerequisites = ge_prereq,
    effects = {
      {type = "unlock-recipe", recipe = "gas-extractor"},
    },
    unit = {
      count = 10,
      ingredients = {{"automation-science-pack", 1}},
      time = 20,
    },
  },
  {
    type = "mining-drill",
    name = "gas-extractor",
    icon = "__bzgas__/graphics/icons/gas-extractor.png",
    icon_size = 128,
    flags = {"placeable-neutral", "player-creation"},
    minable = {mining_time = 0.5, result = "gas-extractor"},
    resource_categories = {"gas"},
    max_health = 200,
    corpse = "pumpjack-remnants",
    dying_explosion = "pumpjack-explosion",
    collision_box = {{ -1.2, -1.2}, {1.2, 1.2}},
    selection_box = {{ -1.5, -1.5}, {1.5, 1.5}},
    -- damaged_trigger_effect = hit_effects.entity(),
    drawing_box = {{-1.6, -2.5}, {1.5, 1.6}},
    energy_source =
    {
      type = "electric",
      emissions_per_minute = 10,
      usage_priority = "secondary-input"
    },
    output_fluid_box =
    {
      base_area = 10,
      base_level = 1,
      pipe_covers = pipecoverspictures(),
      pipe_connections =
      {
        {
          positions = { {0, -2}, {2, 0}, {0, 2}, {-2, 0} }
        }
      }
    },
    energy_usage = "90kW",
    mining_speed = 1,
    resource_searching_radius = 0.49,
    vector_to_place_result = {0, 0},
    module_specification =
    {
      module_slots = 2
    },
    radius_visualisation_picture =
    {
      filename = "__base__/graphics/entity/pumpjack/pumpjack-radius-visualization.png",
      width = 12,
      height = 12
    },
    monitor_visualization_tint = {r=78, g=173, b=255},
    base_render_layer = "lower-object-above-shadow",
    base_picture = {
      north = {
        filename = "__bzgas__/graphics/entity/gas-extractor-base-n.png",
        priority = "extra-high",
        width = 175,
        height = 179,
        scale = 0.5,
        shift = futil.by_pixel(0, -4),
      },
      south = {
        filename = "__bzgas__/graphics/entity/gas-extractor-base-s.png",
        priority = "extra-high",
        width = 175,
        height = 149,
        scale = 0.5,
        shift = futil.by_pixel(0, 13),
      },
      east = {
        filename = "__bzgas__/graphics/entity/gas-extractor-base-e.png",
        priority = "extra-high",
        width = 207,
        height = 129,
        scale = 0.5,
        shift = futil.by_pixel(8, 8),
      },
      west = {
        filename = "__bzgas__/graphics/entity/gas-extractor-base-w.png",
        priority = "extra-high",
        width = 207,
        height = 129,
        scale = 0.5,
        shift = futil.by_pixel(-8, 8),
      },
    },
    animations = {
      layers = {
        {
          filename = "__bzgas__/graphics/entity/gas-extractor.png",
          priority = "extra-high",
          width = 263,
          height = 600,
          scale = 1/3,
          shift = futil.by_pixel(0, -60),
        },
      },
    },
    vehicle_impact_sound = data.raw["mining-drill"]["pumpjack"].vehicle_impact_sound,
    open_sound = data.raw["mining-drill"]["pumpjack"].open_sound,
    close_sound = data.raw["mining-drill"]["pumpjack"].close_sound,
    working_sound =
    {
      sound =
      {
        {
          filename = "__base__/sound/pumpjack.ogg",
          volume = 0.7
        },
      },
      max_sounds_per_type = 3,
      audible_distance_modifier = 0.6,
      fade_in_ticks = 4,
      fade_out_ticks = 10
    },
    fast_replaceable_group = "pumpjack",

    -- circuit_wire_connection_points = circuit_connector_definitions["pumpjack"].points,
    -- circuit_connector_sprites = circuit_connector_definitions["pumpjack"].sprites,
    -- circuit_wire_max_distance = default_circuit_wire_max_distance
  }
})
