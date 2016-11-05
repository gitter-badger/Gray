@include class.lua

class "vec3" {
  vec3 = function(self, x, y, z)
    self.x = x or 0
    self.y = y or 0
    self.z = z or 0
  end;

  dot = function(self, o)
    return self.x * o.x + self.y * o.y + self.z * o.z
  end;

  cross = function(self, o)
    return vec3(
      self.y * o.z - self.z * o.y,
      self.z * o.x - self.x * o.z,
      self.x * o.y - self.y * o.x
    )
  end;

  __length = function(self)
    return math.sqrt(self.x * self.x + self.y * self.y + self.z * self.z)
  end;

  normalize = function(self)
    return self * 1 / #self
  end;

  round = function(self, nTolerance)
      nTolerance = nTolerance or 1
      return vec3(
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
    end
  end;

  __tostring = function(self)
    return self.x .. ", " .. self.y .. ", " .. self.z
  end;

  __add = function(self, o)
    if type(o) == "table" then
      return vec3(
        self.x + o.x,
        self.y + o.y,
        self.z + o.z
      )
    elseif type(o) == "number" then
      return vec3(
        self.x + o,
        self.y + o,
        self.z + o
      )
    end
  end;

  __sub = function( self, o )
    if type(o) == "table" then
      return vec3(
        self.x - o.x,
        self.y - o.y,
        self.z - o.z
      )
    elseif type(o) == "number" then
      return vec3(
        self.x - o,
        self.y - o,
        self.z - o
      )
    end
  end;

  __mul = function( self, m )
    if type(m) == "table" and m.x then
      return vec3(
        self.x * m.x,
        self.y * m.y,
        self.z * m.z
      )
    elseif type(m) == "number" then
      return vec3(
        self.x * m,
        self.y * m,
        self.z * m
      )
    end
  end;

  __div = function( self, m )
    if type(m) == "table" then
      return vec3(
        self.x / m.x,
        self.y / m.y,
        self.z / m.z
      )
    elseif type(m) == "number" then
      return vec3(
        self.x / m,
        self.y / m,
        self.z / m
      )
    end
  end;

  __unm = function( self )
    return vec3(
      -self.x,
      -self.y,
      -self.z
    )
  end;
}
