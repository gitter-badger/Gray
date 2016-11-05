local args = {...}

function contains(t, v)
  for i = 1, #t do
    if t[i] == v then
      return true
    end
  end

  return false
end

function startswith(str, start)
  return str:sub(1, string.len(start)) == start
end

function split(inputstr, sep)
  sep = sep or "%s"

  local t = {}
  local i = 1

  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end

  return t
end

Library = {
  libs = {};
  load = function(path)
    local l = Library.Library()
    if Library.libs[path] then
      return Library.libs[path]
    else
      local lib = dofile(shell.resolve(path))
      if type(l) ~= "table" then
        error("Invalid library " .. path)
      end

      for _, v in ipairs(lib[1]) do
        l:pushdep(v)
      end

      for _, v in ipairs(lib[2]) do
        l:pushlookuppath(v)
      end

      for i, v in pairs(lib) do
        if type(i) ~= "number" then
          l:push(i, v)
        end
      end

      Library.libs[path] = l
      return l
    end
  end;

  Library = function()
    return {
      deps = {};
      lookuppaths = {};
      code = {};

      pushdep = function(self, path)
        if not contains(self.deps, path) then
          table.insert(self.deps, path)
        end
      end;

      pushlookuppath = function(self, path)
        if not contains(self.lookuppaths, path) then
          table.insert(self.lookuppaths, path)
        end
      end;

      push = function(self, name, code)
        self.code[name] = code
      end;

      build = function(self)
        local out = "return {{"

        if #self.deps ~= 0 then
          for _, v in ipairs(self.deps) do
            out = out .. "\"" .. v .. "\", "
          end
          out = out:sub(1, #out - 2)
        end
        out = out .. "}; {"

        if #self.lookuppaths ~= 0 then
          for _, v in ipairs(self.lookuppaths) do
            out = out .. "\"" .. v .. "\", "
          end
          out = out:sub(1, #out - 2)
        end
        out = out .. "};\n"

        for i, v in pairs(self.code) do
          out = out .. "  [\"" .. i .. "\"] = {{"

          if #v[1] ~= 0 then
            for _, v in ipairs(v[1]) do
              out = out .. "\"" .. v .. "\"" .. ", "
            end
            out = out:sub(1, #out - 2)
          end

          local t = 0
          while string.find(v[2], "]" .. string.rep("=", t) .. "]") do t = t + 1 end
          out = out .. "}, [" .. string.rep("=", t) .. "[" .. v[2] .. "]" .. string.rep("=", t) .. "]};\n"
        end

        out = out .. "}"
        return out
      end;
    }
  end;
}

setmetatable(Library, {__call = Library.Library})

LibFile = function()
  return {
    deps = {};
    code = "";

    pushdep = function(self, path)
      if not contains(self.deps, path) then
        table.insert(self.deps, path)
      end
    end;

    set = function(self, code)
      self.code = code
    end;

    build = function(self)
      return {self.deps, self.code}
    end;
  }
end;

setmetatable(Library, {__call = Library.Library})

function archive(out, ins)
  if not out then
    error("No output path")
  elseif not ins then
    error("No input files")
  end

  local lib = Library()
  for i = 1, #ins do
    local inl = Library.load(ins[i])
    for i, v in ipairs(inl.deps) do
      lib:pushdep(v)
    end
    for i, v in ipairs(inl.lookuppaths) do
      lib:pushlookuppath(v)
    end
    for i, v in pairs(inl.code) do
      lib:push(i, v)
    end
  end

  local handle = fs.open(shell.resolve(args[2]), "w")
  if not handle then
    error("Couldn't write to file " .. args[2])
  end

  handle.write(lib:build())
  handle.close()
  print("Saved to", args[2])
end

local mfpath = "makefile"
local mffunc = "make"
if args[1] == "makefile" or args[1] == "mf" then
  mfpath = args[2] or error("Makefile not found")
elseif args[1] == "archive" or args[1] == "ar" then
  if not args[2] then
    error("No output path")
  elseif not args[3] then
    error("No input files")
  end

  local files = {}
  for i = 3, #args do
    table.insert(files, args[i])
  end

  archive(args[2], files)
  error()
elseif args[1] then
  mffunc = args[1]
end

local locvars = [[do
  local __DYNAMIC_LIBRARIES__ = {}
  local __DYNAMIC_SYMBOLS__ = {}
  local __DL_LOOKUP_PATHS____ = {}
  ]]
local globvars = [[do
  __DYNAMIC_LIBRARIES__ = __DYNAMIC_LIBRARIES__ or {}
  __DYNAMIC_SYMBOLS__ = __DYNAMIC_SYMBOLS__ or {}
  __DL_LOOKUP_PATHS__ = __DL_LOOKUP_PATHS__ or {}
  ]]
local dlsym = [[function __dllookuppath(path)
    table.insert(__DL_LOOKUP_PATHS____, path)
  end
  function __dllookup(name, dirs)
    local result = fs.exists(shell.resolve(name)) and shell.resolve(name) or (fs.exists(name) and name or nil)
    if result then return result end
    for _, v in ipairs(dirs or __DL_LOOKUP_PATHS____) do
      result = fs.exists(shell.resolve(fs.combine(v, name))) and shell.resolve(fs.combine(v, name)) or (fs.exists(fs.combine(v, name)) and fs.combine(v, name) or nil)
      if result then return result end
    end
    return result
  end
  function __dlload(path)
    local lib
    if __DYNAMIC_LIBRARIES__[path] then
      lib = __DYNAMIC_LIBRARIES__[path]
    else
      lib = dofile(path)
      for _, v in ipairs(lib[1]) do
        __dlload(__dllookup(v, lib[2]))
      end
      __DYNAMIC_LIBRARIES__[path] = lib
    end
    return lib
  end
  function __dlsym(path, file, tab)
    local lib = __dlload(path)
    if (not lib) or (not lib[file]) then
      return false
    end
    if __DYNAMIC_SYMBOLS__[path .. ":" .. file] then
      return true
    end
    __DYNAMIC_SYMBOLS__[path .. ":" .. file] = true
    for _, v in ipairs(lib[file][1]) do
      if lib[v] then
        if not __dlsym(path, v) then print(path, v) return false end
      else
        local fail = true
        for i, l in pairs(__DYNAMIC_LIBRARIES__) do
          if __dlsym(i, v) then
            fail = false
            break
          end
        end
        if fail then return false end
      end
    end
    local f, err
    if tab then
      f, err = loadstring(tab .. " = (function()\n" .. lib[file][2] .. "\nend)()", fs.getName(path) .. ":" .. fs.getName(file))
    else
      f, err = loadstring(lib[file][2], fs.getName(path) .. ":" .. fs.getName(file))
    end
    if not f then
      for i = 1, 4 do
        err = err:sub(err:find(":") + 1, #err)
      end
      term.setTextColor(colors.red)
      error(fs.getName(path) .. ":" .. fs.getName(file) .. ":" .. err)
    end
    f()
    return true
  end
end
]]

local dir = shell.resolve("")
local root = fs.getDir(dir)
local makefilehandle = fs.open(shell.resolve(mfpath), "r")
local makefile = {}

if not makefilehandle then
  error("Makefile not found")
end

local s = makefilehandle.readAll()
makefile = loadstring("return {" .. s .. "}")()
makefilehandle.close()

if fs.exists(shell.resolve(makefile.output)) and fs.isDir(shell.resolve(makefile.output)) then
  error("Directory exists at \"" .. makefile.output .. "\"")
end

function make()
  local included = {}
  local defined = {}
  defined._ENV = defined

  local sourcedir = makefile.source
  local root

  local dlsymincluded = false
  local dynamiclookup = false
  local localdlink = false
  local lib

  if makefile.root then
    root = shell.resolve(makefile.root)
  elseif sourcedir then
    root = fs.getDir(sourcedir)
  else
    error("No source to build")
  end

  for i, v in ipairs(makefile.options or {}) do
    if v == "library" then
      lib = Library()
    elseif v == "dynamiclookup" then
      dynamiclookup = true
    elseif v == "localdlink" then
      localdlink = true
    end
  end

  if not makefile.source and not lib then
    error("No source to build")
  end

  if not makefile.output then
    makefile.output = "build"
  end

  if not makefile.include then
    makefile.include = {}
  end

  if not makefile.dynamiclibs then
    makefile.dynamiclibs = {}
  end

  if not makefile.libs then
    makefile.libs = {}
  end

  if not makefile.libpaths then
    makefile.libpaths = {}
  end

  if not makefile.options then
    makefile.options = {}
  end

  function resolvedl(path, dirs)
    local result
    for _, v in ipairs(dirs or makefile.libpaths) do
      result = (fs.exists(shell.resolve(fs.combine(v, path))) or fs.exists(fs.combine(v, path))) and fs.combine(v, path) or nil
      if result then
        return result
      end
    end
    return result or ((fs.exists(shell.resolve(path)) or fs.exists(path)) and path or nil)
  end

  local libs = {}
  function libload(path)
    local lib
    if libs[path] then
      lib = libs[path]
    else
      print(path)
      lib = dofile(path)
      for _, v in ipairs(lib[2]) do
        libload(resolvedl(v, lib[1]))
      end
      libs[path] = lib
    end
    return lib
  end

  function libsym(path, file, tab)
    local lib = libload(path)
    local result = ""

    if (not lib) or (not lib[file]) then
      return false
    end

    for _, v in ipairs(lib[file][1]) do
      if lib[v] then
        result = result .. libsym(path, v, false)
      else
        local fail = true
        for i, l in pairs(libs) do
          local r = libsym(i, v)
          if r then
            result = result .. (tab and tab .. " = (function()\n" .. r .. "\nreturn getfenv()\nend)()\n" or "do\n" .. r .. "\nend\n")
            fail = false
            break
          end
        end
        if fail then return false end
      end
    end

    local r = lib[file][2]
    result = result .. r
    return result
  end

  function handleInclude(a, srcdir, sourcename, i, tab)
    local fail = true
    local includefile = fs.combine(srcdir, a[2])

    if not fs.exists(includefile) or fs.isDir(includefile) then
      includefile = fs.combine(root, a[2])
    end

    if not fs.exists(includefile) or fs.isDir(includefile) then
      for i = 1, #makefile.include do
        includefile = shell.resolve(fs.combine(makefile.include[i], a[2]))
        if fs.exists(includefile) and not fs.isDir(includefile) then
          fail = false
          break
        end
      end
    else
      fail = false
    end

    if not fail then
      if not fs.exists(includefile) or fs.isDir(includefile) then
        error(sourcename .. ":" .. i .. ": Invalid include file")
      end

      if contains(included, includefile) then
        return ""
      end

      table.insert(included, includefile)
      local includehandle = fs.open(includefile, "r")

      if not includehandle then
        fail = true
      else
        local txt = includehandle.readAll()
        includehandle.close()
        local psrc = parseSource(txt, fs.getDir(includefile), fs.getName(includefile))
        return tab and tab .. " = (function()\n" .. psrc .. "\nreturn getfenv()\nend)()\n" or "do\n" .. psrc .. "\nend\n"
      end
    end

    if fail then
      for i, v in ipairs(makefile.libs) do
        local rdl = resolvedl(v)
        if rdl then
          local ls = libsym(rdl, a[2])
          if ls then
            if contains(included, rdl .. ":" .. a[2]) then
              return ""
            end

            table.insert(included, rdl .. ":" .. a[2])
            return tab and tab .. " = (function()\n" .. ls .. "\nreturn getfenv()\nend)()\n" or "do\n" .. ls .. "\nend\n"
          end
        end
      end
    end

    if fail then
      for i, v in ipairs(makefile.dynamiclibs) do
        local rdl = resolvedl(v)
        if rdl and dofile(rdl)[a[2]] then
          if contains(included, rdl .. ":" .. a[2]) then
            return ""
          end
          dlsymincluded = true
          fail = false
          if dynamiclookup then
            return "__dlsym(__dllookup(\"" .. rdl .. "\", \"" .. a[2] .. "\"))\n"
          else
            return "__dlsym(\"" .. rdl .. "\", \"" .. a[2] .. "\")\n"
          end
          table.insert(included, rdl .. ":" .. a[2])
          break
        else
          fail = true
        end
      end
    end

    if fail then
      error(sourcename .. ":" .. i .. ": Invalid include file")
    end
  end

  function parseSource(src, srcdir, sourcename)
    local file
    if lib then file = LibFile() end
    local fsource = ""
    local ifdef = true
    local chain = false
    local source = split(src, "\n")

    for i = 1, #source do
      local line = source[i] or ""

      if startswith(line, "@") then
        local a = split(line, " ")

        if a[1] == "@include" then
          if ifdef then
            if lib then
              local fail = true
              local includefile = fs.combine(srcdir, a[2])

              if not fs.exists(includefile) or fs.isDir(includefile) then
                includefile = fs.combine(root, a[2])
              end

              if not fs.exists(includefile) or fs.isDir(includefile) then
                for i = 1, #makefile.include do
                  includefile = shell.resolve(fs.combine(makefile.include[i], a[2]))
                  if fs.exists(includefile) and not fs.isDir(includefile) then
                    fail = false
                    break
                  end
                end
              else
                fail = false
              end

              if not fail then
                if not fs.exists(includefile) or fs.isDir(includefile) then
                  error(sourcename .. ":" .. i .. ": Invalid include file")
                end
                if not contains(included, includefile) then
                  table.insert(included, includefile)
                  local includehandle = fs.open(includefile, "r")

                  if not includehandle then
                    fail = true
                  else
                    local txt = includehandle.readAll()
                    includehandle.close()
                    lib:push(includefile:sub(#root + 2), parseSource(txt, fs.getDir(includefile), fs.getName(includefile)):build())
                  end
                end
                file:pushdep(includefile:sub(#root + 2))
              end

              if fail then
                for i, v in ipairs(makefile.libs) do
                  local rdl = resolvedl(v)
                  if rdl then
                    local ls = libsym(rdl, a[2])
                    if ls then
                      fail = false

                      if not contains(included, rdl .. ":" .. a[2]) then
                        table.insert(included, rdl .. ":" .. a[2])
                        local f = LibFile()
                        f:set(ls)
                        lib:push(rdl .. ":" .. a[2], f:build())
                      end

                      file:pushdep(rdl .. ":" .. a[2])
                    end
                  end
                end
              end

              if fail then
                for i, v in ipairs(makefile.dynamiclibs) do
                  local rdl = resolvedl(v)
                  if rdl and dofile(rdl)[a[2]] then
                    fail = false
                    lib:pushdep(fs.getName(rdl))
                    lib:pushlookuppath(fs.getDir(rdl))
                    file:pushdep(a[2])
                    table.insert(included, rdl .. ":" .. a[2])
                    break
                  else
                    fail = true
                  end
                end
              end

              if fail then
                error(sourcename .. ":" .. i .. ": Invalid include file")
              end
            else
              local tab

              if a[3] == "as" then
                if a[4] then
                  tab = a[4]
                else
                  error(sourcename .. ":" .. i .. ": Include name not specified")
                end
              end

              fsource = fsource .. handleInclude(a, srcdir, sourcename, i, tab)
            end
          end
        elseif a[1] == "@option" then
          if ifdef then
            if a[2] == "dynamiclookup" then
              dynamiclookup = a[3] and loadstring("return " .. a[3])() or true
            elseif a[2] == "library" then
              error(sourcename .. ":" .. i .. ": Cannot alter value of \"library\" option")
            end
          end
        elseif a[1] == "@libpath" then
          if ifdef and not contains(makefile.libpaths, a[2]) then
            if dynamiclookup then
              if lib then
                lib:pushlookuppath(fs.combine(srcdir, a[2]))
              else
                fsource = fsource .. "__dllookuppath(\"" .. fs.combine(srcdir, a[2]) .. "\")"
              end
            end
            table.insert(makefile.libpaths, a[2])
          end
        elseif a[1] == "@libload" then
          if ifdef then
            local rdl = resolvedl(a[2])
            table.insert(makefile.libs, (rdl or error(sourcename .. ":" .. i .. ": Invalid library file")))
            libload(rdl)
          end
        elseif a[1] == "@libsym" then
          if ifdef then
            local rdl = resolvedl(a[2]) or error(sourcename .. ":" .. i .. ": Invalid library file")
            local ls = libsym(rdl, a[3]) or error(sourcename .. ":" .. i .. ": Invalid library symbol")
            if lib then
              local f = LibFile()
              f:set(ls)
              lib:push(a[3], f:build())
              file:pushdep(a[3])
            else
              fsource = fsource .. "do\n" .. ls .. "\nend\n"
            end
          end
        elseif a[1] == "@dlload" then
          if ifdef then
            dlsymincluded = true
            if lib then
              local rdl = resolvedl(a[2]) or error(sourcename .. ":" .. i .. ": Invalid dynamic library")
              lib:pushlookuppath(fs.getDir(rdl))
              lib:pushdep(fs.getName(rdl))
            else
              if dynamiclookup then
                fsource = fsource .. "__dlload(__dllookup(\"" .. (resolvedl(a[2]) or error(sourcename .. ":" .. i .. ": Invalid dynamic library")) .. "\"))\n"
              else
                fsource = fsource .. "__dlload(\"" .. (resolvedl(a[2]) or error(sourcename .. ":" .. i .. ": Invalid dynamic library")) .. "\")\n"
              end
            end
            table.insert(makefile.dynamiclibs, resolvedl(a[2]))
          end
        elseif a[1] == "@dlsym" then
          if ifdef then
            dlsymincluded = true
            if lib then
              local rdl = resolvedl(a[2]) or error(sourcename .. ":" .. i .. ": Invalid dynamic library")
              lib:pushlookuppath(fs.getDir(rdl))
              lib:pushdep(fs.getName(rdl))
              file:pushdep(a[3])
            else
              if dynamiclookup then
                fsource = fsource .. "__dlsym(__dllookup(\"" .. (resolvedl(a[2]) or error(sourcename .. ":" .. i .. ": Invalid dynamic library")) .. "\", \"" .. a[3] .. "\"))" .. "\n"
              else
                fsource = fsource .. "__dlsym(\"" .. (resolvedl(a[2]) or error(sourcename .. ":" .. i .. ": Invalid dynamic library")) .. "\", \"" .. a[3] .. "\")" .. "\n"
              end
            end
          end
        elseif a[1] == "@define" then
          if ifdef then
            defined[a[2]] = loadstring("return " .. line:sub(9 + #a[2]))() or true
          end
        elseif a[1] == "@undefine" then
          if ifdef then
            defined[a[2]] = nil
          end
        elseif a[1] == "@if" then
          local f = loadstring("return " .. line:sub(5))
          setfenv(f, defined)
          if f() then
            ifdef = true
            chain = true
          else
            ifdef = false
            chain = false
          end
        elseif a[1] == "@ifn" then
          local f = loadstring("return " .. line:sub(5))
          setfenv(f, defined)
          if f() then
            ifdef = false
            chain = false
          else
            ifdef = true
            chain = true
          end
        elseif a[1] == "@ifdef" then
          if defined[a[2]] then
            ifdef = true
            chain = true
          else
            ifdef = false
            chain = false
          end
        elseif a[1] == "@ifndef" then
          if defined[a[2]] then
            ifdef = false
            chain = false
          else
            ifdef = true
            chain = true
          end
        elseif a[1] == "@else" then
          ifdef = (not chain) and (not ifdef)
        elseif a[1] == "@elseif" then
          ifdef = (not chain) and (not ifdef)

          if ifdef then
            local f = loadstring("return " .. line:sub(9))
            setfenv(f, defined)
            if f() then
              ifdef = true
              chain = true
            else
              ifdef = false
            end
          end
        elseif a[1] == "@elseifn" then
          ifdef = (not chain) and (not ifdef)

          if ifdef then
            local f = loadstring("return " .. line:sub(5))
            setfenv(f, defined)
            if f() then
              ifdef = false
            else
              ifdef = true
              chain = true
            end
          end
        elseif a[1] == "@elseifdef" then
          ifdef = (not chain) and (not ifdef)

          if ifdef then
            if defined[a[2]] then
              ifdef = true
              chain = true
            else
              ifdef = false
            end
          end
        elseif a[1] == "@elseifndef" then
          ifdef = (not chain) and (not ifdef)

          if ifdef then
            if defined[a[2]] then
              ifdef = false
            else
              ifdef = true
              chain = true
            end
          end
        elseif a[1] == "@endif" then
          ifdef = true
          chain = true
        elseif a[1] == "@file" then
          if ifdef then
            local handle = fs.open(fs.combine(srcdir, a[2]), "r")
            if not handle then
              error(sourcename .. ":" .. i .. ": Invalid file " .. a[2])
            end
            fsource = fsource .. handle.readAll() .. "\n"
            handle.close()
          end
        elseif a[1] == "@code" then
          if ifdef then
            local f = loadstring("return " .. line:sub(7))
            setfenv(f, defined)
            fsource = fsource .. f() .. "\n"
          end
        elseif a[1] == "@error" then
          if ifdef then
            local f = loadstring("return " .. line:sub(8))
            setfenv(f, defined)
            error(sourcename .. ":" .. i .. ": " .. f())
          end
        elseif a[1] == "@print" then
          if ifdef then
            local f = loadstring("return " .. line:sub(8))
            setfenv(f, defined)
            print(f())
          end
        else
          error(sourcename .. ":" .. i .. ": Invalid command")
        end
      elseif ifdef then
        fsource = fsource .. line .. "\n"
      end
    end

    if lib then
      file:set(fsource)
      return file
    else
      return fsource
    end
  end

  if lib then
    function ls(dir)
      for _, v in ipairs(fs.list(dir)) do
        local file = fs.combine(dir, v)
        if fs.isDir(file) then
          ls(file)
        else
          if not contains(included, file) then
            local sourcename = fs.getName(v)
            local sourcehandle = fs.open(file, "r")
            local source = sourcehandle.readAll()
            sourcehandle.close()
            lib:push(fs.combine(dir:sub(#root + 2), v), parseSource(source, dir, sourcename):build())
          end
        end
      end
    end
    ls(root)
    local outhandle = fs.open(shell.resolve(makefile.output), "w")
    outhandle.write(lib:build())
    outhandle.close()
  else
    local sourcename = fs.getName(shell.resolve(path or makefile.source))
    local sourcehandle = fs.open(sourcedir, "r")
    local source = sourcehandle.readAll()
    sourcehandle.close()
    local fsource = parseSource(source, fs.getDir(sourcedir), sourcename)
    if dlsymincluded then
      fsource = (localdlink and locvars or globvars) .. dlsym .. fsource
    end
    local outhandle = fs.open(shell.resolve(makefile.output), "w")
    outhandle.write(fsource)
    outhandle.close()
  end
end

if mffunc == "make" and not makefile.make then
  make()
elseif not makefile[mffunc] then
  error("Unknown command " .. args[1])
end

local env = {_ENV = makefile, make = make, shell = shell.run, error = error, print = print}
for i, v in pairs(makefile) do
  if i ~= "make" then
    env[i] = v
  end
end

setfenv(makefile[mffunc], env)
makefile[mffunc]()
