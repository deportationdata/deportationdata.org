-- Inline any .svg images by replacing <img src="...svg"> with the file's SVG markup.
-- No external Lua modules required.

local function read_file(path)
  -- First try raw path
  local f = io.open(path, "r")
  if f then
    local s = f:read("*a"); f:close()
    return s
  end
  -- If Quarto is available, resolve resource path (handles /_site/, project dirs, etc.)
  if quarto and quarto.doc and quarto.doc.resolvePath then
    local resolved = quarto.doc.resolvePath(path)
    if resolved then
      local g = io.open(resolved, "r")
      if g then
        local s = g:read("*a"); g:close()
        return s
      end
    end
  end
  return nil
end

function Image(img)
  local src = img.src or ""
  if src:match("%.svg$") then
    local svg = read_file(src)
    if not svg then
      -- Fail gracefully; leave image as-is if we can't read it
      return nil
    end
    -- Important: return RawInline so the SVG markup is inserted into the DOM.
    -- Quarto/Pandoc will keep surrounding figure/caption structure.
    return pandoc.RawInline("html", svg)
  end
  return nil
end