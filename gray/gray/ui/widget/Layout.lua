@include class.lua
@include ../../graphics/Canvas.lua
@include ../widget/Widget.lua

class "Layout" extends "Widget" {
  widgets = {};
  width = -1;
  height = -1;
  canvas;

  Layout = function(self)
    self.canvas = Canvas()
  end;

  addWidget = function(self, widget)
    widget.parent = self
    table.insert(self.widgets, widget)
  end;

  removeWidget = function(self, widget)
    for i, v in ipairs(self.widgets) do
      if v == widget then
        table.remove(self.widgets, i)
        break
      end
    end
  end;

  init = function(self)
    for _, w in ipairs(self.widgets) do
      w:init()
    end
  end;

  update = function(self)
    for _, w in ipairs(self.widgets) do
      w:update()
    end
  end;

  handleEvent = function(self, event, p1, p2, p3, p4, p5)
    for i = #self.widgets, 1, -1 do
      local w = self.widgets[i]
      if event == "mouse_click" then
        if p2 >= w.bounds.x1 and p2 < w.bounds.x2 and p3 >= w.bounds.y1 and p3 < w.bounds.y2 then
          w:handleEvent(event, p1, p2, p3)
          if self.focused ~= w then
            if self.focused then self.focused:onLoseFocus() end
            self.focused = w
            w:onFocus()
          end
          break
        elseif self.focused == w then
          w:onLoseFocus()
          self.focused = nil
        end
      elseif event == "mouse_up" or event == "mouse_drag" then
        if self.focused then
          self.focused:handleEvent(event, p1, p2, p3, p2 >= self.focused.bounds.x1 and p2 < self.focused.bounds.x2 and p3 >= self.focused.bounds.y1 and p3 < self.focused.bounds.y2)
          break
        end
      elseif event == "mouse_scroll" and p2 >= w.bounds.x1 and p2 <= w.bounds.x2 and p3 >= w.bounds.y1 and p3 <= w.bounds.y2 then
        w:handleEvent(event, p1, p2, p3)
        break
      elseif event == "key" and self.focused == w then
        w:handleEvent(event, p1, p2)
        break
      elseif event == "key_up" and self.focused == w then
        w:handleEvent(event, p1)
        break
      elseif event == "char" and self.focused == w then
        w:handleEvent(event, p1)
        break
      end
    end
  end;

  onLoseFocus = function(self)
    if self.focused then self.focused:onLoseFocus() end
    self.focused = nil
  end;

  draw = function(self, canvas)
    if not canvas then canvas = AppCanvas end
    self.canvas.x1, self.canvas.y1, self.canvas.x2, self.canvas.y2 = canvas:calcBounds(self.x1, self.y1, self.x2, self.y2, self.alignment, 0, 0)
    self.canvas.width = self.canvas.x2 - self.canvas.x1
    self.canvas.height = self.canvas.y2 - self.canvas.y1
    self.canvas.vscroll = canvas.vscroll
    self.bounds = self.canvas

    self.canvas:drawBox(self.bounds, self.color, self.alignment)
    for _, w in ipairs(self.widgets) do
      w:draw(self.canvas)
    end
  end;
}
