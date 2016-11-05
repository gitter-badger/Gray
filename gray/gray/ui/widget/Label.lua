@include class.lua
@include Widget.lua

class "Label" extends "Widget" {
  textColor = colors.gray;
  clickedColor = nil;
  textAlignment = Alignment.center;
  clicked = false;
  text = "";

  Label = function(self, text)
    self.text = text or ""
  end;

  handleEvent = function(self, event, p1, p2, p3, p4, p5)
    if event == "mouse_click" and self.clickedColor then
      self.clicked = true
    elseif event == "mouse_up" then
      self.clicked = false
    end

    Widget.handleEvent(self, event, p1, p2, p3, p4, p5)
  end;

  draw = function(self, canvas)
    local x1, y1, x2, y2 = canvas:calcBounds(self.x1, self.y1, self.x2, self.y2, self.alignment, #self.text, 0)
    self.bounds = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
    canvas:drawBox(self.bounds, self.clicked and self.clickedColor or self.color, self.alignment)
    canvas:drawText(self.bounds, self.text, self.textColor, self.textAlignment, self.alignment)
  end;
}
