local VERSION = "0.6"

if myHero.charName ~= "Twitch" then return end

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
		print("<b>[Twitch]: Required libraries downloaded successfully, please reload (double F9).</b>")
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


local FullCombo = {ItemManager:GetItem("BOTRK"):GetId(),_AA, _AA, _AA, _AA, _AA, _AA, _E ,_IGNITE}


require 'VPrediction'
require 'SourceLib'
require 'SOW'

local Config = nil

local VP = VPrediction()

local SpellW = {Speed = 1750, Range =950 , Delay = 0.5, Width = 275}

local SpellE = {Range = 1200}

local Pstacks = 0 

local AA = {Range= 550}

local Ranges = { [_W] = 902, [_E] = 900}

function OnLoad()
Init()
ScriptSetUp()
PrintChat("<font color=\"#81BEF7\">Awa Twitch loaded</font>")
end


function Init()

--W and E 
W = Spell(_W, SpellW.Range)
E = Spell(_E, SpellE.Range)

--W skillshot
W:SetSkillshot(VP, SKILLSHOT_CIRCULAR, SpellW.Width, SpellW.Delay, SpellW.Speed, false)
W:SetAOE(true,SpellW.Width,0)
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

DamageCalculator:RegisterDamageSource(_E, _PHYSICAL, 65, 45, _PHYSICAL, _AD, 1.5, function() return (player:CanUseSpell(_E) == READY) end)


Config = scriptConfig("Twitch", "Twitch")
Config:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
--Orbwalker
Config:addSubMenu("Orbwalk", "Orbwalk")
Orbwalker:LoadToMenu(Config.Orbwalk)
--Combo options
Config:addSubMenu("Combo options", "ComboSub")
Config.ComboSub:addSubMenu("E options", "Esub")
Config.ComboSub:addSubMenu("W options", "Wsub")
	--Spells Combo Options
--W
Config.ComboSub.Wsub:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)
Config.ComboSub.Wsub:addParam("Whitchance", "WHitchance", SCRIPT_PARAM_SLICE, 2, 1, 2, 0)
--E
Config.ComboSub.Esub:addParam("useE", "Use E if x Poison stack", SCRIPT_PARAM_ONOFF, true)
Config.ComboSub.Esub:addParam("Pstack", "Set poison stack", SCRIPT_PARAM_SLICE, 6, 1, 6, 0) --KS
Config:addSubMenu("KS", "KS")
Config.KS:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
--TS
Config:addSubMenu("Target Selector", "TS")
TS:AddToMenu(Config.TS)

--Draw
Config:addSubMenu("Draw", "Draw")
for spell, range in pairs(Ranges) do
		DrawHandler:CreateCircle(myHero, range, 1, {255, 255, 255, 255}):AddToMenu(Config.Draw, SpellToString(spell).." Range", true, true, true)
	end
	
DamageCalculator:AddToMenu(Config.Draw, FullCombo)
	


--Permashow
Config:permaShow("Combo")
end



function Combo()
--W hitchance
W:SetHitChance(Config.ComboSub.Wsub.Whitchance)
--Targets
local Efound = TS:GetTarget(SpellE.Range)
local Wfound = TS:GetTarget(SpellW.Range)
--Botrk 
if Wfound then
ItemManager:CastOffensiveItems(Wfound)
end 

--W cast
if  Wfound and W:IsReady() and Config.ComboSub.Wsub.useW then

 W:Cast(Wfound)

 end
--E cast
if Efound and E:IsReady() and Pstacks >= Config.ComboSub.Esub.Pstack and  Config.ComboSub.Esub.useE then 

E:Cast() 

 end
 
 end 


--Kill Steal
 function KillSteal()
local Enemies = GetEnemyHeroes()
	for i, enemy in pairs(Enemies) do
 if getDmg("E", enemy, myHero) + 75 > enemy.health and  Config.KS.useE and GetDistance(enemy) < SpellE.Range then
				E:Cast()
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
end
end

function OnGainBuff(unit, buff)
	if unit and unit.team == TEAM_ENEMY and unit.type == 'obj_AI_Hero' and  buff.name == 'twitchdeadlyvenom' then
		Pstacks = 1
end 
end

function OnUpdateBuff(unit, buff)
	if unit and unit.team == TEAM_ENEMY and unit.type == 'obj_AI_Hero' and  buff.name == 'twitchdeadlyvenom' then
		Pstacks = buff.stack
		
	end 
end

function OnLoseBuff(unit, buff)
	if unit and unit.team == TEAM_ENEMY and unit.type =='obj_AI_Hero' and buff.name == 'twitchdeadlyvenom' then
		Pstacks = 0
	end 
end












