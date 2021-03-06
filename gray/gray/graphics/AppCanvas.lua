@include class.lua
@include Canvas.lua

term.width, term.height = term.getSize()

class "AppCanvas" {
  term = term.current();
  x1 = 1;
  y1 = 1;
  x2 = term.width + 1;
  y2 = term.height + 1;
  width = term.width;
  height = term.height;
  hscroll = 0;
  vscroll = 0;
  pixels = {};
  tcolors = {};
  chars = {};
  cursorx;
  cursory;

  AppCanvas = function(self)
    error("Cannot instantiate static class AppCanvas")
  end;

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

    return math.ceil(math.clamp(x1 + xdiff + self.x1 - 1, self.x1, self.x2)),
           math.ceil(math.clamp(y1 + ydiff + self.y1 - 1, self.y1, self.y2)),
           math.ceil(math.clamp(x2 + xdiff + self.x1 - 1, self.x1, self.x2)),
           math.ceil(math.clamp(y2 + ydiff + self.y1 - 1, self.y1, self.y2))
  end;

  setPixel = function(x, y, c)
    if c ~= colors.transparent then
      if not AppCanvas.pixels[y] then AppCanvas.pixels[y] = {} end
      AppCanvas.pixels[y][x] = c
    end
  end;

  setTextColor = function(x, y, c)
    if not AppCanvas.tcolors[y] then AppCanvas.tcolors[y] = {} end
    AppCanvas.tcolors[y][x] = c
  end;

  setChar = function(x, y, c)
    if not AppCanvas.chars[y] then AppCanvas.chars[y] = {} end
    AppCanvas.chars[y][x] = c
  end;

  setCursorBlink = function(x, y)
    AppCanvas.cursorx = x
    AppCanvas.cursory = y
  end;

  clear = function()
    AppCanvas.pixels = {}
    AppCanvas.tcolors = {}
    AppCanvas.chars = {}
  end;

  redraw = function()
    for y = AppCanvas.y1, AppCanvas.y2 do
      local pcol = AppCanvas.pixels[y]
      local tcol = AppCanvas.tcolors[y]
      local col = AppCanvas.chars[y]
      AppCanvas.term.setCursorPos(AppCanvas.x1, y)
      for x = AppCanvas.x1, AppCanvas.x2 do
        AppCanvas.term.setBackgroundColor(pcol and (pcol[x] or colors.black) or colors.black)
        local tc = tcol and tcol[x] or 0
        if tc == 0 then
          AppCanvas.term.write(" ")
        else
          AppCanvas.term.setTextColor(tc)
          AppCanvas.term.write(col and (col[x] or " ") or " ")
        end
      end
    end

    AppCanvas.term.setVisible(true)
    if AppCanvas.cursorx then
      AppCanvas.term.setCursorPos(AppCanvas.cursorx, AppCanvas.cursory)
      AppCanvas.term.setCursorBlink(true)
    else
      AppCanvas.term.setCursorBlink(false)
    end
    AppCanvas.term.setVisible(false)
  end;
}                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
