-- Panel Generator v1.2
-- Compatible with Aseprite v1.3+

function createPanel(width, height, roundedCorners, cornerRadius, hasBorder, borderColor, baseColor, shadowEnabled, position)
  local sprite = app.activeSprite
  if not sprite then
      app.alert("Please open a sprite first!")
      return
  end
  
  local panelLayer = sprite:newLayer()
  panelLayer.name = "Panel"
  
  local panelImage = Image(width, height, sprite.colorMode)
  
  if baseColor then
      for x = 0, width-1 do
          for y = 0, height-1 do
              if not shouldDrawPixel(x, y, width, height, roundedCorners, cornerRadius) then
                  goto continue
              end
              panelImage:drawPixel(x, y, baseColor)
              ::continue::
          end
      end
  end
  
  if hasBorder and borderColor then
      for x = roundedCorners and cornerRadius or 0, width - (roundedCorners and cornerRadius + 1 or 1) do
          panelImage:drawPixel(x, 0, borderColor)  -- Top
          panelImage:drawPixel(x, height-1, borderColor)  -- Bottom
      end
      
      for y = roundedCorners and cornerRadius or 0, height - (roundedCorners and cornerRadius + 1 or 1) do
          panelImage:drawPixel(0, y, borderColor)  -- Left
          panelImage:drawPixel(width-1, y, borderColor)  -- Right
      end
      
      if roundedCorners then
          drawRoundedCorners(panelImage, width, height, cornerRadius, borderColor)
      end
  end
  
  sprite:newCel(panelLayer, app.activeFrame.frameNumber, panelImage, position)
  
  if shadowEnabled then
      addShadow(sprite, width, height, roundedCorners, cornerRadius, position)
  end
end

function shouldDrawPixel(x, y, width, height, roundedCorners, radius)
  if not roundedCorners then return true end
  
  -- Check each corner
  if x < radius and y < radius then  -- Top-left
      return ((x - radius)^2 + (y - radius)^2) <= radius^2
  elseif x >= width-radius and y < radius then  -- Top-right
      return ((x - (width-radius-1))^2 + (y - radius)^2) <= radius^2
  elseif x < radius and y >= height-radius then  -- Bottom-left
      return ((x - radius)^2 + (y - (height-radius-1))^2) <= radius^2
  elseif x >= width-radius and y >= height-radius then  -- Bottom-right
      return ((x - (width-radius-1))^2 + (y - (height-radius-1))^2) <= radius^2
  end
  
  return true
end

function drawRoundedCorners(image, width, height, radius, color)
  local function drawArc(centerX, centerY, radius, startAngle, endAngle)
      for angle = startAngle, endAngle, 0.01 do
          local x = centerX + math.floor(radius * math.cos(angle))
          local y = centerY + math.floor(radius * math.sin(angle))
          if x >= 0 and x < width and y >= 0 and y < height then
              image:drawPixel(x, y, color)
          end
      end
  end
  
  drawArc(radius, radius, radius, math.pi, 3*math.pi/2)  -- Top-left
  drawArc(width-radius-1, radius, radius, 3*math.pi/2, 2*math.pi)  -- Top-right
  drawArc(radius, height-radius-1, radius, math.pi/2, math.pi)  -- Bottom-left
  drawArc(width-radius-1, height-radius-1, radius, 0, math.pi/2)  -- Bottom-right
end

function addShadow(sprite, width, height, roundedCorners, radius, position)
  local shadowLayer = sprite:newLayer()
  shadowLayer.name = "Panel Shadow"
  
  local shadowImage = Image(width + 4, height + 4, sprite.colorMode)
  local shadowColor = Color{ r=0, g=0, b=0, a=64 }
  
  local shadowOffset = 2
  local shadowPosition = Point(position.x - shadowOffset, position.y - shadowOffset)
  
  for x = shadowOffset, width+shadowOffset-1 do
      for y = shadowOffset, height+shadowOffset-1 do
          if x < width+4 and y < height+4 and shouldDrawPixel(x-shadowOffset, y-shadowOffset, width, height, roundedCorners, radius) then
              shadowImage:drawPixel(x, y, shadowColor)
          end
      end
  end
  
  sprite:newCel(shadowLayer, app.activeFrame.frameNumber, shadowImage, shadowPosition)
  
  shadowLayer.stackIndex = #sprite.layers - 1
end

if not app.activeSprite then
  app.alert("Please open a sprite first!")
  return
end

local dlg = Dialog("Panel Generator")

dlg:number{ id="width", label="Width:", text="100", decimals=0 }
 :number{ id="height", label="Height:", text="50", decimals=0 }
 :number{ id="x", label="X Position:", text=tostring(app.activeCel and app.activeCel.position.x or 0), decimals=0 }
 :number{ id="y", label="Y Position:", text=tostring(app.activeCel and app.activeCel.position.y or 0), decimals=0 }
 :check{ id="roundedCorners", label="Rounded Corners:", selected=true }
 :number{ id="cornerRadius", label="Corner Radius:", text="8", decimals=0 }
 :check{ id="hasBorder", label="Add Border:", selected=true }
 :color{ id="borderColor", label="Border Color:", color=Color{r=0,g=0,b=0} }
 :color{ id="baseColor", label="Base Color:", color=Color{r=255,g=255,b=255} }
 :check{ id="shadow", label="Add Shadow:", selected=true }
 :button{ id="generate", text="Generate Panel",
     onclick=function()
         local data = dlg.data
         local position = Point(data.x, data.y)
         app.transaction(
             function()
                 createPanel(
                     data.width,
                     data.height,
                     data.roundedCorners,
                     data.cornerRadius,
                     data.hasBorder,
                     data.borderColor,
                     data.baseColor,
                     data.shadow,
                     position
                 )
             end
         )
     end
 }
 :show{ wait=false }