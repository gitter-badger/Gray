@include class.lua
@include Checkbox.lua

class "RadioButton" extends "Checkbox" {
  RadioButton = function(self, text)
    self.text = text or ""
  end;

  onClickUp = function(self, button, x, y, inside)
    self.clicked = false
    if inside then
      for _, v in ipairs(self.parent.widgets) do
        v.checked = false
      end
      self.checked = true
    end
  end;
}
