if myHero.charName ~= "Corki" then return end
local VERSION = "0.4"
local autoupdateenabled = true 
local UPDATE_SCRIPT_NAME = "Corki"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/AWABoL150/BoL/master/Corki2.lua"
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

local ServerData
if autoupdateenabled then
	GetAsyncWebResult(UPDATE_HOST, UPDATE_PATH.."?rand="..math.random(1,1000), function(d) ServerData = d end)
	function update()
		if ServerData ~= nil then
			local ServerVersion
			local send, tmp, sstart = nil, string.find(ServerData, "local version = \"")
			if sstart then
				send, tmp = string.find(ServerData, "\"", sstart+1)
			end
			if send then
				ServerVersion = tonumber(string.sub(ServerData, sstart+1, send-1))
			end

			if ServerVersion ~= nil and tonumber(ServerVersion) ~= nil and tonumber(ServerVersion) > tonumber(version) then
				DownloadFile(UPDATE_URL.."?rand="..math.random(1,1000), UPDATE_FILE_PATH, function () print("<font color=\"#FF0000\"><b>"..UPDATE_SCRIPT_NAME..":</b> successfully updated. Reload (double F9) Please. ("..version.." => "..ServerVersion..")</font>") end)     
			elseif ServerVersion then
				print("<font color=\"#FF0000\"><b>"..UPDATE_SCRIPT_NAME..":</b> You have got the latest version: <u><b>"..ServerVersion.."</b></u></font>")
			end		
			ServerData = nil
		end
	end
	AddTickCallback(update)
end

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
		print("<b>[Corki]: Required libraries downloaded successfully, please reload (double F9).</b>")
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

require 'VPrediction'
require 'SourceLib'
require 'SOW'

local Config = nil

local VP = VPrediction()

local SpellQ = {Speed = 850, Range = 825, Delay = 0.5, Width = 250}

local SpellE = {Speed = 902, Range = 600, Delay = 0.5, Width = 100}

local SpellR = {Range= 1225 ,Eidth = 40, Speed = 828, Delay= 	-0.5}



function OnLoad()
Init()
ScriptSetUp()
PrintChat("<font color=\"#81BEF7\">Awa Corki loaded</font>")
end


function Init()

Q = Spell(_Q, SpellQ.Range)
E = Spell(_E, SpellE.Range)
R = Spell(_R, SpellR.Range)


Q:SetSkillshot(VP, SKILLSHOT_CIRCULAR, SpellQ.Width,SpellQ.Delay, SpellQ.Speed, false)
R:SetSkillshot(VP, SKILLSHOT_LINEAR,SpellR.Width, SpellR.Delay, SpellR.Speed, true)

Q:SetAOE(true,SpellQ.Width,0)


EnemyMinions = minionManager(MINION_ENEMY, 1100, myHero, MINION_SORT_MAXHEALTH_DEC)
Loaded = true
end

function ScriptSetUp()
VP = VPrediction()
TS = SimpleTS(STS_LESS_CAST_PHYSICAL)
Orbwalker = SOW(VP)
--((Menu))--
Config = scriptConfig("Corki", "Corki")
Config:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
Config:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('C'))
---Orbwalker
Config:addSubMenu("Orbwalk", "Orbwalk")
Orbwalker:LoadToMenu(Config.Orbwalk)
--Combo options
Config:addSubMenu("Combo options", "ComboSub")
Config.ComboSub:addSubMenu("Q options", "Qsub")
Config.ComboSub:addSubMenu("E options", "Esub")
Config.ComboSub:addSubMenu("R options", "Rsub")
--Spells Combo Options
--Q
Config.ComboSub.Qsub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.ComboSub.Qsub:addParam("Qhitchance", "Q Hitchance", SCRIPT_PARAM_SLICE, 2, 1, 3, 0)
--E
Config.ComboSub.Esub:addParam("useE", "use E", SCRIPT_PARAM_ONOFF, true)
--R
Config.ComboSub.Rsub:addParam("useR", "use R", SCRIPT_PARAM_ONOFF, true)
Config.ComboSub.Rsub:addParam("Rhitchance", "R Hitchance", SCRIPT_PARAM_SLICE, 2, 1, 2, 0)
--Harass
Config:addSubMenu("Harass options", "HarassSub")
    Config.HarassSub:addSubMenu("Q options", "Qsub")
	Config.HarassSub:addSubMenu("E options", "Esub")
	Config.HarassSub:addSubMenu("R options", "Rsub")

