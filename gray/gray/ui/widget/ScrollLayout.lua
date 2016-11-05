@include class.lua
@include Layout.lua

class "ScrollLayout" extends "Layout" {
  widgets = {};
  width = -1;
  height = -1;
  xScroll = 0;
  yScroll = 0;
  orientation = 1;
  canvas;

  ScrollLayout = function(self, orientation)
    self.canvas = Canvas()
    self.orientation = orientation or 1
  end;

  handleEvent = function(self, event, p1, p2, p3, p4, p5)
    if event == "mouse_scroll" then
      if p1 < 0 and self.yScroll > 0 then
        self.yScroll = self.yScroll + p1
        return nil
      elseif p1 > 0 and self.yScroll < self:resolveMaxYScroll() then
        self.yScroll = self.yScroll + p1
        return nil
      end
    end

    Layout.handleEvent(self, event, p1, p2, p3, p4, p5)
  end;

  resolveMaxScroll = function(self)
    local xScroll = 0
    local yScroll = 0
    for _, w in ipairs(self.widgets) do
      if w.x + w.width > self.width + xScroll then
        xScroll = w.x + w.width - self.width - xScroll + 1
      end
      if w.y + w.height > self.height + yScroll then
        yScroll = w.y + w.height - self.height - yScroll + 1
      end
    end
    return xScroll, yScroll
  end;

  resolveMaxXScroll = function(self)
    local rscroll = 0
    for _, w in ipairs(self.widgets) do
      if w.y + w.height > self.height + rscroll then
        rscroll = w.y + w.height - self.height - rscroll + 1
      end
    end
    return rscroll
  end;

  resolveMaxYScroll = function(self)
    local rscroll = 0
    for _, w in ipairs(self.widgets) do
      if w.y + w.height > self.height + rscroll then
        rscroll = w.y + w.height - self.height - rscroll + 1
      end
    end
    return rscroll
  end;

  draw = function(self, canvas)
    if not canvas then canvas = AppCanvas end
    self.canvas.x1, self.canvas.y1, self.canvas.x2, self.canvas.y2 = canvas:calcBounds(self.x1, self.y1, self.x2 - 1, self.y2, self.alignment, 0, 0)
    self.canvas.width = self.canvas.x2 - self.canvas.x1
    self.canvas.height = self.canvas.y2 - self.canvas.y1
    self.bounds = self.canvas

    self.canvas.yScroll = canvas.vscroll
    self.canvas:drawBox(self.bounds, self.color, self.alignment)
    self.canvas.yScroll = self.yScroll + canvas.yScroll
    for _, w in ipairs(self.widgets) do
      w:draw(self.canvas)
    end
  end;
}
