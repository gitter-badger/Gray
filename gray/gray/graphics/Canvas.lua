@include class.lua
@include AppCanvas.lua
@include ../ui/Alignment.lua

function math.clamp(n, min, max)
  return n < min and min or (n > max and max or n)
end

function math.round(n)
  return math.floor(n + 0.5)
end

class "Canvas" {
  x1 = 0;
  y1 = 0;
  x2 = 0;
  y2 = 0;
  width = 0;
  height = 0;
  xScroll = 0;
  yScroll = 0;

  calcBounds = function(self, x1, y1, x2, y2, alignment, minwidth, minheight)
    local xdiff = 0
    local ydiff = 0

    if x2 == x1 - 1 then
      x2 = x1 + self.width
    end

    if y2 == y1 - 1 then
      y2 = y1 + self.height
    end

    if x2 == x1 - 2 then
      x2 = x1 + minwidth
    end

    if y2 == y1 - 2 then
      y2 = y1 + minheight
    end

    if bit.band(alignment, 5) == 5 then
      xdiff = self.width * 0.25 - (x2 - x1) * 0.5
    elseif bit.band(alignment, 9) == 9 then
      xdiff = self.width * 0.75 - (x2 - x1) * 0.5
    elseif bit.band(alignment, 1) == 1 then
      xdiff = self.width * 0.5 - (x2 - x1) * 0.5
    elseif bit.band(alignment, 8) == 8 then
      xdiff = self.width - (x2 - x1)
    end

    if bit.band(alignment, 18) == 18 then
      ydiff = self.height * 0.25 - (y2 - y1) * 0.5
    elseif bit.band(alignment, 34) == 34 then
      ydiff = self.height * 0.75 - (y2 - y1) * 0.5
    elseif bit.band(alignment, 2) == 2 then
      ydiff = self.height * 0.5 - (y2 - y1) * 0.5
    elseif bit.band(alignment, 32) == 32 then
      ydiff = self.height - (y2 - y1)
    end

    return math.ceil(math.clamp(x1 + xdiff + self.x1 - self.xScroll - 1, self.x1, self.x2)),
           math.ceil(math.clamp(y1 + ydiff + self.y1 - self.yScroll - 1, self.y1, self.y2)),
           math.ceil(math.clamp(x2 + xdiff + self.x1 - self.xScroll - 1, self.x1, self.x2)),
           math.ceil(math.clamp(y2 + ydiff + self.y1 - self.yScroll - 1, self.y1, self.y2))
  end;

  drawBox = function(self, x1, y1, x2, y2, color, alignment, keeptext)
    if type(y1) == "table" then
      keeptext = color
      alignment = y2
      color = x2
      y2 = y1.y
      x2 = y1.x
      y1 = x1.y
      x1 = x1.x
    elseif type(x1) == "table" then
      keeptext = y2
      alignment = x2
      color = y1
      y2 = x1.y2
      x2 = x1.x2
      y1 = x1.y1
      x1 = x1.x1
    end

    if color == colors.transparent then return nil end
    for y = y1, y2 - 1 do
      for x = x1, x2 - 1 do
        AppCanvas.setPixel(x, y, color)
        if not keeptext then AppCanvas.setTextColor(x, y, 0) end
      end
    end
  end;

  drawText = function(self, x1, y1, x2, y2, text, textcolor, textAlignment, alignment, cursor, selectioncolor, selection, wrap, isfield)
    if type(y1) == "table" then
      isfield = selection
      wrap = selectioncolor
      selection = cursor
      selectioncolor = alignment
      cursor = textAlignment
      alignment = textcolor
      textAlignment = text
      textcolor = y2
      text = x2
      y2 = y1.y
      x2 = y1.x
      y1 = x1.y
      x1 = x1.x
    elseif type(x1) == "table" then
      isfield = selectioncolor
      wrap = cursor
      selection = alignment
      selectioncolor = textAlignment
      cursor = textcolor
      alignment = text
      textAlignment = y2
      textcolor = x2
      text = y1
      y2 = x1.y2
      x2 = x1.x2
      y1 = x1.y1
      x1 = x1.x1
    end

    cursor = cursor or 0
    selection = selection and selection - 1 or cursor

    local cx = 0
    local cy = 0
    local chome = 0
    local cend = 0
    local width = isfield and x2 - x1 - 1 or x2 - x1
    local height
    local lines
    if wrap then
      height = y2 - y1
      text = text:sub(1, width * height + 1)
      lines = #text / width
    else
      height = 1
      text = text:sub(1, width + 1)
      lines = 1
    end

    if x2 == x1 - 1 then
      x2 = x1 + self.width
    end

    if y2 == y1 - 1 then
      y2 = y1 + self.height
    end

    local alignX
    local alignY

    if bit.band(textAlignment, 5) == 5 then
      alignX = function(w)
        return width * 0.25 - w * 0.5
      end
    elseif bit.band(textAlignment, 9) == 9 then
      alignX = function(w)
        return width * 0.75 - w * 0.5
      end
    elseif bit.band(textAlignment, 1) == 1 then
      alignX = function(w)
        return width * 0.5 - w * 0.5
      end
    elseif bit.band(textAlignment, 8) == 8 then
      alignX = function(w)
        return width - w
      end
    else
      alignX = function(w)
        return 0
      end
    end

    if bit.band(textAlignment, 18) == 18 then
      alignY = function(h)
        return height * 0.25 - h * 0.5
      end
    elseif bit.band(textAlignment, 34) == 34 then
      alignY = function(h)
        return height * 0.75 - h * 0.5
      end
    elseif bit.band(textAlignment, 2) == 2 then
      alignY = function(h)
        return height * 0.5 - h * 0.5
      end
    elseif bit.band(textAlignment, 32) == 32 then
      alignY = function(h)
        return height - h
      end
    else
      alignY = function(h)
        return 0
      end
    end

    local ti = 1
    for y = 1, height do
      local tl = #text - ti + 1
      if tl > width then tl = width end
      local tx = math.ceil(alignX(tl) + x1)
      local ty = math.ceil(alignY(lines) + y + y1 - 1)
      if ty > y2 then
        break
      end

      if cursor >= ti and cursor <= ti + tl then
        chome = ti
        cend = ti + tl
        cx = tx + cursor - ti
        cy = ty
      end

      for x = 1, width do
        local sx = tx + x - 1
        if (cursor <= ti and selection >= ti) or (selection < ti and cursor > ti) then
          AppCanvas.setPixel(sx, ty, selectioncolor)
        end
        AppCanvas.setTextColor(sx, ty, textcolor)
        AppCanvas.setChar(sx, ty, text:sub(ti, ti))
        ti = ti + 1
        if ti > #text then
          return cx, cy, chome, cend
        end
      end

      if y > lines then
        break
      end
    end

    return cx, cy, chome, cend
  end;
}
