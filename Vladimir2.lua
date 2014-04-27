local VERSION = '0.7'

if myHero.charName ~= "Vladimir" then return end

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
		print("<b>[Vladimir]: Required libraries downloaded successfully, please reload (double F9).</b>")
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

--Required Libs


require "VPrediction"

require "SOW"

require "SourceLib"

--[[Globals]]

local SpellQ = {Speed = 1400, Range = 575, Delay = 0.5, Width = 0 }

local SpellE = {Speed = 1100, Range = 575, Delay = 0.5, Width = 0}

local SpellR = {Range= 700 ,Width = 375, Speed = 1200, Delay= 0.2 }




local ignite

local Endpoint1, Endpoint2, Diffunitvector = nil, nil, nil



--Items and stuff
local znaSlot= nil
local znaReady  = nil
local hpSlot= nil
local wgtSlot= nil
local fskSlot= nil

--Dodging Stuff
local informationTable = {}
local spellExpired = true

--Checks
local Qready = false
local Wready = false
local Eready = false
local Rready = false
local Config = nil
local VP=VPrediction()

--Level sequence
local levelSequence = { 1,2,1,3,1,4,1,3,1,3,4,3,3,2,2,4,2,2 }
local latestVersion=nil
--Updater Stuff
local updateCheck = false
local attacked = false

function getDownloadVersion(response)
        latestVersion = response
end

function getVersion()
        GetAsyncWebResult("dl.dropboxusercontent.com","/s/zcwgv2evby6ssbh/Vladversion.txt",getDownloadVersion)
end

function update()
   if updateCheck == false then
       local PATH = BOL_PATH.."Scripts\\Vladimir2.lua"
       local URL = "https://dl.dropboxusercontent.com/s/c7bkmus63dnquhn/Vladimir2.lua"
       if latestVersion~=nil and latestVersion ~= VERSION then
           updateCheck = true
           PrintChat("UPDATING Vladmir the bloodbender - "..SCRIPT_PATH:gsub("/", "\\").."Vladimir2.lua")
           DownloadFile(URL, PATH,function ()
            PrintChat("UPDATED - Please Reload (F9 twice)")
            end)
        elseif latestVersion == VERSION then
            updateCheck = true
            PrintChat("Vladmir the bloodbender is up to date")
        end
   end
end
AddTickCallback(update)




function Menu()
SOWi = SOW(VP)
Config = scriptConfig("Vladimir", "Vladimir")
Config:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
Config:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('C'))
Config:addParam("Farm", "Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('V'))

Config:addSubMenu("Orbwalker", "Orbwalker")

Config:addSubMenu("Combo options", "ComboSub")

Config:addSubMenu("Harass options", "HarassSub")

Config:addSubMenu("Farm", "FarmSub")

Config:addSubMenu("Jungle", "Jungle")

Config:addSubMenu("W settings ", "WStuff")

Config:addSubMenu("KS", "KS")

Config:addSubMenu("Ultimate", "Ultimate")

Config:addSubMenu("Misc", "Misc")

Config:addSubMenu("Extra Config", "Extras")

Config:addSubMenu("Draw", "Draw")

--orbwalker
SOWi:LoadToMenu(Config.Orbwalker)

--Combo
Config.ComboSub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.ComboSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
Config.ComboSub:addParam("useR", "Use R if enemy killable with full combo", SCRIPT_PARAM_ONOFF, false)

--Harass
Config.HarassSub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.HarassSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
Config.HarassSub:addParam("Enabled2", "Harass (TOGGLE)!", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))

--farm
Config.FarmSub:addParam("useQ", "Use E ", SCRIPT_PARAM_ONOFF, true)
Config.FarmSub:addParam("useQonly", "use Q ", SCRIPT_PARAM_ONOFF, true)
Config.FarmSub:addParam("Enabled", "FarmToggable", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte('I'))

--jungle farm
Config.Jungle:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.Jungle:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
Config.Jungle:addParam("Junglef", "Jungle farm", SCRIPT_PARAM_ONKEYDOWN, false,string.byte('X'))

