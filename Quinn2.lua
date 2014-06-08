local VERSION = "0.5"

if myHero.charName ~= "Quinn" then return end

--Auto Download Required LIBS

local REQUIRED_LIBS = {
		["VPrediction"] = "https://raw.githubusercontent.com/Hellsing/BoL/master/common/VPrediction.lua",
		["SOW"] = "https://raw.githubusercontent.com/Hellsing/BoL/master/common/SOW.lua",
		["SourceLib"] = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua",

	}



local DOWNLOADING_LIBS, DOWNLOAD_COUNT = false, 0
local SELF_NAME = GetCurrentEnv() and GetCurrentEnv().FILE_NAME or ""



function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		print("<b>[Quinn]: Required libraries downloaded successfully, please reload (double F9).</b>")
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


--End auto downloading LIBS

local latestVersion=nil

local updateCheck = false


function getDownloadVersion(response)
        latestVersion = response
end

function getVersion()
        GetAsyncWebResult("dl.dropboxusercontent.com","/s/niliki5rpp6qh9q/Quinn2.txt",getDownloadVersion)
end

function update()
   if updateCheck == false then
       local PATH = BOL_PATH.."Scripts\\Quinn2.lua"
       local URL = "https://dl.dropboxusercontent.com/s/l8yd1nk9khvu45u/Quinn2.lua"
       if latestVersion~=nil and latestVersion ~= VERSION then
           updateCheck = true
           PrintChat("UPDATING Quinn - "..SCRIPT_PATH:gsub("/", "\\").."Quinn2.lua")
           DownloadFile(URL, PATH,function ()
            PrintChat("UPDATED - Please Reload (F9 twice)")
            end)
        elseif latestVersion == VERSION then
            updateCheck = true
            PrintChat("Quinn is up to date")
        end
   end
end
AddTickCallback(update)



local FullCombo = {_AA, _Q, _E, _AA, _AA, _Q, _R ,_IGNITE}


require 'VPrediction'
require 'SourceLib'
require 'SOW'

local Config = nil

local VP = VPrediction()
local SpellQ = {Speed = 1200, Range =1025 , Delay = 0.5, Width = 80}

local SpellW = {Range =2000}

local SpellE = {Range = 725}

local SpellR = {Range = 700}

local SpellValorQ = {Range =125}

local Form=false

local AA = {Range= 550}

local Ranges = {[_Q] = 902, [_W] = 2000 ,[_E] = 725 ,[_R] =700}

local informationTable = {}
local spellExpired = true

function OnLoad()
getVersion()
Init()
ScriptSetUp()
PrintChat("<font color=\"#81BEF7\">Awa Quinn loaded</font>")
end


function Init()

--Quinn Spells
Q = Spell(_Q, SpellQ.Range)
W = Spell(_W, SpellW.Range)
E = Spell(_E, SpellE.Range)
R = Spell(_R, SpellR.Range)

--Q skillshot
Q:SetSkillshot(VP, SKILLSHOT_LINEAR, SpellQ.Width, SpellQ.Delay, SpellQ.Speed, true)

--Minion manager for incoming farming
EnemyMinions = minionManager(MINION_ENEMY, 1100, myHero, MINION_SORT_MAXHEALTH_DEC)
Loaded = true
end


function ScriptSetUp()
VP = VPrediction()
TS = SimpleTS(STS_LESS_CAST_PHYSICAL)
Orbwalker = SOW(VP)
DrawHandler = DrawManager()
DamageCalculator= DamageLib()


Config = scriptConfig("Quinn", "Quinn")

Config:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
--Orbwalker
Config:addSubMenu("Orbwalk", "Orbwalk")
Orbwalker:LoadToMenu(Config.Orbwalk)
--Combo options
--Human Form
Config:addSubMenu("Combo options", "ComboSub")
Config.ComboSub:addSubMenu("Human Form", "HumanSub")
Config.ComboSub.HumanSub:addSubMenu("Q options", "Qsub")
Config.ComboSub.HumanSub.Qsub:addParam("Qhitchance", "set  Q hitchance", SCRIPT_PARAM_SLICE, 2, 1, 2, 0)
Config.ComboSub.HumanSub.Qsub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.ComboSub.HumanSub:addSubMenu("E options", "Esub")
Config.ComboSub.HumanSub.Esub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
Config.ComboSub.HumanSub.Esub:addParam("useEgap", "Use E on gapclose", SCRIPT_PARAM_ONOFF, true)

