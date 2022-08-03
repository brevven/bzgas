local me = {}

me.name = "bzgas"
me.list = {}

function me.finite()   -- Krastorio 2
  return me.get_setting("kr-finite-oil")
end

function me.handcraft() 
  return me.get_setting("bzgas-handcraft")
end


function me.use_boiler() 
  return me.get_setting("bzgas-boiler")
end

function me.use_phenol() 
  return me.get_setting("bzgas-more-intermediates") == "phenol"
end

function me.get_setting(name)
  if settings.startup[name] == nil then
    return nil
  end
  return settings.startup[name].value
end

me.bypass = {}
if me.get_setting(me.name.."-recipe-bypass") then 
  for recipe in string.gmatch(me.get_setting(me.name.."-recipe-bypass"), '[^",%s]+') do
    me.bypass[recipe] = true
  end
end

function me.add_modified(name) 
  if me.get_setting(me.name.."-list") then 
    table.insert(me.list, name)
  end
end


return me
