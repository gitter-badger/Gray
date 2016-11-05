local _class = nil
local _classname = nil

function table.deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[table.deepcopy(orig_key)] = table.deepcopy(orig_value)
        end
        setmetatable(copy, getmetatable(orig))
    else
        copy = orig
    end
    return copy
end

_G.class = function(name)
  local _name = name
  _classname = name
  _class = {}

  return function(structure)
    _class = structure

    _class.__call = function(self, ...)
      local inst = table.deepcopy(self)

      if inst[_name] then inst[_name](inst, ...) end
      setmetatable(inst, inst)
      return inst
    end

    setmetatable(_class, _class)
    _G[_classname] = _class
  end
end

_G.extends = function(name)
  local _name = _classname
  for i, v in pairs(table.deepcopy(_G[name])) do
    _class[i] = v
  end
  _class[_name] = _G[name][name]

  return function(structure)
    _class[_classname] = structure[name]
    for i, v in pairs(structure) do
      _class[i] = v
    end

    _class.__call = function(self, ...)
      local inst = table.deepcopy(self)

      if inst[_name] then inst[_name](inst, ...) end
      setmetatable(inst, inst)
      return inst
    end

    setmetatable(_class, _class)
    _G[_classname] = _class
  end
end
