if myHero.charName ~= "Fizz" then return end
--VERSION
local VERSION = 1.3

--AUTO LIBS DOWNLOADER
local AUTOUPDATE = true

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
        print("<b>[Fizz]: Required libraries downloaded successfully, please reload (double F9).</b>")
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



--END AUTO LIBS DOWNLOADER




--REQUIRED LIBS


  require "VPrediction"
    require "SOW"
    require "SourceLib"


--END REQUIRED LIBS

--GLOBALS


local MainCombo = {ItemManager:GetItem("DFG"):GetId(), _AA, _Q, _W, _E, _R, _IGNITE}


--Ranges
local Ranges = {[_Q] = 550, [_W] = 125, [_E] = 400, [_R] = 1275}
--Delays
local Delays = {[_Q] = 0.5, [_W] = 0,[_E]=0.5,[_R]=0.5}
--Widths
local Widths = {[_Q] = 0,[_E]=330,[_R]=80}
--Speeds
local Speeds = {[_E]=20,[_R]=1200}

-- E

local SpellE = {Speed = 20, Range =400, Delay = 0.5, Width = 330}





local informationTable = {}

local spellExpired = true

local levelSequence = {3,2,1,3,3,4,3,1,3,1,4,1,1,2,2,4,2,2 }

local Ename2=myHero:GetSpellData(_E).name

--AUTO UPDATER
function getDownloadVersion(response)
        latestVersion = response
end






function getVersion()
        GetAsyncWebResult("dl.dropboxusercontent.com","/s/fx5bl9pvv4c41m4/Fizzversion.txt",getDownloadVersion)
end





function update()
   if updateCheck == false then
       local PATH = BOL_PATH.."Scripts\\Fizz2.lua"
       local URL = "https://dl.dropboxusercontent.com/s/i2p29ovbj2kj31g/Fizz2.lua"
       if latestVersion~=nil and latestVersion ~= VERSION then
           updateCheck = true
           PrintChat("UPDATING Fizz The fisherman - "..SCRIPT_PATH:gsub("/", "\\").."Fizz2.lua")
           DownloadFile(URL, PATH,function ()
            PrintChat("UPDATED - Please Reload (F9 twice)")
            end)
        elseif latestVersion == VERSION then
            updateCheck = true
            PrintChat("Fizz the fisherman is up to date")
        end
   end
end
AddTickCallback(update)




--END AUTO UPDATER

function OnLoad()

    getVersion()

  VP = VPrediction()

    SOWi = SOW(VP)

    STS = SimpleTS(STS_PRIORITY_LESS_CAST_MAGIC)

    DLib = DamageLib()

    DManager = DrawManager()

  --Q
    Q = Spell(_Q, Ranges[_Q])
    --W
    W = Spell(_W, Ranges[_W])
    --E
    E = Spell(_E, Ranges[_E])
    --R
    R = Spell(_R, Ranges[_R])
--VPred Settings
R:SetSkillshot(VP, SKILLSHOT_LINEAR, Widths[_R], Delays[_R], Speeds[_R], false)

E:SetSkillshot(VP, SKILLSHOT_CIRCULAR, Widths[_E], Delays[_E], Speeds[_E], false)

E:SetHitChance(1)
--End VPred settings


--Damage Calculator
    DLib:RegisterDamageSource(_Q, _MAGIC, 30, 30, _MAGIC, _AP, 0.60, function() return (player:CanUseSpell(_Q) == READY) end)
    DLib:RegisterDamageSource(_W, _MAGIC, 10, 10, _MAGIC, _AP, 0.35, function() return (player:CanUseSpell(_W) == READY) end)
    DLib:RegisterDamageSource(_E, _MAGIC, 20, 50, _MAGIC, _AP, 0.75, function() return (player:CanUseSpell(_E) == READY) end)
    DLib:RegisterDamageSource(_R, _MAGIC, 75, 125, _MAGIC, _AP, 1, function() return (player:CanUseSpell(_R) == READY) end)
    --End Damage Calculator


