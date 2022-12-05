local util = require("control-util")

function on_console_chat(event)
  if event.message and string.lower(event.message) == "bzlist" then
    local player = game.players[event.player_index]
    if player and player.connected then
      local list = util.get_list()
      if list and #list>0 then
        local filename = util.me.name..".txt"
        game.write_file(filename, list, false, event.player_index)
        player.print("Wrote recipes to script-output/"..filename)
      end
    end
  end
end
script.on_event(defines.events.on_console_chat, on_console_chat)

function on_init()
  if global.starting_spawn then return end
  if settings.global["bzgas-force-spawn"].value then
    local gas = game.surfaces["nauvis"].find_entities_filtered({area = {{-100, -100}, {100, 100}}, name="gas"})
    if #gas == 0 then
      local position=game.surfaces["nauvis"].find_non_colliding_position("gas", {math.random(-100,100),math.random(-100,100)}, 0, 1)
      if position then 
        game.surfaces["nauvis"].create_entity({name="gas", amount=math.random(400000, 999999), position=position})
      end
    end
  end
  global.starting_spawn = true
end
script.on_init(on_init)
