@include class.lua

class "Buffer" {
  Buffer = function(self, array)
    self.array = array or {}
    self.pointer = 1
  end,

  put = function(self, ...)
    for _, v in ipairs({...}) do
      self.array[self.pointer] = v
      self.pointer = self.pointer + 1
    end
  end,

  putAll = function(self, ...)
    for _, v in ipairs({...}) do
      for _, c in ipairs(v) do
        self.array[self.pointer] = c
        self.pointer = self.pointer + 1
      end
    end
  end,

  get = function(self, pointer)
    local r = self.array[pointer or self.pointer]
    self.pointer = pointer and self.pointer or self.pointer + 1
    return r
  end,

  clear = function(self)
    self.array = {}
    self.pointer = 1
  end,

  rewind = function(self)
    self.pointer = 1
  end,

  getArray = function(self)
    return self.array
  end
}
