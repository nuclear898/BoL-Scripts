--[[
  Minion AutoAttack Indicator v0.2
  By Nuclear898
]]--

--vars
local version = 0.2
local myHero = GetMyHero()
local minions = minionManager(MINION_ENEMY, 1500)

function OnLoad()  
  AAIConfig = scriptConfig("Minion AutoAttack Indicator", "MAAIndicator")  
  AAIConfig:addParam("enabled", "Enable/disable this script", SCRIPT_PARAM_ONOFF, true) 
  AAIConfig:addParam("drawHpBarDividers", "Divide hp bars", SCRIPT_PARAM_ONOFF, true) 
  AAIConfig:addParam("drawRemainingAA", "Show remaining auto attacks", SCRIPT_PARAM_ONOFF, true) 
  AAIConfig:addParam("drawKillableBorder", "Draw a border around killable minions", SCRIPT_PARAM_ONOFF, true)
  AAIConfig:addSubMenu("Masteries", "masteries")
  AAIConfig.masteries:addParam("doSword", "Double-Edged Sword", SCRIPT_PARAM_ONOFF, false)
  AAIConfig.masteries:addParam("doSwordRanged", "Enable if ranged champion", SCRIPT_PARAM_ONOFF, false)
  AAIConfig.masteries:addParam("butcher", "Butcher", SCRIPT_PARAM_ONOFF, false)
  AAIConfig.masteries:addParam("havoc", "Havoc", SCRIPT_PARAM_ONOFF, false)
  PrintChat("Minion AutoAttack Indicator v" .. version .. " loaded")
end

function OnTick()
  if not AAIConfig.enabled then return end
  minions:update()
end

function OnDraw()  
  if not AAIConfig.enabled then return end  
  for _, mob in pairs(minions.objects) do
    if mob ~= nil and mob.valid and not mob.dead and mob.visible then     
      DrawMobIndicators(mob)
    end
  end
end

function DrawMobIndicators(mob)
  --PrintChat(mob.charName) -- debug
  --local barPos = GetUnitHPBarPos(mob) -- debug
  local position, width, height = GetHpBarInfo(mob)
  local aaDamage = myHero:CalcDamage(mob, myHero.totalDamage)
  local damageMod = 1.0
  if (AAIConfig.masteries.doSword) then 
    damageMod = damageMod + (AAIConfig.masteries.doSwordRanged and 0.015 or 0.02)
  end
  if (AAIConfig.masteries.havoc) then
    damageMod = damageMod + 0.03
  end
  
  aaDamage = math.floor(aaDamage * damageMod)
  
  if (AAIConfig.masteries.butcher) then
    aaDamage = aaDamage + 2
  end
 
  --PrintChat("damage: " .. tostring(aaDamage)) -- debug
  if (AAIConfig.drawHpBarDividers) then
    local aaWidth = (aaDamage / mob.maxHealth) * width
    local mobHealthWidth = (mob.health / mob.maxHealth) * width
	if mobHealthWidth > 1 then -- Prevent drawing on mobs that are too strong
      local bars = math.ceil(mobHealthWidth / aaWidth)
      local c = 1
      while (c <= bars) do
        local barX = position.x + (c * aaWidth)
        if (barX < position.x + mobHealthWidth) then
          DrawLine(barX, position.y - 1, barX, position.y + height, 1, 0xFF000000)
        end
        c = c + 1
      end
	end
  end
  local remainingAAs = math.ceil(mob.health / aaDamage)
  
  --DrawOutlineRectangle(position.x, position.y, width, height, 0xFF00FFFF) --border around hp bar
  if (AAIConfig.drawKillableBorder and mob.health <= aaDamage) then
    DrawOutlineRectangle(position.x-1, position.y-1, width+1, height+1, 0xFF00FF00) --border around hp bar
  end  
  if (AAIConfig.drawRemainingAA) then
    DrawText(tostring(remainingAAs), 14, position.x - 1, position.y - 13, (mob.health <= aaDamage) and 0xFF00FF00 or 0xFF00FFFF) --green text if can be lasthit, else cyan
  end
  
  --DrawLine(barPos.x, barPos.y, barPos.x+1, barPos.y, 1, 0xFF00FFFF) -- center --debug
  --DrawLine(position.x, position.y, position.x+1, position.y, 1, 0xFFFFFFFF) --rectangle start pos with offset --debug
end

--returns position of hp bar top left point and the hp bar's width and height
function GetHpBarInfo(mob)
    local barPos = GetUnitHPBarPos(mob)
    local width = 62
    local height = 4    
    barPos.x = barPos.x - 31
    barPos.y = barPos.y - 2
    return barPos, width, height
end

function DrawOutlineRectangle(x, y, width, height, color)  
  local lX = x - 1      -- left X
  local rX = x + width  -- right X
  local tY = y - 1      -- top Y  
  local bY = y + height -- bottom Y
  
  DrawLine(lX, tY, rX, tY,     1, color) --top hori
  DrawLine(lX, tY, lX, bY,     1, color) --left vert
  DrawLine(rX, tY, rX, bY + 1, 1, color) --right vert
  DrawLine(lX, bY, rX, bY,     1, color) --bottom hori
end
