
-- For testing only
-- local kept1 = false
-- for name in pairs(data.raw["utility-constants"]["default"].main_menu_simulations) do
--   if kept1 then
--     data.raw["utility-constants"]["default"].main_menu_simulations[name] = nil
--   end
--   kept1 = true
-- end

data.raw["utility-constants"]["default"].main_menu_simulations["gas-rig"] = {
  checkboard = false,
  save = "__bzgas__/menu-simulations/gas-rig-sim.zip", length = 15*60,
  init =
  [[
    local logo = game.surfaces.nauvis.find_entities_filtered{
      name = "factorio-logo-16tiles", limit = 1}[1]
    game.camera_position = {logo.position.x, logo.position.y+14}
    game.camera_zoom = 0.75
    game.tick_paused = false
    game.surfaces.nauvis.daytime = 0
  ]],
  update = [[]]
}

