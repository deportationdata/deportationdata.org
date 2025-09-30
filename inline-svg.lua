-- inline-svg.lua (replace the Image() with this version)

local function read_file(path)
  local f = io.open(path, "r")
  if f then local s=f:read("*a"); f:close(); return s end
  if quarto and quarto.doc and quarto.doc.resolvePath then
    local resolved = quarto.doc.resolvePath(path)
    if resolved then
      local g = io.open(resolved, "r")
      if g then local s=g:read("*a"); g:close(); return s end
    end
  end
  return nil
end

local function add_svg_classes(svg)
  -- add Bootstrap/Quarto classes + responsive style
  local injected = false
  svg = svg:gsub("<svg([^>]*)>", function(attrs)
    injected = true
    local cls = attrs:match('class="([^"]*)"')
    local extra = ' d-block mx-auto img-fluid figure-img'
    if cls then
      attrs = attrs:gsub('class="([^"]*)"', 'class="%1' .. extra .. '"')
    else
      attrs = attrs .. ' class="d-block mx-auto img-fluid figure-img"'
    end
    -- ensure responsiveness
    if not attrs:match("style=") then
      attrs = attrs .. ' style="max-width:100%;height:auto;display:block"'
    end
    return "<svg" .. attrs .. ">"
  end, 1)
  return svg
end

function Image(img)
  local src = img.src or ""
  if src:match("%.svg$") then
    local svg = read_file(src)
    if not svg then return nil end
    svg = add_svg_classes(svg)
    return pandoc.RawInline("html", svg)
  end
  return nil
end