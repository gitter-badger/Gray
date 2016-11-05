@include class.lua
@include Layout.lua

class "RadioGroup" extends "Layout" { -- Just a mirror for now
  RadioGroup = function(self)
    self.canvas = Canvas()
  end;
}
