local VERSION = "0.2"

if myHero.charName ~= "Zyra" then return end

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
        print("<b>[Morgana]: Required libraries downloaded successfully, please reload (double F9).</b>")
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

local latestVersion=nil

local updateCheck = false

--Auto update

function getDownloadVersion(response)
        latestVersion = response
end

function getVersion()
        GetAsyncWebResult("dl.dropboxusercontent.com","/s/f553ug0xxa6iwax/Zyra2.txt",getDownloadVersion)
end

function update()
   if updateCheck == false then
       local PATH = BOL_PATH.."Scripts\\Zyra2.lua"
       local URL = "https://dl.dropboxusercontent.com/s/khj63nceprveqhr/Zyra2.lua"
       if latestVersion~=nil and latestVersion ~= VERSION then
           updateCheck = true
           PrintChat("UPDATING Zyra - "..SCRIPT_PATH:gsub("/", "\\").."Zyra2.lua")
           DownloadFile(URL, PATH,function ()
            PrintChat("UPDATED - Please Reload (F9 twice)")
            end)
        elseif latestVersion == VERSION then
            updateCheck = true
            PrintChat("Zyra is up to date")
        end
   end
end
AddTickCallback(update)

--End auto update






local FullCombo = {_Q, _E , _R , _Q , _IGNITE}

require 'VPrediction'
require 'SourceLib'
require 'SOW'


local Config = nil

local VP = VPrediction()

local SpellQ = {Range =800 , Delay = 0.8, Width = 160 }

local SpellW = {Range =850}

local SpellE = {Speed = 1400 , Range =1050 , Delay = 0.5, Width = 70}

local SpellR = {Range =700 , Delay = 0.5, Width = 500}

local Pstacks = 0 

local AA = {Range= 550}

local Ranges = { [_Q] = 800 , [_W] = 850 , [_E] = 1150 , [_R] = 700}

local informationTable = {}

local spellExpired = true


function OnLoad()
getVersion()
Init()
ScriptSetUp()
PrintChat("<font color=\"#81BEF7\">Awa Zyra loaded</font>")
end


function Init()

--Full Spells 
Q = Spell(_Q, SpellQ.Range)
W = Spell(_W, SpellW.Range)
E = Spell(_E, SpellE.Range)
R = Spell(_R, SpellR.Range)

--W skillshot
Q:SetSkillshot(VP, SKILLSHOT_CIRCULAR, SpellQ.Width, SpellQ.Delay, false)
Q:SetAOE(true,SpellQ.Width,0)--sets Aoe for Q 

E:SetSkillshot(VP, SKILLSHOT_LINEAR, SpellE.Width, SpellE.Delay, SpellE.Speed, false)

R:SetSkillshot(VP, SKILLSHOT_CIRCULAR, SpellR.Width, SpellR.Delay, false)

R:SetAOE(true,SpellR.Width,0)--sets aoe For R 

--minion manager
EnemyMinions = minionManager(MINION_ENEMY, 1100, myHero, MINION_SORT_MAXHEALTH_DEC)
JungleMinions = minionManager(MINION_JUNGLE, 1100, myHero, MINION_SORT_MAXHEALTH_DEC)
Loaded = true
end

function ScriptSetUp()

VP = VPrediction()
TS = SimpleTS(STS_LESS_CAST_MAGIC)
Orbwalker = SOW(VP)
DrawHandler = DrawManager()
DamageCalculator= DamageLib()

DamageCalculator:RegisterDamageSource(_Q, _MAGIC, 35, 35, _MAGIC, _AP, 0.65, function() return (player:CanUseSpell(_Q) == READY) end)
DamageCalculator:RegisterDamageSource(_E, _MAGIC, 25, 35, _MAGIC, _AP, 0.50, function() return (player:CanUseSpell(_E) == READY) end)
DamageCalculator:RegisterDamageSource(_R, _MAGIC, 95, 85, _MAGIC, _AP, 0.70, function() return (player:CanUseSpell(_R) == READY) end)



Config = scriptConfig("Zyra", "Zyra")
Config:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
Config:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('C'))
Config:addParam("Farm", "Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('V'))

--Orbwalker
Config:addSubMenu("Orbwalk", "Orbwalk")
Orbwalker:LoadToMenu(Config.Orbwalk)

--Target Selector 

Config:addSubMenu("Target Selector", "TS")
TS:AddToMenu(Config.TS)

--Combo options

--Combo Type N 1 
Config:addSubMenu("Combo options", "ComboSub")
Config.ComboSub:addSubMenu("Combo Q>Seed>E options ", "ComboSub1")
Config.ComboSub.ComboSub1:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.ComboSub.ComboSub1:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)
Config.ComboSub.ComboSub1:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)


