local VERSION = '1.1'

if myHero.charName ~= "Lux" then return end


--Required Libs Auto download

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
		print("<b>[Lux]: Required libraries downloaded successfully, please reload (double F9).</b>")
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

--Required Libs

require "VPrediction"

require "SOW"

--[[Globals]]
--SpellData
local SpellQ = {Speed = 1200, Range = 1300, Delay = 0.5, Width = 80 , Radius=210}

local SpellE = {Speed = 1300, Range = 1100, Delay = 0.5, Width = 275 ,Radius=275 }

local SpellR = {Range= 3340 ,Width = 190, Speed = 3000, Delay= 1.75 , Radius=250}


local Qdamage = {60, 110, 160, 210, 260}

local Qscaling = 0.70

local Edamage = {60, 105, 150, 195, 240}

local Escaling = 0.60

local Rdamage = {300, 400, 500}

local Rscaling = 0.75

local LastPing = 0

--Checks
local Qready = false

local Wready = false

local Eready = false

local Rready = false

local Config = nil

local VP = VPrediction()

local ts = nil

local LastE=nil

local sparks = {}

local jungle = {
                                Vilemaw = {obj = nil, name = "TT_Spiderboss7.1.1"},
                                Baron = {obj = nil, name = "Worm12.1.1"},
                                Dragon = {obj = nil, name = "Dragon6.1.1"},
                                Golem1 = {obj = nil, name = "AncientGolem1.1.1"},
                                Golem2 = {obj = nil, name = "AncientGolem7.1.1"},
                                --LizardElder1 = {obj = nil, name = "LizardElder4.1.1"},
                                --LizardElder2 = {obj = nil, name = "LizardElder10.1.1"},
}





function Menu()
SOWi = SOW(VP)
Config = scriptConfig("Prolux", "Prolux")
Config:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
Config:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('C'))

Config:addSubMenu("Orbwalker", "Orbwalker")

Config:addSubMenu("Combo options", "ComboSub")

Config:addSubMenu("Harass options", "HarassSub")

Config:addSubMenu("KS", "KS")

Config:addSubMenu("Ultimate", "Ultimate")

Config:addSubMenu("Misc", "Misc")

Config:addSubMenu("Extra Config", "Extras")

Config:addSubMenu("Draw", "Draw")

--Orbwalker
SOWi:LoadToMenu(Config.Orbwalker)

--Combo

Config.ComboSub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)

Config.ComboSub:addParam("Eusage", "Use E", SCRIPT_PARAM_ONOFF, true)

Config.ComboSub:addParam("useE", "Auto E On Caged Enemy", SCRIPT_PARAM_ONOFF, true)

Config.ComboSub:addParam("useUlt", "Auto Ult On Caged Enemy", SCRIPT_PARAM_ONOFF, true)

Config.ComboSub:addParam("attackspark", "Auto spark", SCRIPT_PARAM_ONOFF, true)

--Harass
Config.HarassSub:addParam("Ehim", "Use E", SCRIPT_PARAM_ONOFF, true)

Config.HarassSub:addParam("Enabled2", "Harass (TOGGLE)!", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))

--Draw
Config.Draw:addParam("DrawE", "Draw E range", SCRIPT_PARAM_ONOFF, false)

Config.Draw:addParam("DrawQ", "Draw Q range", SCRIPT_PARAM_ONOFF, false)

Config.Draw:addParam("DrawDamage", "Draw circle around actual target", SCRIPT_PARAM_ONOFF, true)

--KS
Config.KS:addParam("useR", "Killsteal using ultimate", SCRIPT_PARAM_ONOFF, true)

--Ultimate
Config.Ultimate:addParam("Auto",  "Auto ultimate if ", SCRIPT_PARAM_LIST, 1, { "No", ">0 hit", ">1 hit", ">2 hit", ">3 hit", ">4 hit" })

Config.Ultimate:addParam("Enabled", "Ultimate Auto-aim", SCRIPT_PARAM_ONKEYDOWN , false, string.byte("R"))

