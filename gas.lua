local resource_autoplace = require('resource-autoplace');
local noise = require('noise');

local util = require("data-util");

data:extend({
	{
    type = "autoplace-control",
    category = "resource",
    name = "gas",
    richness = true,
    order = "b-ez"
	},
	{
    type = "noise-layer",
    name = "gas"
	},
  {
    type = "resource",
    name = "gas",
    icon = "__base__/graphics/icons/crude-oil-resource.png",
    icon_size = 64, icon_mipmaps = 4,
    flags = {"placeable-neutral"},
    category = "basic-fluid",
    subgroup = "raw-resource",
    order="a-b-a",
    infinite = true,
    highlight = true,
    minimum = 60000,
    normal = 300000,
    infinite_depletion_amount = 10,
    resource_patch_search_radius = 12,
    tree_removal_probability = 0.7,
    tree_removal_max_distance = 32 * 32,
    minable =
    {
      mining_time = 1,
      results =
      {
        {
          type = "fluid",
          name = "gas",
          amount_min = 10,
          amount_max = 10,
          probability = 1
        }
      }
    },
    walking_sound = sounds.oil,
    collision_box = {{-1.4, -1.4}, {1.4, 1.4}},
    selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
    autoplace = resource_autoplace.resource_autoplace_settings
    {
      name = "gas",
      order = "c-g", -- Other resources are "b"; oil won't get placed if something else is already there.
      base_density = 8.2,
      base_spots_per_km2 = 1.8,
      random_probability = 1/48,
      random_spot_size_minimum = 1,
      random_spot_size_maximum = 1, -- don't randomize spot size
      additional_richness = 220000, -- this increases the total everywhere, so base_density needs to be decreased to compensate
      has_starting_area_placement = true,
      regular_rq_factor_multiplier = 1
    },
    stage_counts = {0},
    stages =
    {
      sheet =
      {
        filename = "__base__/graphics/entity/crude-oil/crude-oil.png",
        priority = "extra-high",
        width = 74,
        height = 60,
        frame_count = 4,
        variation_count = 1,
        shift = util.by_pixel(0, -2),
        hr_version =
        {
          filename = "__base__/graphics/entity/crude-oil/hr-crude-oil.png",
          priority = "extra-high",
          width = 148,
          height = 120,
          frame_count = 4,
          variation_count = 1,
          shift = util.by_pixel(0, -2),
          scale = 0.5
        }
      }
    },
    map_color = {0.67, 0.87, 0.77},
    map_grid = false
  },
  {
    type = "fluid",
    name = "gas",
    default_temperature = 25,
    heat_capacity = "0.1KJ",
    fuel_value = "1KJ",
    base_color = {r=0.67, g=0.87, b=0.77},
    flow_color = {r=0.67, g=0.87, b=0.87},
    icon = "__base__/graphics/icons/crude-oil-resource.png",
    icon_size = 64,
    order = "a[fluid]-f[organotins]"
  },
})
