@include class.lua
@include ../util/Coroutine.lua

function math.interpolate(v1, v2, progress)
  return v1 + (v2 - v1) * progress
end

class "Animation" {
  Animation = function(self, min, max, duration, target, index)
    self.value = min or 0
    self.min = min or 0
    self.max = max or 0
    self.target = target
    self.index = index
    self.duration = duration or 0
    self.finished = false
  end;

  play = function(self, duration)
    Coroutine(function()
      if not duration then duration = self.duration end

      self.finished = false
      local t = os.clock()

      while os.clock() - t <= duration do
        self.value = math.interpolate(self.min, self.max, (os.clock() - t) / duration)
        if type(self.index) == "table" then
          for _, v in ipairs(self.index) do
            self.target[v] = self.value
          end
        elseif self.index then
          self.target[self.index] = self.value
        else
          self.target = self.value
        end

        Coroutine.yield()
      end

      self.finished = true
    end):start()
  end;
}
