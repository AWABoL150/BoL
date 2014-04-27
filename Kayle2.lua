
if myHero.charName ~= "Kayle" then return end
local VERSION = 0.5

local latestVersion=nil

local updateCheck = false

--Auto Download Required LIBS

local REQUIRED_LIBS = {
		["VPrediction"] = "https://raw.github.com/honda7/BoL/master/Common/VPrediction.lua",
		["SOW"] = "https://raw.github.com/honda7/BoL/master/Common/SOW.lua",
		["SourceLib"] = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua",

	}



local DOWNLOADING_LIBS, DOWNLOAD_COUNT = false, 0
local SELF_NAME = GetCurrentEnv() and GetCurrentEnv().FILE_NAME or ""



function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		print("<b>[Kayle]: Required libraries downloaded successfully, please reload (double F9).</b>")
	end
end





for DOWNLOAD_LIB_NAME, DOWNLOAD_LIB_URL in pairs(REQUIRED_LIBS) do
	if FileExist(LIB_PATH .. DOWNLOAD_LIB_NAME .. ".lua") then
		require(DOWNLOAD_LIB_NAME)
	else
		DOWNLOADING_LIBS = true
		DOWNLOAD_COUNT = DOWNLOAD_COUNT + 1
		DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
	end
end


if DOWNLOADING_LIBS then return end

--End auto lib downloader



--Auto update

function getDownloadVersion(response)
        latestVersion = response
end

function getVersion()
        GetAsyncWebResult("dl.dropboxusercontent.com","/s/6oikm3fcp1lhitl/Kayle2.txt",getDownloadVersion)
end

function update()
   if updateCheck == false then
       local PATH = BOL_PATH.."Scripts\\Kayle2.lua"
       local URL = "https://dl.dropboxusercontent.com/s/eran6o9mj2sf8d8/Kayle2.lua"
       if latestVersion~=nil and latestVersion ~= VERSION then
           updateCheck = true
           PrintChat("UPDATING Kayle - "..SCRIPT_PATH:gsub("/", "\\").."Kayle2.lua")
           DownloadFile(URL, PATH,function ()
            PrintChat("UPDATED - Please Reload (F9 twice)")
            end)
        elseif latestVersion == VERSION then
            updateCheck = true
            PrintChat("Kayle is up to date")
        end
   end
end
AddTickCallback(update)
--end Autoupdate
 require "SOW"
 require "SourceLib"
 require "VPrediction" 


local Config = nil
local VP = VPrediction()

local FullCombo = {_Q,_E,_AA,_AA,_Q ,_IGNITE}

local SpellQ = {Speed = 1500, Range = 650, Delay = 0.5}

local SpellW = {Range = 900, Delay = 0.5}

local SpellE = {Range = 550}

local SpellR = {Range= 900 }

local Ranges = {[_Q] = 650, [_W] = 900, [_E] = 550, [_R] = 900}


local informationTable = {}
local spellExpired = true
local Ulti = nil 

function OnLoad()
Init()
ScriptSetUp()
PrintChat("<font color=\"#81BEF7\">Awa Kayle loaded</font>")
end

function Init()

Q = Spell(_Q, SpellQ.Range)
W = Spell(_W, SpellW.Range)
E = Spell(_E, SpellE.Range)
R = Spell(_R, SpellR.Range)

EnemyMinions = minionManager(MINION_ENEMY, SpellE.Range , myHero, MINION_SORT_MAXHEALTH_DEC)
JungleMinions = minionManager(MINION_JUNGLE, SpellE.Range, myHero, MINION_SORT_MAXHEALTH_DEC)

Loaded = true
end

function ScriptSetUp()
   TS = SimpleTS(STS_LESS_CAST_MAGIC)
   Orbwalker = SOW(VP)
   DrawHandler = DrawManager()
   DamageCalculator= DamageLib()

   DamageCalculator:RegisterDamageSource(_Q, _MAGIC, 10, 50, _MAGIC, _AP, 0.60, function() return (player:CanUseSpell(_Q) == READY) end)
   DamageCalculator:RegisterDamageSource(_E, _MAGIC, 10, 20, _MAGIC, _AP, 0.55, function() return (player:CanUseSpell(_E) == READY) end)

Config = scriptConfig("Kayle", "Kayle")
	
