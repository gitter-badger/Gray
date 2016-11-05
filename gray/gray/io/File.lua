@include class.lua

class "File" {
  File = function(self, path)
    self.path = path or ""
  end;

  open = function(self, mode)
    return fs.open(self.path, mode)
  end;

  readLine = function(self, line)
    local h = fs.open(self.path, "r")
    local str
    for i = 1, line or 1 do
      str = h.readLine()
    end
    h.close()
    return str
  end;

  readAll = function(self)
    local h = fs.open(self.path, "r")
    local str = h.readAll()
    h.close()
    return str
  end;

  write = function(self, text)
    local h = fs.open(self.path, "w")
    h.write(text)
    h.close()
  end;

  append = function(self, text)
    local h = fs.open(self.path, "a")
    h.write(text)
    h.close()
  end;

  exists = function(self)
    return fs.exists(self.path)
  end;

  getDir = function(self)
    return fs.getDir(self.path)
  end;

  tostring = function(self)
    return self.path
  end;
}
