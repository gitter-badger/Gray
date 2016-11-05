function textutils.contains(t, v)
  for i = 1, #t do
    if t[i] == v then
      return true
    end
  end

  return false
end

function textutils.startswith(str, start)
  if str and start then
    return string.sub(str, 1, string.len(start)) == start
  else
    return false
  end
end

function textutils.split(inputstr, sep)
  sep = sep or "%s"

  local t = {}
  local i = 1

  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
    t[i] = str
    i = i + 1
  end

  return t
end

function textutils.chars(str)
  local c = {}

  for i = 1, #str do
    table.insert(c, str:sub(i, i))
  end

  return c
end
