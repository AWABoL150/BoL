local VERSION = "0.1"
if myHero.charName ~= "Irelia" then return end
--Encrypt this line and below
---------------------------------------------------------------------
--- AutoUpdate for the script ---------------------------------------
---------------------------------------------------------------------
local UPDATE_FILE_PATH = SCRIPT_PATH.."Irelia2.lua"
local UPDATE_NAME = "Irelia2"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/bolqqq/BoLScripts/master/Irelia2.lua?chunk="..math.random(1, 1000)
local UPDATE_FILE_PATH = SCRIPT_PATH.."Irelia2.lua"
local UPDATE_URL = "https://"..UPDATE_HOST..UPDATE_PATH

function AutoupdaterMsg(msg) print("<font color=\"#FF7373\">[".._G.IsLoaded.."]:</font> <font color=\"#FFDFBF\">"..msg..".</font>") end
if _G.EVEAUTOUPDATE then
    local ServerData = GetWebResult(UPDATE_HOST, UPDATE_PATH)
    if ServerData then
        local ServerVersion = string.match(ServerData, "_G.IreliaVersion = \"%d+.%d+\"")
        ServerVersion = string.match(ServerVersion and ServerVersion or "", "%d+.%d+")
        if ServerVersion then
            ServerVersion = tonumber(ServerVersion)
            if tonumber(_G.IreliaVersion) < ServerVersion then
                AutoupdaterMsg("A new version is available: ["..ServerVersion.."]")
                AutoupdaterMsg("The script is updating... please don't press [F9]!")
                DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function ()
				AutoupdaterMsg("Successfully updated! (".._G.IreliaVersion.." -> "..ServerVersion.."), Please reload (double [F9]) for the updated version!") end) end, 3)
            else
                AutoupdaterMsg("Your script is already the latest version: ["..ServerVersion.."]")
            end
        end
    else
        AutoupdaterMsg("Error downloading version info!")
    end
end
---------------------------------------------------------------------
--- AutoDownload the required libraries -----------------------------
---------------------------------------------------------------------
local REQUIRED_LIBS = 
	{
		["VPrediction"] = "https://raw.github.com/honda7/BoL/master/Common/VPrediction.lua",
		["SOW"] = "https://raw.github.com/honda7/BoL/master/Common/SOW.lua"
	}		
local DOWNLOADING_LIBS = false
local DOWNLOAD_COUNT = 0
local SELF_NAME = GetCurrentEnv() and GetCurrentEnv().FILE_NAME or ""

function AfterDownload()
	DOWNLOAD_COUNT = DOWNLOAD_COUNT - 1
	if DOWNLOAD_COUNT == 0 then
		DOWNLOADING_LIBS = false
		print("<font color=\"#FF7373\">[".._G.IsLoaded.."]:</font><font color=\"#FFDFBF\"> Required libraries downloaded successfully, please reload (double [F9]).</font>")
	end
end

for DOWNLOAD_LIB_NAME, DOWNLOAD_LIB_URL in pairs(REQUIRED_LIBS) do
	if FileExist(LIB_PATH .. DOWNLOAD_LIB_NAME .. ".lua") then
		require(DOWNLOAD_LIB_NAME)
	else
		DOWNLOADING_LIBS = true
		DOWNLOAD_COUNT = DOWNLOAD_COUNT + 1

		print("<font color=\"#FFFF73\">[".._G.IsLoaded.."]:</font><font color=\"#FFDFBF\"> Not all required libraries are installed. Downloading: <b><u><font color=\"#73B9FF\">"..DOWNLOAD_LIB_NAME.."</font></u></b> now! Please don't press [F9]!</font>")
		DownloadFile(DOWNLOAD_LIB_URL, LIB_PATH .. DOWNLOAD_LIB_NAME..".lua", AfterDownload)
	end
end
if DOWNLOADING_LIBS then return end

