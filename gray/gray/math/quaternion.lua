@include class.lua

class "quaternion" { -- WARNING: Outdated
  quaternion = function(a, b, c, d)
    local q = {
      a = a or 0,
      b = b or 0,
      c = c or 0,
      d = d or 0,

      conjugate = function(self)
        return quaternion(self.a, -self.b, -self.c, -self.d)
      end,

      toVector = function(self)
        return vec3(b, c, d)
      end
    }

    setmetatable(q, {
      __add = function(self, q)
        return quaternion(self.a + q.a, self.b + q.b, self.c + q.c, self.d + q.d)
      end,

      __sub = function(self, q)
        return quaternion(self.a - q.a, self.b - q.b, self.c - q.c, self.d - q.d)
      end,

      __mul = function(self, q)
        local a, b, c, d
        a = self.a * q.a - self.b * q.b - self.c * q.c - self.d * q.d
        b = self.a * q.b + self.b * q.a + self.c * q.d - self.d * q.c
        c = self.a * q.c - self.b * q.d + self.c * q.a + self.d * q.b
        d = self.a * q.d + self.b * q.c - self.c * q.b + self.d * q.a

        return quaternion(a, b, c, d)
      end,

      __div = function(self, q)
        local length = 1 / #q
        local conjugate = q:conjugate()
        local reciprocal = quaternion(conjugate.a * length, conjugate.b * length, conjugate.c * length, conjugate.d * length)

        return self * reciprocal
      end,

      __unm = function(self)
        return quaternion(-self.a, -self.b, -self.c, -self.d)
      end,

      __len = function(self)
        return math.pow(self.a, 2) + math.pow(self.b, 2) + math.pow(self.c, 2) + math.pow(self.d, 2)
      end
    })

    return q
  end,

  fromVector = function(vec)
    return quaternion(0, vec.x, vec.y, vec.z)
  end
}