Menu = scriptConfig("Fizz", "Fizz")

    Menu:addSubMenu("Orbwalking", "Orbwalking")
        SOWi:LoadToMenu(Menu.Orbwalking)


    Menu:addSubMenu("Target selector", "STS")
        STS:AddToMenu(Menu.STS)

    Menu:addSubMenu("Combo", "Combo")
        Menu.Combo:addParam("UseQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
        Menu.Combo:addParam("UseW", "Use W", SCRIPT_PARAM_ONOFF, true)
				Menu.Combo:addParam("UseE", "Use E (use it at your own risk) ", SCRIPT_PARAM_ONOFF, false)
        Menu.Combo:addParam("UseR", "Use R", SCRIPT_PARAM_ONOFF, true)
        Menu.Combo:addParam("Enabled", "Use Combo!", SCRIPT_PARAM_ONKEYDOWN, false, 32)

    Menu:addSubMenu("Harass", "Harass")
        Menu.Harass:addParam("UseQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
        Menu.Harass:addParam("UseW", "Use W", SCRIPT_PARAM_ONOFF, true)
        Menu.Harass:addParam("ManaCheck", "Don't harass if mana < %", SCRIPT_PARAM_SLICE, 0, 0, 100)
        Menu.Harass:addParam("Enabled", "Harass!", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))


    Menu:addSubMenu("Farm", "Farm")
        Menu.Farm:addParam("UseQ",  "Use Q", SCRIPT_PARAM_LIST, 1, { "No", "Freeze", "LaneClear", "Both" })
        Menu.Farm:addParam("UseW",  "Use W", SCRIPT_PARAM_LIST, 3, { "No", "Freeze", "LaneClear", "Both" })
        Menu.Farm:addParam("UseE",  "Use E", SCRIPT_PARAM_LIST, 4, { "No", "Freeze", "LaneClear", "Both" })
        Menu.Farm:addParam("ManaCheck", "Don't farm if mana < %", SCRIPT_PARAM_SLICE, 0, 0, 100)
        Menu.Farm:addParam("Freeze", "Farm freezing", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("C"))
        Menu.Farm:addParam("LaneClear", "Farm LaneClear", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))


    Menu:addSubMenu("JungleFarm", "JungleFarm")
        Menu.JungleFarm:addParam("UseQ",  "Use Q", SCRIPT_PARAM_ONOFF, false)
        Menu.JungleFarm:addParam("UseW",  "Use W", SCRIPT_PARAM_ONOFF, true)
        Menu.JungleFarm:addParam("UseE",  "Use E", SCRIPT_PARAM_ONOFF, true)
        Menu.JungleFarm:addParam("Enabled", "Farm!", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("V"))


  Menu:addSubMenu("Ultimate", "R")
Menu.R:addParam("CastR", "Force ultimate cast", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("J"))


Menu:addSubMenu("Misc", "Misc")
Menu.Misc:addParam("autolevel", "Auto level skills", SCRIPT_PARAM_ONOFF, true)
Menu.Misc:addParam("DodgeE", "Auto E important spells", SCRIPT_PARAM_ONOFF, true)