local FullCombo = {_Q,_AA,_E,_AA,_R,_Q,_AA,_IGNITE}
local Combofull = {_Q}
--((Auto Download Required LIBS))--
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
		print("<b>[Irelia]: Required libraries downloaded successfully, please reload (double F9).</b>")
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
--((Required Libs))--
require 'VPrediction'
require 'SourceLib'
require 'SOW'
--((Spells))--
local Config = nil
local VP = VPrediction()
local SpellQ = {Range =650}
local SpellW = {Range =125}
local SpellE = {Range =425}
local SpellR = {Range = 1000}
local AA = {Range= 125}
local Ranges = {[_Q] = 650,[_W] = 125,[_E] = 425,[_R] = 1000}
--((OnLoad Function))--
function OnLoad()
Init()
ScriptSetUp()
PrintChat("<font color=\"#81BEF7\">AwA Irelia loaded Succesfully</font>")
end
function Init()
--((Spells))--
Q = Spell(_Q, SpellQ.Range)
W = Spell(_W, SpellW.Range)
E = Spell(_E, SpellE.Range)
R = Spell(_R, SpellR.Range)
--((Skillshots))--

--((Minion Manger))--
EnemyMinions = minionManager(MINION_ENEMY, 1100, myHero, MINION_SORT_MAXHEALTH_DEC)
JungleMinions = minionManager(MINION_JUNGLE, 1100, myHero, MINION_SORT_MAXHEALTH_DEC)
Loaded = true
end
--((Script Menu))--
function ScriptSetUp()
VP = VPrediction()
TS = SimpleTS(STS_LESS_CAST_PHYSICAL)
Orbwalker = SOW(VP)
DrawHandler = DrawManager()
DamageCalculator= DamageLib()
--((Damage Calclator))--
DamageCalculator:RegisterDamageSource(_Q, _PHYSICAL, 10, 30, _PHYSICAL, _AD, 1, function() return (player:CanUseSpell(_Q) == READY) end)
DamageCalculator:RegisterDamageSource(_E, _MAGIC, 30, 50, _MAGIC, _AP, 0.5, function() return (player:CanUseSpell(_E) == READY) end)
DamageCalculator:RegisterDamageSource(_R, _PHYSICAL, 40, 40, _PHYSICAL, _AD, 0.6, function() return (player:CanUseSpell(_R) == READY) end)
Config = scriptConfig("Irelia", "Irelia")
Config:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
Config:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("T"))
Config:addParam("Laneclear", "Laneclear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
Config:addParam("Flee", "Flee", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
--((Orbwalker))--
Config:addSubMenu("Orbwalk", "Orbwalk")
Orbwalker:LoadToMenu(Config.Orbwalk)
--((Target Selector))--
Config:addSubMenu("Target Selector", "TS")
TS:AddToMenu(Config.TS)
--((Combo options))--
Config:addSubMenu("Combo options", "ComboSub")
Config.ComboSub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.ComboSub:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)
Config.ComboSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
--((Harass options))--
Config:addSubMenu("Harass options", "HarassSub")
Config.HarassSub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.HarassSub:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)
Config.HarassSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
Config.HarassSub:addParam("ManaC", "Block Harass When Mana is under %", SCRIPT_PARAM_SLICE, 0, 0, 100)
--((Ultimate))--
Config:addSubMenu("Ultimate", "Ultimate")
Config.Ultimate:addParam("useR", "Force R Cast", SCRIPT_PARAM_ONKEYDOWN, false,string.byte("A"))
--((Farm options))--
Config:addSubMenu("Laneclear options", "FSub")
Config.FSub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.FSub:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)
Config.FSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
Config.FSub:addParam("ManaC", "Block Harass When Mana is under %", SCRIPT_PARAM_SLICE, 0, 0, 100)
--((Jfarm options))--
Config:addSubMenu("Jungle Farm options", "Jfarm")
Config.Jfarm:addParam("Enabled", "Jungle Farm ", SCRIPT_PARAM_ONKEYDOWN, true,string.byte("V"))
Config.Jfarm:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.Jfarm:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)
Config.Jfarm:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
--((Advanced options))
Config:addSubMenu("Advanced Options", "AdvOpt")
Config.AdvOpt:addParam("useQG","useQ to gapclose", SCRIPT_PARAM_ONOFF, true)
--((Draw))--
Config:addSubMenu("Draw", "Draw")
for spell, range in pairs(Ranges) do
DrawHandler:CreateCircle(myHero, range, 1, {255, 255, 255, 255}):AddToMenu(Config.Draw, SpellToString(spell).." Range", true, true, true)
end
DamageCalculator:AddToMenu(Config.Draw, FullCombo)
--((Permashow))--
Config:permaShow("Combo")
Config:permaShow("Harass")
Config:permaShow("Laneclear")
Config:permaShow("Flee")
end
--((Combo))--
function Combo() 
local Qfound = TS:GetTarget(SpellQ.Range)
local Wfound = TS:GetTarget(SpellW.Range)
local Efound = TS:GetTarget(SpellE.Range)
local Rfound = TS:GetTarget(SpellR.Range)
local Gapfound = TS:GetTarget(Config.ComboSub.SetGRange)
if Qfound and Q:IsReady() and Config.ComboSub.useQ then 
    Q:Cast(Qfound)