--misc
Config.Misc:addParam("WARN", "Warn me when enemy killable (R)", SCRIPT_PARAM_ONOFF, true)


--Extras
Config.Extras:addParam("autoE", "Auto-pop E", SCRIPT_PARAM_ONOFF, true)

Config.Extras:addParam("mManager", "Mana slider", SCRIPT_PARAM_SLICE, 0, 0, 100, 0)

Config.Extras:addParam("jungleSteal", "Steal jungle buffs using ultimate", SCRIPT_PARAM_ONOFF, true,string.byte('L'))

Config.Extras:addParam("autoignite", "Auto ignite killable", SCRIPT_PARAM_ONOFF, true)



--permashow

Config:permaShow("Combo")

Config:permaShow("Harass")

end

function Getje()
        for i = 0, objManager.maxObjects do
                local obj = objManager:getObject(i)
                for _, mob in pairs(jungle) do
                        if obj and obj.valid and obj.name:find(mob.name) then
                                mob.obj = obj
                        end
                end
        end
end

function OnLoad()
Menu()

Init()

Getje()
end

function Init()
ts= TargetSelector(TARGET_LESS_CAST_PRIORITY, 1500, DAMAGE_MAGICAL)

ts2= TargetSelector(TARGET_LESS_CAST_PRIORITY,3000, DAMAGE_MAGICAL)

ts.name = "Lux"

ts2.name="Lux Ultimate target selector"

Config:addTS(ts)

Config:addTS(ts2)

EnemyMinions = minionManager(MINION_ENEMY, 1300, myHero, MINION_SORT_MAXHEALTH_DEC)

print('Awa prolux beta  ' .. tostring(VERSION) .. ' loaded!')

initDone = true

end

function OnTick()
Check()

if initDone then

KillSteal()

ts:update()

ts2:update()

target = ts.target

Rtarget=ts2.target

EnemyMinions:update()

if Config.Combo then

if ValidTarget(target, 1300) and not target.dead then

Combo(target)

end

end


if Config.Harass then

if ValidTarget(target, 1300) and not target.dead

then Harass(target)

end

end

if Config.Extras.autoE then

checkE()

end
if Config.ComboSub.useE then

foundQ()
end

if Config.ComboSub.useUlt then

foundedQ()

end
if Config.Extras.jungleSteal then

checkJungleKillable()

end
if Config.Extras.autoignite then

IgniteKS()

end
if Config.Ultimate.Enabled then

CastRversion(Rtarget)

end
if Config.Misc.WARN then

Warning()

end

if Config.HarassSub.Enabled2 then

if ValidTarget(target, 1300) and not target.dead  then

Harass(target)

end
end

if Config.Ultimate.Auto - 1 >=2 and Rready then

if target ~= nil then

local Mintargets = Config.Ultimate.Auto
local AOECastPosition, MainTargetHitChance, nTargets = VP:GetLineAOECastPosition(target, SpellR.Delay, SpellR.Width, SpellR.Range, SpellR.Speed, myHero)
if nTargets >= Mintargets then

CastSpell(_R, AOECastPosition.x, AOECastPosition.z)

end

end

end

end


end





function Combo(Target)

SOWi:DisableAttacks()

if QReady and Config.ComboSub.useQ then

CastQ(Target)

end

if EReady and not QReady and Config.ComboSub.Eusage then

CastE(Target)

end


 if Config.ComboSub.attackspark and hasSpark() then

myHero:Attack(ts.target)

end

if not QReady and not EReady then

SOWi:EnableAttacks()

end

end


function Harass(Target)

 if EReady then

CastE(Target)

end

 if Config.ComboSub.attackspark and hasSpark() then

myHero:Attack(ts.target)

end

end




