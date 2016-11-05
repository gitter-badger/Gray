@include class.lua

class "mat4x4" {
  [1] = vec4(1, 0, 0, 0);
  [2] = vec4(0, 1, 0, 0);
  [3] = vec4(0, 0, 1, 0);
  [4] = vec4(0, 0, 0, 1);

  translate = function(self, x, y, z, w)
    if type(x) == "table" then
      w = x.w or 1
      z = x.z
      y = x.y
      x = x.x
    end

    self[4] = vec4(self[4].x + x, self[4].y + y, self[4].z + z, self[4].w * (w or 1));
		return self;
  end;

  translation = function(x, y, z, w)
    if type(x) == "table" then
      w = x.w or 1
      z = x.z
      y = x.y
      x = x.x
    end

    local m = mat4x4()
    m[4] = vec4(x, y, z, w or 1);
		return m;
  end;

  rotation = function(x, y, z)
    if type(x) == "table" then
      z = x.z
      y = x.y
      x = x.x
    end

    --local rotx = mat4x4()
    --rotx[1] = vec4(1, 0, 0, 0)
    --rotx[2] = vec4(0, math.cos(x), math.sin(x), 0)
    --rotx[3] = vec4(0, -math.sin(x), math.cos(x), 0)
    --rotx[4] = vec4(0, 0, 0, 1)

    --local roty = mat4x4()
    --roty[1] = vec4(math.cos(y), 0, -math.sin(y), 0)
    --roty[2] = vec4(0, 1, 0, 0)
    --roty[3] = vec4(-math.sin(y), 0, math.cos(y), 0)
    --roty[4] = vec4(0, 0, 0, 1)

    --local rotz = mat4x4()
    --rotz[1] = vec4(math.cos(z), math.sin(z), 0, 0)
    --rotz[2] = vec4(-math.sin(z), math.cos(z), 0, 0)
    --rotz[3] = vec4(0, 0, 1, 0)
    --rotz[4] = vec4(0, 0, 0, 1)

    local rot = mat4x4()
    rot[1] = vec4(math.cos(y) * math.cos(z), math.cos(y) * math.sin(z), -math.sin(z), 0)
    rot[2] = vec4(math.cos(z) * math.sin(x) * math.sin(y) - math.cos(x) * math.sin(z), math.cos(x) * math.cos(z) + math.sin(x) * math.sin(y) * math.sin(z), math.cos(y) * math.sin(x), 0)
    rot[3] = vec4(math.cos(x) * math.cos(z) * math.sin(y) + math.sin(x) * math.sin(z), math.cos(x) * math.sin(y) * math.sin(z) - math.cos(z) * math.sin(x), math.cos(x) * math.cos(y), 0)
    rot[4] = vec4(0, 0, 0, 1)

    return rot;
  end;

  perspective = function(fov, ratio, near, far)
    local result = mat4x4()
    local depth = far - near;
    local h = 1 / math.tan(fov / 2)
    local w = (h / ratio)

    result[1] = vec4(w, 0, 0, 0)
    result[2] = vec4(0, h, 0, 0)
    result[3] = vec4(0, 0, far / depth, near * far / depth)
    result[4] = vec4(0, 0, 1, 0)

    return result
  end;

  __mul = function(self, m)
    if m.x then -- Vector
      local out = vec4()
      local w = m.w and m.w or 1

      out.x = m.x * self[1][1] + m.y * self[2][1] + m.z * self[3][1] + w * self[4][1]
      out.y = m.x * self[1][2] + m.y * self[2][2] + m.z * self[3][2] + w * self[4][2]
      out.z = m.x * self[1][3] + m.y * self[2][3] + m.z * self[3][3] + w * self[4][3]
      out.w = m.x * self[1][4] + m.y * self[2][4] + m.z * self[3][4] + w * self[4][4]

      if not out.w == 1 then
        out.x = out.x / w
        out.y = out.y / w
        out.z = out.z / w
      end

      return out
    elseif type(m) == "table" then -- Matrix
      local out = mat4x4()

		  out[1] = self[1] * m[1][1] + self[2] * m[1][2] + self[3] * m[1][3] + self[4] * m[1][4]
		  out[2] = self[1] * m[2][1] + self[2] * m[2][2] + self[3] * m[2][3] + self[4] * m[2][4]
		  out[3] = self[1] * m[3][1] + self[2] * m[3][2] + self[3] * m[3][3] + self[4] * m[3][4]
		  out[4] = self[1] * m[4][1] + self[2] * m[4][2] + self[3] * m[4][3] + self[4] * m[4][4]

      return out
    else -- Number
      local out = mat4x4()

      out[1] = self[1] * m
      out[2] = self[2] * m
      out[3] = self[3] * m
      out[4] = self[4] * m

      return out
    end
  end;
}

class "mat4" extends "mat4x4" -- People have different styles