--Spells Harass Options
--Q
   Config.HarassSub.Qsub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
--E
   Config.HarassSub.Esub:addParam("useE", "use E", SCRIPT_PARAM_ONOFF, true)
--R
	Config.HarassSub.Rsub:addParam("useR", "Use R", SCRIPT_PARAM_ONOFF, true)
--KS
Config:addSubMenu("KS", "KS")
Config.KS:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.KS:addParam("useE", "use E", SCRIPT_PARAM_ONOFF, true)
Config.KS:addParam("useR", "Spam R", SCRIPT_PARAM_ONOFF, true)
--Ultimate
	Config:addSubMenu("Ultimate", "Ultimate")
	Config.Ultimate:addParam("AimForme", "AutoAim your R ", SCRIPT_PARAM_ONKEYDOWN, false,string.byte('R'))
--Dra
Config:addSubMenu("Draw", "Draw")
Config.Draw:addParam("DrawQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
Config.Draw:addParam("DrawR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
--Permashow
Config:permaShow("Combo")
Config:permaShow("Harass")
end

function Combo()

Q:SetHitChance(Config.ComboSub.Qsub.Qhitchance)
R:SetHitChance(Config.ComboSub.Rsub.Rhitchance)


	local Qfound = TS:GetTarget(SpellQ.Range)


	local Efound = TS:GetTarget(SpellE.Range)


	local Rfound = TS:GetTarget(SpellR.Range)

	Orbwalker:EnableAttacks()


if Qfound and Q:IsReady() and Config.ComboSub.Qsub.useQ  then


   Q:Cast(Qfound)

	end

 if  Efound and E:IsReady() and  Config.ComboSub.Esub.useE  then

 E:Cast(Efound)
end

if Rfound and R:IsReady() and Config.ComboSub.Rsub.useR then

   R:Cast(Qfound)

	end

 end



 function Harass()

local Qfound = TS:GetTarget(SpellQ.Range)


local Efound = TS:GetTarget(SpellE.Range)


local Rfound = TS:GetTarget(SpellR.Range)


if Qfound and Q:IsReady() and Config.HarassSub.Qsub.useQ   then

   Q:Cast(Qfound)

	end

 if  Efound and E:IsReady() and  Config.ComboSub.Esub.useE  then

 E:Cast(Efound)

end

if Rfound and R:IsReady() and Config.HarassSub.Rsub.useR then

   R:Cast(Qfound)

	end

end


function KillSteal()
local Enemies = GetEnemyHeroes()
	for i, enemy in pairs(Enemies) do

if getDmg("Q", enemy, myHero) > enemy.health and  Config.KS.useQ then
				Q:Cast(enemy)
			end

if getDmg("E", enemy, myHero) > enemy.health and GetDistance(enemy) < SpellE.Range and Config.KS.useE then
				E:Cast(enemy)
			end

 if getDmg("R", enemy, myHero) + 75 > enemy.health and  Config.KS.useR then
				R:Cast(enemy)
			end
		end
	end



function OnTick()
if Loaded then

	KillSteal()

local Rfound = TS:GetTarget(SpellR.Range)

if Config.Ultimate.AimForme then

R:Cast(Rfound)

end

if Config.Combo then

Combo()

end

if Config.Harass then

	Harass()

end



end

end

