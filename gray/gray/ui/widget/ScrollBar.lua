@include class.lua
@include Widget.lua

class "ScrollBar" extends "Widget" {
  color = colors.transparent;
  thumbColor = colors.lightGray;
  orientation = 1;
  x = 1;
  y = 1;
  width = 1;
  height = -1;
  scroll = 0;
  my = 0;

  ScrollBar = function(self, orientation)
    self.orientation = orientation or 1
  end;

  onClick = function(self, button, x, y)
    self.my = y
  end;

  onDrag = function(self, button, x, y, inside)
    local diff = y - self.my

    if (diff < 0 and self.parent.yScroll > -diff - 1) or (diff > 0 and self.parent.yScroll <= self.parent:resolveMaxScroll() - diff) then
      self.parent.yScroll = self.parent.yScroll + diff
    end
  end;

  draw = function(self, canvas)
    local x1, y1, x2, y2
    local xScroll = self.parent.xScroll
    local yScroll = self.parent.yScroll
    local maxXScroll, maxYScroll = self.parent:resolveMaxScroll()
    local width = self.parent.width
    local height = self.parent.height
    if self.orientation == 0 then
      self.width = width
      self.height = 1

      x1, y1, x2, y2 = canvas:calcBounds(xScroll, yScroll + height - 1, xScroll + width + 1, yScroll + height + 1, self.alignment, 0, 0)
      self.bounds = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
      canvas:drawBox(self.bounds, self.color, self.alignment)
      x1 = math.ceil(width * xScroll / width + 0.5)
      x2 = x1 + math.floor(width - width * maxXScroll / width + 0.5)
      x1, y1, x2, y2 = canvas:calcBounds(xScroll + x1, yScroll + height - 1, xScroll + x2, yScroll + height + 1, self.alignment, 0, 0)
      local bounds = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
      canvas:drawBox(bounds, colors.lightGray, self.alignment)
    else
      self.width = 1
      self.height = height

      x1, y1, x2, y2 = canvas:calcBounds(width - 1, yScroll, width + 1, yScroll + height + 1, self.alignment, 0, 0)
      self.bounds = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
      canvas:drawBox(self.bounds, self.color, self.alignment)
      y1 = math.ceil(height * yScroll / height + 0.5)
      y2 = y1 + math.floor(height - height * maxYScroll / height + 0.5)
      x1, y1, x2, y2 = canvas:calcBounds(xScroll + width - 1, yScroll + y1, xScroll + width + 1, yScroll + y2, self.alignment, 0, 0)
      local bounds = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
      canvas:drawBox(bounds, colors.lightGray, self.alignment)
    end
  end;
}