--wstuff
Config.WStuff:addParam("AutoW", "Auto W ", SCRIPT_PARAM_ONOFF, true)
Config.WStuff:addParam("AutoWhz", "Min Health % for Auto w", SCRIPT_PARAM_SLICE, 15, 0, 100, -1)
Config.WStuff:addParam("Wimportant", "W important spells", SCRIPT_PARAM_ONOFF, true)
--Config.WStuff:addParam("AutoZo", "Auto Zhonya ", SCRIPT_PARAM_ONOFF, true)


--Draw
Config.Draw:addParam("DrawQ", "Draw Q range", SCRIPT_PARAM_ONOFF, false)
Config.Draw:addParam("DrawE", "Draw E range", SCRIPT_PARAM_ONOFF, false)
Config.Draw:addParam("drawText", "Draw enemy texts", SCRIPT_PARAM_ONOFF, true)
Config.Draw:addParam("DrawTarget", "Draw circle around actual target", SCRIPT_PARAM_ONOFF, true)

--KS
Config.KS:addParam("useQ", "Killsteal using Q", SCRIPT_PARAM_ONOFF, true)
Config.KS:addParam("useE", "Killsteal using E", SCRIPT_PARAM_ONOFF, true)

--Ultimate
Config.Ultimate:addParam("AutoR",  "Auto ultimate if ", SCRIPT_PARAM_LIST, 1, { "No", ">0 hit", ">1 hit", ">2 hit", ">3 hit", ">4 hit" })
Config.Ultimate:addParam("AutoAim", "AutoAim your ultimate", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('R'))


--misc
Config.Misc:addParam("WARN", "Warn me when enemy killable (R)", SCRIPT_PARAM_ONOFF, true)
Config.Misc:addParam("autolevel", "Auto level skills", SCRIPT_PARAM_ONOFF, true)

--Extras
Config.Extras:addParam("autoE", "Auto E stack tracking(next update)", SCRIPT_PARAM_ONOFF, true)
Config.Extras:addParam("autoignite", "Auto ignite killable", SCRIPT_PARAM_ONOFF, true)


--permashow
Config:permaShow("Combo")
Config:permaShow("Harass")
Config:permaShow("Farm")
end

function OnLoad()

getVersion()

Menu()

Init()

end

function Init()
ts= TargetSelector(TARGET_LESS_CAST_PRIORITY, 875, DAMAGE_MAGICAL)

ts.name = "Vladimir"

Config:addTS(ts)

EnemyMinions = minionManager(MINION_ENEMY, 875, myHero, MINION_SORT_MAXHEALTH_DEC)

JungleMinions = minionManager(MINION_JUNGLE, 875, myHero, MINION_SORT_MAXHEALTH_DEC)

print('Vladimir TheBlood Bender  ' .. tostring(VERSION) .. ' loaded!')

initDone = true

end

function OnTick()
Check()

if initDone then

KillSteal()

ts:update()

target = ts.target

EnemyMinions:update()

if Config.Combo then

if ValidTarget(target, 875) and not target.dead then

Combo(target)

end

end




if Config.Harass then

if ValidTarget(target, 875) and not target.dead then

Harass(target)

end

end

if Config.Extras.autoignite then

IgniteKS()

end
if ValidTarget(target, 875) and not target.dead then

if Config.HarassSub.Enabled2 then

Harass(target)

end

end

if Config.Misc.autolevel then

autoLevelSetSequence(levelSequence)

end

if Config.Farm and Config.FarmSub.useQ  then

Farm()

end
if Config.Misc.WARN then

Warning()

end
if Config.WStuff.AutoW then

DangerDetected()

end

if Config.Ultimate.AutoAim then

CastRversion(target)

end
if Config.WStuff.Wimportant then

opshit()

end
if Config.Farm and

Config.FarmSub.useQonly then

farmQ()

end

if Config.FarmSub.Enabled then 

farmQ() 

end 

if Config.Jungle.Junglef then

JungleFarm()

end
if Config.Ultimate.AutoR - 1 >=2  then

if target ~= nil then AutoTracker(target)

end
end
end
end




function Check()
wgtReady		= (wgtSlot		~= nil and myHero:CanUseSpell(wgtSlot)		== READY)

