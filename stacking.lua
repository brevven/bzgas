-- Deadlock stacking recipes

local util = require("data-util");

if deadlock then
  deadlock.add_stack("bakelite",  "__bzgas__/graphics/icons/stacked/bakelite.png", "deadlock-stacking-1", 128)
  if data.raw.item["phenol"] then
    deadlock.add_stack("phenol",  "__bzgas__/graphics/icons/stacked/phenol.png", "deadlock-stacking-1", 128)
  end
end

-- Deadlock crating recipes
if deadlock_crating then
  deadlock_crating.add_crate("bakelite", "deadlock-crating-1")
  if data.raw.item["phenol"] then
    deadlock_crating.add_crate("phenol", "deadlock-crating-1")
  end
end