--Combo Type N 2 
--Config.ComboSub:addSubMenu("Combo E>Seed>Q options ", "ComboSub2")
--Config.ComboSub.ComboSub2:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
--Config.ComboSub.ComboSub2:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)
--Config.ComboSub.ComboSub2:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)


--Hitchances 
Config.ComboSub:addSubMenu("Hit chances ", "HitSub")
Config.ComboSub.HitSub:addParam("Qhitchance", "QHitchance", SCRIPT_PARAM_SLICE, 2, 1, 2, 0)
Config.ComboSub.HitSub:addParam("Ehitchance", "EHitchance", SCRIPT_PARAM_SLICE, 2, 1, 2, 0)


--Harass 
Config:addSubMenu("Harass options", "HarassSub")
Config.HarassSub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.HarassSub:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)
Config.HarassSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)

--Jungle Farm 
Config:addSubMenu("JungleFarm options", "JSub")
Config.JSub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.JSub:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)
Config.JSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
Config.JSub:addParam("JFarm", "JFarm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('V'))

--Farm
Config:addSubMenu("Farm  options", "FSub")
Config.FSub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.FSub:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)
Config.FSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)

--Ultimate
Config:addSubMenu("Ultimate", "Ultimate")
Config.Ultimate:addParam("AutoAim", "Auto_Aim Ultimate", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('R'))
Config.Ultimate:addParam("AutoR",  "Auto ultimate if ", SCRIPT_PARAM_LIST, 1, { "No", ">0 hit", ">1 hit", ">2 hit", ">3 hit", ">4 hit" })

--Advanced options
Config:addSubMenu("Advanced  options", "ASub")
Config.ASub:addParam("useE", "Auto Use E on Gapclose", SCRIPT_PARAM_ONOFF, true) 
Config.ASub:addParam("useP", "Auto Use Passive on Lowest Enemy", SCRIPT_PARAM_ONOFF, true)

--Draw
Config:addSubMenu("Draw", "Draw")
for spell, range in pairs(Ranges) do
 DrawHandler:CreateCircle(myHero, range, 1, {255, 255, 255, 255}):AddToMenu(Config.Draw, SpellToString(spell).." Range", true, true, true)
   end
DamageCalculator:AddToMenu(Config.Draw, FullCombo)

--Permashow
Config:permaShow("Combo")
Config:permaShow("Harass")
Config:permaShow("Farm")
end


function Combo()

Q:SetHitChance(Config.ComboSub.HitSub.Qhitchance)
E:SetHitChance(Config.ComboSub.HitSub.Ehitchance)

--Targets 
local Qfound = TS:GetTarget(SpellQ.Range)
local Wfound = TS:GetTarget(SpellW.Range)
local Efound = TS:GetTarget(SpellE.Range)
local Rfound = TS:GetTarget(SpellR.Range)

if Efound and E:IsReady() and Config.ComboSub.ComboSub1.useE and GetDistance(Efound)< SpellE.Range then 

E:Cast(Efound)
if W:IsReady() then 
W:Cast(Efound)
end 

end 


if Qfound and Q:IsReady() and Config.ComboSub.ComboSub1.useQ and (not E:IsReady() or not Config.ComboSub.ComboSub1.useE) then 


Q:Cast(Qfound)
if W:IsReady() then 
W:Cast(Qfound)
end 

end 

 if Wfound and W:IsReady() and  Config.ComboSub.ComboSub1.useW  and TargetHaveBuff('zyragraspingrootshold',Wfound)  then
W:Cast(Wfound)

end 

end
  
    


function Harass() 
local Qfound = TS:GetTarget(SpellQ.Range)
local Wfound = TS:GetTarget(SpellW.Range)
local Efound = TS:GetTarget(SpellE.Range)

if Efound and E:IsReady() and Config.HarassSub.useE then 

E:Cast(Efound) 

if W:IsReady() then 

W:Cast(Efound)

end
end 

if Qfound and Q:IsReady() and Config.HarassSub.useQ then 

Q:Cast(Qfound)
    
if W:IsReady() then 

W:Cast(Qfound)

end 

end 


end 

function JFarm()

JungleMinions:update()

local JungleObject = JungleMinions.objects[1]

if JungleObject then

if Config.JSub.useQ and (not E:IsReady() or not Config.JSub.useE) then

local BestPos, BestHit = GetBestCircularFarmPosition(SpellQ.Range, SpellQ.Width, JungleMinions.objects)