function KillSteal()

	local Enemies = GetEnemyHeroes()

	for i, enemy in pairs(Enemies) do

		if ValidTarget(enemy, 3000) and not enemy.dead and GetDistance(enemy) < 3000 then

			if getDmg("R", enemy, myHero) > enemy.health and GetDistance(enemy) < SpellR.Range and Config.KS.useR then

				CastR(enemy)

			end

		end

	end

	end

	function KillStealirino()

	local Enemies = GetEnemyHeroes()

	for i, enemy in pairs(Enemies) do

		if ValidTarget(enemy, 3000) and not enemy.dead and GetDistance(enemy) < 3000 then

			if getDmg("R", enemy, myHero) > enemy.health and GetDistance(enemy) < SpellR.Range  then
				CastR(enemy)

			end

		end

	end

	end

	function Warning()

	local Enemies = GetEnemyHeroes()

	for i, enemy in pairs(Enemies) do

		if ValidTarget(enemy, 3000) and not enemy.dead and GetDistance(enemy) < 3000 and (GetGameTimer() - LastPing > 30) then

			if getDmg("R", enemy, myHero) > enemy.health and GetDistance(enemy) < SpellR.Range and RReady then

				for i = 1, 3 do

					DelayAction(RecPing,  1000 * 0.3 * i/1000, {enemy.x, enemy.z})

					end

					LastPing = GetGameTimer()
			end

		end

	end

	end


function CastQ(Target)

if QReady  and GetDistance(Target) < SpellQ.Range then

		local CastPosition, HitChance, Position =  VP:GetLineCastPosition(Target, SpellQ.Delay, SpellQ.Width, SpellQ.Range, SpellQ.Speed, myHero, true)

		 if HitChance >= 2 then


			CastSpell(_Q,CastPosition.x,CastPosition.z)

		end

	end

end

function RecPing(X, Y)
	Packet("R_PING", {x = X, y = Y, type = PING_FALLBACK}):receive()
	end


function CastE(Target)

if EReady  and GetDistance(Target) < SpellE.Range then

		 local CastPosition,  HitChance,  Position = VP:GetCircularCastPosition(Target,
		 SpellE.Delay,SpellE.Width,SpellE.Range,SpellE.Speed,false)

                if HitChance >= 2 and GetDistance(CastPosition) < 850 then
                     CastSpell(_E,CastPosition.x,CastPosition.z)

                                            end

	end

end


function CastR(Target)

	if RReady and GetDistance(Target) < SpellR.Range then

local CastPosition, HitChance, Pos = VP:GetLineCastPosition(Target, SpellR.Delay, SpellR.Width, SpellR.Range, SpellR.Speed, myHero, false)

                    if HitChance >= 2 and GetDistance(CastPosition) < SpellR.Range then
					CastSpell(_R,CastPosition.x,CastPosition.z)

                    end

end

end

function CastRversion(Target)

	if RReady and GetDistance(Target) < SpellR.Range and ValidTarget(Target, 3000) then

local CastPosition, HitChance, Pos = VP:GetLineCastPosition(Target, SpellR.Delay, SpellR.Width, SpellR.Range, SpellR.Speed, myHero, false)
                    if HitChance >= 2 and GetDistance(CastPosition) < SpellR.Range then

					CastSpell(_R,CastPosition.x,CastPosition.z)

										end


end

end



function foundQ()
            if qPart ~= nil and qPart.valid then
                    if EReady  then CastSpell(_E, qPart.x, qPart.z) end

						end
						end

function foundedQ()
            if qPart ~= nil and qPart.valid then
            if RReady  then CastSpell(_R, qPart.x, qPart.z) end
            end
						end




function checkE()
            if ePart ~= nil and ePart.valid then
                    for i = 1, heroManager.iCount do
                            local enemy = heroManager:getHero(i)
                            if ValidTarget(enemy, 1190, true) and GetDistance(ePart, enemy) < 300 then
                                    CastSpell(_E)
                            end
                    end
            end
    end

		--Jungle Steal STUFF and Spark stuff

function OnCreateObj(obj)
        if obj ~= nil and obj.valid then
                if obj.name:lower():find("luxlightbinding") and isObjectOnEnemy(obj) then
                        qPart = obj
                elseif obj.name:lower():find("luxlightstrike") and GetTickCount() < lastE + 2000 then
                        ePart = obj;
                elseif obj.name:find("LuxDebuff") then
                        table.insert(sparks, obj)
                else
                        checkJungleCreated(obj)
                end
        end
