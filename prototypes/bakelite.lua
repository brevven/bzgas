local util = require("data-util");

b_prereq = {"basic-chemistry"}
if data.raw.technology["foundry"] then
  table.insert(b_prereq, "foundry")
end

data:extend({
  {
    type = "item",
    name = "bakelite",
    icon = "__bzgas__/graphics/icons/bakelite.png",
    icon_size = 128,
    subgroup = "raw-material",
    order = "g[bakelite]",
    stack_size = util.get_stack_size(100),
  },
  {
    type = "recipe",
    name = "bakelite",
    category = "chemistry",
    main_product = "bakelite",
    enabled = "false",
    ingredients = {
      {util.me.use_phenol() and "phenol" or "coal", 1},
      {type="fluid", name="formaldehyde", amount=10}
    },
    energy_required = 2,
    results = {
      {type="item", name="bakelite", amount = 2},
    },
  },
  {
    type = "technology",
    name = "bakelite",
    icon = "__bzgas__/graphics/technology/bakelite.png",
    icon_size = 256,
    prerequisites = b_prereq,
    effects = {
      {type = "unlock-recipe", recipe = "bakelite"},
    },
    unit = {
      count = 10,
      ingredients = {{"automation-science-pack", 1}},
      time = 20,
    },
  },
})

util.add_prerequisite("electronics", "bakelite")
