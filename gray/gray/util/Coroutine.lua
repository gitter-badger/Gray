@include class.lua

class "Coroutine" {
  coroutines = {};
  co = "fucj";

  Coroutine = function(self, func)
    self.co = coroutine.create(func)
  end;

  start = function(self)
    table.insert(Coroutine.coroutines, self)
  end;

  stop = function(self)
    for i, c in Coroutine.coroutines do
      if c == self then
        table.remove(Coroutine.coroutines, i)
        break
      end
    end
  end;

  yield = coroutine.yield;

  step = function()
    for i, c in ipairs(Coroutine.coroutines) do
      if not coroutine.resume(c.co) then
        table.remove(Coroutine.coroutines, i)
      end
    end
  end;
}
