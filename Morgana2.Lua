local VERSION = "0.8"

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

if myHero.charName ~= "Morgana" then return end

require 'VPrediction'
require 'SourceLib'
require 'SOW'

local Config = nil

local VP = VPrediction()

local SpellQ = {Speed = 1200, Range = 1175, Delay = 0.2, Width = 50}

local SpellW = {Range = 900, Delay = 0.5, Width = 280}

local SpellR = {Range= 625 , Speed = 20, Delay= 0.3}

local latestVersion=nil

local updateCheck = false

local attacked = false

local informationTable = {}
local spellExpired = true



--Auto update

function getDownloadVersion(response)
        latestVersion = response
end

function getVersion()
        GetAsyncWebResult("dl.dropboxusercontent.com","/s/mi80iugh8yn0iii/Morgana2.txt",getDownloadVersion)
end

function update()
   if updateCheck == false then
       local PATH = BOL_PATH.."Scripts\\Morgana2.lua"
       local URL = "https://dl.dropboxusercontent.com/s/cfjgy7nn3crx3no/Morgana2.lua"
       if latestVersion~=nil and latestVersion ~= VERSION then
           updateCheck = true
           PrintChat("UPDATING Morgana - "..SCRIPT_PATH:gsub("/", "\\").."Morgana2.lua")
           DownloadFile(URL, PATH,function ()
            PrintChat("UPDATED - Please Reload (F9 twice)")
            end)
        elseif latestVersion == VERSION then
            updateCheck = true
            PrintChat("Morgana is up to date")
        end
   end
end
AddTickCallback(update)




function OnLoad()
getVersion()
Init()
ScriptSetUp()
PrintChat("<font color=\"#81BEF7\">Awa Morgana loaded</font>")
end



function Init()

Q = Spell(_Q, SpellQ.Range)
W = Spell(_W, SpellW.Range)
R = Spell(_R, SpellR.Range)


Q:SetSkillshot(VP, SKILLSHOT_LINEAR, SpellQ.Width , SpellQ.Delay, SpellQ.Speed, true)

Loaded = true
end


function ScriptSetUp()

VP = VPrediction()
TS = SimpleTS(STS_LESS_CAST_MAGIC)
Orbwalker = SOW(VP)






	Config = scriptConfig("Morgana", "Morgana")
	Config:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	


	Config:addSubMenu("Orbwalk", "Orbwalk")
    Orbwalker:LoadToMenu(Config.Orbwalk)


    Config:addSubMenu("Combo options", "ComboSub")
    
	Config.ComboSub:addSubMenu("Q options", "Qsub")
	Config.ComboSub.Qsub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	Config.ComboSub.Qsub:addParam("useQGap", "Use Q on gapclose", SCRIPT_PARAM_ONOFF, true)
	Config.ComboSub.Qsub:addParam("Qhitchance", "Q Hitchance", SCRIPT_PARAM_SLICE, 2, 1, 3, 0)

    Config.ComboSub:addSubMenu("W options", "Wsub")
	Config.ComboSub.Wsub:addParam("useW", "Auto W on stunned enemies", SCRIPT_PARAM_ONOFF, true)

--Ultimate
	Config:addSubMenu("Ultimate", "Ultimate")
	Config.Ultimate:addParam("AutoUlti", "AutoUlti if X enemies are in range ",SCRIPT_PARAM_ONOFF, true)
	Config.Ultimate:addParam("RTargetSet", "Set Minimum Enemies to auto ulti ", SCRIPT_PARAM_SLICE, 2, 1, 5, 0)
	
	--TS
Config:addSubMenu("Target Selector", "TS")
TS:AddToMenu(Config.TS)




    --Draw
	Config:addSubMenu("Draw", "Draw")
  Config.Draw:addParam("DrawQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
  Config.Draw:addParam("DrawW", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
  Config.Draw:addParam("DrawR", "Draw R Range", SCRIPT_PARAM_ONOFF, true)
	





--Permashow
Config:permaShow("Combo")



		end




function Combo()

Q:SetHitChance(Config.ComboSub.Qsub.Qhitchance)

local Qfound = TS:GetTarget(SpellQ.Range)
local Wfound = TS:GetTarget(SpellW.Range)


   Orbwalker:EnableAttacks()


if Qfound and Q:IsReady() and Config.ComboSub.Qsub.useQ  then

   Q:Cast(Qfound)

	end


	end



function Wonstunned()
local Enemies = GetEnemyHeroes()
for i, enemy in pairs(Enemies) do
if not enemy.dead  and enemy.canMove == false and TargetHaveBuff('DarkBindingMissile',enemy) and GetDistance(enemy) < SpellW.Range then
W:Cast(enemy) 
end 
end 
end 



function Autotracker()
local MinEnemies = Config.Ultimate.RTargetSet
local enemyinrange = CountEnemyHeroInRange(400,myHero)
if enemyinrange ~= nil and Config.Ultimate.RTargetSet ~= nil then 
if MinEnemies <= enemyinrange then 
CastSpell(_R)
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
	
		if Config.Draw.DrawR then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, SpellR.Range, 1,  ARGB(255, 0, 255, 255))
	end

end


function OnTick()
if Loaded then


if Config.Combo then

Combo()

end

if Config.ComboSub.Wsub.useW then Wonstunned() end 

if Config.Ultimate.AutoUlti then Autotracker() end 

if Config.ComboSub.Qsub.useQGap then opshit() end 

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

            if lineSegment:distance(heroPosition) <= 200 and Q:IsReady() then
            	--print('Dodging dangerous spell with E')
               
            end
						
        else
            spellExpired = true
            informationTable = {}
        end
				end

function OnProcessSpell(unit, spell)
if Config.ComboSub.Qsub.useQGap then
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
	        		if Q:IsReady()then
	        			CastSpell(_Q,unit.x,unit.y)
	        			--print('Trying to dodge gapclosing spell ' .. tostring(spell.name) .. ' with E!')
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