--Valor Form
Config.ComboSub:addSubMenu("Valor Form", "ValorSub")
Config.ComboSub.ValorSub:addSubMenu("Q options", "Qsub")
Config.ComboSub.ValorSub.Qsub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.ComboSub.ValorSub:addSubMenu("E options", "Esub")
Config.ComboSub.ValorSub.Esub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
Config.ComboSub.ValorSub:addSubMenu("R options", "Rsub")
Config.ComboSub.ValorSub.Rsub:addParam("useR", "Use R to finish targets", SCRIPT_PARAM_ONOFF, true)

--KS
Config:addSubMenu("KS", "KS")
Config.KS:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
--Draw
Config:addSubMenu("Draw", "Draw")
for spell, range in pairs(Ranges) do
		DrawHandler:CreateCircle(myHero, range, 1, {255, 255, 255, 255}):AddToMenu(Config.Draw, SpellToString

(spell).." Range", true, true, true)
	end
	



--Permashow
Config:permaShow("Combo")
end


function Combo()
--Q hitchance
Q:SetHitChance(Config.ComboSub.HumanSub.Qsub.Qhitchance)

if not Form then 
--Targets 
local Qfound = TS:GetTarget(SpellQ.Range)
local Efound = TS:GetTarget(SpellE.Range)
local Rfound = TS:GetTarget(SpellR.Range)
--Q 
if Qfound and Q:IsReady() and Config.ComboSub.HumanSub.Qsub.useQ then 

	Q:Cast(Qfound)

end 
--E 
if Efound and E:IsReady() and Config.ComboSub.HumanSub.Esub.useE then 

	E:Cast(Efound)

end 
end 

if Form then 
local QfoundValor = TS:GetTarget(SpellValorQ.Range)
local Efound = TS:GetTarget(SpellE.Range)
local Rfound = TS:GetTarget(SpellR.Range)

if Efound and E:IsReady() and Config.ComboSub.ValorSub.Esub.useE then 

	E:Cast(Efound)

end 

if QfoundValor and Q:IsReady() and Config.ComboSub.ValorSub.Qsub.useQ then 

	Q:Cast(QfoundValor)

end 

if Rfound and R:IsReady() and Config.ComboSub.ValorSub.Rsub.useR then 
	if getDmg("R", Rfound, myHero) +50 >= Rfound.health then 
		CastSpell(_R)
		print('casted manually')
	end 
end 

end 

end 


 function KillSteal()
local Enemies = GetEnemyHeroes()
	for i, enemy in pairs(Enemies) do
 if getDmg("E", enemy, myHero) + 75 > enemy.health and  Config.KS.useQ and GetDistance(enemy) < SpellQ.Range then
				Q:Cast(enemy)
			end
		end
	end

function OnTick()
if Loaded then

KillSteal()
--Combo
if Config.Combo then

Combo()

end

if Config.ComboSub.HumanSub.Esub.useEgap then opshit() end 

end
end

function OnGainBuff(unit, buff)
	if unit.isMe and buff.name == 'quinnrtimeout' then
		Form = true
	end 
end



function OnLoseBuff(unit, buff)
	if unit.isMe and buff.name == 'quinnrtimeout' then
		Form = false
	end 
end

function opshit()
if not spellExpired and (GetTickCount() - informationTable.spellCastedTick) <= 

