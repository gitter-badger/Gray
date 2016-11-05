@include class.lua

class "Window" {
  x = 1;
  y = 1;
  width = 0;
  height = 0;
  buttons = {{"_", colors.lightGray}, {"=", colors.lightGray}, {"x", colors.red}};
  term;

  Window = function(self, parent)
    self.term = window.create(parent and (parent.term or parent) or term.native(), 1, 1, 0, 0, true, self)
  end;

  removeAllButtons = function(self)
    self.buttons = {};
  end;

  removeButton = function(self, button)
    if type(button) == "string" then
      for i, v in ipairs(self.buttons) do
        if v[1] == button then
          table.remove(self.buttons, i)
          break
        end
      end
    elseif type(button) == "number" then
      table.remove(self.buttons, button)
    elseif type(button) == "table" then
      for i, v in ipairs(self.buttons) do
        if v == button then
          table.remove(self.buttons, i)
          break
        end
      end
    end
  end;

  addButton = function(self, text, color)
    table.insert(self.buttons, {text, color})
  end;

  setVisible = function(self, visible)
    self.term.setVisible(visible)
  end;

  redirect = function(self)
    term.redirect(self.term)
  end;

  reposition = function(self, x, y, width, height)
    self.term.reposition(x, y, width or self.width, height or self.height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
  end;

  resize = function(self, width, height)
    self.term.reposition(nil, nil, width, height)
    self.width = width
    self.height = height
  end;

  close = function(self)
    if self.term.close then
      self.term.close()
    else
      self.term.setVisible(false)
    end
    self.term = nil
  end;

  -- Callbacks
  onReposition = function(self, x, y) end;
  onResize = function(self, width, height) end;
  onButton = function(self, id, button) end;
}