CastSpell(_Q, BestPos.x, BestPos.z)

if Config.JSub.useW then 

if W:IsReady() then

CastSpell(_W, BestPos.x, BestPos.z)
end 
end 

end

if Config.JSub.useE then

E:Cast(JungleObject)


end
end
end



function farm()
EnemyMinions:update()

local Minion_Object = EnemyMinions.objects[1]

if Minion_Object then

 if Config.FSub.useQ  and (not E:IsReady() or not Config.FSub.useE) then 
 
local RangedMinions = SelectUnits(EnemyMinions.objects, function(t) return (t.charName:lower():find("wizard") or t.charName:lower():find("caster")) and ValidTarget(t) end)

RangedMinions = GetPredictedPositionsTable(VP, RangedMinions, SpellQ.Delay , SpellQ.Width , SpellQ.Width , math.huge, myHero, false)


local BestPos, BestHit = GetBestCircularFarmPosition(SpellQ.Range, SpellQ.Width, RangedMinions)

if BestHit > 2 then

CastSpell(_Q, BestPos.x, BestPos.z)


if Config.FSub.useW then 

CastSpell(_W, BestPos.x, BestPos.z)

end 

if not RangedMinions then 

local BestPos, BestHit = GetBestCircularFarmPosition(SpellQ.Range, SpellQ.Width, EnemyMinions)

if BestHit > 2 then

CastSpell(_Q, BestPos.x, BestPos.z)

end 
end 



do return end

end
end 

if Config.FSub.useE then 

local BestPos, BestHit = GetBestLineFarmPosition(SpellE.Range, SpellE.Width, EnemyMinions.objects)

if BestHit > 2 then

CastSpell(_E, BestPos.x, BestPos.z)

do return end

end

    
end 
end 
end 


function OnGainBuff(unit, buff)
    if unit.isMe and buff.name == 'zyrapqueenofthorns' then
        Imhalfdead = true 
    end 
end



function OnLoseBuff(unit, buff)
    if unit.isMe and buff.name == 'zyrapqueenofthorns' then
        Imhalfdead = false
    end 
end


function AutoCastPassive() 
if Imhalfdead then 
local Enemies = GetEnemyHeroes()
local passiveDmg = 80 + (20*myHero.level)
for i, enemy in pairs(Enemies) do
if passiveDmg >= enemy.health then 
E:Cast(enemy) 
end 
end 
end 
end 

function AutoTracker() 
local Rfound = TS:GetTarget(SpellR.Range)
local MinimumHit = Config.Ultimate.AutoR - 1
if Rfound ~= nil  then 
if R:IsReady()  then 

local AOECastPosition, MainTargetHitChance, nTargets = VP:GetCircularAOECastPosition(Rfound, SpellR.Delay, SpellR.Width, SpellR.Range, SpellR.Speed)

if nTargets >= MinimumHit then

CastSpell(_R, AOECastPosition.x, AOECastPosition.z)

end 
end 
end 
end 






function OnTick()

if Loaded then


local Rfound = TS:GetTarget(SpellR.Range)

if Config.Ultimate.AutoAim then 

R:Cast(Rfound)

    end 


if Config.Combo then


Combo()

end


if Config.Harass then 

    Harass()

end 

if Config.JSub.JFarm then

    JFarm()

end 

if Config.Farm then 

    farm()

end 

if Config.ASub.useP then 

AutoCastPassive()

end 

if Config.ASub.useE then 

opshit()

end 

if Config.Ultimate.AutoR - 1 >= 2  then

AutoTracker()

end 

end
end



function opshit()

if not spellExpired and (GetTickCount() - informationTable.spellCastedTick) <= (informationTable.spellRange/informationTable.spellSpeed)*1000 then
            local spellDirection     = (informationTable.spellEndPos - informationTable.spellStartPos):normalized()
            local spellStartPosition = informationTable.spellStartPos + spellDirection
            local spellEndPosition   = informationTable.spellStartPos + spellDirection * informationTable.spellRange
            local heroPosition = Point(myHero.x, myHero.z)

            local lineSegment = LineSegment(Point(spellStartPosition.x, spellStartPosition.y), Point(spellEndPosition.x, spellEndPosition.y))
            --lineSegment:draw(ARGB(255, 0, 255, 0), 70)

            if lineSegment:distance(heroPosition) <= 200 and E:IsReady() then
                --print('Trying to stop gapclose with E ')
                CastSpell(_E,unit.x,unit.y)
            end
                        
        else
            spellExpired = true
            informationTable = {}
        end
                end