Menu:addSubMenu("Jungle Steal", "Jungle")
Menu.Jungle:addParam("Enabled", "Drake Steal", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("A"))
Menu.Jungle:addParam("Enabled2", "Baron Steal", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("U"))
Menu.Jungle:addParam("RightPost", "Get Baron right position", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
Menu.Jungle:addParam("RightPost2", "Get Drake right position", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("L"))
Menu.Jungle:addParam("DrawSpots", "Draw Steal spots", SCRIPT_PARAM_ONOFF, true)



Menu:addSubMenu("Drawings", "Drawings")

    for spell, range in pairs(Ranges) do
        DManager:CreateCircle(myHero, range, 1, {255, 255, 255, 255}):AddToMenu(Menu.Drawings, SpellToString(spell).." Range", true, true, true)
    end
    
    DLib:AddToMenu(Menu.Drawings, MainCombo)

    EnemyMinions = minionManager(MINION_ENEMY, Ranges[_Q], myHero, MINION_SORT_MAXHEALTH_DEC)
    JungleMinions = minionManager(MINION_JUNGLE, Ranges[_Q], myHero, MINION_SORT_MAXHEALTH_DEC)

end



function Combo()

    local Qtarget = STS:GetTarget(Ranges[_Q])

    local Wtarget = STS:GetTarget(Ranges[_W])

    local Etarget = STS:GetTarget(Ranges[_E])
    
    local Rtarget = STS:GetTarget(Ranges[_R])

    
    SOWi:EnableAttacks()

    --DFG
    if Qtarget and DLib:IsKillable(Qtarget, MainCombo) then

    ItemManager:CastOffensiveItems(Qtarget)

    end

    if Qtarget and Q:IsReady() and Menu.Combo.UseQ then

  Q:Cast(Qtarget)

    end



if  W:IsReady() and Menu.Combo.UseW and Wtarget then

CastSpell(_W)

end

if  E:IsReady() and Menu.Combo.UseE and Etarget then
print('called')
castE(Etarget) 

end 





--Auto ignite
    local IgniteTarget = STS:GetTarget(600)

    if IgniteTarget and DLib:IsKillable(Rtarget, MainCombo) and _IGNITE and  GetInventorySlotItem(_IGNITE) then

        CastSpell(GetInventorySlotItem(_IGNITE), IgniteTarget)

    end

    end

--Elogic 
function castE(Target) 

local Ename=E:GetName() 

if Target ~= nil then 

local CastPosition1,  HitChance1,  Position1 = VP:GetCircularCastPosition(Target,Delays[_E],Widths[_E],Ranges[_E])

if HitChance1 >= 1  then 

CastSpell(_E,CastPosition1.x,CastPosition1.z)

elseif HitChance1 == 1 and Ename=='fizzjumptwo'   then 

local CastPosition2,  HitChance2,  Position2 = VP:GetCircularCastPosition(Target,Delays[_E],Widths[_E],Ranges[_E])

if HitChance2 >= 1 then 

CastSpell(_E,CastPosition2.x,CastPosition2.z) 

end 

end 

end 

end 



    


function Harass()
--Checks for mana
    if Menu.Harass.ManaCheck > (myHero.mana / myHero.maxMana) * 100 then return end

    local Qtarget = STS:GetTarget(Ranges[_Q])

    local Wtarget = STS:GetTarget(Ranges[_W])


    if Qtarget and Q:IsReady() and Menu.Harass.UseQ  then

        Q:Cast(Qtarget)

    end

    if Wtarget and W:IsReady() and Menu.Harass.UseW then

        CastSpell(_W)

    end

end





function Farm()
--CHECKS FOR MANA
    if Menu.Farm.ManaCheck > (myHero.mana / myHero.maxMana) * 100 then return end

    EnemyMinions:update()

    local UseQ = Menu.Farm.LaneClear and (Menu.Farm.UseQ >= 3) or (Menu.Farm.UseQ == 2)

    local UseW = Menu.Farm.LaneClear and (Menu.Farm.UseW >= 3) or (Menu.Farm.UseW == 2)

    local UseE = Menu.Farm.LaneClear and (Menu.Farm.UseE >= 3) or (Menu.Farm.UseE == 2)

    local minion = EnemyMinions.objects[1]
    if minion then

        if UseQ then

            Q:Cast(minion)

        end
        --E grouped Minions
if UseE then

            local CasterMinions = SelectUnits(EnemyMinions.objects, function(t) return (t.charName:lower():find("wizard") or t.charName:lower():find("caster")) and ValidTarget(t) end)
            CasterMinions = GetPredictedPositionsTable(VP, CasterMinions, Delays[_E], Widths[_E], Ranges[_E], math.huge, myHero, false)

            local BestPos, BestHit = GetBestCircularFarmPosition(Ranges[_E], Widths[_E], CasterMinions)
            if BestHit > 2 then
                CastSpell(_E, BestPos.x, BestPos.z)
                do return end

            end


            local AllMinions = SelectUnits(EnemyMinions.objects, function(t) return ValidTarget(t) end)
            AllMinions = GetPredictedPositionsTable(VP, AllMinions, Delays[_E], Widths[_E], Ranges[_E], math.huge, myHero, false)

            local BestPos, BestHit = GetBestCircularFarmPosition(Ranges[_E], Widths[_E], AllMinions)
            if BestHit > 2 then
                CastSpell(_E, BestPos.x, BestPos.z)
                do return end
            end
        end

        if UseW then

            if Menu.Farm.LaneClear then

CastSpell(_W)
end

end

end

end

function JungleFarm()

    JungleMinions:update()

    SOWi:EnableAttacks()

    local UseQ = Menu.Farm.UseQ

    local UseW = Menu.Farm.UseW

    local UseE = Menu.Farm.UseE

    local minion = JungleMinions.objects[1]

    if minion then

        if UseQ  then

            Q:Cast(minion)

        end

        if UseE then

            local BestPos, BestHit = GetBestCircularFarmPosition(Ranges[_E], Widths[_E], JungleMinions.objects)
            CastSpell(_E, BestPos.x, BestPos.z)
        end
        if UseW  then

            CastSpell(_W)

        end

    end

end

function OnTick()
    SOWi:EnableAttacks()

    if Menu.R.CastR then

        local Rtarget = STS:GetTarget(Ranges[_R])

        R:Cast(Rtarget)
    end

    if Menu.Combo.Enabled then

        Combo()
    elseif Menu.Harass.Enabled then

        Harass()

    end

    if Menu.Farm.Freeze or Menu.Farm.LaneClear then

        Farm()

    end

    if Menu.JungleFarm.Enabled then

        JungleFarm()

    end

if Menu.Misc.DodgeE then

opshit()

end

if Menu.Jungle.RightPost then

GetStealPosition()

end
if Menu.Jungle.RightPost2 then

GetStealPosition2()

end

if Menu.Jungle.Enabled then

DrakeSteal()

end
if Menu.Jungle.Enabled2 then

BaronSteal()

end
if Menu.Misc.autolevel then

autoLevelSetSequence(levelSequence)

end

end
--Dodge E
function opshit()
if not spellExpired and (GetTickCount() - informationTable.spellCastedTick) <= (informationTable.spellRange/informationTable.spellSpeed)*1000 then
            local spellDirection     = (informationTable.spellEndPos - informationTable.spellStartPos):normalized()
            local spellStartPosition = informationTable.spellStartPos + spellDirection
            local spellEndPosition   = informationTable.spellStartPos + spellDirection * informationTable.spellRange
            local heroPosition = Point(myHero.x, myHero.z)

            local lineSegment = LineSegment(Point(spellStartPosition.x, spellStartPosition.y), Point(spellEndPosition.x, spellEndPosition.y))
            --lineSegment:draw(ARGB(255, 0, 255, 0), 70)

            if lineSegment:distance(heroPosition) <= 200 and E:IsReady() then
                --print('Dodging dangerous spell with E')
                CastSpell(_E)
            end

        else
            spellExpired = true
            informationTable = {}
        end
                end


function OnProcessSpell(unit, spell)
if Menu.Misc.DodgeE then
        local DangerousSpellList = {
        ['Amumu'] = {true, spell = _R, range = 550, projSpeed = math.huge},
        ['Annie'] = {true, spell = _R, range = 600, projSpeed = math.huge},
        ['Ashe'] = {true, spell= _R, range = 20000, projSpeed = 1600},
        ['Fizz'] = {true, spell = _R, range = 1300, projSpeed = 2000},
        ['Jinx'] = {true, spell = _R, range = 20000, projSpeed = 1700},
        ['Malphite'] = {true, spell = _R, range = 1000,  projSpeed = 1500 + unit.ms},
        ['Nautilus'] = {true, spell = _R, range = 825, projSpeed = 1400},
        ['Sona'] = {true, spell = _R, range = 1000, projSpeed = 2400},
        ['Orianna'] = {true, spell = _R, range = 900, projSpeed = math.huge},
        ['Zed'] = {true, spell = _R, range = 625, projSpeed = math.huge},
        ['Vi'] = {true, spell = _R, range = 800, projSpeed = math.huge},
        ['Yasuo'] = {true, spell = _R, range = 800, projSpeed = math.huge},
        }
        if unit.type == 'obj_AI_Hero' and unit.team == TEAM_ENEMY and DangerousSpellList[unit.charName] and GetDistance(unit) < 2000 and spell ~= nil then
            if spell.name == (type(DangerousSpellList[unit.charName].spell) == 'number' and unit:GetSpellData(DangerousSpellList[unit.charName].spell).name or DangerousSpellList[unit.charName].spell) then
                if spell.target ~= nil and spell.target.name == myHero.name then
                    ----print('Gapcloser: ',unit.charName, ' Target: ', (spell.target ~= nil and spell.target.name or 'NONE'), " ", spell.name, " ", spell.projectileID)
                    if E:IsReady() then
                        CastSpell(_E)
                        print('Trying to dodge dangerous spell ' .. tostring(spell.name) .. ' with E!')
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
if unit.isMe and spell.name == myHero:GetSpellData(_Q).name  then 

SharkDatBitch()

    end
    end
    end 
--End Dodge E

--Draw steal spots
function OnDraw()

if Menu.Jungle.DrawSpots then

local Xone3=8645

local Yone3=4515

local Xone4=8971

local Yone4=4447

local Xone5=5400

local Yone5=10388

local Xone6=5103

local Yone6=10402

DrawCircle(Xone3, 0, Yone3, 75, 0x0000ff)

DrawCircle(Xone4, 0, Yone4, 75, 0x0000ff)

DrawCircle(Xone5, 0, Yone5, 75, 0x0000ff)

DrawCircle(Xone6, 0, Yone6, 75, 0x0000ff)

end

end

 function GetStealPosition()

local heroPosition = Point(myHero.x, myHero.z,myHero.y)

local Xone5=5400

local Yone5=10388

if myHero.x~=5400 and myHero.z~=10388 then myHero:MoveTo(Xone5, Yone5) end

end

 function GetStealPosition2()

local heroPosition = Point(myHero.x, myHero.z,myHero.y)

local Xone3=8645

local Yone3=4515

if myHero.x~=8645 and myHero.z~=4515 then
myHero:MoveTo(Xone3, Yone3)

end

end

function BaronSteal()

local heroPosition = Point(myHero.x, myHero.z,myHero.y)
local D1 = Point(5400,10388)
local D2 = Point(5103,10402)

local Xone5=5400

local Yone5=10388

local Xone6=5103

local Yone6=10402

local Ename=E:GetName()

if  E:IsReady()  and Ename == "FizzJump" and GetDistance(D2,myHero) < SpellE.Range   then

CastSpell(_E,Xone6,Yone6)

end
if  E:IsReady() and Ename == "fizzjumptwo" and GetDistance(D1,myHero) < SpellE.Range  then

CastSpell(_E,Xone5,Yone5)

end

end

function DrakeSteal()

local heroPosition = Point(myHero.x, myHero.z,myHero.y)
local D1 = Point(8645,4515)
local D2 = Point(8971,4447)

local Xone3=8645

local Yone3=4515

local Xone4=8971

local Yone4=4447

local Ename=E:GetName()

if  E:IsReady()  and Ename == "FizzJump" and GetDistance(D2,myHero) < SpellE.Range  then

CastSpell(_E,Xone4,Yone4)

end

if  E:IsReady() and Ename == "fizzjumptwo" and  GetDistance(D1,myHero) < SpellE.Range then

CastSpell(_E,Xone3,Yone3)

end

end

function SharkDatBitch()
local Rtarget = STS:GetTarget(Ranges[_R])

if Rtarget ~= nil then 

if Rtarget and Menu.Combo.UseR then 

R:Cast(Rtarget)

end 
end 
end 