znaReady = (znaSlot		~= nil and myHero:CanUseSpell(znaSlot)		== READY)

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

--Credit Skeems
				znaSlot, wgtSlot, bftSlot, liandrysSlot =	GetInventorySlotItem(3157),
													GetInventorySlotItem(3090),
													GetInventorySlotItem(3188),
													GetInventorySlotItem(3151)
--End Credit Skeems
end



function Combo(Target)

SOWi:DisableAttacks()

if QReady and Config.ComboSub.useQ then

CastQ(Target)

end
if EReady and Config.ComboSub.useE then

CastE(Target)

end

if RReady and Config.ComboSub.useR then

CastR(Target)

end

if not QReady and not EReady then

SOWi:EnableAttacks()

end

end

function Harass(Target)

if QReady and Config.HarassSub.useQ then

CastQ(Target) end

if EReady and  Config.HarassSub.useE then

CastE(Target)

end
end


function KillSteal()
	local Enemies = GetEnemyHeroes()

	for i, enemy in pairs(Enemies) do

		if ValidTarget(enemy, 875) and not enemy.dead and GetDistance(enemy) < 875 then

			if getDmg("Q", enemy, myHero) > enemy.health and GetDistance(enemy) < SpellQ.Range and Config.KS.useQ then

				CastQ(enemy)
			end

if getDmg("E", enemy, myHero) > enemy.health and GetDistance(enemy) < SpellE.Range and Config.KS.useW then

    CastE(enemy)

			end
end
end
end

function Warning()

	local Enemies = GetEnemyHeroes()

	for i, enemy in pairs(Enemies) do

		if ValidTarget(enemy, SpellR.range) and not enemy.dead and GetDistance(enemy) < SpellR.Range then

			if getDmg("R", enemy, myHero) > enemy.health and GetDistance(enemy) < SpellR.Range and RReady then

				PrintFloatText(myHero,10,"WARNING : Killable enemy DETECTED !")
			end

		end

	end

	end

function CastQ(Target)

	if QReady and GetDistance(Target) < SpellQ.Range then

		Packet("S_CAST", {spellId = _Q, targetNetworkId = Target.networkID}):send()

	end

end

function CastW()

	if WReady  then

		CastSpell(_W)

	end

end


function CastE(Target)

	if EReady and GetDistance(Target) < SpellE.Range then

		CastSpell(_E)

	end

end


function CastR(Target)

	if RReady and GetDistance(Target) < SpellR.Range and GetComboDamage(Target) +200 > Target.health then


			local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(Target, SpellR.Delay, SpellR.Width, SpellR.Range, SpellR.Speed, myHero)
			if HitChance >= 1 then
				CastSpell(_R, CastPosition.x, CastPosition.z)


				end

		 end
		end


function CastRversion(Target)

if RReady and GetDistance(Target) < SpellR.Range  then

local CastPosition, HitChance, Position = VP:GetCircularAOECastPosition(Target, SpellR.Delay, SpellR.Width, SpellR.Range, SpellR.Speed, myHero)

			if HitChance >= 1 then

				CastSpell(_R, CastPosition.x, CastPosition.z)

			end
			end
			end


function AutoTracker(Target)

if RReady then

local Mintargets = Config.Ultimate.AutoR - 1
local AOECastPosition, MainTargetHitChance, nTargets = VP:GetCircularAOECastPosition(Target, SpellR.Delay, SpellR.Width, SpellR.Range, SpellR.Speed)

if nTargets >= Mintargets then

CastSpell(_R, AOECastPosition.x, AOECastPosition.z)

end
end
end


function OnDraw()

local target=ts.target

if Config.Draw.DrawTarget then

if target ~= nil then

DrawCircle3D(target.x, target.y, target.z, VP:GetHitBox(target), 1, ARGB(255, 255, 0, 0))

end

end

if Config.Draw.drawText then

if target ~= nil then

if GetComboDamage(target) > target.health and not target.dead then

DrawText3D("Kill HIM ", target.x, target.y, target.z, 15,  ARGB(255,0,255,0), true)

elseif not target.dead then

DrawText3D("Harass him", target.x, target.y, target.z, 15,  ARGB(255,0,255,0), true)
end

