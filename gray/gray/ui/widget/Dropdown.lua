@include class.lua
@include Label.lua
@include ScrollLayout.lua

class "Dropdown" extends "Widget" {
  dropLayout;
  color = colors.gray;
  textColor = colors.white;
  textAlignment = Alignment.left;
  text = "fags";

  __index = function(self, index)
    if index == "x1" or index == "x" then
      return self.dropLayout.x
    elseif index == "y1" or index == "y" then
      return self.dropLayout.y - 1
    elseif index == "x2" then
      return self.dropLayout.x + self.dropLayout.width - 1
    elseif index == "y2" then
      return self.dropLayout.y
    elseif index == "dropdownColor" then
      return rawget(self.dropLayout, "color")
    elseif index == "width" or index == "height" then
      return rawget(self.dropLayout, index)
    end
  end;

  __newindex = function(self, index, value)
    if index == "y" then
      self.dropLayout[index] = value + 1
    elseif index == "x" or index == "width" or index == "height" then
      self.dropLayout[index] = value
    elseif index == "dropdownColor" then
      self.dropLayout.color = value
    else
      rawset(self, index, value)
    end
  end;

  Dropdown = function(self, text)
    rawset(self, "x", nil)
    rawset(self, "y", nil)
    rawset(self, "width", nil)
    rawset(self, "height", nil)

    if text then self.text = text end
    self.dropLayout = ScrollLayout()
    self.dropLayout.dropdown = self
    self.dropLayout:addWidget(ScrollBar())

    self.dropLayout.handleEvent = function(self, event, p1, p2, p3, p4, p5)
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
    end

    self.dropLayout.onLoseFocus = function()
      if not self.clicked then
        self:close()
      end
    end

    self.x = 23
    self.y = 6
    self.width = 16
    self.height = 3
    self.color = colors.gray
    self.dropdownColor = colors.gray
  end;

  lasty = 1;
  opt = Label();
  addOption = function(self, opt)
    local l = table.deepcopy(self.opt)
    l.text = opt
    l.y = self.lasty
    l.width = self.width - 2
    self.lasty = self.lasty + 1
    self.dropLayout:addWidget(l)
  end;

  onClick = function(self, button, x, y)
    self.clicked = true
  end;

  onClickUp = function(self, button, x, y, inside)
    self.clicked = false
    if not inside then return nil end

    self.dropLayout.visible = not self.dropLayout.visible
    self.open = self.dropLayout.visible

    if self.open then
      self.parent:addWidget(self.dropLayout)
      self.parent.focused = self.dropLayout
    else
      self.parent:removeWidget(self.dropLayout)
    end
  end;

  select = function(self, option)
    for i, v in ipairs(self.dropLayout.widgets) do
      if v == option then
        self.text = v.text
        self.selected = i
        self:close()
        self:onSelect(v.text, i)
        break
      end
    end
  end;

  onSelect = function(self, option, id) end;

  close = function(self)
    self.dropLayout.visible = false
    self.open = false

    if self.open then
      self.parent:addWidget(self.dropLayout)
      self.parent.focused = self.dropLayout
    else
      self.parent:removeWidget(self.dropLayout)
      self.parent.focused = self
    end
  end;

  draw = function(self, canvas)
    local x1, y1, x2, y2 = canvas:calcBounds(self.x1, self.y1, self.x2, self.y2, self.alignment, 0, 0)
    self.bounds = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
    rawset(self, "height", 1)
    if self.clicked then
      canvas:drawBox(self.bounds, self.clickedColor or self.textColor, self.alignment, #self.text)
      canvas:drawText(self.bounds, self.text, self.clickedColor and self.textColor or self.color, self.textAlignment, self.alignment)
      local align = self.textAlignment
      self.textAlignment = Alignment.right
      canvas:drawText(self.bounds, self.open and "\031" or "\016", self.clickedColor and self.textColor or self.color, self.textAlignment, self.alignment)
      self.textAlignment = align
    else
      canvas:drawBox(self.bounds, self.color, self.alignment, #self.text)
      canvas:drawText(self.bounds, self.text, self.textColor, self.textAlignment, self.alignment)
      local align = self.textAlignment
      self.textAlignment = Alignment.right
      canvas:drawText(self.bounds, self.open and "\031" or "\016", self.clickedColor and self.textColor or self.color, self.textAlignment, self.alignment)
      self.textAlignment = align
    end
    rawset(self, "height", nil)
  end;
}

Dropdown.opt.textAlignment = 0
Dropdown.opt.clickedColor = colors.cyan
Dropdown.opt.textColor = colors.white
Dropdown.opt.onClickUp = function(self, button, x, y, inside)
  if inside then self.parent.dropdown:select(self) end
  Label.onClickUp(self, button, x, y, inside)
end
