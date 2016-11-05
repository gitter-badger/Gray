@include class.lua

class "vec4" {
  vec4 = function(self, x, y, z, w)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
    self.w = w or 0
  end;

  dot = function(self, o)
    return self.x * o.x + self.y * o.y + self.z * o.z + self.w * o.w
  end;

  cross = function(self, o)
    return vec4(
      self.y * o.z - self.z * o.y,
      self.z * o.x - self.x * o.z,
      self.x * o.y - self.y * o.x,
      self.w
    )
  end;

  __length = function(self)
    return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w)
  end;

  normalize = function(self)
    return self * 1 / self:length()
  end;

  round = function(self, nTolerance)
      nTolerance = nTolerance or 1
      return vec4(
        math.floor((self.x + (nTolerance * 0.5)) / nTolerance) * nTolerance,
        math.floor((self.y + (nTolerance * 0.5)) / nTolerance) * nTolerance,
        math.floor((self.z + (nTolerance * 0.5)) / nTolerance) * nTolerance
      )
  end;

  __index = function(self, h)
    if h == 1 then
      return self.x
    elseif h == 2 then
      return self.y
    elseif h == 3 then
      return self.z
    elseif h == 4 then
      return self.w
    end
  end;

  __tostring = function(self)
    return self.x .. ", " .. self.y .. ", " .. self.z .. ", " .. self.w
  end;

  __add = function(self, o)
    if type(o) == "table" then
      return vec4(
        self.x + o.x,
        self.y + o.y,
        self.z + o.z
      )
    elseif type(o) == "number" then
      return vec4(
        self.x + o,
        self.y + o,
        self.z + o
      )
    end
  end;

  __sub = function( self, o )
    if type(o) == "table" then
      return vec4(
        self.x - o.x,
        self.y - o.y,
        self.z - o.z
      )
    elseif type(o) == "number" then
      return vec4(
        self.x - o,
        self.y - o,
        self.z - o,
        self.w - o
      )
    end
  end;

  __mul = function( self, m )
    --if type(self) ~= "table" then return commit(suicide) end
    if type(m) == "table" and m.x then
      return vec4(
        self.x * m.x,
        self.y * m.y,
        self.z * m.z,
        self.w * m.w
      )
    elseif type(m) == "number" then
      return vec4(
        self.x * m,
        self.y * m,
        self.z * m,
        self.w * m
      )
    end
  end;

  __div = function( self, m )
    if type(m) == "table" then
      return vec4(
        self.x / m.x,
        self.y / m.y,
        self.z / m.z,
        self.w / m.w
      )
    elseif type(m) == "number" then
      return vec4(
        self.x / m,
        self.y / m,
        self.z / m,
        self.w / m
      )
    end
  end;

  __unm = function( self )
    return vec4(
      -self.x,
      -self.y,
      -self.z,
      -self.w
    )
  end;
}