function OnProcessSpell(unit, spell)
if Config.ASub.useE then
                local isAGapcloserUnit = {
    --        ['Ahri']        = {true, spell = _R, range = 450,   projSpeed = 2200},
            ['Aatrox']      = {true, spell = _Q,                  range = 1000,  projSpeed = 1200, },
            ['Akali']       = {true, spell = _R,                  range = 800,   projSpeed = 2200, }, -- Targeted ability
            ['Alistar']     = {true, spell = _W,                  range = 650,   projSpeed = 2000, }, -- Targeted ability
            ['Diana']       = {true, spell = _R,                  range = 825,   projSpeed = 2000, }, -- Targeted ability
            ['Gragas']      = {true, spell = _E,                  range = 600,   projSpeed = 2000, },
            ['Hecarim']     = {true, spell = _R,                  range = 1000,  projSpeed = 1200, },
            ['Irelia']      = {true, spell = _Q,                  range = 650,   projSpeed = 2200, }, -- Targeted ability
            ['JarvanIV']    = {true, spell = jarvanAddition,      range = 770,   projSpeed = 2000, }, -- Skillshot/Targeted ability
            ['Jax']         = {true, spell = _Q,                  range = 700,   projSpeed = 2000, }, -- Targeted ability
            ['Jayce']       = {true, spell = 'JayceToTheSkies',   range = 600,   projSpeed = 2000, }, -- Targeted ability
            ['Khazix']      = {true, spell = _E,                  range = 900,   projSpeed = 2000, },
            ['Leblanc']     = {true, spell = _W,                  range = 600,   projSpeed = 2000, },
            ['LeeSin']      = {true, spell = 'blindmonkqtwo',     range = 1300,  projSpeed = 1800, },
            ['Leona']       = {true, spell = _E,                  range = 900,   projSpeed = 2000, },
            ['Malphite']    = {true, spell = _R,                  range = 1000,  projSpeed = 1500 + unit.ms},
            ['Maokai']      = {true, spell = _Q,                  range = 600,   projSpeed = 1200, }, -- Targeted ability
            ['MonkeyKing']  = {true, spell = _E,                  range = 650,   projSpeed = 2200, }, -- Targeted ability
            ['Pantheon']    = {true, spell = _W,                  range = 600,   projSpeed = 2000, }, -- Targeted ability
            ['Poppy']       = {true, spell = _E,                  range = 525,   projSpeed = 2000, }, -- Targeted ability
            --['Quinn']       = {true, spell = _E,                  range = 725,   projSpeed = 2000, }, -- Targeted ability
            ['Renekton']    = {true, spell = _E,                  range = 450,   projSpeed = 2000, },
            ['Sejuani']     = {true, spell = _Q,                  range = 650,   projSpeed = 2000, },
            ['Shen']        = {true, spell = _E,                  range = 575,   projSpeed = 2000, },
            ['Tristana']    = {true, spell = _W,                  range = 900,   projSpeed = 2000, },
            ['Tryndamere']  = {true, spell = 'Slash',             range = 650,   projSpeed = 1450, },
            ['XinZhao']     = {true, spell = _E,                  range = 650,   projSpeed = 2000, }, -- Targeted ability
        }
        if unit.type == 'obj_AI_Hero' and unit.team == TEAM_ENEMY and isAGapcloserUnit[unit.charName] and GetDistance(unit) < 2000 and spell ~= nil then
            if spell.name == (type(isAGapcloserUnit[unit.charName].spell) == 'number' and unit:GetSpellData(isAGapcloserUnit[unit.charName].spell).name or isAGapcloserUnit[unit.charName].spell) then
                if spell.target ~= nil and spell.target.name == myHero.name or isAGapcloserUnit[unit.charName].spell == 'blindmonkqtwo' then
                    ----print('Gapcloser: ',unit.charName, ' Target: ', (spell.target ~= nil and spell.target.name or 'NONE'), " ", spell.name, " ", spell.projectileID)
                    if E:IsReady()then
                        CastSpell(_E,unit.x,unit.y)
                        --print('Trying to stop Gapclosing  ' .. tostring(spell.name) .. ' with E!')
                    end
                else
                    spellExpired = false
                    informationTable = {
                        spellSource = unit,
                        spellCastedTick = GetTickCount(),
                        spellStartPos = Point(spell.startPos.x, spell.startPos.z),
                        spellEndPos = Point(spell.endPos.x, spell.endPos.z),
                        spellRange = isAGapcloserUnit[unit.charName].range,
                        spellSpeed = isAGapcloserUnit[unit.charName].projSpeed
                    }
                end
            end
        end
    end 
    
end 