Config:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
Config:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('C'))

	Config:addSubMenu("Combo options", "ComboSub")
	Config:addSubMenu("Harass options", "HarassSub")
	Config:addSubMenu("Farm options", "FarmSub")
	Config:addSubMenu("Jungle Farm options", "JFarmSub")
	Config:addSubMenu("W options", "WSub")
	Config:addSubMenu("Ultimate", "Ultimate")
	Config:addSubMenu("Draw", "Draw")
	

 --Orbwalker
 Config:addSubMenu("Orbwalk", "Orbwalk")
 Orbwalker:LoadToMenu(Config.Orbwalk)

 --Combo and options 
  Config.ComboSub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Config.ComboSub:addParam("usePQ", "Use Packets for Q", SCRIPT_PARAM_ONOFF, true)
    Config.ComboSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
    Config.ComboSub:addParam("useW", "Use W to Gain speed if enemy is out of range", SCRIPT_PARAM_ONOFF, true)


    --Harass and options 
    
    Config.HarassSub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Config.HarassSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)

    --Farm and options 
    Config.FarmSub:addParam("Farm", "Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('V'))
    Config.FarmSub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Config.FarmSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)

    --Jungle farm and options 
		Config.JFarmSub:addParam("JFarm", "JFarm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('J'))
    Config.JFarmSub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
    Config.JFarmSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)

    --W options
    
    Config.WSub:addParam("LowAutoHealth", "Heal If health Under %",SCRIPT_PARAM_ONOFF, false)
    Config.WSub:addParam("AutoPercent", "Min Health % for Auto Heal", SCRIPT_PARAM_SLICE, 15, 0, 100, -1)
	Config.WSub:addParam("LowAAutoHealth", "Heal If Ally health Under %",SCRIPT_PARAM_ONOFF, false)
    Config.WSub:addParam("Percent", "Min Health % for Auto Heal ally", SCRIPT_PARAM_SLICE, 15, 0, 100, -1)

--Ultimate
	
Config.Ultimate:addParam("SUltimate", "Self ultimate", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('R'))
Config.Ultimate:addParam("AutoUlti", "AutoUlti Dangerous Spells(Allys also)",SCRIPT_PARAM_ONOFF, true)
Config.Ultimate:addParam("LowAutoUlti", "If health Under %",SCRIPT_PARAM_ONOFF, false)
Config.Ultimate:addParam("Percent", "Min Health % for Auto R", SCRIPT_PARAM_SLICE, 15, 0, 100, -1)
Config.Ultimate:addParam("LowAutoUlti", "If health Under %",SCRIPT_PARAM_ONOFF, false)
Config.Ultimate:addParam("AntiBitchs", "Anti Zed , fizz , vlad",SCRIPT_PARAM_ONOFF, false)



 --Draw
	
for spell, range in pairs(Ranges) do
		DrawHandler:CreateCircle(myHero, range, 1, {255, 255, 255, 255}):AddToMenu(Config.Draw, SpellToString(spell).." Range", true, true, true)
	end

	DamageCalculator:AddToMenu(Config.Draw, FullCombo)



	end

function Combo()

local Qfound = TS:GetTarget(SpellQ.Range)
local Efound = TS:GetTarget(SpellE.Range)

Orbwalker:EnableAttacks()


if  Qfound  then 
if GetDistance(Qfound , myHero) > SpellE.Range then 

	CastSpell(_W,myHero)

end 
end 

if Qfound and Q:IsReady() and Config.ComboSub.useQ and not Config.ComboSub.usePQ  then

 Q:Cast(Qfound)

 elseif Qfound and Config.ComboSub.usePQ  then 

 Packet("S_CAST", {spellId = _Q, targetNetworkId = Qfound.networkID}):send()

	end

if Efound and Config.ComboSub.useE then 

	E:Cast()

end 
end 


function Harass() 
local Qfound = TS:GetTarget(SpellQ.Range)
local Efound = TS:GetTarget(SpellE.Range)
Orbwalker:EnableAttacks()

if Qfound and Q:IsReady() and Config.HarassSub.useQ  then

 Q:Cast(Qfound)

 end 


 if Efound and Config.ComboSub.useE then 

	E:Cast()

end 

end 




function Farm()

  EnemyMinions:update()

local minion = EnemyMinions.objects[1]

Orbwalker:EnableAttacks()

if minion then

		if Config.FarmSub.useQ  then

			Q:Cast(minion)

		end

		if Config.FarmSub.useE then 

			E:Cast() 

		end 

	end 
end


function JFarm() 

JungleMinions:update()

Orbwalker:EnableAttacks()

local minion = JungleMinions.objects[1]

if minion then

		if Config.JFarmSub.useQ then

			Q:Cast(minion)

		end


if Config.JFarmSub.useE then 

			E:Cast() 

		end 
		
		end 
		end 
		

function DangerDetected()

if (myHero.health / myHero.maxHealth) <= (Config.Ultimate.Percent/ 100)  then
if CountEnemyHeroInRange(550, myHero) >= 1  then 

CastSpell(_R,myHero) 

end

end
end 
	

function HealMe()
if (myHero.health / myHero.maxHealth) <= (Config.WSub.AutoPercent/ 100)  then

CastSpell(_W,myHero) 
end 
end 

function HealHim()
local Allys = GetAllyHeroes()
for i, Ally in pairs(Allys) do
if (Ally.health / Ally.maxHealth) <= (Config.WSub.Percent/ 100) and GetDistance(Ally) < SpellW.Range   then
CastSpell(_W,Ally)
end 
end 
end 


	
function OnTick()

