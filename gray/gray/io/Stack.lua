@include class.lua

class "Stack" {
  Stack = function(self, array)
    self.array = array or {}
    self.pointer = 1
  end,

  push = function(self, ...)
    for _, v in ipairs({...}) do
      table.insert(self.array, v)
    end
  end,

  pushAll = function(self, ...)
    for _, v in ipairs({...}) do
      for _, c in ipairs(v) do
        table.insert(self.array, c)
      end
    end
  end,

  pop = function(self, pointer)
    local p = pointer or #self.array
    local r = self.array[p]
    table.remove(self.array, p)
    return r
  end,

  clear = function(self)
    self.array = {}
  end,

  getArray = function(self)
    return self.array
  end
}
