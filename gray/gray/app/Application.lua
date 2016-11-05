@include class.lua
@include ../graphics/Canvas.lua
@include ../util/Coroutine.lua

class "Application" {
  instance;
  init = function(self) end;
  update = function(self) end;

  run = function(self)
    self:init()
    self.contentView:init()

    parallel.waitForAny(function()
      while true do
        local event, p1, p2, p3, p4, p5 = os.pullEvent()
        if event == "mouse_scroll" or event == "mouse_click" or event == "mouse_up" or event == "mouse_scroll" then
          if p2 >= self.contentView.x1 and p3 >= self.contentView.y1 and p2 < self.contentView.x2 and p3 < self.contentView.y2 then
            self.contentView:handleEvent(event, p1, p2, p3, p4, p5)
          end
        else
          self.contentView:handleEvent(event, p1, p2, p3, p4, p5)
        end
      end
    end, function()
      while true do
        os.sleep(0)
        Application.instance = self;

        AppCanvas.clear()
        Coroutine.step()

        self:update()
        self.contentView:update()
        self.contentView:draw()
        AppCanvas.redraw()
      end
    end)
  end;
}
