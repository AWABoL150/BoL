local VERSION = "0.4"

if myHero.charName ~= "Graves" then return end

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
		print("<b>[Graves]: Required libraries downloaded successfully, please reload (double F9).</b>")
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

local Config = nil

local VP = VPrediction()

local SpellQ = {Speed = 902, Range = 700, Delay = 0.5, Width = 100}

local SpellW = {Speed = 1650, Range = 900, Delay = 0.5, Width = 250}

local SpellR = {Range= 1000 ,Width = 100, Speed = 1400, Delay= 	-0.5}

local AA = {Range= 500}

local Ranges = {RangeQ= 700 ,RangeW = 900, RangeR = 1000}


function OnLoad()
Init()
ScriptSetUp()
PrintChat("<font color=\"#81BEF7\">Awa Graves loaded</font>")
end



function Init()

Q = Spell(_Q, SpellQ.Range)
W = Spell(_W, SpellW.Range)
R = Spell(_R, SpellR.Range)


Q:SetSkillshot(VP, SKILLSHOT_CONE, SpellQ.Width,SpellQ.Delay, SpellQ.Speed, false)
R:SetSkillshot(VP, SKILLSHOT_LINEAR,SpellR.Width, SpellR.Delay, SpellR.Speed, false)
W:SetSkillshot(VP, SKILLSHOT_CIRCULAR, SpellW.Width, SpellW.Delay, SpellW.Speed, false)
W:SetAOE(true,SpellW.Width,0)


EnemyMinions = minionManager(MINION_ENEMY, 1100, myHero, MINION_SORT_MAXHEALTH_DEC)
Loaded = true
end


function ScriptSetUp()

VP = VPrediction()
TS = SimpleTS(STS_LESS_CAST_PHYSICAL)
Orbwalker = SOW(VP)
--Sub menus











	Config = scriptConfig("Graves", "Graves")
	Config:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Config:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('C'))


--Orbwalker
Config:addSubMenu("Orbwalk", "Orbwalk")
 Orbwalker:LoadToMenu(Config.Orbwalk)


  --Combo Config
	Config:addSubMenu("Combo options", "ComboSub")
Config.ComboSub:addSubMenu("Q options", "Qsub")
Config.ComboSub:addSubMenu("W options", "Wsub")
Config.ComboSub:addSubMenu("R options", "Rsub")

	--Spells Combo Options
	--Q
Config.ComboSub.Qsub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.ComboSub.Qsub:addParam("Qhitchance", "Q Hitchance", SCRIPT_PARAM_SLICE, 2, 1, 3, 0)


	--W
Config.ComboSub.Wsub:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)
Config.ComboSub.Wsub:addParam("Whitchance", "WHitchance", SCRIPT_PARAM_SLICE, 2, 1, 2, 0)


	--R
Config.ComboSub.Rsub:addParam("Rhitchance", "R Hitchance", SCRIPT_PARAM_SLICE, 2, 1, 2, 0)


 --Harass options 
 Config:addSubMenu("Harass options", "HarassSub")
Config.HarassSub:addSubMenu("Q options", "Qsub")
Config.HarassSub:addSubMenu("W options", "Wsub")
Config.HarassSub:addSubMenu("R options", "Rsub")

--Spells Harass Options


--Q
Config.HarassSub.Qsub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)

 --W
Config.HarassSub.Wsub:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)

--R
Config.HarassSub.Rsub:addParam("useR", "Use R", SCRIPT_PARAM_ONOFF, true)




--KS

	
Config:addSubMenu("KS", "KS")
Config.KS:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)

Config.KS:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)

Config.KS:addParam("useR", "execute targets with R", SCRIPT_PARAM_ONOFF, true)


    --Ultimate
	Config:addSubMenu("Ultimate", "Ultimate")
Config.Ultimate:addParam("AimForme", "AutoAim your R ", SCRIPT_PARAM_ONKEYDOWN, false,string.byte('R'))

--Draw
Config:addSubMenu("Draw", "Draw")

Config.Draw:addParam("DrawQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
Config.Draw:addParam("DrawW", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
	
--Target Selector
Config:addSubMenu("Target Selector", "TS")
TS:AddToMenu(Config.TS)



--Permashow
Config:permaShow("Combo")
Config:permaShow("Harass")


		end

function Combo()

Q:SetHitChance(Config.ComboSub.Qsub.Qhitchance)
W:SetHitChance(Config.ComboSub.Wsub.Whitchance)
R:SetHitChance(Config.ComboSub.Rsub.Rhitchance)


	local Qfound = TS:GetTarget(AA.Range)


	local Wfound = TS:GetTarget(SpellW.Range)


if Qfound and Q:IsReady() and Config.ComboSub.Qsub.useQ   then

   Q:Cast(Qfound)

	end

 if  Wfound and W:IsReady() and Config.ComboSub.Wsub.useW then

 W:Cast(Wfound)

 end
 end

function Harass()

local Qfound = TS:GetTarget(AA.Range)

local Wfound = TS:GetTarget(SpellW.Range)

if Qfound and Q:IsReady() and Config.HarassSub.Qsub.useQ   then

   Q:Cast(Qfound)

	end

if  Wfound and W:IsReady() and  Config.HarassSub.Wsub.useW  then

 W:Cast(Wfound)

end

end




function KillSteal()
local Enemies = GetEnemyHeroes()
	for i, enemy in pairs(Enemies) do

			if getDmg("Q", enemy, myHero) > enemy.health and  Config.KS.useQ then
				Q:Cast(enemy)
			end
      if getDmg("R", enemy, myHero) + 75 > enemy.health and  Config.KS.useR then
				R:Cast(enemy)
			end
		end
	end


function OnDraw()
if Config.Draw.DrawQ then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, SpellQ.Range, 1,  ARGB(255, 0, 255, 255))
	end

	if Config.Draw.DrawW then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, SpellW.Range, 1,  ARGB(255, 0, 255, 255))
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