end 
if Wfound and W:IsReady() and Config.ComboSub.useW then 
    W:Cast()
end 
if Efound and E:IsReady() and Config.ComboSub.useE then 
    E:Cast(Efound)
end

end 



--((Harass))--
function Harass()
if Config.HarassSub.ManaC > (myHero.mana / myHero.maxMana) * 100 then return end 
local Qfound = TS:GetTarget(SpellQ.Range)
local Wfound = TS:GetTarget(SpellW.Range)
local Efound = TS:GetTarget(SpellE.Range)
local Rfound = TS:GetTarget(SpellR.Range)
if Qfound and Q:IsReady() and Config.ComboSub.useQ then 
    Q:Cast(Qfound)
end 
if Wfound and W:IsReady() and Config.ComboSub.useW then
    W:Cast()
end 
if Efound and E:IsReady() and Config.ComboSub.useE then 
    E:Cast(Efound)
end 
end 
--((Farm))--
function Farm()
if Config.FSub.ManaC > (myHero.mana / myHero.maxMana) * 100 then return end
    EnemyMinions:update()
    local MinionObj = EnemyMinions.objects[1]
    if MinionObj then 
    if DamageCalculator:IsKillable(MinionObj,Combofull) then 
        if Config.FSub.useQ then 
            Q:Cast(MinionObj)
        end 
        if W:IsReady() and Config.FSub.useW then 
            W:Cast() 
        end 
        if  E:IsReady() and Config.FSub.useE then
            E:Cast(MinionObj)
        end 
    end 
end 
end 
--((Jungle Farm))--
function JFarm() 
    JungleMinions:update()
    local JungleObj = JungleMinions.objects[1]
    if JungleObj then 
        if Q:IsReady() and  Config.Jfarm.useQ then 
            Q:Cast(JungleObj)
        end 
        if W:IsReady() and Config.Jfarm.useW then 
            W:Cast() 
        end 
        if E:IsReady() and Config.Jfarm.useE then 
            E:Cast(JungleObj)
        end 
    end 
end 
--((Flee))--
function flee() 
    EnemyMinions:update()
    for i, minion in pairs(EnemyMinions.objects) do
        if DamageCalculator:IsKillable(minion,Combofull) then 
            Q:Cast(minion)
        end 
    end 
end 
--((OnTick))--
function OnTick() 
    if Loaded then 
        if Config.Ultimate.useR then 
            local Rfound = TS:GetTarget(SpellR.Range)
            if Rfound and R:IsReady() then 
                R:Cast(Rfound.x,Rfound.z)
            end 
        end 
        if Config.Combo then 
            Combo()
        end 
        if Config.Harass then 
            Harass()
        end 
        if Config.Laneclear then 
            Farm () 
        end 
        if Config.Flee then 
            flee()
        end 
    end 
end 