end

function OnDeleteObj(obj)
        if obj == qPart then
                qPart = nil
        elseif obj == ePart then
                ePart = nil
        else
                deleteSpark(obj)
                checkJungleDeleted(obj)
        end
end

function OnProcessSpell(unit, spell)
        if unit.isMe and spell ~= nil and spell.name:lower():find("luxlightstrike") then
                lastE = GetTickCount()
        end
end


	function isObjectOnEnemy(obj)
        for i = 1, heroManager.iCount do
                local enemy = heroManager:getHero(i)
                if enemy.team ~= myHero.team and not enemy.dead and GetDistance(enemy, obj) < 50 then
                        return true
                end
        end
        return false
end
function checkJungleDeleted(obj)
        for _, mob in pairs(jungle) do
                if obj ~= nil and obj.name == mob.name then mob.obj = nil end
        end
end

function checkJungleCreated(obj)
        for _, mob in pairs(jungle) do
                if obj ~= nil and obj.name == mob.name then mob.obj = obj end
        end
end

function checkJungleKillable()
        for _, mob in pairs(jungle) do
                if mob.obj ~= nil and mob.obj.valid and not mob.obj.dead
                and GetDistance(mob.obj) < 2999 and RReady
                and mob.obj.health < getDmg("R",mob.obj,myHero) + 50 then
                        CastSpell(_R, mob.obj.x, mob.obj.z)
                end
        end
end

function deleteSpark(obj)
        for _, spark in pairs(sparks) do
                if spark == obj then
                        spark = nil
                end
        end
end

function hasSpark()
        for _, spark in pairs(sparks) do
                if spark ~= nil and spark.valid and GetDistance(ts.target) < 540 + getHitBoxRadius(ts.target) and GetDistance(spark, ts.target) < 100 then
                        return true
                end
        end
        return false
end

--End jungle Steal Spark stuff


function OnDraw()

if Config.Draw.DrawQ then

	DrawCircle3D(myHero.x, myHero.y, myHero.z, SpellQ.Range, 1,  ARGB(255, 0, 255, 255))

end

if Config.Draw.DrawE then

	DrawCircle3D(myHero.x, myHero.y, myHero.z, SpellE.Range, 1,  ARGB(255, 0, 255, 255))

	end

	if Config.Draw.DrawDamage and false then

		for i=1, heroManager.iCount do

			local enemy = heroManager:GetHero(i)

			if ValidTarget(enemy) then

				if DamageToHeros[i] ~= nil then

					RemainingHealth = enemy.health - DamageToHeros[i]

				end

				if RemainingHealth ~= nil then

					DrawIndicator(enemy, math.floor(RemainingHealth))

					DrawOnHPBar(enemy, math.floor(RemainingHealth))

				end

			end

		end

	end

end



function Check()

	QReady = (myHero:CanUseSpell(_Q) == READY)

	WReady = (myHero:CanUseSpell(_W) == READY)

	EReady = (myHero:CanUseSpell(_E) == READY)

	RReady = (myHero:CanUseSpell(_R) == READY)

    if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then

            ignite = SUMMONER_1

    elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then

            ignite = SUMMONER_2
    end

    igniteReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)

end

function IsMyManaLow()

    if myHero.mana < (myHero.maxMana * ( Config.Extras.mManager / 100)) then

        return true

    else

        return false

    end

end

function getHitBoxRadius(target)

    return GetDistance(target.minBBox, target.maxBBox)/2

end

function IgniteKS()

	if igniteReady then

		local Enemies = GetEnemyHeroes()

		for idx,val in ipairs(Enemies) do

			if ValidTarget(val, 600) then

                if getDmg("IGNITE", val, myHero) > val.health and GetDistance(val) <= 600 then

                        CastSpell(ignite, val)

                end

			end

		end

	end

end







