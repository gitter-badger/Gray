@include class.lua
@include Widget.lua

class "TextField" extends "Widget" {
  clickedColor = colors.cyan;
  selectionColor = colors.lightBlue;
  color = colors.lightGray;
  textColor = colors.gray;
  textAlignment = 0;
  focused = false;
  multiline = false;
  selecting = false;
  selection = 0;
  clicked = false;
  hscroll = 0;
  cursor = 1;
  chome = 0;
  cend = 0;
  text = "";
  hint = "";

  TextField = function(self, hint)
    self.hint = hint
  end;

  onKey = function(self, key, held)
    if key == keys.left then
      if self.selecting and not self.shiftPressed then
        self.selecting = false
        if self.selection < self.cursor then
          self.cursor = self.selection
        end
      elseif self.shiftPressed and not self.selecting then
        self.selection = self.cursor
        self.selecting = true

        if self.cursor > 1 then
          self.cursor = self.cursor - 1
        end
      elseif self.cursor > 1 then
        self.cursor = self.cursor - 1
      end
    elseif key == keys.right then
      if self.selecting and not self.shiftPressed then
        self.selecting = false
        if self.selection > self.cursor then
          self.cursor = self.selection
        end
      elseif self.shiftPressed and not self.selecting then
        self.selection = self.cursor
        self.selecting = true

        if self.cursor < #self.text + 1 then
          self.cursor = self.cursor + 1
        end
      elseif self.cursor < #self.text + 1 then
        self.cursor = self.cursor + 1
      end
    elseif key == keys.leftShift or key == keys.rightShift then
      self.shiftPressed = true
    elseif key == keys.enter and self.multiline then
      if self.selecting then
        self.selecting = false
        if self.selection > self.cursor then
          self.text = self.text:sub(1, self.cursor - 1) .. char .. self.text:sub(self.selection)
          self.cursor = self.cursor - 1
        else
          self.text = self.text:sub(1, self.selection - 1) .. char .. self.text:sub(self.cursor)
          self.cursor = self.selection + 1
        end
      else
        self.text = self.text:sub(1, self.cursor - 1) .. char .. self.text:sub(self.cursor)
        self.cursor = self.cursor + 1
      end
    elseif key == keys.backspace then
      if self.selecting then
        self.selecting = false
        if self.selection > self.cursor then
          self.text = self.text:sub(1, self.cursor - 1) .. self.text:sub(self.selection)
        else
          self.text = self.text:sub(1, self.selection - 1) .. self.text:sub(self.cursor)
          self.cursor = self.selection
        end
      elseif self.cursor > 1 then
        self.text = self.text:sub(1, self.cursor - 2) .. self.text:sub(self.cursor)
        self.cursor = self.cursor - 1
      end
    elseif key == keys.delete and self.cursor < #self.text + 1 then
      if self.selecting then
        self.selecting = false
        if self.selection > self.cursor then
          self.text = self.text:sub(1, self.cursor - 1) .. self.text:sub(self.selection)
        else
          self.text = self.text:sub(1, self.selection - 1) .. self.text:sub(self.cursor)
          self.cursor = self.selection
        end
      else
        self.text = self.text:sub(1, self.cursor - 1) .. self.text:sub(self.cursor + 1)
      end
    elseif key == keys.home then
      if self.selecting and not self.shiftPressed then
        self.selecting = false
      elseif self.shiftPressed and not self.selecting then
        self.selection = self.cursor
        self.selecting = true
      end

      self.cursor = self.chome
    elseif key == keys["end"] then
      if self.selecting and not self.shiftPressed then
        self.selecting = false
      elseif self.shiftPressed and not self.selecting then
        self.selection = self.cursor
        self.selecting = true
      end

      self.cursor = self.cend
    end
  end;

  onKeyUp = function(self, key)
    if key == keys.leftShift or key == keys.rightShift then
      self.shiftPressed = false
    end
  end;

  onChar = function(self, char)
    if self.selecting then
      self.selecting = false
      if self.selection > self.cursor then
        self.text = self.text:sub(1, self.cursor - 1) .. char .. self.text:sub(self.selection)
        self.cursor = self.cursor + 1
      else
        self.text = self.text:sub(1, self.selection - 1) .. char .. self.text:sub(self.cursor)
        self.cursor = self.selection + 1
      end
    else
      self.text = self.text:sub(1, self.cursor - 1) .. char .. self.text:sub(self.cursor)
      self.cursor = self.cursor + 1
    end
  end;

  onClick = function(self, button, x, y)
    if not self.multiline then
      self.cursor = math.min(x - self.hscroll + 2, #self.text + 1)
      self.selecting = true
      self.selection = self.cursor
    end
  end;

  onClickUp = function(self, button, x, y, inside)
    if self.clicked then
      if inside then
        self.focused = true
      else
        self.parent.focused = nil
      end
    end
    self.clicked = false
  end;

  onDrag = function(self, button, x, y, inside)
    if not self.multiline then
      self.cursor = math.min(x - self.hscroll + 2, #self.text + 1)
    end
  end;

  onFocus = function(self)
    self.clicked = true
  end;

  onLoseFocus = function(self)
    self.focused = false
    AppCanvas.setCursorBlink(false, false)
  end;

  draw = function(self, canvas)
    local x1, y1, x2, y2 = canvas:calcBounds(self.x1, self.y1, self.x2, self.y2, self.alignment, 0, 0)
    self.bounds = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
    if self.focused then
      canvas:drawBox(self, self.clicked and self.clickedColor or self.color, self.alignment)
    else
      canvas:drawBox(self, self.clicked and self.clickedColor or self.textColor, self.alignment)
    end

    local cx, cy = 0, 0
    if #self.text ~= 0 then
      if self.selecting and self.focused then
        cx, cy, self.chome, self.cend = canvas:drawText(self.bounds, self.text, self.focused and self.textColor or self.color, self.textAlignment, self.alignment, self.cursor, self.selectionColor, self.selection, self.multiline, true, self.hscroll)
      else
        cx, cy, self.chome, self.cend = canvas:drawText(self.bounds, self.text, self.focused and self.textColor or self.color, self.textAlignment, self.alignment, self.cursor, self.selectionColor, self.cursor, self.multiline, true, self.hscroll)
      end
    else
      cx, cy, self.chome, self.cend = canvas:drawText(self.bounds, self.hint, self.focused and self.textColor or self.color, self.textAlignment, self.alignment, self.cursor, self.selectionColor, self.cursor, self.multiline, true, self.hscroll, self.vscroll)
    end

    if self.focused then
      AppCanvas.setCursorBlink(cx, cy)
    end
  end;
}
