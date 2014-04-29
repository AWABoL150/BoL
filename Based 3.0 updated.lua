if myHero.charName ~= "Ezreal" and myHero.charName ~= "Ashe" and  myHero.charName ~= "Jinx"then return end

local Champions = {["Ezreal"] = {Speed = 2000, Delay = 1.0}, ["Ashe"] = {Speed = 1600, Delay = 0.125},["Jinx"] = {Speed = 2000, Delay = 1.0}}

local AwaBased = nil

local CastInfo = nil

local HotSpot = nil

local InformationTable = {}

local ShotPlaces = {
    ["Red"] = { x = 514.287109375,    y = -35.081577301025, z = 4149.9916992188  }, -- LEFT BASE              [4]
	["Blue"] = { x = 13311.96484375,    y = -37.369071960449, z = 4161.232421875  }  -- RIGHT BASE             [6]
}

local ShotPlaces1 = {
    ["Red"] = { x = 27, z = 265  }, -- LEFT BASE              [4]
	["Blue"] = { x = 13953, z = 14162  }  -- RIGHT BASE  
}


local function GetEnemyTeam()

	return (myHero.team == TEAM_BLUE and "Blue" or "Red")
	
end


local function DONOTUSE()

	return GetDistance(HotSpot) / CastInfo.Speed/1000 + CastInfo.Delay*1000 + GetLatency()*2
	
end

local function GetHitTime()

	return GetDistance(HotSpot) / (CastInfo.Speed/1000) + CastInfo.Delay*1000 + GetLatency()
	
end

local function IsInBounds()

local temp = GetHitTime()
	
return temp < 5000
	
end

function OnLoad()

init() 

Menu()

end

function init()
 
CastInfo = Champions[myHero.charName]

local map = GetGame().map.index

HotSpot = map == 1 and ShotPlaces1[GetEnemyTeam()] or ShotPlaces[GetEnemyTeam()]

PrintChat("<font color=\"#81BEF7\">Based 3.0 Updated By A.W.A </font>")

end 

function Menu() 

AwaBased = scriptConfig("Based!", "Based 3.0 Updated By A.W.A")

AwaBased:addParam("enabled", "Enable", SCRIPT_PARAM_ONOFF, true)

AwaBased:addParam("Debug", "Debug", SCRIPT_PARAM_ONOFF, false)

end 





function OnTick()

if InformationTable.Target ~= nil and AwaBased.enabled then
	
InformationTable.RecallTime = InformationTable.RecallTime - (GetTickCount() - InformationTable.Time)

InformationTable.Time = GetTickCount()

local hittime = GetHitTime()

if AwaBased.Debug then 

PrintChat("HitTime fuckin time".. hittime)

end 

if hittime >= InformationTable.RecallTime and hittime < InformationTable.RecallTime + 20 and myHero:CanUseSpell(_R) == READY then

if AwaBased.Debug then 

PrintChat("FIRED")

end 

CastSpell(_R, HotSpot.x, HotSpot.z)

end

end

end



function OnProcessSpell(unit, spell)

if unit.isMe and spell.name == myHero:GetSpellData(_R).name  then 

for i, k in pairs(InformationTable) do

InformationTable[i] = nil

if AwaBased.Debug then 

print('Everything Erased Effectively') 

end 

end

end

end 


function OnRecall(hero, channelTimeInMs) 
  
    if hero.team ~= myHero.team then
	
		if getDmg("R", hero, myHero) > hero.health and InformationTable.Target == nil then
		
			InformationTable.Target = hero
			
			InformationTable.Time = GetTickCount()
			
			InformationTable.RecallTime = channelTimeInMs+500
			
			InformationTable.RecallTimeStatic = channelTimeInMs+500
			
			if AwaBased.Debug then 
			
			PrintChat("We're trying to rape")
			
			end 
			
		end
		
    end
		
end

function OnAbortRecall(hero)      
          
    if InformationTable.Target ~= nil and hero.networkID == InformationTable.Target.networkID then
	
        InformationTable.Target = nil
		
    end
	
end
