-- Export selected layers as individual PNG files
-- Script : Miisan

local sprite = app.activeSprite
if not sprite then
  app.alert("No active sprite")
  return
end

local spritePath = sprite.filename
if not spritePath or spritePath == "" then
  app.alert("Please save your sprite file first")
  return
end

local spriteDir = spritePath:match("(.*/)")
if not spriteDir then
  spriteDir = spritePath:match("(.*\\)")
end
if not spriteDir then
  spriteDir = "./"
end

local dlg = Dialog("Export Layers")

local layerData = {}
for i, layer in ipairs(sprite.layers) do
  local checkboxId = "layer_" .. i
  layerData[i] = {
    layer = layer,
    checkboxId = checkboxId,
    selected = layer.isVisible 
  }
  
  dlg:check {
    id = checkboxId,
    text = layer.name,
    selected = layer.isVisible
  }
end

dlg:separator()
dlg:button{ id="select_all", text="Select All" }
dlg:button{ id="select_none", text="Select None" }
dlg:separator()
dlg:button{ id="ok", text="Export Selected" }
dlg:button{ id="cancel", text="Cancel" }

dlg:modify{
  id="select_all",
  onclick=function()
    for i, data in ipairs(layerData) do
      dlg:modify{ id=data.checkboxId, selected=true }
    end
  end
}

dlg:modify{
  id="select_none", 
  onclick=function()
    for i, data in ipairs(layerData) do
      dlg:modify{ id=data.checkboxId, selected=false }
    end
  end
}

dlg:show()
if not dlg.data.ok then
  return
end

local originalVisibility = {}
for i, layer in ipairs(sprite.layers) do
  originalVisibility[i] = layer.isVisible
end

local selectedCount = 0
for i, data in ipairs(layerData) do
  if dlg.data[data.checkboxId] then
    selectedCount = selectedCount + 1
  end
end

if selectedCount == 0 then
  app.alert("No layers selected")
  return
end

local exportedCount = 0
for i, data in ipairs(layerData) do
  if dlg.data[data.checkboxId] then
    for j, otherLayer in ipairs(sprite.layers) do
      otherLayer.isVisible = false
    end
    
    data.layer.isVisible = true
    
    local layerName = data.layer.name:gsub("[<>:\"/\\|?*]", "_")
    local filename = spriteDir .. layerName .. ".png"
    
    local image = Image(sprite.spec)
    image:drawSprite(sprite, 1) 
    
    image:saveAs(filename)
    
    exportedCount = exportedCount + 1
    print("Exported: " .. filename)
  end
end

for i, layer in ipairs(sprite.layers) do
  layer.isVisible = originalVisibility[i]
end

app.alert("Exported " .. exportedCount .. " layers!")