if Config.Combo then 

Combo() 

end 


if Config.Harass then 

	Harass() 

end 


if Config.FarmSub.Farm then 

	Farm()
end 

if Config.JFarmSub.JFarm  then 
	JFarm() 

end 

if Config.Ultimate.AutoUlti  then 

	opshit() 

end 

if Config.Ultimate.SUltimate then CastSpell(_R,myHero) end 

if Config.Ultimate.LowAutoUlti then DangerDetected() end 

if Config.WSub.LowAutoHealth then HealMe() end 

if Config.WSub.LowAAutoHealth then HealHim() end 

if Config.Ultimate.AntiBitchs then ShieldThatShit() end 

end 
	


function opshit()

if not spellExpired and (GetTickCount() - informationTable.spellCastedTick) <= (informationTable.spellRange/informationTable.spellSpeed)*1000 then
            local spellDirection     = (informationTable.spellEndPos - informationTable.spellStartPos):normalized()
            local spellStartPosition = informationTable.spellStartPos + spellDirection
            local spellEndPosition   = informationTable.spellStartPos + spellDirection * informationTable.spellRange
            local heroPosition = Point(myHero.x, myHero.z)

            local lineSegment = LineSegment(Point(spellStartPosition.x, spellStartPosition.y), Point(spellEndPosition.x, spellEndPosition.y))
            --lineSegment:draw(ARGB(255, 0, 255, 0), 70)

            if lineSegment:distance(heroPosition) <= 200 and R:IsReady() then
            	--print('Dodging dangerous spell with E')
                CastSpell(_R,myHero)
            end
						
        else
            spellExpired = true
            informationTable = {}
        end
				end


function OnProcessSpell(unit, spell)

if Config.Ultimate.AutoUlti then
		local DangerousSpellList = {
		['Amumu'] = {true, spell = _R, range = 550, projSpeed = math.huge},
		['Annie'] = {true, spell = _R, range = 600, projSpeed = math.huge},
		['Ashe'] = {true, spell= _R, range = 20000, projSpeed = 1600},
		['Jinx'] = {true, spell = _R, range = 20000, projSpeed = 1700},
		['Sona'] = {true, spell = _R, range = 1000, projSpeed = 2400},
		['Orianna'] = {true, spell = _R, range = 900, projSpeed = math.huge},
		
		}
	    if unit.type == 'obj_AI_Hero' and unit.team == TEAM_ENEMY and DangerousSpellList[unit.charName] and GetDistance(unit) < 2000 and spell ~= nil then
	        if spell.name == (type(DangerousSpellList[unit.charName].spell) == 'number' and unit:GetSpellData(DangerousSpellList[unit.charName].spell).name or DangerousSpellList[unit.charName].spell) then
	        	local Allys = GetAllyHeroes()
	        	for i, Ally in pairs(Allys) do
if spell.target ~= nil and spell.target.name == myHero.name then
					----print('Gapcloser: ',unit.charName, ' Target: ', (spell.target ~= nil and spell.target.name or 'NONE'), " ", spell.name, " ", spell.projectileID)
	        		if R:IsReady() then
	        			CastSpell(_R,myHero)
	        			print('Trying to dodge dangerous spell ' .. tostring(spell.name) .. ' with W!')
	        		end
							end 
							if spell.target ~= nil and spell.target.name ~= myHero.name and spell.target.name == Ally.name then
							if R:IsReady() then
	        			CastSpell(_R,Ally)
								end 
								 
							
							
	            else
	                spellExpired = false
	                informationTable = {
	                    spellSource = unit,
	                    spellCastedTick = GetTickCount(),
	                    spellStartPos = Point(spell.startPos.x, spell.startPos.z),
	                    spellEndPos = Point(spell.endPos.x, spell.endPos.z),
	                    spellRange = DangerousSpellList[unit.charName].range,
	                    spellSpeed = DangerousSpellList[unit.charName].projSpeed
	                }
	            end
	        end
	    end
	end
	end
	end 

--Credit pqmailer
function ShieldThatShit()
	if R:IsReady()  and (Ulti ~= nil and GetTickCount() > Ulti) then
		CastSpell(_R,myHero)
		Ulti = nil
	end
	
end 

 
 function OnGainBuff(unit, buff)
 	local UltiAble = {
	["Zed"] = {spellName = "zedultexecute", onApply = false},
	["Vladimir"] = {spellName = "vladimirhemoplaguedebuff", onApply = false},
	["Fizz"] = {spellName = "fizzmarinerdoombomb", onApply = true}
}
	if unit.isMe and buff and R:IsReady() then
		for _, Buff in pairs(UltiAble) do
			if Buff.spellName == buff.name then
				if Buff.onApply then
					Ulti = GetTickCount()
				else
					Ulti = GetTickCount() + (buff.duration*1000 - 2500)
				end
			end
		end
	end
end
--End Credit pqmailer






































