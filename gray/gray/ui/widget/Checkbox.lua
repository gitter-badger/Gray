@include class.lua
@include Widget.lua

class "Checkbox" extends "Widget" {
  textAlignment = Alignment.left;
  textColor = colors.lightGray;
  clickedColor = nil;
  checkedColor = colors.lightGray;
  crossColor = colors.white;
  color = colors.gray;
  checked = false;
  width = 1;
  height = 1;
  text = "";

  Checkbox = function(self, text)
    self.text = text or ""
  end;

  onClick = function(self, button, x, y)
    self.clicked = true
  end;

  onClickUp = function(self, button, x, y, inside)
    self.clicked = false
    if inside then
      self.checked = not self.checked
    end
  end;

  draw = function(self, canvas)
    local x1, y1, x2, y2 = canvas:calcBounds(self.x1, self.y1, self.x2, self.y2, self.alignment, 0, 0)
    self.bounds = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
    canvas:drawBox(self.bounds, self.clicked and (self.clickedColor or self.crossColor) or self.checked and self.checkedColor or self.color, self.alignment)
    if self.checked then
      canvas:drawText(self.bounds, "x", self.clicked and self.checkedColor or self.crossColor, Alignment.center, self.alignment, 0, 0, 0)
    end

    local x1 = 0
    local x2 = 0
    if self.textAlignment == Alignment.left then
      x1 = self.x - #self.text - 1
      x2 = x1 + #self.text + 2
    elseif self.textAlignment == Alignment.right then
      x2 = self.x + #self.text + 2
    end
    local x1, y1, x2, y2 = canvas:calcBounds(x1, self.y1, x2, self.y2, self.alignment, 0, 0)
    local bounds = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
    canvas:drawText(bounds, self.text, self.textColor, self.textAlignment, self.alignment, 0, 0, 0)
    --if self.textAlignment == Alignment.left then
    --  self.x = self.x + #self.text + 1
    --end
  end;
}
