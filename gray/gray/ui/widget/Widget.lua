@include class.lua
@include ../../graphics/Canvas.lua

colors.transparent = 0
class "Widget" {
  x = 1;
  y = 1;
  width = -2;
  height = 1;
  alignment = 0;
  color = colors.transparent;
  bounds = {};
  parent;

  __index = function(self, index)
    if index == "x1" then
      return self.x
    elseif index == "y1" then
      return self.y
    elseif index == "x2" then
      return self.x + self.width
    elseif index == "y2" then
      return self.y + self.height
    end
  end;

  handleEvent = function(self, event, p1, p2, p3, p4, p5)
    if event == "mouse_click" then
      self:onClick(p1, p2 - self.x - 1, p3 - self.y - 1)
    elseif event == "mouse_up" then
      self:onClickUp(p1, p2 - self.x - 1, p3 - self.y - 1, p4)
    elseif event == "mouse_drag" then
      self:onDrag(p1, p2 - self.x - 1, p3 - self.y - 1, p4)
    elseif event == "mouse_scroll" then
      self:onScroll(p1, p2 - self.x - 1, p3 - self.y - 1)
    elseif event == "key" then
      self:onKey(p1, p2)
    elseif event == "key_up" then
      self:onKeyUp(p1)
    elseif event == "char" then
      self:onChar(p1)
    end
  end;

  onClick = function(self, button, x, y) end;
  onClickUp = function(self, button, x, y, inside) end;
  onDrag = function(self, button, x, y, inside) end;
  onScroll = function(self, direction, x, y) end;
  onKey = function(self, key, held) end;
  onKeyUp = function(self, key) end;
  onChar = function(self, char) end;

  onFocus = function(self) end;
  onLoseFocus = function(self) end;

  init = function(self) end;
  update = function(self) end;
  draw = function(self) end;
}
