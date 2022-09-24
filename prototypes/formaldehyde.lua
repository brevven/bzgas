local util = require("data-util");

-- data:extend({
--   {
--     type = "recipe-category",
--     name = "basic-chemistry",
--   }
-- })

data:extend({
  {
    type = "fluid",
    name = "formaldehyde",
    default_temperature = 25,
    heat_capacity = "0.1KJ",
    fuel_value = "0.5KJ",
    base_color = {r=0.77, g=0.87, b=0.67},
    flow_color = {r=0.77, g=0.87, b=0.77},
    icon =  "__bzgas__/graphics/icons/formaldehyde.png",
    icon_size = 128,
    order = "a[fluid]-f[formaldehyde]"
  },
  {
    type = "recipe",
    name = "formaldehyde",
    category = "chemistry",
    enabled = "false",
    ingredients = {
      {type="fluid", name="gas", amount=10}
    },
    energy_required = 1.8,
    results = {
      {type="fluid", name="formaldehyde", amount=9}
    },
  },

  {
    type = "technology",
    name = "basic-chemistry",
    icon = "__bzgas__/graphics/technology/formaldehyde.png",
    icon_size = 256,
    prerequisites = {"gas-extraction"},
    effects = {
      {type = "unlock-recipe", recipe = "basic-chemical-plant"},
      {type = "unlock-recipe", recipe = "formaldehyde"},
    },
    unit = {
      count = 10,
      ingredients = {{"automation-science-pack", 1}},
      time = 20,
    },
  },
})
