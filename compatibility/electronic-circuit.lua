local util = require("data-util");
local futil = require("util");

-- Electronic circuits need final fixes
if data.raw.recipe["electronic-circuit-stone"] then
  util.set_hidden("electronic-circuit-stone")
  util.replace_ingredient("electronic-circuit-stone", "stone-tablet", "bakelite")
  util.remove_recipe_effect("electronics", "electronic-circuit-stone")
  util.set_hidden("electronic-circuit-stone")
end

-- electronic circuits should each require one bakelite
local amt = util.get_amount("electronic-circuit")
util.remove_ingredient("electronic-circuit", "wood")
util.remove_ingredient("electronic-circuit", "iron-plate")
util.remove_ingredient("electronic-circuit", "stone-tablet")
util.add_ingredient("electronic-circuit", "bakelite", amt)
util.set_icons("electronic-circuit", nil)


if util.me.handcraft() then
  data:extend({{ type = "recipe-category", name = "handcraft-only" }})
  for i, character in pairs(data.raw.character) do
    if character and character.crafting_categories then
      table.insert(character.crafting_categories, "handcraft-only")
    end
  end
  local hcec = futil.table.deepcopy(data.raw.recipe["electronic-circuit"])
  hcec.name = "electronic-circuit-handcraft-only"
  data:extend({hcec})
  util.set_icons("electronic-circuit-handcraft-only", 
  {
    { icon = "__base__/graphics/icons/electronic-circuit.png", icon_size = 64, icon_mipmaps = 4},
    { icon = "__base__/graphics/icons/wood.png", icon_size = 64, icon_mipmaps = 4, scale=0.25, shift={-8,-8}},
  })
  util.set_category("electronic-circuit-handcraft-only", "handcraft-only")
  util.replace_ingredient("electronic-circuit-handcraft-only", "bakelite", "wood")
  util.add_unlock("electronics", "electronic-circuit-handcraft-only")
end