(informationTable.spellRange/informationTable.spellSpeed)*1000 then
            local spellDirection     = (informationTable.spellEndPos - informationTable.spellStartPos):normalized()
            local spellStartPosition = informationTable.spellStartPos + spellDirection
            local spellEndPosition   = informationTable.spellStartPos + spellDirection * informationTable.spellRange
            local heroPosition = Point(myHero.x, myHero.z)

            local lineSegment = LineSegment(Point(spellStartPosition.x, spellStartPosition.y), Point(spellEndPosition.x, 

spellEndPosition.y))
            

            if lineSegment:distance(heroPosition) <= 200 and E:IsReady() then
            	
                CastSpell(_E,unit)
            end
						
        else
            spellExpired = true
            informationTable = {}
        end
				end

function OnProcessSpell(unit, spell)
if Config.ComboSub.HumanSub.Esub.useEgap then
				local isAGapcloserUnit = {
	
	        ['Aatrox']      = {true, spell = _Q,                  range = 1000,  projSpeed = 1200, },
	        ['Akali']       = {true, spell = _R,                  range = 800,   projSpeed = 2200, }, 
	        ['Alistar']     = {true, spell = _W,                  range = 650,   projSpeed = 2000, }, 
	        ['Diana']       = {true, spell = _R,                  range = 825,   projSpeed = 2000, }, 
	        ['Gragas']      = {true, spell = _E,                  range = 600,   projSpeed = 2000, },
	        ['Hecarim']     = {true, spell = _R,                  range = 1000,  projSpeed = 1200, },
	        ['Irelia']      = {true, spell = _Q,                  range = 650,   projSpeed = 2200, }, 
	        ['JarvanIV']    = {true, spell = jarvanAddition,      range = 770,   projSpeed = 2000, }, 
	        ['Jax']         = {true, spell = _Q,                  range = 700,   projSpeed = 2000, }, 
	        ['Jayce']       = {true, spell = 'JayceToTheSkies',   range = 600,   projSpeed = 2000, }, 
	        ['Khazix']      = {true, spell = _E,                  range = 900,   projSpeed = 2000, },
	        ['Leblanc']     = {true, spell = _W,                  range = 600,   projSpeed = 2000, },
	        ['LeeSin']      = {true, spell = 'blindmonkqtwo',     range = 1300,  projSpeed = 1800, },
	        ['Leona']       = {true, spell = _E,                  range = 900,   projSpeed = 2000, },
	        ['Malphite']    = {true, spell = _R,                  range = 1000,  projSpeed = 1500 + unit.ms},
	        ['Maokai']      = {true, spell = _Q,                  range = 600,   projSpeed = 1200, }, 
	        ['MonkeyKing']  = {true, spell = _E,                  range = 650,   projSpeed = 2200, }, 
	        ['Pantheon']    = {true, spell = _W,                  range = 600,   projSpeed = 2000, }, 
	        ['Poppy']       = {true, spell = _E,                  range = 525,   projSpeed = 2000, }, 
	        ['Renekton']    = {true, spell = _E,                  range = 450,   projSpeed = 2000, },
	        ['Sejuani']     = {true, spell = _Q,                  range = 650,   projSpeed = 2000, },
	        ['Shen']        = {true, spell = _E,                  range = 575,   projSpeed = 2000, },
	        ['Tristana']    = {true, spell = _W,                  range = 900,   projSpeed = 2000, },
	        ['Tryndamere']  = {true, spell = 'Slash',             range = 650,   projSpeed = 1450, },
	        ['XinZhao']     = {true, spell = _E,                  range = 650,   projSpeed = 2000, }, 
	    }
	    if unit.type == 'obj_AI_Hero' and unit.team == TEAM_ENEMY and isAGapcloserUnit[unit.charName] and 

GetDistance(unit) < 2000 and spell ~= nil then
	        if spell.name == (type(isAGapcloserUnit[unit.charName].spell) == 'number' and unit:GetSpellData

(isAGapcloserUnit[unit.charName].spell).name or isAGapcloserUnit[unit.charName].spell) then
	            if spell.target ~= nil and spell.target.name == myHero.name or isAGapcloserUnit[unit.charName].spell 

== 'blindmonkqtwo' then
					
	        		if E:IsReady() then
	        			CastSpell(_E,unit)
	        			
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









 