end

end





if Config.Draw.DrawQ then

DrawCircle3D(myHero.x, myHero.y, myHero.z, SpellQ.Range, 1,  ARGB(255, 0, 255, 255))

		end

		if Config.Draw.DrawE then

		DrawCircle3D(myHero.x, myHero.y, myHero.z, SpellE.Range, 1,  ARGB(255, 0, 255, 255))

	end

	if Config.Draw.DrawR then

		DrawCircle3D(myHero.x, myHero.y, myHero.z, SpellR.Range, 1,  ARGB(255, 0, 255, 255))

	end

	end

function GetComboDamage(Target)
local QDmg=nil

local EDmg =nil

local Rdmg =nil

local Igdmg=nil

local combodamage= 0

QDmg=getDmg("Q", Target, myHero)

EDmg=getDmg("E", Target, myHero)

Rdmg=getDmg("R", Target, myHero)

Igdmg=getDmg("IGNITE", Target, myHero)

combodamage = QDmg + EDmg +  Rdmg + Igdmg

return combodamage

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

function DangerDetected()

if (myHero.health / myHero.maxHealth) <= (Config.WStuff.AutoWhz/ 100) then

CastW()

end

end


function UseHealProtect()

if Config.Misc.Autozo and AMiLOW('Me') and (znaReady or wgtReady) then

			CastSpell((wgtSlot or znaSlot))

		end

end

function AMiLOW(Lawl)

if Lawl == 'Me' then

			if (myHero.health / myHero.maxHealth) <= (Config.Misc.ZWHealth / 100) then

				return true

			else

				return false

			end

		end

end


function Farm()

for _, minion in pairs(EnemyMinions.objects) do

local qMiniyoDmg = getDmg("Q", minion, myHero)

local eMiniyoDmg = getDmg("E", minion, myHero)

local qFarmKey = Config.FarmSub.useQ

if ValidTarget(minion) then

if GetDistance(minion) <= SpellE.Range then

if QReady or EReady then

if minion.health <= ( qMiniyoDmg + eMiniyoDmg) and minion.health > qMiniyoDmg then

CastQ(minion)

CastE(minion)

end

elseif QReady  then

if minion.health <= (qMiniyoDmg) then

CastQ(minion)

end

elseif EReady and not QReady then

if minion.health <= (eMiniyoDmg) then

CastE(minion)

end
elseif EFarmKey and not QFarmKey then

if EReady  then

if minion.health <= (eMiniyoDmg) then

CastE(minion)

end

end

elseif not eFarmKey and QFarmKey then

if QReady then

if minion.health <= (MiniyoDmg) then

CastQ(minion)

end

end

end

elseif (GetDistance(minion) > SpellE.Range) then

if qFarmKey then

if minion.health <= qMiniyoDmg and (GetDistance(minion) <= SpellQ.Range) then

CastQ(minion)

end

end


end

end

end

end

function farmQ()

for _, minion in pairs(EnemyMinions.objects) do

local qMiniyoDmg = getDmg("Q", minion, myHero)

if QReady  then

if minion.health <= (qMiniyoDmg) then

CastQ(minion)

end

end

end

end

function JungleFarm()

	JungleMinions:update()

	SOWi:EnableAttacks()

	local UseQ = Config.Jungle.useQ

	local UseE = Config.Jungle.useE

	local minion = JungleMinions.objects[1]

	if minion then

		if UseQ  then

			CastQ(minion)

		end

		if UseE then

CastSpell(_E)

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

            if lineSegment:distance(heroPosition) <= 200 and WReady then
            	--print('Dodging dangerous spell with E')
                CastSpell(_W)
            end
						if not WReady and znaReady  then CastSpell((wgtSlot or znaSlot)) end
        else
            spellExpired = true
            informationTable = {}
        end
				end


function OnProcessSpell(unit, spell)

if Config.WStuff.Wimportant then
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
	        		if WReady then
	        			CastSpell(_W)
	        			print('Trying to dodge dangerous spell ' .. tostring(spell.name) .. ' with W!')
	        		end
							if not WReady and znaReady  then CastSpell((wgtSlot or znaSlot)) end
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




--end


