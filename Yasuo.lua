local version = 1.0
--[[ AWA and Pyryoer Legendary Yasuo  if you like our work feel free to donate  ;)

--Orbwalker : Integrated Orbwalker: SOW with highly fluid Orbwalking abilities , farm lane clear and last hit

-Fully Supports SAC/MMA With a menu to choose which orbwalker you want to use just activate SAC/MMA in case you want to use one of them

-- Target Selector

-Advanced Target Selector Written in the SourceLib

-a Menu To choose Which target To focus and The focus Mode

--Combo Mode

--Skill Manager :

-Configurable Spell Usage Q R E

- Smart Combo taking care of the E Q

- Smart ability usage depends on the situation


--Packets Manager :

-Choose whether you want or you don't want to use packets for casting Q

--Harass Options

-Will use Q and and use E to back to the minions

--Jungle farm options

-Smart Jungle Farm

-Configurable usage of Q and E

--Farm options

-Configurable Usage Q And E

-Lane Clear mode

-- Advanced  options :

-Auto use Q on enemies

-Auto use Q2 on enemies

--Configurable Auto Q options with Smart under turret detection  , and Recalling detection

--Use R , Auto use R on Knocked up enemies

--Configurable Auto Use R

-Choose to use R on enemies knocked by you

-Choose to use R on any knocked up enemies

-Use E to gap close

-- Auto Wall options :

-Configurable usage of Evadeee Integration

-Auto wall ON/OFF

- Prioritize Important Spells


--Items and summoner spells  manager :

-Auto ignite Options

- Botrk Usage

- Hydra Usage


--Other options

- Ping When enemy is knocked up

--Show options

Configurable Permashow options

-Combo , harass , flee , farm

--Draw options

-Draw of spells Range with configurable Colors Circle Types and much more

]]
if myHero.charName ~= "Yasuo" then return end
local AUTOUPDATE = true
local SCRIPT_NAME = "Yasuo"

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local SOURCELIB_URL = "https://raw.github.com/TheRealSource/public/master/common/SourceLib.lua"
local SOURCELIB_PATH = LIB_PATH.."SourceLib.lua"

if FileExist(SOURCELIB_PATH) then
  require("SourceLib")
else
  DOWNLOADING_SOURCELIB = true
  DownloadFile(SOURCELIB_URL, SOURCELIB_PATH, function() print("Required libraries downloaded successfully, please reload") end)
end

if DOWNLOADING_SOURCELIB then print("Downloading required libraries, please wait...") return end

if AUTOUPDATE then
  SourceUpdater(SCRIPT_NAME, version, "http://bitbucket.org", "/christiantluciani/BoL/raw/master/"..SCRIPT_NAME..".lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/christiantluciani/BoL/raw/master/VersionFiles/"..SCRIPT_NAME..".version"):CheckUpdate()
end

local RequireI = Require("SourceLib")
  RequireI:Add("vPrediction", "https://raw.github.com/honda7/BoL/master/Common/VPrediction.lua")
  RequireI:Add("SOW", "https://raw.github.com/honda7/BoL/master/Common/SOW.lua")
  RequireI:Check()

if RequireI.downloadNeeded == true then return end

local BlockableProjectiles = {
  --AAtrox
  ['AatroxQ'] = {charName = "Aatrox", spellSlot = "Q", range = 650, width = 0, speed = 20,  delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = true, hitLineCheck = false},
  ['AatroxE'] = {charName = "Aatrox", spellSlot = "E", range = 1000, width = 150, speed = 1200, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['AatroxR'] = {charName = "Aatrox", spellSlot = "R", range = 550, width = 0, speed = 0, delay = 0, SpellType = "selfCast", collision = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  -- Ahri
  ['AhriOrbofDeception'] = {charName = "Ahri", spellSlot = "Q", range = 880, width = 100, speed = 1100, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  ['AhriFoxFire'] = {charName = "Ahri", spellSlot = "W", range = 800, width = 0, speed = 1800, delay = 0, SpellType = "selfCast", collision = false ,  riskLevel = "kill", cc = false,  hitLineCheck = false},
  ['AhriSeduce'] = {charName = "Ahri", spellSlot = "E", range = 975,  width = 60, speed = 1200, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
    --special spell
  ['AhriTumble'] = {charName = "Ahri", spellSlot = "R", range = 450, width = 0, speed = 2200, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  --Akali
  ['AkaliMota'] = {charName = "Akali", spellSlot = "Q", range = 600, width = 0, speed = 1000, delay = .65, SpellType = "enemyCast", Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false},
  ['AkaliSmokeBomb'] = {charName = "Akali", spellSlot = "W", range = 700, width = 0, speed = 0, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "dangerous", cc = true, hitLineCheck = false},
  ['AkaliShadowSwipe'] = {charName = "Akali", spellSlot = "E", range = 325, width = 0, speed = 0, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['AkaliShadowDance'] = {charName = "Akali", spellSlot = "R", range = 800, width = 0, speed = 2200, delay = 0, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  --Alistar
  ['Pulverize'] = {charName = "Alistar", spellSlot = "Q", range = 365, width = 0, speed = 20, delay = .5, SpellType  = "enemyCast", riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['Headbutt'] = {charName = "Alistar", spellSlot = "W", range = 100, width = 0 , speed = 0, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['TriumphantRoar'] = {charName = "Alistar", spellSlot = "E", range = 575, width = 0 , speed = 0, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false, healSlot = _E},
  ['FerouciousHowl'] = {charName = "Alistar", spellSlot = "R", range = 0, width = 0, speed = 828, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  -- Amumu
  ['BandageToss'] = {charName = "Amumu", spellSlot = "Q", range = 1100, width = 80, speed = 2000, delay = .5, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['AuraofDespair'] = {charName = "Amumu", spellSlot = "W", range = 300, width = 0, speed = math.huge, delay = .47, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['Tantrum'] = {charName = "Amumu", spellSlot = "E", range = 350, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['CurseoftheSadMumm'] = {charName = "Amumu", spellSlot = "R", range = 550, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false, timer = 0},
  -- Anivia
  ['FlashFrost'] = {charName = "Anivia", spellSlot = "Q", range = 1200, width = 110, speed = 850, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['Crystalize'] = {charName = "Anivia", spellSlot = "W", range = 1000, width = 400, speed = 1600, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['Frostbite'] = {charName = "Anivia", spellSlot = "E", range = 650, width = 0, speed = 1200, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false},
  ['GlacialStorm'] = {charName = "Anivia", spellSlot = "R", range = 675, width = 400, speed = math.huge, delay = .3, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  --Annie
  ['Disintegrate'] = {charName = "Annie", spellSlot = "Q", range = 710, width = 0, speed = 1400, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "Kill", cc = false, hitLineCheck = false},
  ['Incinerate'] = {charName = "Annie", spellSlot = "W", range = 210, width = 0, speed = 0, delay = .5, SpellType = "enemyCast", collision = false , riskLevel = "Kill", cc = false, hitLineCheck = true},
  ['MoltenShield'] = {charName = "Annie", spellSlot = "E", range = 100, width = 0, speed = 20, delay = 0, SpellType = "selfCast", Blockable = false ,  rickLevel = "noDmg", cc = false, hitLineCheck = false} ,
  ['InfernalGuardian'] = {charName = "Annie", spellSlot = "R", range = 250, width = 0, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "Kill", cc = false, hitLineCheck = true, timer = 0},
  -- Ashe
  ['FrostShot'] = {charName = "Ashe", spellSlot = "Q", range = 0, width = 0, speed = math.huge, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['frostarrow'] = {charName = "Ashe", spellSlot = "Q", range = 0, width = 0, speed = math.huge, delay = 0, SpellType = "enemyCast", Blockable = false, riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['Volley'] = {charName = "Ashe", spellSlot = "W", range = 1200, width = 250, speed = 902, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
    --special spell: 2500 / 3250 / 4000 / 4750 / 5500 (range increase with level)
  ['AsheSpiritOfTheHawk'] = {charName = "Ashe", spellSlot = "E", range = 2500, width = 0, speed = 1400, delay = .5, SpellType = "skillshot",collision = false, collision = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['EnchantedCrystalArrow'] = {charName = "Ashe", spellSlot = "R", range = 50000, width = 130, speed = 1600, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  -- Blitzcrank
  ['RocketGrabMissile'] = {charName = "Blitzcrank", spellSlot = "Q", range = 925, width = 70, speed = 1800, delay = .22, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['Overdrive'] = {charName = "Blitzcrank", spellSlot = "W", range = 0, width = 0, speed = 0, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['PowerFist'] = {charName = "Blitzcrank", spellSlot = "E", range = 0, width = 0, speed = 0, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['StaticField'] = {charName = "Blitzcrank", spellSlot = "R", range = 600, width = 0, speed = 0, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  -- Brand
  ['BrandBlaze'] = {charName = "Brand", spellSlot = "Q", range = 1050, width = 80, speed = 1200, delay = 0.5, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  ['BrandFissure'] = {charName = "Brand", spellSlot = "W", range = 240, width = 0, speed = 20, delay = 0.5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false,  hitLineCheck = false},
  ['BrandConflagration'] = {charName = "Brand", spellSlot = "E", range = 0, width = 0, speed = 1800, delay = 0, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['BrandWildfire'] = {charName = "Brand", spellSlot = "R", range = 0, width = 0, speed = 1000, delay = 0, SpellType = "enemyCast", Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false, timer = 230 - GetLatency()},
  -- Braum
  ['BraumQ'] = {charName = "Braum", spellSlot = "Q", range = 1100, width = 100, speed = 1200, delay = .5, spellType = "skillShot", riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['BraumQMissle'] = {charName = "Braum", spellSlot = "Q", range = 1100, width = 100, speed = 1200, delay = .5, spellType = "skillShot", riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['BraumW'] = {charName = "Braum", spellSlot = "W", range = 650, width = 0, speed = 1500, delay = .5, spellType = "allyCast", riskLevel = "noDmg", cc = false,  hitLineCheck = false},
  ['BraumE'] = {charName = "Braum", spellSlot = "E", range = 250, width = 0, speed = math.huge, delay = 0, spellType = "skillshot", riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['BraumR'] = {charName = "Braum", spellSlot = "R", range = 1250, width = 180, speed = 1200, delay = 0, spellType = "skillshot", riskLevel = "extreme", cc = true, hitLineCheck = true},
  -- Caitlyn
  ['CaitlynPiltoverPeacemaker'] = {charName = "Caitlyn", spellSlot = "Q", range = 1250, width = 90, speed = 2200, delay = 0.25, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  ['CaitlynYordleTrap'] = {charName = "Caitlyn", spellSlot = "W", range = 800, width = 0, speed = 1400, delay = 0, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['CaitlynEntrapment'] = {charName = "Caitlyn", spellSlot = "E", range = 950, width = 80, speed = 2000, delay = 0.25, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['CaitlynAceintheHole'] = {charName = "Caitlyn", spellSlot = "R", range = 2500, width = 0, speed = 1500, delay = 0, SpellType = "enemyCast", Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false, timer = 1350-GetLatency()},
  -- Cassiopeia
  ['CassiopeiaNoxiousBlast'] = {charName = "Cassiopeia", spellSlot = "Q", range = 925, width = 130, speed = math.huge, delay = 0.25, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['CassiopeiaMiasma'] = {charName = "Cassiopeia", spellSlot = "W", range = 925, width = 212, speed = 2500, delay = 0.5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['CassiopeiaTwinFang'] = {charName = "Cassiopeia", spellSlot = "E", range = 700, width = 0, speed = 1900, delay = 0, SpellType = "enemyCast", Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false},
  ['CassiopeiaPetrifyingGaze'] = {charName = "Cassiopeia", spellSlot = "R", range = 875, width = 210, speed = math.huge, delay = 0.5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true, timer = 0},
  -- Cho'Gath
  ['Rupture'] = {charName = "Chogath", spellSlot = "Q", range = 1000, width = 250, speed = math.huge, delay = 0.5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['FeralScream'] = {charName = "Chogath", spellSlot = "W", range = 675, width = 210, speed = math.huge, delay = 0.25, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['VorpalSpikes'] = {charName = "Chogath", spellSlot = "E", range = 0, width = 170, speed = 347, delay = 0, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['Feast'] = {charName = "Chogath", spellSlot = "R", range = 230, width = 0, speed = 500, delay = 0, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  -- Corki
  ['PhosphorusBomb'] = {charName = "Corki", spellSlot = "Q", range = 875, width = 250, speed = math.huge, delay = 0, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['CarpetBomb'] = {charName = "Corki", spellSlot = "W", range = 875, width = 160, speed = 700, delay = 0, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  ['GGun'] = {charName = "Corki", spellSlot = "E", range = 750, width = 100, speed = 902, delay = 0, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  ['MissileBarrage'] = {charName = "Corki", spellSlot = "R", range = 1225, width = 40, speed = 828.5, delay = 0.25, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  --Darius
  ['DariusCleave'] = {charName = "Darius", spellSlot = "Q", range = 425, width = 0, speed = 0, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['DariusNoxianTacticsONH'] = {charName = "Darius", spellSlot = "W", range = 210, speed = 0, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['DariusAxeGrabCone'] = {charName = "Darius", spellSlot = "E", range = 540, speed = 1500, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "dangerous", cc = true, hitLineCheck = true},
  ['DariusExecute'] = {charName = "Darius", spellSlot = "R", range = 460, width = 0, speed = 20, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  -- Diana
  ['DianaArc'] = {charName = "Diana", spellSlot = "Q", range = 900, width = 75, speed = 1500, delay = .5, SpellType = "skillshot",collision = false, collision = false ,  riskLevel = "kill", cc = true, hitLineCheck = true},
  ['DianaOrbs'] = {charName = "Diana", spellSlot = "W", range = 0, width = 0, speed = 0, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false, shieldSlot = _W},
  ['DianaVortex'] = {charName = "Diana", spellSlot = "E", range = 300, width = 0, speed = 1500, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "dangerous", cc = true, hitLineCheck = false},
  ['DianaTeleport'] = {charName = "Diana", spellSlot = "R", range = 800, width = 0, speed = 1500, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = true, hitLineCheck = false},
  -- DrMundo
  ['InfectedCleaverMissileCast'] = {charName = "DrMundo", spellSlot = "Q", range = 900, width = 75, speed = 1500, delay = .5, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['BurningAgony'] = {charName = "DrMundo", spellSlot = "W", range = 325, width = 0, speed = math.huge, delay = math.huge, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},--CC?
  ['Masochism'] = {charName = "DrMundo", spellSlot = "E", range = 0, width = 0, speed = math.huge, delay = math.huge, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['Sadism'] = {charName = "DrMundo", spellSlot = "R", range = 0, width = 0, speed = math.huge, delay = math.huge, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  -- Draven
  ['dravenspinning'] = {charName = "Draven", spellSlot = "Q", range = 0, width = 0, speed = math.huge, delay = math.huge, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['DravenFury'] = {charName = "Draven", spellSlot = "W", range = 0, width = 0, speed = math.huge, delay = math.huge, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['DravenDoubleShot'] = {charName = "Draven", spellSlot = "E", range = 1050, width = 130, speed = 1600, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['DravenRCast'] = {charName = "Draven", spellSlot = "R", range = 20000, width = 160, speed = 2000, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  --Elise
  ['EliseHumanQ'] = {charName = "Elise", spellSlot = "Q", range = 625, width = 0, speed = 2200, delay = .75, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['EliseHumanW'] = {charName = "Elise", spellSlot = "W", range = 950, width = 235, speed = 5000, delay = .75, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['EliseHumanE'] = {charName = "Elise", spellSlot = "E", range = 1075, width = 70, speed = 1450, delay = .5, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "dangerous", cc = true, hitLineCheck = true},
  ['EliseR'] = {charName = "Elise", spellSlot = "R", range = 0, width = 0, speed = math.huge, delay = math.huge, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['EliseSpiderQCast'] = {charName = "Elise", spellSlot = "Q", range = 475, width = 0, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['EliseSpiderW'] = {charName = "Elise", spellSlot = "W", range = 0, width = 0, speed = math.huge, delay = math.huge, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['EliseSpiderEInitial'] = {charName = "Elise", spellSlot = "E", range = 975, width = 0, speed = math.huge, delay = math.huge, SpellType = "enemyCast", Blockable = false, riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['elisespideredescent'] = {charName = "Elise", spellSlot = "E", range = 975, width = 0, speed = math.huge, delay = math.huge, SpellType = "enemyCast", Blockable = false, riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['EliseSpiderR'] = {charName = "Elise", spellSlot = "R", range = 0, width = 0, speed = math.huge, delay = math.huge, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  --Evelynn
  ['EvelynnQ'] = {charName = "Evelynn", spellSlot = "Q", range = 500, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['EvelynnW'] = {charName = "Evelynn", spellSlot = "W", range = 0, width = 0, speed = math.huge, delay = math.huge, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['EvelynnE'] = {charName = "Evelynn", spellSlot = "E", range = 290, width = 0, speed = 900, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['EvelynnR'] = {charName = "Evelynn", spellSlot = "R", range = 650, width = 350, speed = 1300, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  -- Ezreal
  ['EzrealMysticShot'] = {charName = "Ezreal", spellSlot = "Q", range = 1150, width = 80, speed = 1200, delay = .5, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  ['EzrealEssenceFlux'] = {charName = "Ezreal", spellSlot = "W", range = 1000, width = 80, speed = 1200, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  ['EzrealArcaneShift'] = {charName = "Ezreal", spellSlot = "E", range = 475, width = 0, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['EzrealTruehotBarrage'] = {charName = "Ezreal", spellSlot = "R", range = 20000, width = 160, speed = 2000, delay = 1, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  --FiddleSticks
  ['Terrify'] = {charName = "FiddleSticks", spellSlot = "Q", range = 575, width = 0, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "dangerous", cc = true, hitLineCheck = false},
  ['Drain'] = {charName = "FiddleSticks", spellSlot = "W", range = 575, width = 0, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['FiddlesticksDarkWind'] = {charName = "FiddleSticks", spellSlot = "E", range = 750, width = 0, speed = 1100, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['Crowstorm'] = {charName = "FiddleSticks", spellSlot = "R", range = 800, width = 600, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false , riskLevel = "dangerous", cc = true, hitLineCheck = false},
  --Fiora
  ['FioraQ'] = {charName = "Fiora", spellSlot = "Q", range = 300 , width = 0 , speed = 2200, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['FioraRiposte'] = {charName = "Fiora", spellSlot = "W", range = 100, width = 0, speed = 0, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false, aaShieldSlot = _W},
  ['FioraFlurry'] = {charName = "Fiora", spellSlot = "E", range = 210 , width = 0, speed = 0, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['FioraDance'] = {charName = "Fiora", spellSlot = "R", range = 210, width = 0, speed = 0, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false, timer = 280 - GetLatency()},
  --Fizz
  ['FizzPiercingStrike'] = {charName = "Fizz", spellSlot = "Q", range = 550 , width = 0 , speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['FizzSeastonePassive'] = {charName = "Fizz", spellSlot = "W", range = 0 , width = 0 , speed = 0, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['FizzJump'] = {charName = "Fizz", spellSlot = "E", range = 400 , width = 120 , speed = 1300, delay = .5, SpellType = "selfcast", riskLevel = "extreme", cc = true, hitLineCheck = false, shieldSlot = _E},
  ['FizzJumptwo'] = {charName = "Fizz", spellSlot = "E", range = 400 , width = 500 , speed = 1300, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['FizzMarinerDoom'] = {charName = "Fizz", spellSlot = "R", range = 1275 , width = 250 , speed = 1200, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  -- Galio
  ['GalioResoluteSmite'] = {charName = "Galio", spellSlot = "Q", range = 940 , width = 120 , speed = 1300, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['GalioBulwark'] = {charName = "Galio", spellSlot = "W", range = 800 , width = 0 , speed = math.huge, delay = .5, SpellType = "allyCast", riskLevel = "noDmg", cc = false, hitLineCheck = false, shieldSlot = _W},
  ['GalioRighteousGust'] = {charName = "Galio", spellSlot = "E", range = 1180 , width = 140 , speed = 1200, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  ['GalioIdolOfDurand'] = {charName = "Galio", spellSlot = "R", range = 560 , width = 0 , speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false, timer = 0},
  --GangPlank
  ['Parley'] = {charName = "Gangplank", spellSlot = "Q", range = 625 , width = 0 , speed = 2000, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false},
  ['RemoveScurvy'] = {charName = "Gangplank", spellSlot = "W", range = 0 , width = 0 , speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false, healSlot = _W, qssSlot = _W},
  ['RaiseMorale'] = {charName = "Gangplank", spellSlot = "E", range = 1300 , width = 0 , speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['CannonBarrage'] = {charName = "Gangplank", spellSlot = "R", range = 20000 , width = 525 , speed = 500, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = true, hitLineCheck = false},
  --Garen
  ['GarenQ'] = {charName = "Garen", spellSlot = "Q", range = 0 , width = 0 , speed = math.huge, delay = .2, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['GarenW'] = {charName = "Garen", spellSlot = "W", range = 0 , width = 0 , speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['GarenE'] = {charName = "Garen", spellSlot = "E", range = 325 , width = 0 , speed = 700, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['GarenR'] = {charName = "Garen", spellSlot = "R", range = 400 , width = 0 , speed = math.huge, delay = .12, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  -- Gragas
  ['GragasBarrelRoll'] = {charName = "Gragas", spellSlot = "Q", range = 1100 , width = 320 , speed = 1000, delay = .3, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['gragasbarrelrolltoggle'] = {charName = "Gragas", spellSlot = "Q", range = 1100 , width = 320 , speed = 1000, delay = .3, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['GragasDrunkenRage'] = {charName = "Gragas", spellSlot = "W", range = 0 , width = 0 , speed = 0, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['GragasBodySlam'] = {charName = "Gragas", spellSlot = "E", range = 1100 , width = 50 , speed = 1000, delay = .3, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['GragasExplosiveCask'] = {charName = "Gragas", spellSlot = "R", range = 1100 , width = 700 , speed = 1000, delay = .3, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  -- Graves
  ['GravesClusterShot'] = {charName = "Graves", spellSlot = "Q", range = 1100 , width = 10 , speed = 902, delay = .3, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  ['GravesSmokeGrenade'] = {charName = "Graves", spellSlot = "W", range = 1100 , width = 250 , speed = 1650, delay = .3, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['gravessmokegrenadeboom'] = {charName = "Graves", spellSlot = "W", range = 1100 , width = 250 , speed = 1650, delay = .3, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['GravesMove'] = {charName = "Graves", spellSlot = "E", range = 425 , width = 50 , speed = 1000, delay = .3, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['GravesChargeShot'] = {charName = "Graves", spellSlot = "R", range = 1000 , width = 100 , speed = 1200, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  --Hecarim
  ['HecarimRapidSlash'] = {charName = "Hecarim", spellSlot = "Q", range = 350 , width = 0 , speed = 1450, delay = .3, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['HecarimW'] = {charName = "Hecarim", spellSlot = "W", range = 525 , width = 0 , speed = 828.5, delay = .12, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['HecarimRamp'] = {charName = "Hecarim", spellSlot = "E", range = 0 , width = 0 , speed = math.huge, delay = math.huge, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['HecarimUlt'] = {charName = "Hecarim", spellSlot = "R", range = 1350 , width = 200 , speed = 1200, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  -- Heimerdinger
  ['HeimerdingerQ'] = {charName = "Heimerdinger", spellSlot = "Q", range = 350 , width = 0 , speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['HeimerdingerW'] = {charName = "Heimerdinger", spellSlot = "W", range = 1525 , width = 200 , speed = 902, delay = .5, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  ['HeimerdingerE'] = {charName = "Heimerdinger", spellSlot = "E", range = 970 , width = 120 , speed = 2500, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['HeimerdingerR'] = {charName = "Heimerdinger", spellSlot = "R", range = 0 , width = 0 , speed = math.huge, delay = .23, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  -- Irelia
  ['IreliaGatotsu'] = {charName = "Irelia", spellSlot = "Q", range = 650 , width = 0 , speed =2200, delay = 0, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['IreliaHitenStyle'] = {charName = "Irelia", spellSlot = "W", range = 0 , width = 0 , speed =347, delay = .23, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['IreliaEquilibriumStrike'] = {charName = "Irelia", spellSlot = "E", range = 325 , width = 0 , speed =math.huge, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['IreliaTranscendentBlades'] = {charName = "Irelia", spellSlot = "R", range = 1200 , width = 0 , speed =779, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  -- Janna
  ['HowlingGale'] = {charName = "Janna", spellSlot = "Q", range = 1800 , width = 200 , speed = math.huge, delay = 0, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['SowTheWind'] = {charName = "Janna", spellSlot = "W", range = 600 , width = 0 , speed = 1600, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['EyeOfTheStorm'] = {charName = "Janna", spellSlot = "E", range = 800 , width = 0, speed = math.huge, delay = .5, SpellType = "allyCast", riskLevel = "noDmg", cc = false, hitLineCheck = false, shieldSlot = _E},
  ['ReapTheWhirlwind'] = {charName = "Janna", spellSlot = "R", range = 725 , width = 0 , speed = 828.5, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = true, hitLineCheck = false},
  -- JarvanIV
  ['JarvanIVDragonStrike'] = {charName = "JarvanIV", spellSlot = "Q", range = 700, width = 70, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  ['JarvanIVGoldenAegis'] = {charName = "JarvanIV", spellSlot = "W", range = 300, width = 0, speed = 0, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "dangerous", cc = true, hitLineCheck = false, shieldSlot = _W},
  ['JarvanIVDemacianStandard'] = {charName = "JarvanIV", spellSlot = "E", range = 830, width = 75, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['JarvanIVCataclysm'] = {charName = "JarvanIV", spellSlot = "R", range = 650, width = 325, speed = 0, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  --Jax
  ['JaxLeapStrike'] = {charName = "Jax", spellSlot = "Q", range = 210, width = 0, speed = 0, delay = .5, SpellType = "everyCast", riskLevel = "kill", cc = false, hitLineCheck = false},
  ['JaxEmpowerTwo'] = {charName = "Jax", spellSlot = "W", range = 0, width = 0, speed = 0, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['JaxCounterStrike'] = {charName = "Jax", spellslot = "E", range = 300, width = 0, speed = 1450, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "extreme" , cc = true, hitLineCheck = true},
  ['JaxRelentlessAsssault'] = {charName = "Jax", spellSlot = "R", range = 0, width = 0, speed = 0, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel =  "noDmg", cc = false, hitLineCheck = false},
  --Jayce
  ['JayceToTheSkies'] = {charName = "Jayce", spellSlot = "Q", range = 600 , width = 0 , speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['JayceStaticField'] = {charName = "Jayce", spellSlot = "W", range = 285 , width = 200 , speed = 1500, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['JayceThunderingBlow'] = {charName = "Jayce", spellSlot = "E", range = 300 , width = 80 , speed = math.huge, delay = 0, SpellType = "enemyCast", Blockable = false, riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['JayceStanceHtG'] = {charName = "Jayce", spellSlot = "R", range = 0 , width = 0 , speed = math.huge, delay = .75, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['jayceshockblast'] = {charName = "Jayce", spellSlot = "Q", range = 1050 , width = 80 , speed = 1200, delay = .5, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['jaycehypercharge'] = {charName = "Jayce", spellSlot = "W", range = 0 , width = 0 , speed = math.huge, delay = .75, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['jayceaccelerationgate'] = {charName = "Jayce", spellSlot = "E", range = 685 , width = 0 , speed = 1600, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['jaycestancegth'] = {charName = "Jayce", spellSlot = "R", range = 0 , width = 0 , speed = math.huge, delay = .75, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  --Jinx 
  ['JinxW'] = {charName = "Jinx", spellSlot = "W", range = 1450 , width = 80 , speed = 1200, delay = .5, SpellType = "skillshot",collision = true, Blockable = true, riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['JinxRWrapper'] = {charName = "Jinx", spellSlot = "R", range = 20000 , width = 120 , speed = 1200, delay = .5, SpellType = "skillshot",collision = false, Blockable = true, riskLevel = "extreme", cc = true, hitLineCheck = false},
  -- Karthus
  ['LayWaste'] = {charName = "Karthus", spellSlot = "Q", range = 875 , width = 160 , speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['WallOfPain'] = {charName = "Karthus", spellSlot = "W", range = 1090 , width = 525 , speed = 1600, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "dangerous", cc = true, hitLineCheck = false},
  ['Defile'] = {charName = "Karthus", spellSlot = "E", range = 550 , width = 160 , speed = 1000, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['FallenOne'] = {charName = "Karthus", spellSlot = "R", range = 20000 , width = 0 , speed = math.huge, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false, timer = 2200},
  --Karma
  ['KarmaQ'] = {charName = "Karma", spellSlot = "Q", range = 950 , width = 90 , speed = 902, delay = .5, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['KarmaSpiritBind'] = {charName = "Karma", spellSlot = "W", range = 700 , width = 60 , speed = 2000, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['KarmaSolKimShield'] = {charName = "Karma", spellSlot = "E", range = 800 , width = 0 , speed = math.huge, delay = .5, SpellType = "allyCast", riskLevel = "noDmg", cc = false, hitLineCheck = false, shieldSlot = _E},
  ['KarmaMantra'] = {charName = "Karma", spellSlot = "R", range = 0 , width = 0 , speed = 1300, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  --Kassadin
  ['NullLance'] = {charName = "Kassadin", spellSlot = "Q", range = 650, width = 0, speed = 1400, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "extreme", cc = trueww, hitLineCheck = false},
  ['NetherBlade'] = {charName = "Kassadin", spellSlot = "W", range = 0, width = 0, speed = 0, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['ForcePulse'] = {charName = "Kassadin", spellSlot = "E", range = 700, width = 10, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['RiftWalk'] = {charName = "Kassadin", spellSlot = "R", range = 675, width = 150, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  -- Katarina
  ['KatarinaQ'] = {charName = "Katarina", spellSlot = "Q", range = 675, width = 0, speed = 1800, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false},
  ['KatarinaW'] = {charName = "Katarina", spellSlot = "W", range = 400, width = 0, speed = 1800, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['KatarinaE'] = {charName = "Katarina", spellSlot = "E", range = 700, width = 0, speed = 0, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['KatarinaR'] = {charName = "Katarina", spellSlot = "R", range = 550, width = 0, speed = 1450, delay = .5, SpellType = "selfCast", Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  --Kayle
  ['JudicatorReckoning'] = {charName = "Kayle", spellSlot = "Q", range = 650, width = 0, speed = 1500, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['JudicatorDevineBlessing'] = {charName = "Kayle", spellSlot = "W", range = 900, width = 0, speed = math.huge, delay = .22, SpellType = "allyCast", riskLevel = "noDmg", cc = false, hitLineCheck = false, healSlot = _W},
  ['JudicatorRighteousFury'] = {charName = "Kayle", spellSlot = "E", range = 0, width = 0, speed = 779, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['JudicatorIntervention'] = {charName = "Kayle", spellSlot = "R", range = 900, width = 0, speed = math.huge, delay = .5, SpellType = "allyCast", riskLevel = "noDmg", cc = false, hitLineCheck = false, ultSlot = _R},
  -- Kennen
  ['KennenShurikenHurlMissile1'] = {charName = "Kennen", spellSlot = "Q", range = 1000, width = 0, speed = 1700, delay = .69, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  ['KennenBringTheLight'] = {charName = "Kennen", spellSlot = "W", range = 900, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['KennenLightningRush'] = {charName = "Kennen", spellSlot = "E", range = 0, width = 0, speed = math.huge, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['KennenShurikenStorm ']= {charName = "Kennen", spellSlot = "R", range = 550, width = 0, speed = 779, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  --Kha'Zix
  ['KhazixQ'] = {charName = "Khazix", spellSlot = "Q", range = 325, width = 0, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['KhazixW'] = {charName = "Khazix", spellSlot = "W", range = 1000, width = 60, speed = 828.5, delay = .5, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['KhazixE'] = {charName = "Khazix", spellSlot = "E", range = 600, width = 300, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['KhazixR'] = {charName = "Khazix", spellSlot = "R", range = 0, width = 0, speed = math.huge, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['khazixqlong'] = {charName = "Khazix", spellSlot = "Q", range = 375, width = 0, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['khazixwlong'] = {charName = "Khazix", spellSlot = "W", range = 1000, width = 250, speed = 828.5, delay = .5, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['khazixelong'] = {charName = "Khazix", spellSlot = "E", range = 900, width = 300, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['khazixrlong'] = {charName = "Khazix", spellSlot = "R", range = 0, width = 0, speed = math.huge, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  -- KogMaw
  ['KogMawCausticSpittle'] = {charName = "KogMaw", spellSlot = "Q", range = 625, width = 0, speed = math.huge, delay = .5, SpellType = "skillshot",collision = true , Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false},
  ['KogMawBioArcanBarrage'] = {charName = "KogMaw", spellSlot = "W", range = 130, width = 0, speed = 2000, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['KogMawVoidOoze'] = {charName = "KogMaw", spellSlot = "E", range = 1000, width = 120, speed = 1200, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
    --special spell 1400/1700/2200 range
  ['KogMawLivingArtillery'] = {charName = "KogMaw", spellSlot = "R", range = 1400, width = 225, speed = 2000, delay = .6, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  -- Leblanc
  ['LeblancChaosOrb'] = {charName = "Leblanc", spellSlot = "Q", range = 700, width = 0, speed = 2000, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false},
  ['LeblancSlide'] = {charName = "Leblanc", spellSlot = "W", range = 600, width = 220, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['leblacslidereturn'] = {charName = "Leblanc", spellSlot = "W", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['LeblancSoulShackle'] = {charName = "Leblanc", spellSlot = "E", range = 925, width = 70, speed = 1600, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['LeblancChaosOrbM'] = {charName = "Leblanc", spellSlot = "R", range = 700, width = 0, speed = 2000, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false},
  ['LeblancSlideM'] = {charName = "Leblanc", spellSlot = "R", range = 600, width = 220, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['leblancslidereturnm'] = {charName = "Leblanc", spellSlot = "R", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['LeblancSoulShackleM'] = {charName = "Leblanc", spellSlot = "R", range = 925, width = 70, speed = 1600, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  -- LeeSin
  ['BlindMonkQOne'] = {charName = "LeeSin", spellSlot = "Q", range = 1000, width = 60, speed = 1800, delay = .5, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  ['BlindMonkWOne'] = {charName = "LeeSin", spellSlot = "W", range = 700, width = 0, speed = 1500, delay = 0, SpellType = "allyCast", riskLevel = "noDmg", cc = false, hitLineCheck = false, shieldSlot = _W},
  ['BlindMonkEOne'] = {charName = "LeeSin", spellSlot = "E", range = 425, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['BlindMonkRKick'] = {charName = "LeeSin", spellSlot = "R", range = 375, width = 0, speed = 1500, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['blindmonkqtwo'] = {charName = "LeeSin", spellSlot = "Q", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = true},
  ['blindmonkwtwo'] = {charName = "LeeSin", spellSlot = "W", range = 700, width = 0, speed = math.huge, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['blindmonketwo'] = {charName = "LeeSin", spellSlot = "E", range = 425, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "dangerous", cc = true, hitLineCheck = false},
  -- Leona
  ['LeonaShieldOfDaybreak'] = {charName = "Leona", spellSlot = "Q", range = 215, width = 0, speed = 0, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = true, hitLineCheck = false},
  ['LeonaSolarBarrier'] = {charName = "Leona", spellSlot = "W", range = 500, width = 0, speed = 0, delay = 3, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = true, hitLineCheck = false},
  ['LeonaZenithBlade'] = {charName = "Leona", spellSlot = "E", range = 900, width = 85, speed = 2000, delay = 0, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme" , cc = true, hitLineCheck = true},
  ['LeonaZenithBladeMissle'] = {charName = "Leona", spellSlot = "E", range = 900, width = 85, speed = 2000, delay = 0, SpellType = "skillshot",collision = true, Blockable = false ,  riskLevel = "extreme" , cc = true, hitLineCheck = true},
  ['LeonaSolarFlare'] = {charName = "Leona", spellSlot = "R", range = 1200, width = 315, speed = math.huge, delay = 0.7, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  --Lissandra
  ['LissandraQ'] = {charName = "Lissandra", spellSlot = "Q", range = 725, width = 75, speed = 1200, delay = .5, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = truew},
  ['LissandraW'] = {charName = "Lissandra", spellSlot = "W", range = 450, width = 80, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['LissandraE'] = {charName = "Lissandra", spellSlot = "E", range = 1050, width = 110, speed = 850, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  ['LissandraR'] = {charName = "Lissandra", spellSlot = "R", range = 550, width = 0, speed = math.huge, delay = 0, SpellType = "selfEnemyCast", riskLevel = "extreme", cc = true, hitLineCheck = true, timer = 0, zhonyaSlot = _R},
  --Lucian
  ['LucianQ']= {charName = "Lucian", spellSlot = "Q", range = 550, width = 65, speed = 500, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false},
  ['LucianW']= {charName = "Lucian", spellSlot = "W", range = 1000, width = 80, speed = 500, delay = .5, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  ['LucianE'] = {charName = "Lucian", spellSlot = "E", range = 650, width = 50, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['LucianR'] = {charName = "Lucian", spellSlot = "R", range = 1400, width = 60, speed = math.huge, delay = .5, SpellType = "allyCast", riskLevel = "kill", cc = false, hitLineCheck = true},
  -- Lulu
  ['LuluQ'] = {charName = "Lulu", spellSlot = "Q", range = 925, width = 80, speed = 1400, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['LuluW'] = {charName = "Lulu", spellSlot = "W", range = 650, width = 0, speed = 2000, delay = .64, SpellType = "enemyCast", Blockable = false, riskLevel = "dangerous", cc = true, hitLineCheck = false},
  ['LuluE'] = {charName = "Lulu", spellSlot = "E", range = 650, width = 0, speed = math.huge, delay = .64, SpellType = "everyCast", riskLevel = "kill", cc = false, hitLineCheck = false, shieldSlot = _E},
  ['LuluR'] = {charName = "Lulu", spellSlot = "R", range = 900, width = 0, speed = math.huge, delay = .5, SpellType = "allyCast", riskLevel = "dangerous", cc = true, hitLineCheck = false, ultSlot = _R},
  -- Lux
  ['LuxLightBinding'] = {charName = "Lux", spellSlot = "Q", range = 1300, width = 80, speed = 1200, delay = .5, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['LuxPrismaticWave'] = {charName = "Lux", spellSlot = "W", range = 1075, width = 150, speed = 1200, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false, shieldSlot = _E},
  ['LuxLightStrikeKugel'] = {charName = "Lux", spellSlot = "E", range = 1100, width = 275, speed = 1300, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "dangerous", cc = true, hitLineCheck = false},
  ['luxlightstriketoggle'] = {charName = "Lux", spellSlot = "E", range = 1100, width = 275, speed = 1300, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['LuxMaliceCannon'] = {charName = "Lux", spellSlot = "R", range = 3340, width = 190, speed = 3000, delay = 1.75, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  -- Malphite
  ['SeismicShard'] = {charName = "Malphite", spellSlot = "Q", range = 625, width = 0, speed = 1200, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['Obduracy'] = {charName = "Malphite", spellSlot = "W", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['Landslide'] = {charName = "Malphite", spellSlot = "E", range = 400, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['UFSlash'] = {charName = "Malphite", spellSlot = "R", range = 1000, width = 270, speed = 700, delay = 0, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  -- Malzahar
    --special spell (wall)
  ['AlZaharCalloftheVoid'] = {charName = "Malzahar", spellSlot = "Q", range = 900, width = 110, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['AlZaharNullZone'] = {charName = "Malzahar", spellSlot = "W", range = 800, width = 250, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['AlZaharMaleficVisions'] = {charName = "Malzahar", spellSlot = "E", range = 650, width = 0, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['AlZaharNetherGrasp'] = {charName = "Malzahar", spellSlot = "R", range = 700, width = 0, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "extreme", cc = true, hitLineCheck = false},
  -- Maokai
  ['MaokaiTrunkLine'] = {charName = "Maokai", spellSlot = "Q", range = 600, width = 110, speed = 1200, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['MaokaiUnstableGrowth'] = {charName = "Maokai", spellSlot = "W", range = 650, width = 0, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['MaokaiSapling2'] = {charName = "Maokai", spellSlot = "E", range = 1100, width = 250, speed = 1750, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['MaokaiDrain3'] = {charName = "Maokai", spellSlot = "R", range = 625, width = 575, speed = math.huge, delay = .5, SpellType = "skillShoot", riskLevel = "kill", cc = false, hitLineCheck = false},
  --Master Yi
  ['AlphaStrike'] = {charName = "MasterYi", spellSlot = "Q", range = 600, width = 0, speed = 4000, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['Meditate'] = {charName = "MasterYi", spellSlot = "W", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['WujuStyle'] = {charName = "MasterYi", spellSlot = "E", range = 0, width = 0, speed = math.huge, delay = .23, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['Highlander'] = {charName = "MasterYi", spellSlot = "R", range = 0, width = 0, speed = math.huge, delay = .37, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false, slowSlot = _R},
  -- MissFortune
  ['MissFortuneRicochetShot'] = {charName = "MissFortune", spellSlot = "Q", range = 650, width = 0, speed = 1400, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false},
  ['MissFortuneViciousStrikes'] = {charName = "MissFortune", spellSlot = "W", range = 0, width = 0, speed = math.huge, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['MissFortuneScattershot'] = {charName = "MissFortune", spellSlot = "E", range = 1000, width = 400, speed = 500, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['MissFortuneBulletTime'] = {charName = "MissFortune", spellSlot = "R", range = 1400, width = 100, speed = 775, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "extreme", cc = false, hitLineCheck = true},
  --Mordekaiser
  ['MordekaiserMaceOfSpades'] = {charName = "Mordekaiser", spellSlot = "Q", range = 600, width = 0, speed = 1500, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['MordekaiserCreepinDeathCast'] = {charName = "Mordekaiser", spellSlot = "W", range = 750, width = 0, speed = math.huge, delay = .5, SpellType = "allyCast", riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['MordekaiserSyphoneOfDestruction'] = {charName = "Mordekaiser", spellSlot = "E", range = 700, width = 0, speed = 1500, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['MordekaiserChildrenOfTheGrave'] = {charName = "Mordekaiser", spellSlot = "R", range = 850, width = 0, speed = 1500, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  -- Morgana
  ['DarkBindingMissile'] = {charName = "Morgana", spellSlot = "Q", range = 1175, width = 70, speed = 1200, delay = .5, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['TormentedSoil'] = {charName = "Morgana", spellSlot = "W", range = 1075, width = 350, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['BlackShield'] = {charName = "Morgana", spellSlot = "E", range = 750, width = 0, speed = math.huge, delay = .5, SpellType = "allyCast", riskLevel = "noDmg", cc = false, hitLineCheck = false, shieldSlot = _E},
  ['SoulShackles'] = {charName = "Morgana", spellSlot = "R", range = 1, width = 1000, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = true, timer = 2800},
  --Nami
  ['NamiQ'] = {charName = "Nami", spellSlot = "Q", range = 875, width = 200, speed = 1750, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['NamiW'] = {charName = "Nami", spellSlot = "W", range = 725, width = 0, speed = 1100, delay = .5, SpellType = "everyCast", riskLevel = "kill", cc = false, hitLineCheck = false, healSlot = _W},
  ['NamiE'] = {charName = "Nami", spellSlot = "E", range = 800, width = 0, speed = math.huge, delay = .5, SpellType = "allyCast", riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['NamiR'] = {charName = "Nami", spellSlot = "R", range = 2550, width = 600, speed = 1200, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  --Nasus
  ['NasusQ'] = {charName = "Nasus", spellSlot = "Q", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['NasusW'] = {charName = "Nasus", spellSlot = "W", range = 600, width = 0, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "noDmg", cc = true, hitLineCheck = false},
  ['NasusE'] = {charName = "Nasus", spellSlot = "E", range = 850, width = 400, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['NasusR'] = {charName = "Nasus", spellSlot = "R", range = 1, width = 350, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  -- Nautilus
  ['NautilusAnchorDrag'] = {charName = "Nautilus", spellSlot = "Q", range = 950, width = 80, speed = 1200, delay = .5, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = truew},
  ['NautilusPiercingGaze'] = {charName = "Nautilus", spellSlot = "W", range = 0, width = 0, speed = 0, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false, shieldSlot = _W},
  ['NautilusSplashZone'] = {charName = "Nautilus", spellSlot = "E", range = 600, width = 60, speed = 1300, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['NautilusGandLine'] = {charName = "Nautilus", spellSlot = "R", range = 1500, width = 60, speed = 1400, delay = .5, SpellType = "enemyCast", Blockable = false , riskLevel = "extreme", cc = true, hitLineCheck = false, timer = 450 - GetLatency()},
  -- Nidalee
    ---Nidalee HUMAN
  ['JavelinToss'] = {charName = "Nidalee", spellSlot = "Q", range = 1500, width = 60, speed = 1300, delay = .5, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['Bushwhack'] = {charName = "Nidalee", spellSlot = "W", range = 900, width = 125, speed = 1450, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['PrimalSurge'] = {charName = "Nidalee", spellSlot = "E", range = 600, width = 0, speed = math.huge, delay = 0, SpellType = "allyCast", riskLevel = "noDmg", cc = false, hitLineCheck = false, healSlot = _E},
  ['AspectOfTheCougar'] = {charName = "Nidalee", spellSlot = "R", range = 0, width = 0, speed = math.huge, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
    ---Nidalee COUGAR
  ['Takedown'] = {charName = "Nidalee", spellSlot = "Q", range = 50, width = 0, speed = 500, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['Pounce'] = {charName = "Nidalee", spellSlot = "W", range = 375, width = 150, speed = 1500, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['Swipe'] = {charName = "Nidalee", spellSlot = "E", range = 300, width = 300, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  -- Nocturne
  ['NocturneDuskbringer'] = {charName = "Nocturne", spellSlot = "Q", range = 1125, width = 60, speed = 1600, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  ['NocturneShroudofDarkness'] = {charName = "Nocturne", spellSlot = "W", range = 0, width = 0, speed = 500, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false, shieldSlot = _E},
  ['NocturneUnspeakableHorror'] = {charName = "Nocturne", spellSlot = "E", range = 500, width = 0, speed = 0, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "noDmg", cc = true, hitLineCheck = false},
    --special spell 2000/2750/3500
  ['NocturneParanoia'] = {charName = "Nocturne", spellSlot = "R", range = 2000, width = 0, speed = 500, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  --Nunu
  ['Consume'] = {charName = "Nunu", spellSlot = "Q", range = 125, width = 60, speed = 1400, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "extreme", cc = false, hitLineCheck = false},
  ['BloodBoil'] = {charName = "Nunu", spellSlot = "W", range = 700, width = 0, speed = math.huge, delay = .5, SpellType = "allyCast", riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['IceBlast'] = {charName = "Nunu", spellSlot = "E", range = 550, width = 0, speed = 1000, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['AbsoluteZero'] = {charName = "Nunu", spellSlot = "R", range = 1, width = 650, speed = math.huge, delay = .5, SpellType = "selfcast", Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  -- Olaf
  ['OlafAxeThrowCast'] = {charName = "Olaf", spellSlot = "Q", range = 1000, width = 90, speed = 1600, delay = .5, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['OlafFrenziedStrikes'] = {charName = "Olaf", spellSlot = "W", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['OlafRecklessStrike'] = {charName = "Olaf", spellSlot = "E", range = 325, width = 0, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['OlafRagnarok'] = {charName = "Olaf", spellSlot = "R", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false, qssSlot = _R},
  -- Orianna
  ['OrianaIzunaCommand'] = {charName = "Orianna", spellSlot = "Q", range = 825, width = 145, speed = 1200, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['OrianaDissonanceCommand'] = {charName = "Orianna", spellSlot = "W", range = 0, width = 260, speed = 1200, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['OrianaRedactCommand'] = {charName = "Orianna", spellSlot = "E", range = 1095, width = 145, speed = 1200, delay = .5, SpellType = "allyCast", riskLevel = "kill", cc = false, hitLineCheck = false, shieldSlot = _E},
  ['OrianaDetonateCommand'] = {charName = "Orianna", spellSlot = "R", range = 0, width = 425, speed = 1200, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  --Pantehon
  ['Pantheon_Throw'] = {charName = "Pantheon", spellSlot = "Q", range = 600, width = 0, speed = 1500, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false},
  ['Pantheon_LeapBash'] = {charName = "Pantheon", spellSlot = "W", range = 600, width = 0, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['Pantheon_Heartseeker'] = {charName = "Pantheon", spellSlot = "E", range = 600, width = 100, speed = 775, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['Pantheon_GrandSkyfall_Jump'] = {charName = "Pantheon", spellSlot = "R", range = 5500, width = 1000, speed = 3000, delay = 1.0, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  --Poppy
  ['PoppyDevastatingBlow'] = {charName = "Poppy", spellSlot = "Q", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['PoppyParagonOfDemacia'] = {charName = "Poppy", spellSlot = "W", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['PoppyHeroicCharge'] = {charName = "Poppy", spellSlot = "E", range = 525, width = 0, speed = 1450, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['PoppyDiplomaticImmunity'] = {charName = "Poppy", spellSlot = "R", range = 900, width = 0, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "noDmg", cc = false, hitLineCheck = false},
  --Quinn
  ['QuinnQ'] = {charName = "Quinn", spellSlot = "Q", range = 1025, width = 80, speed = 1200, delay = .5, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['QuinnW'] = {charName = "Quinn", spellSlot = "W", range = 2100, width = 0, speed = 0, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = falsee},
  ['QuinnE'] = {charName = "Quinn", spellSlot = "E", range = 700, width = 0, speed = 775, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['QuinnR'] = {charName = "Quinn", spellSlot = "R", range = 0, width = 0, speed = 0, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  --Rammus
  ['PowerBall'] = {charName = "Rammus", spellSlot = "Q", range = 1, width = 200, speed = 775, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['DefensiveBallCurl'] = {charName = "Rammus", spellSlot = "W", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['PuncturingTaunt'] = {charName = "Rammus", spellSlot = "E", range = 325, width = 0, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['Tremors2'] = {charName = "Rammus", spellSlot = "R", range = 1, width = 300, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  -- Renekton
  ['RenektonCleave'] = {charName = "Renekton", spellSlot = "Q", range = 1, width = 450, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['RenektonPreExecute'] = {charName = "Renekton", spellSlot = "W", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['RenektonSliceAndDice'] = {charName = "Renekton", spellSlot = "E", range = 450, width = 50, speed = 1400, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['RenektonReignOfTheTyrant'] = {charName = "Renekton", spellSlot = "R", range = 1, width = 530, speed = 775, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  --Rengar
  ['RengarQ'] = {charName = "Rengar", spellSlot = "Q", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['RengarW'] = {charName = "Rengar", spellSlot = "W", range = 1, width = 500, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['RengarE'] = {charName = "Rengar", spellSlot = "E", range = 575, width = 0, speed = 1800, delay = .5, SpellType = "skillshot", collision = true , Blockable = true , riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['RengarR'] = {charName = "Rengar", spellSlot = "R", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  --Riven
  ['RivenTriCleav'] = {charName = "Riven", spellSlot = "Q", range = 250, width = 0, speed = 0,  delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['RivenTriCleave_03'] = {charName = "Riven", spellSlot = "Q", range = 250, width = 0, speed = 0,  delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['RivenMartyr'] = {charName = "Riven", spellSlot = "W", range = 260, width = 0, speed = 1500,  delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['RivenFeint'] = {charName = "Riven", spellSlot = "E", range = 325, width = 0, speed = 1450, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false, shieldSlot = _E},
  ['RivenFengShuiEngine'] = {charName = "Riven", spellSlot = "R", range = 0, width = 0, speed = 1200, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['rivenizunablade'] = {charName = "Riven", spellSlot = "R", range = 900, width = 200, speed = 1450, delay = .3, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  -- Rumble
  ['RumbleFlameThrower'] = {charName = "Rumble", spellSlot = "Q", range = 600, width = 10, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  ['RumbleShield'] = {charName = "Rumble", spellSlot = "W", range = 0, width = 0, speed = 0, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false, shieldSlot = _W},
  ['RumbeGrenade'] = {charName = "Rumble", spellSlot = "E", range = 850, width = 90, speed = 1200, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
    --special spell
  ['RumbleCarpetBomb'] = {charName = "Rumble", spellSlot = "R", range = 625, width = 0, speed = 1400, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  --Ryze used Qrange+stun(from w) for Rvalues because of the "worst case"
  ['Overload'] = {charName = "Ryze", spellSlot = "Q", range = 625, width = 0, speed = 1400, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false},
  ['RunePrison'] = {charName = "Ryze", spellSlot = "W", range = 600, width = 0, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['SpellFlux'] = {charName = "Ryze", spellSlot = "E", range = 600, width = 0, speed = 1000, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false},
  ['DesperatePower'] = {charName = "Ryze", spellSlot = "R", range = 625, width = 0, speed = 1400, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "extreme", cc = true, hitLineCheck = false},
  -- Sejuani
  ['SejuaniArcticAssault'] = {charName = "Sejuani", spellSlot = "Q", range = 650, width = 75, speed = 1450, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['SejuaniNorthernWinds'] = {charName = "Sejuani", spellSlot = "W", range = 1, width = 350, speed = 1500, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['SejuaniWintersClaw'] = {charName = "Sejuani", spellSlot = "E", range = 1, width = 1000, speed = 1450, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['SejuaniGlacialPrisonStart'] = {charName = "Sejuani", spellSlot = "R", range = 1175, width = 110, speed = 1400, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  -- Shaco
  ['Deceive'] = {charName = "Shaco", spellSlot = "Q", range = 400, width = 0, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['JackInTheBox'] = {charName = "Shaco", spellSlot = "W", range = 425, width = 60, speed = 1450, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['TwoShivPoisen'] = {charName = "Shaco", spellSlot = "E", range = 625, width = 0, speed = 1500, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['HallucinateFull'] = {charName = "Shaco", spellSlot = "R", range = 1125, width = 250, speed = 395, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  -- Shen
  ['ShenVorpalStar'] = {charName = "Shen", spellSlot = "Q", range = 475, width = 0, speed = 1500, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false},
  ['ShenFeint'] = {charName = "Shen", spellSlot = "W", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false, shieldSlot = _W},
  ['ShenShadowDash'] = {charName = "Shen", spellSlot = "E", range = 600, width = 50, speed = 1000, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['ShenStandUnited'] = {charName = "Shen", spellSlot = "R", range = 75000, width = 0, speed = math.huge, delay = .5, SpellType = "allyCast", riskLevel = "noDmg", cc = false, hitLineCheck = false, ultSlot = _R},
  -- Shyvana
  ['ShyvanaDoubleAttack'] = {charName = "Shyvana", spellSlot = "Q", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['ShyvanaImmolationAura'] = {charName = "Shyvana", spellSlot = "W", range = 1, width = 325, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['ShyvanaFireball'] = {charName = "Shyvana", spellSlot = "E", range = 925, width = 60, speed = 1200, delay = .5, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "dangerous", cc = true, hitLineCheck = true},
  ['ShyvanaTransformCast'] = {charName = "Shyvana", spellSlot = "R", range = 1000, width = 160, speed = 700, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "dangerous", cc = true, hitLineCheck = true},
  -- Singed
  ['PoisenTrail'] = {charName = "Singed", spellSlot = "Q", range = 0, width = 400, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['MegaAdhesive'] = {charName = "Singed", spellSlot = "W", range = 1175, width = 350, speed = 700, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "dangerous", cc = true, hitLineCheck = false},
  ['Fling'] = {charName = "Singed", spellSlot = "E", range = 125, width = 0, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['InsanityPotion'] = {charName = "Singed", spellSlot = "R", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  --Sion
  ['CrypticGaze'] = {charName = "Sion", spellSlot = "Q", range = 550, width = 0, speed = 1600, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['DeathsCaressFull'] = {charName = "Sion", spellSlot = "W", range = 550, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false, shieldSlot = _W},
  ['Enrage'] = {charName = "Sion", spellSlot = "E", range = 1, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['Cannibalism'] = {charName = "Sion", spellSlot = "R", range = 1, width = 0, speed = 500, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  -- Sivir
  ['SivirQ'] = {charName = "Sivir", spellSlot = "Q", range = 1075, width = 90, speed = 1350, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['SivirW'] = {charName = "Sivir", spellSlot = "W", range = 500, width = 0, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['SivirE'] = {charName = "Sivir", spellSlot = "E", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false, shieldSlot = _E},
  ['SivirR'] = {charName = "Sivir", spellSlot = "R", range = 0, width = 1000, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  -- Skarner
  ['SkarnerVirulentSlash'] = {charName = "Skarner", spellSlot = "Q", range = 350, width = 0, speed = math.huge, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['SkarnerExoskeleton'] = {charName = "Skarner", spellSlot = "W", range = 0, width = 0, speed = math.huge, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false, shieldSlot = _W },
  ['SkarnerFracture'] = {charName = "Skarner", spellSlot = "E", range = 1000, width = 60, speed = 1200, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['SkarnerImpale'] = {charName = "Skarner", spellSlot = "R", range = 350, width = 0, speed = math.huge, delay = 0, SpellType = "enemyCast", Blockable = false, riskLevel = "extreme", cc = true, hitLineCheck = false},
  -- Sona
  ['SonaHymnofValor'] = {charName = "Sona", spellSlot = "Q", range = 700, width = 0, speed = 1500, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false},
  ['SonaAriaofPerseverance'] = {charName = "Sona", spellSlot = "W", range = 1000, width = 0, speed = 1500, delay = .5, SpellType = "allyCast", riskLevel = "noDmg", cc = false, hitLineCheck = false, healSlot = _W},
  ['SonaSongofDiscord'] = {charName = "Sona", spellSlot = "E", range = 1000, width = 0, speed = 1500, delay = .5, SpellType = "allyCast", riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['SonaCrescendo'] = {charName = "Sona", spellSlot = "R", range = 900, width = 600, speed = 2400, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = false, timer = 0},
  --Soraka
  ['Starcall'] = {charName = "Soraka", spellSlot = "Q", range = 675, width = 0, speed = math.huge, delay = .5, SpellType = "selfcast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['AstralBlessing'] = {charName = "Soraka", spellSlot = "W", range = 750, width = 0, speed = math.huge, delay = .5, SpellType = "allyCast", riskLevel = "noDmg", cc = false, hitLineCheck = false, healSlot = _W},
  ['InfuseWrapper'] = {charName = "Soraka", spellSlot = "E", range = 725, width = 0, speed = math.huge, delay = .5, SpellType = "everyCast", riskLevel = "dangerous", cc = false, hitLineCheck = false},
  ['Wish'] = {charName = "Soraka", spellSlot = "R", range = 75000, width = 0, speed = math.huge, delay = .5, SpellType = "allyCast", riskLevel = "noDmg", cc = false, hitLineCheck = false, ultSlot = _R},
  -- Swain
  ['SwainDecrepify'] = {charName = "Swain", spellSlot = "Q", range = 625, width = 0, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false , riskLevel = "extreme", cc = frue, hitLineCheck = false},
  ['SwainShadowGrasp'] = {charName = "Swain", spellSlot = "W", range = 1040, width = 275, speed = 1250, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = frue, hitLineCheck = false},
  ['SwainTorment'] = {charName = "Swain", spellSlot = "E", range = 625, width = 0, speed = 1400, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false},
  ['SwainMetamorphism'] = {charName = "Swain", spellSlot = "R", range = 0, width = 700, speed = 950, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  --Syndra
  ['SyndraQ']= {charName = "Syndra", spellSlot = "Q", range = 800, width = 180, speed = 1750, delay = .25, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
    --special spell
  ['SyndraW ']= {charName = "Syndra", spellSlot = "W", range = 600, width = 0, speed = 1450, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
    --special spell
  ['SyndraE'] = {charName = "Syndra", spellSlot = "E", range = 100, width = 0, speed = 902, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['SyndraR'] = {charName = "Syndra", spellSlot = "R", range = 1010, width = 0, speed = 1100, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false},
  --Talon
  ['TalonNoxianDiplomacy'] = {charName = "Talon", spellSlot = "Q", range = 0, width = 0, speed = 0, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['TalonRake'] = {charName = "Talon", spellSlot = "W", range = 750, width = 0, speed = 1200, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['TalonCutthroat'] = {charName = "Talon", spellSlot = "E", range = 750, width = 0, speed = 1200, delay = 0, SpellType = "enemyCast", Blockable = false, riskLevel = "dangerous", cc = true, hitLineCheck = false},
  ['TalonShadowAssault'] = {charName = "Talon", spellSlot = "R", range = 750, width = 0, speed = 0, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  --Taric
  ['Imbue'] = {charName = "Taric", spellSlot = "Q", range = 750, width = 0, speed = 1200, delay = .5, SpellType = "allyCast", riskLevel = "noDmg", cc = false, hitLineCheck = false, healSlot = _Q},
  ['Shatter'] = {charName = "Taric", spellSlot = "W", range = 400, width = 0, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['Dazzle'] = {charName = "Taric", spellSlot = "E", range = 625, width = 0, speed = 1400, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['TaricHammerSmash'] = {charName = "Taric", spellSlot = "R", range = 400, width = 0, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  --Teemo
  ['BlindingDart'] = {charName = "Teemo", spellSlot = "Q", range = 580, width = 0, speed = 1500, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['MoveQuick'] = {charName = "Teemo", spellSlot = "W", range = 0, width = 0, speed = 943, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['ToxicShot'] = {charName = "Teemo", spellSlot = "E", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['BantamTrap'] = {charName = "Teemo", spellSlot = "R", range = 230, width = 0, speed = 1500, delay = 0, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = true, hitLineCheck = false},
  --Thresh
  ['ThreshQ'] = {charName = "Thresh", spellSlot = "Q", range = 1075, width = 60, speed = 1200, delay = 0.5, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['ThreshW'] = {charName = "Thresh", spellSlot = "W", range = 950, width = 315, speed = math.huge, delay = 0.5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false, shieldSlot = _W},
    --special spell
  ['ThreshE'] = {charName = "Thresh", spellSlot = "E", range = 515, width = 160, speed = math.huge, delay = 0.3, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['ThreshRPenta'] = {charName = "Thresh", spellSlot = "R", range = 420, width = 420, speed = math.huge, delay = 0.3, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  -- Tristana
  ['RapidFire'] = {charName = "Tristana", spellSlot = "Q", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['RocketJump'] = {charName = "Tristana", spellSlot = "W", range = 900, width = 270, speed = 1150, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['DetonatingShot'] = {charName = "Tristana", spellSlot = "E", range = 625, width = 0, speed = 1400, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false},
  ['BusterShot'] = {charName = "Tristana", spellSlot = "R", range = 700, width = 0, speed = 1600, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "extreme", cc = true, hitLineCheck = false},
  --Trundle
  ['TrundleTrollSmash'] = {charName = "Trundle", spellSlot = "Q", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false , riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['trundledesecrate'] = {charName = "Trundle", spellSlot = "W", range = 0, width = 900, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "noDmg", cc = true, hitLineCheck = false},
  ['TrundleCircle'] = {charName = "Trundle", spellSlot = "E", range = 1100, width = 188, speed = 1600, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "dangerous", cc = true, hitLineCheck = false},
  ['TrundlePain'] = {charName = "Trundle", spellSlot = "R", range = 700, width = 0, speed = 1400, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  -- Tryndamere
  ['Bloodlust'] = {charName = "Tryndamere", spellSlot = "Q", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['MockingShout'] = {charName = "Tryndamere", spellSlot = "W", range = 400, width = 400, speed = 500, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "dangerous", cc = true, hitLineCheck = false},
  ['slashCast'] = {charName = "Tryndamere", spellSlot = "E", range = 660, width = 225, speed = 700, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['UndyingRage'] = {charName = "Tryndamere", spellSlot = "R", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false, ultSlot = _R},
  -- TwistedFate
  ['WildCards'] = {charName = "TwistedFate", spellSlot = "Q", range = 1450, width = 80, speed = 1450, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['PickACard'] = {charName = "TwistedFate", spellSlot = "W", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "dangerous", cc = true, hitLineCheck = false},
  ['CardmasterStack'] = {charName = "TwistedFate", spellSlot = "E", range = 525, width = 0, speed = 1200, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['Destiny'] = {charName = "TwistedFate", spellSlot = "R", range = 5500, width = 0, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  --Twitch
  ['HideInShadows'] = {charName = "Twitch", spellSlot = "Q", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['TwitchVenomCask'] = {charName = "Twitch", spellSlot = "W", range = 800, width = 275, speed = 1750, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['TwitchVenomCaskMissle'] = {charName = "Twitch", spellSlot = "W", range = 800, width = 275, speed = 1750, delay = .5, SpellType = "skillshot",collision = false, Blockable = false,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['Expunge'] = {charName = "Twitch", spellSlot = "E", range = 1200, width = 0, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['FullAutomatic'] = {charName = "Twitch", spellSlot = "R", range = 850, width = 0, speed = 500, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  --Udyr
  ['UdyrTigerStance'] = {charName = "Udyr", spellSlot = "Q", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['UdyrTurtleStance'] = {charName = "Udyr", spellSlot = "W", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false, shieldSlot = _W},
  ['UdyrBearStance'] = {charName = "Udyr", spellSlot = "E", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = true, hitLineCheck = false},
  ['UdyrPhoenixStance'] = {charName = "Udyr", spellSlot = "R", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  -- Urgot
  ['UrgotHeatseekingMissile'] = {charName = "Urgot", spellSlot = "Q", range = 1000, width = 80, speed = 1600, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['UrgotTerrorCapacitorActive2'] = {charName = "Urgot", spellSlot = "W", range = 0, width = 300, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "dangerous", cc = true, hitLineCheck = false, shieldSlot = _W},
  ['UrgotPlasmaGrenade'] = {charName = "Urgot", spellSlot = "E", range = 950, width = 0, speed = 1750, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['UrgotSwap2'] = {charName = "Urgot", spellSlot = "R", range = 850, width = 0, speed = 1800, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "dangerous", cc = true, hitLineCheck = false},
  -- Varus
    --special spell (charge)
  ['VarusQ'] = {charName = "Varus", spellSlot = "Q", range = 1500, width = 100, speed = 1500, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  ['VarusW'] = {charName = "Varus", spellSlot = "W", range = 0, width = 0, speed = 0, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['VarusE'] = {charName = "Varus", spellSlot = "E", range = 800, width = 55, speed = 1500, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['VarusR'] = {charName = "Varus", spellSlot = "R", range = 800, width = 100, speed = 1500, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  -- Vayne
  ['VayneTumble'] = {charName = "Vayne", spellSlot = "Q", range = 250, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['VayneSilverBolts'] = {charName = "Vayne", spellSlot = "W", range = 0, width = 0, speed = math.huge, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['VayneCondemm'] = {charName = "Vayne", spellSlot = "E", range = 450, width = 0, speed = 1200, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "dangerous", cc = true, hitLineCheck = false},
  ['vayneinquisition'] = {charName = "Vayne", spellSlot = "R", range = 0, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  -- Veigar|same as vik inc. E(cage) range to teh maximum of range+(cage/2)
  ['VeigarBalefulStrike'] = {charName = "Veigar", spellSlot = "Q", range = 650, width = 0, speed = 1500, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false},
  ['VeigarDarkMatter'] = {charName = "Veigar", spellSlot = "W", range = 900, width = 225, speed = 1500, delay = 1.2, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['VeigarEventHorizon'] = {charName = "Veigar", spellSlot = "E", range = 813, width = 425, speed = 1500, delay = math.huge, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "dangerous", cc = true, hitLineCheck = false},
  ['VeigarPrimordialBurst'] = {charName = "Veigar", spellSlot = "R", range = 650, width = 0, speed = 1400, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false, timer = 230 - GetLatency()},
  --Vel'Koz
  ['VelkozQ'] = {charName = "Velkoz", spellSlot = "Q", range = 1050, width = 60, speed = 1200, delay = 0.3, SpellType = "enemyCast", Blockable = true , riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['VelkozQMissle'] = {charName = "Velkoz", spellSlot = "Q", range = 1050, width = 60, speed = 1200, delay = 0, SpellType = "enemyCast", Blockable = true , riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['velkozqplitactive'] = {charName = "Velkoz", spellSlot = "Q", range = 1050, width = 60, speed = 1200, delay = 0.8, SpellType = "enemyCast", Blockable = true , riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['VelkozW'] = {charName = "Velkoz", spellSlot = "W", range = 1050, width = 90, speed = 1200, delay = 0, SpellType = "enemyCast", Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false},
  ['VelkozE'] = {charName = "Velkoz", spellSlot = "E", range = 850, width = 0, speed = 500, delay = 0, SpellType = "enemyCast", Blockable = true , riskLevel = "extreme", cc = true, hitLineCheck = false},
    --special spell
  ['VelkozR'] = {charName = "Velkoz", spellSlot = "R", range = 1575, width = 0, speed = 1500, SpellType = "enemyCast", Blockable = true , riskLevel = "extreme", cc = true, hitLineCheck = true},
  --Vi
  ['ViQ'] = {charName = "Vi", spellSlot = "Q", range = 600, width = 55, speed = 1500, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['ViW'] = {charName = "Vi", spellSlot = "W", range = 600, width = 0, speed = 0, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = true, hitLineCheck = false},
  ['ViE'] = {charName = "Vi", spellSlot = "E", range = 600, width = 0, speed = 0, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = true, hitLineCheck = false},
  ['ViR'] = {charName = "Vi", spellSlot = "R", range = 600, width = 0, speed = 0, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "extreme", cc = true, hitLineCheck = false, timer = 230 - GetLatency()},
  -- Viktor
  ['ViktorPowerTransfer'] = {charName = "Viktor", spellSlot = "Q", range = 600, width = 0, speed = 1400, delay = .5, SpellType = "enemyCast", Blockable = true , riskLevel = "kill", cc = false, hitLineCheck = false},
  ['ViktorGravitonField'] = {charName = "Viktor", spellSlot = "W", range = 815, width = 300, speed = 1750, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "dangerous", cc = true, hitLineCheck = false},
  ['ViktorDeathRa'] = {charName = "Viktor", spellSlot = "E", range = 700, width = 90, speed = 1210, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['ViktorChaosStorm'] = {charName = "Viktor", spellSlot = "R", range = 700, width = 250, speed = 1210, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  --Vladimir|notice:Rrange is defined as 875, because the true range to the center of the aoe is 700, and the aoe range is 350. 175+700=875, if this is not correct use 700(standart range)-Bilbao
  ['VladimirTransfusion'] = {charName = "Vladimir", spellSlot = "Q", range = 600, width = 0, speed = 1400, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['VladimirSanguinePool'] = {charName = "Vladimir", spellSlot = "W", range = 300, width = 0, speed = 1600, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['VladimirTidesofBlood'] = {charName = "Vladimir", spellSlot = "E", range = 620, width = 0, speed = 1100, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = true, hitLineCheck = false},
  ['VladimirHemoplague'] = {charName = "Vladimir", spellSlot = "R", range = 875, width = 350, speed = 1200, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  --Volibear
  ['VolibearQ'] = {charName = "Volibear", spellSlot = "Q", range = 300, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = true, hitLineCheck = false},
  ['VolibearW'] = {charName = "Volibear", spellSlot = "W", range = 400, width = 0, speed = 1450, delay = .5, SpellType = "enemyCast", Blockable = false , riskLevel = "kill", cc = false, hitLineCheck = false},
  ['VolibearE'] = {charName = "Volibear", spellSlot = "E", range = 425, width = 425, speed = 825, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = true, hitLineCheck = false},
  ['VolibearR'] = {charName = "Volibear", spellSlot = "R", range = 425, width = 425, speed = 825, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  --Warwick
  ['HungeringStrike'] = {charName = "Warwick", spellSlot = "Q", range = 400, width = 0, speed = math.huge, delay = 0, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['HuntersCall'] = {charName = "Warwick", spellSlot = "W", range = 1000, width = 0, speed = math.huge, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['BlooScent'] = {charName = "Warwick", spellSlot = "E", range = 1500, width = 0, speed = math.huge, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['InfiniteDuress'] = {charName = "Warwick", spellSlot = "R", range = 700, width = 0, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "extreme", cc = true, hitLineCheck = false},
  --Wukong
  ['MonkeyKingDoubleAttack'] = {charName = "MonkeyKing", spellSlot = "Q", range = 300, width = 0, speed = 20, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
    -- special spell
  ['MonkeyKingDecoy'] = {charName = "MonkeyKing", spellSlot = "W", range = 0, width = 0, speed = 0, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['MonkeyKingNimbus'] = {charName = "MonkeyKing", spellSlot = "E", range = 625, width = 0, speed = 2200, delay = 0, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['MonkeyKingSpinToWin'] = {charName = "MonkeyKing", spellSlot = "R", range = 315, width = 0, speed = 700, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['monkeykingspintowinleave'] = {charName = "MonkeyKing", spellSlot = "R", range = 0, width = 0, speed = 700, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  -- Xerath
    --special spell (chargeup)
  ['XerathArcanoPulseChargeUp'] = {charName = "Xerath", spellSlot = "Q", range = 750, width = 100, speed = 500, delay = .75, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  ['XerathArcaneBarrage2'] = {charName = "Xerath", spellSlot = "W", range = 1100, width = 0, speed = 20, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['XerathMageSpear'] = {charName = "Xerath", spellSlot = "E", range = 1050, width = 70, speed = 1600, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
    --special spell range 3200, 4400, 5600
  ['XerathLocusOfPower2'] = {charName = "Xerath", spellSlot = "R", range = 3200, width = 0, speed = 500, delay = .75, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  --Xin Zhao
  ['XenZhaoComboTarget'] = {charName = "Xin Zhao", spellSlot = "Q", range = 200, width = 0, speed = 2000, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "extreme", cc = false, hitLineCheck = false},
  ['XenZhaoBattleCry'] = {charName = "Xin Zhao", spellSlot = "W", range = 20, width = 0, speed = 2000, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['XenZhaoSweep'] = {charName = "Xin Zhao", spellSlot = "E", range = 600, width = 0, speed = 1750, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['XenZhaoParry'] = {charName = "Xin Zhao", spellSlot = "R", range = 375, width = 0, speed = 1750, delay = 0, SpellType = "selfCast", Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  --Yasuo
  ['YasuoQW'] = {charName = "Yasuo", spellSlot = "Q", range = 475, width = 55, speed = 1500, delay = .75, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['yasuoq2w'] = {charName = "Yasuo", spellSlot = "Q", range = 475, width = 55, speed = 1500, delay = .75, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['yasuoq3w'] = {charName = "Yasuo", spellSlot = "Q", range = 1000, width = 90, speed = 1500, delay = .75, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
  ['YasuoWMovingWall'] = {charName = "Yasuo", spellSlot = "W", range = 400, width = 0, speed = 500, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['YasuoDashWrapper'] = {charName = "Yasuo", spellSlot = "E", range = 475, width = 0, speed = 20, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  ['YasuoRKnockUpComboW'] = {charName = "Yasuo", spellSlot = "R", range = 1200, width = 0, speed = 20, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  --Yorick
  ['YorickSpectral'] = {charName = "Yorick", spellSlot = "Q", range = 1, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['YorickDecayed'] = {charName = "Yorick", spellSlot = "W", range = 600, width = 200, speed = math.huge, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['YorickRavenous'] = {charName = "Yorick", spellSlot = "E", range = 550, width = 200, speed = math.huge, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = true, hitLineCheck = false},
  ['YorickReviveAlly'] = {charName = "Yorick", spellSlot = "R", range = 900, width = 0, speed = 1500, delay = .5, SpellType = "allyCast", riskLevel = "noDmg", cc = false, hitLineCheck = false},
  --Zac
  ['ZacQ'] = {charName = "Zac", spellSlot = "Q", range = 550, width = 120, speed = 902, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "dangerous", cc = true, hitLineCheck = true},
  ['ZacW'] = {charName = "Zac", spellSlot = "W", range = 550, width = 40, speed = 1600, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "extreme", cc = false, hitLineCheck = false},
    --special spell
  ['ZacE'] = {charName = "Zac", spellSlot = "E", range = 300, width = 0, speed = 1500, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
    --special spell
  ['ZacR'] = {charName = "Zac", spellSlot = "R", range = 850, width = 0, speed = 1800, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  --Zed
  ['ZedShuriken'] = {charName = "Zed", spellSlot = "Q", range = 900, width = 45, speed = 902, delay = .5, SpellType = "skillshot",collision = false, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  ['ZedShdaowDash'] = {charName = "Zed", spellSlot = "W", range = 550, width = 40, speed = 1600, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['ZedPBAOEDummy'] = {charName = "Zed", spellSlot = "E", range = 300, width = 0, speed = 0, delay = .0, SpellType = "selfCast", Blockable = false ,  riskLevel = "dangerous", cc = true, hitLineCheck = false},
  ['zedult'] = {charName = "Zed", spellSlot = "R", range = 850, width = 0, speed = 0, delay = .5, SpellType = "enemyCast", Blockable = false, riskLevel = "kill", cc = false, hitLineCheck = false},
  -- Ziggs
  ['ZiggsQ'] = {charName = "Ziggs", spellSlot = "Q", range = 850, width = 75, speed = 1750, delay = .5, SpellType = "skillshot",collision = true, Blockable = true ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  ['ZiggsW'] = {charName = "Ziggs", spellSlot = "W", range = 850, width = 0, speed = 1750,  delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false},
  ['ZiggsE'] = {charName = "Ziggs", spellSlot = "E", range = 850, width = 350, speed = 1750, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
  ['ZiggsR'] = {charName = "Ziggs", spellSlot = "R", range = 850, width = 600, speed = 1750, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = false, timer = 950 - GetLatency()},
  --Zilean
  ['TimeBomb'] = {charName = "Zilean", spellSlot = "Q", range = 700, width = 0, speed = 1100, delay = .0, SpellType = "everyCast", riskLevel = "kill", cc = false, hitLineCheck = false, timer = 2100},
  ['Rewind'] = {charName = "Zilean", spellSlot = "W", range = 1, width = 0, speed = math.huge, delay = .5, SpellType = "selfCast", Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['TimeWarp'] = {charName = "Zilean", spellSlot = "E", range = 700, width = 0, speed = 1100, delay = .5, SpellType = "everyCast", riskLevel = "dangerous", cc = true, hitLineCheck = false},
  ['ChronoShift'] = {charName = "Zilean", spellSlot = "R", range = 780, width = 0, speed = math.huge, delay = .5, SpellType = "allyCast", riskLevel = "noDmg", cc = false, hitLineCheck = false, ultSlot = _R},
  -- Zyra
  ['ZyraQFissure'] = {charName = "Zyra", spellSlot = "Q", range = 800, width = 85, speed = 1400, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "kill", cc = false, hitLineCheck = true},
  ['ZyraSeed'] = {charName = "Zyra", spellSlot = "W", range = 800, width = 0, speed = 2200, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "noDmg", cc = false, hitLineCheck = false},
  ['ZyraGraspingRoots'] = {charName = "Zyra", spellSlot = "E", range = 1100, width = 70, speed = 1400, delay = .5, SpellType = "skillshot",collision = true, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = true},
    --special spell
  ['ZyraBrambleZone'] = {charName = "Zyra", spellSlot = "R", range = 1100, width = 70, speed = 20, delay = .5, SpellType = "skillshot",collision = false, Blockable = false ,  riskLevel = "extreme", cc = true, hitLineCheck = false},
}

local VERSION = 0.1
local FullCombo = {_Q,_AA,_Q,_AA,_Q,_R,_IGNITE}
local Q , E , R = _Q , _E , _R 
local Spells = {_Q,_W,_E,_R}
local Spells2 = {"Q","W","E","R"}
--(())--
local Config , Menu = nil , nil 
local VP = VPrediction()
--((spells and shit))--
local SpellQ = {Range = 450 , Delay = 0.36 , Speed = 1200 , Width = 90}
local SpellQEmpowered = {Range = 850 , Delay = 0.36  , Speed = 1200 , Width = 120}
local SpellW = {Range = 100}
local SpellE = {Range = 475}
local SpellR = {Range = 1300}
local AA = {Range= 125}
local RDQ = false
local Ranges = { [_Q] = 450 ,  [_E] = 475 , [_R] = 1300 }
--((Dodgin and Stuff))--
local informationTable = {}
local spellExpired = true
--((Other Options))--
local ShowComboOn , ShowHarassOn , ShowFarmOn , ShowFleeOn
local piece=myHero.name
local  KnockDetected , KnockedByAlly , counter
local nofarm = false
--((Auto Q Stuff))--
local RecallDetection 
local UnderTurretDetection
local isCastingE = false
--((OnLoad))--
function OnLoad()
  Init()
  ScriptSetUp()
  ScriptSetUp1()
  PrintChat("<font color=\"#0DF8FF\">AWA and PYR Yasuo loaded</font> <font color=\"#FF0000\">0.1</font> <font color=\"#0DF8FF\">Successfully</font> ")
  PrintChat("<font color=\"#0DF8FF\">Enjoy your game </font> "..tostring(piece).. "<font color=\"#0DF8FF\"> Report back bugs suggestions </font>")
end
--((Init)--
function Init()
  if not RDQ then
      Q = Spell(_Q, SpellQ.Range)
      W = Spell(_W, SpellW.Range)
      E = Spell(_E, SpellE.Range)
      R = Spell(_R, SpellR.Range)
  elseif RDQ then
    Q = Spell(_Q, SpellQEmpowered.Range)
    W = Spell(_W, SpellW.Range)
    E = Spell(_E, SpellE.Range)
    R = Spell(_R, SpellR.Range)
  end
  if not  RDQ then
      Q:SetSkillshot(VP,SKILLSHOT_LINEAR,SpellQ.Width,SpellQ.Delay ,false)
      Q:SetHitChance(1)
  elseif RDQ then
    Q:SetSkillshot(VP,SKILLSHOT_LINEAR,SpellQEmpowered.Width,SpellQEmpowered.Delay ,false)
    Q:SetHitChance(1)
  end
  EnemyMinions = minionManager(MINION_ENEMY, 1100, myHero, MINION_SORT_MAXHEALTH_DEC)
  JungleMinions = minionManager(MINION_JUNGLE, 1100, myHero, MINION_SORT_MAXHEALTH_DEC)
  Loaded = true
end
--((Spells Menu))--
function ScriptSetUp1()
  Menu = scriptConfig("Yasuo Spells Menu","Yasuo1")
  Enemies = GetEnemyHeroes() 
  for i,enemy in pairs (Enemies) do
    for j,spell in pairs (Spells) do 
    if BlockableProjectiles[enemy:GetSpellData(spell).name] then 
      if BlockableProjectiles[enemy:GetSpellData(spell).name].Blockable then 
    Menu:addParam("Block"..tostring(enemy:GetSpellData(spell).name),"Block "..tostring(enemy.charName).." Spell "..tostring(Spells2[j]),SCRIPT_PARAM_ONOFF,true)
    end 
  end 
 end 
end 
end 
--((Menu))--  
function ScriptSetUp()
--((VP and STUFF))--
  VP = VPrediction()
  TS = SimpleTS(STS_LESS_CAST_PHYSICAL)
  Orbwalker = SOW(VP)
  DrawHandler = DrawManager()
  DamageCalculator= DamageLib()

--((MENU))--
Config = scriptConfig("Yasuo", "Yasuo")
Config:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
Config:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('X'))
Config:addParam("Farm", "Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('L'))
Config:addParam("Flee", "Flee", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('C'))

--((Orbwalker))--
Config:addSubMenu("Orbwalk", "Orbwalk")
--((SOW))--
Config.Orbwalk:addSubMenu("SOW orbwalker", "SOrbwalker")
Orbwalker:LoadToMenu(Config.Orbwalk.SOrbwalker)
--((SAC/MMA integration))--
Config.Orbwalk:addSubMenu("SAC/MMA manager", "NOrbwalker")
Config.Orbwalk.NOrbwalker:addParam("SACOrb", "Use SAC integration", SCRIPT_PARAM_ONOFF, false)
Config.Orbwalk.NOrbwalker:addParam("MMAOrb", "Use MMA integration", SCRIPT_PARAM_ONOFF, false)

--((Target Selector))--
Config:addSubMenu("Target Selector", "TS")
TS:AddToMenu(Config.TS)

--((Combo options))--
Config:addSubMenu("Combo options", "ComboSub")
Config.ComboSub:addSubMenu("Skill Activation Manager", "ComboSub1")
Config.ComboSub.ComboSub1:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.ComboSub.ComboSub1:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
Config.ComboSub.ComboSub1:addParam("useR", "Use R", SCRIPT_PARAM_ONOFF, true)

--((Packets))--
Config.ComboSub:addSubMenu("Packets Manager", "Packet")
Config.ComboSub.Packet:addParam("useP", "Cast Q Using Packets ", SCRIPT_PARAM_ONOFF, true)

--((harass))--
Config:addSubMenu("Harass options", "HarassSub")
Config.HarassSub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.HarassSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, false)

--((Farm))--
Config:addSubMenu("Farm  options", "FSub")
Config.FSub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
Config.FSub:addParam("useE", "Use E", SCRIPT_PARAM_ONOFF, true)
Config.FSub:addParam("LFarm", "Lane clear mode Farm", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('L'))
Config.FSub:addParam("Toggle", "Farm Toggle", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte('O'))
Config.FSub:addParam("JFarm", "Jungle Farm", SCRIPT_PARAM_ONOFF, true)

--((Ultimate))--
Config:addSubMenu("Ultimate", "Ultimate")
Config.Ultimate:addParam("OnlyMe", "Use R on targets knocked by me", SCRIPT_PARAM_ONOFF, true)
Config.Ultimate:addParam("Everyone", "Use R On any Knocked up target", SCRIPT_PARAM_ONOFF, true)

--((Advanced Options))--
Config:addSubMenu("Advanced  options", "ASub")
Config.ASub:addParam("useQ", "Auto Use Q on enemies", SCRIPT_PARAM_ONOFF, true)
Config.ASub:addParam("useQ2", "Auto Use Empowered Q (Q2) on enemies", SCRIPT_PARAM_ONOFF, true)
Config.ASub:addSubMenu("Auto Q options", "AutoOpt")
Config.ASub.AutoOpt:addParam("SmartD", "Smart Under Turret Detection", SCRIPT_PARAM_ONOFF, true)
Config.ASub.AutoOpt:addParam("SmartR", "Smart Recalling Detection", SCRIPT_PARAM_ONOFF, true)
Config.ASub:addParam("useR", "Auto R on enemies knocked up", SCRIPT_PARAM_ONOFF, false)
Config.ASub:addSubMenu("Auto R options", "AutoRopt")
Config.ASub.AutoRopt:addParam("Ronlyme", "Auto use R only on enemies knocked by me", SCRIPT_PARAM_ONOFF, false)
Config.ASub.AutoRopt:addParam("Reveryone", "Auto use R on any knocked up enemy", SCRIPT_PARAM_ONOFF, false)
Config.ASub:addParam("GapE","Use E to Gapclose",SCRIPT_PARAM_ONOFF,true)

--((WallOptions))--
Config:addSubMenu("Wall options ", "WASub")
Config.WASub:addParam("UseEva","Use Evadeee Integration",SCRIPT_PARAM_ONOFF,false)
Config.WASub:addParam("AutoWA", "Auto Wall On blockable Spells", SCRIPT_PARAM_ONOFF, true)
Config.WASub:addParam("PrioWA","Prioritize Important Spells",SCRIPT_PARAM_ONOFF,true)

--((WallOptions))-
Config:addSubMenu("Items And Summoner Spells Options ", "SAItem")
Config.SAItem:addParam("AutoG", "Auto ignite if killable", SCRIPT_PARAM_ONOFF, true)
Config.SAItem:addParam("BoUse","Use Botrk",SCRIPT_PARAM_ONOFF,true)
Config.SAItem:addParam("UseHy","Use Hydra",SCRIPT_PARAM_ONOFF,true)

--((KillSteal))--
Config:addSubMenu("KillSteal options", "KSSub")
Config.KSSub:addParam("useQ", "Use Q to KillSteal", SCRIPT_PARAM_ONOFF, true)

--((Other options))--
Config:addSubMenu("Other options", "OOSub")
Config.OOSub:addParam("Ping", "Ping When enemy is knocked up", SCRIPT_PARAM_ONOFF, true)
Config.OOSub:addParam("nodive", "Don't Turret Dive", SCRIPT_PARAM_ONOFF, true)

--((Show))--
Config:addSubMenu("Show options (Requires Reload (F9) )", "Show")
Config.Show:addParam("Comboshow", "Permashow combo ", SCRIPT_PARAM_ONOFF, true)
Config.Show:addParam("Harassshow", "Permashow Harass", SCRIPT_PARAM_ONOFF, true)
Config.Show:addParam("Farmshow", "Permashow Farm", SCRIPT_PARAM_ONOFF, true)
Config.Show:addParam("Fleeshow", "Permashow Flee", SCRIPT_PARAM_ONOFF, true)

--((Draw))--
Config:addSubMenu("Draw", "Draw")
for spell, range in pairs(Ranges) do
 DrawHandler:CreateCircle(myHero, range, 1, {255, 255, 255, 255}):AddToMenu(Config.Draw, SpellToString(spell).." Range", true, true, true)
   end
   
--((Debug))--
Config:addSubMenu("Debug", "Debug")
Config.Debug:addParam("Enabled", "Debug", SCRIPT_PARAM_ONOFF, false)

--((Permashow))--
if Config.Show.Comboshow then
  ShowComboOn = true
   else
  ShowComboOn = false
end
if Config.Show.Harassshow then
  ShowHarassOn = true
  else
  ShowHarassOn = false
end
if Config.Show.Farmshow then
  ShowFarmOn = true
  else
  ShowFarmOn = false
end
if Config.Show.Fleeshow then
  ShowFleeOn = true
  else
  ShowFleeOn = false
end
if ShowComboOn then
   Config:permaShow("Combo")
end
if ShowHarassOn then
   Config:permaShow("Harass")
end
if ShowFarmOn then
   Config:permaShow("Farm")
end
if ShowFleeOn then
   Config:permaShow("Flee")
   end 
end
--((Combo))--
function Combo()
  if TS:GetTarget(1000) then Chase() end
  local itarget = TS:GetTarget(600)
  if itarget then
    CastItems()
    if Config.SAItem.AutoG then
      AutoIgnite()
    end
  end
    if not Config.Orbwalk.NOrbwalker.MMAOrb and not Config.Orbwalk.NOrbwalker.SACOrb then
    Orbwalker:EnableAttacks()
    local Qfound = TS:GetTarget(SpellQ.Range)
    local QEfound = TS:GetTarget(SpellQEmpowered.Range)
    local Efound = TS:GetTarget(SpellE.Range)
    local Rfound = TS:GetTarget(SpellR.Range)
    if RDQ == false  then
        if Qfound and  Q:IsReady() and Config.ComboSub.ComboSub1.useQ and not
      Config.ComboSub.Packet.useP then
      Q:Cast(Qfound)
      elseif Qfound and  Q:IsReady() and Config.ComboSub.ComboSub1.useQ and    Config.ComboSub.Packet.useP then
        CastQPacket(Qfound)
        end
    end
    if RDQ == true then
      if QEfound and  Q:IsReady() and Config.ComboSub.ComboSub1.useQ and not Config.ComboSub.Packet.useP and (not isCastingE or Qfound) then
        Q:Cast(QEfound)
        elseif QEfound and  Q:IsReady() and Config.ComboSub.ComboSub1.useQ and  Config.ComboSub.Packet.useP and (not isCastingE or Qfound) then
        CastQPacket(QEfound)
        end
    end
    if Efound and  E:IsReady() and Config.ComboSub.ComboSub1.useE  then
        E:Cast(Efound)
    end
    if Rfound and  R:IsReady() and Config.ComboSub.ComboSub1.useR and Config.Ultimate.OnlyMe then
      if KnockDetected then
        R:Cast()
        end
      end 
        if Rfound and R:IsReady() and Config.ComboSub.ComboSub1.useR and Config.Ultimate.Everyone then 
          if KnockDetected or KnockedByAlly then 
            R:Cast()
          end 
        end 
      end 
  
    
--((MMA))--
    if Config.Orbwalk.NOrbwalker.MMAOrb then
    Orbwalker:DisableAttacks()
    local MMATarget = GetMMATarget()
    if MMATarget ~= nil then
        if Q:IsReady() and Config.ComboSub.ComboSub1.useQ and not Config.ComboSub.Packet.useP  then
        Q:Cast(MMATarget)
        elseif Q:IsReady() and Config.ComboSub.ComboSub1.useQ and  Config.ComboSub.Packet.useP then
        CastQPacket(MMATarget)
        end
        if E:IsReady() and Config.ComboSub.ComboSub1.useE   then
        E:Cast(MMATarget)
        end
        if R:IsReady() and Config.ComboSub.ComboSub1.useR and Config.Ultimate.OnlyMe then
         if KnockDetected then
            R:Cast()
        end
        end
        if R:IsReady() and Config.ComboSub.ComboSub1.useR and Config.Ultimate.Everyone then 
          if KnockDetected or KnockedByAlly then
            R:Cast() 
          end 
        end 
    end
    end
--((SAC))--
    if Config.Orbwalk.NOrbwalker.SACOrb then
    Orbwalker:DisableAttacks()
    local SACTarget = GetSACTarget()
    if Q:IsReady() and Config.ComboSub.ComboSub1.useQ and not Config.ComboSub.Packet.useP  then
      Q:Cast(SACTarget)
    elseif  Q:IsReady() and Config.ComboSub.ComboSub1.useQ and  Config.ComboSub.Packet.useP then
      CastQPacket(SACTarget)
    end
    if E:IsReady() and Config.ComboSub.ComboSub1.useE    then
      E:Cast(SACTarget)
    end
    if R:IsReady() and Config.ComboSub.ComboSub1.useR and Config.Ultimate.OnlyMe then
      if KnockDetected then
        R:Cast()
        end
    end
    if R:IsReady() and Config.ComboSub.ComboSub1.useR and Config.Ultimate.Everyone then 
      if KnockDetected or KnockedByAlly then 
        R:Cast() 
    end
end
end 
end 

function AutoQ()
  --print('autoq')
  local Qfound = TS:GetTarget(SpellQ.Range)
  local QEfound = TS:GetTarget(SpellQEmpowered.Range)
    if not (Config.OOSub.nodive and UnderTurret(myHero.pos)) and not RecallDetection then
        if RDQ == false then
          if Qfound and Q:IsReady() and Config.ASub.useQ and not Config.ComboSub.Packet.useP then
            Q:Cast(Qfound)
          elseif Qfound and  Q:IsReady() and Config.ASub.useQ and Config.ComboSub.Packet.useP then
            CastQPacket(Qfound)
            --print('autoq')
          end
        end
        if RDQ == true then
          if QEfound and  Q:IsReady() and Config.ASub.useQ2 and not Config.ComboSub.Packet.useP then
            Q:Cast(QEfound)
            elseif QEfound and  Q:IsReady() and Config.ASub.useQ2 and  Config.ComboSub.Packet.useP then
            CastQPacket(QEfound)
            end
        end
    end
end

function CastItems()
        local target = TS:GetTarget(500)
        if ValidTarget(target) then
                if GetDistance(target) <=480 then
                  if Config.SAItem.BoUse then
                        CastItem(3144, target) --Bilgewater Cutlass
                        CastItem(3153, target) --Blade Of The Ruined King
                  end
                end
                if GetDistance(target) <=400 then
                        CastItem(3146, target) --Hextech Gunblade
                end
                if GetDistance(target) <= 350 then
                  if Config.SAItem.UseHy then
                        CastItem(3184, target) --Entropy
                        CastItem(3143, target) --Randuin's Omen
                        CastItem(3074, target) --Ravenous Hydra
                        CastItem(3131, target) --Sword of the Divine
                        CastItem(3077, target) --Tiamat
                        CastItem(3142, target) --Youmuu's Ghostblade
                  end
                end
                if GetDistance(target) <= 1000 then
                        CastItem(3023, target) --Twin Shadows
                end
        end
end

function AutoIgnite()
  local target = TS.target
  if target then
     local iDmg = (getDmg("IGNITE", target, myHero)) or 0
   end
  if target then
    if target.health <= iDmg and (GetDistance(TS.target, myHero) <= 600) then
      if iReady then CastSpell(ignite, target) end
    end
  end
end

--((Credit TREES))--
function GetMMATarget()
  if _G.MMA_Target and _G.MMA_Target.type == myHero.type then
    return _G.MMA_Target
  else print('Failed TO detect MMA please use SOW or Use MMA at your OWN Risk ')
    end
end

function GetSACTarget()
  if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then
    return _G.AutoCarry.Attack_Crosshair.target
  end
  if not _G.AutoCarry then
    print('Failed to detect SAC please use SOW Or Use SAC at your OWN risk')
    end
end

--((QpacketCast))--

function CastQPacket(Target) 
 if Target ~= nil then 
  if not RDQ then
      if Config.Debug.Enabled then 
        print('cast normally')
    end 
    local CastPosition, HitChance, Position =  VP:GetLineCastPosition(Target, SpellQ.Delay , SpellQ.Width , SpellQ.Range , SpellQ.Speed , myHero, false)
      if HitChance >= 1 then
        Packet("S_CAST", {spellId = _Q, toX=CastPosition.x, toY=CastPosition.z, fromX=CastPosition.x, fromY=CastPosition.z}):send()
      end
  end
  if RDQ then
      if Config.Debug.Enabled then 
      print('casted with RDQ')
    end 
    local CastPosition, HitChance, Position =  VP:GetLineCastPosition(Target, SpellQEmpowered.Delay , SpellQEmpowered.Width , SpellQEmpowered.Range , SpellQEmpowered.Speed , myHero, false)
    if HitChance >= 2 then
        Packet("S_CAST", {spellId = _Q, toX=CastPosition.x, toY=CastPosition.z, fromX=CastPosition.x, fromY=CastPosition.z}):send()
    end
    end
end
end 

-- Fuggi's code finding nearest minions and end position of E cast 

function eEndPos(unit)
    local endPos = Point(unit.x-myHero.x, unit.z-myHero.z)
    abs = math.sqrt(endPos.x*endPos.x + endPos.y*endPos.y)
    endPos2 = Point(myHero.x + (SpellE.Range*(endPos.x/abs)), myHero.z + (SpellE.Range*(endPos.y/abs)))
    return endPos2
end

function getNearestMinion(unit)

  local closestMinion = nil
  local nearestDistance = 0

    EnemyMinions:update()
    JungleMinions:update()
    for index, minion in pairs(EnemyMinions.objects) do
      if minion ~= nil and minion.valid and string.find(minion.name,"Minion_") == 1 and minion.team ~= player.team and minion.dead == false then
        if GetDistance(minion) <= SpellE.Range then
                    --PrintChat(GetDistance(eEndPos(minion), unit) .. "  -  ".. GetDistance(unit))
          if GetDistance(eEndPos(minion), unit) < GetDistance(unit) and nearestDistance < GetDistance(minion) then
            nearestDistance = GetDistance(minion)
            closestMinion = minion
          end
        end
      end
    end
    for index, minion in pairs(JungleMinions.objects) do
      if minion ~= nil and minion.valid and minion.dead == false then
        if GetDistance(minion) <= SpellE.Range then
          if GetDistance(eEndPos(minion), unit) < GetDistance(unit) and nearestDistance < GetDistance(minion) then
            nearestDistance = GetDistance(minion)
            closestMinion = minion
          end
        end
      end
    end
    for i = 1, heroManager.iCount, 1 do
      local minion = heroManager:getHero(i)
      if ValidTarget(minion, SpellE.Range) then
        if GetDistance(minion) <= SpellE.Range then
          if GetDistance(eEndPos(minion), unit) < GetDistance(unit) and nearestDistance < GetDistance(minion) then
            nearestDistance = GetDistance(minion)
            closestMinion = minion
          end
        end
      end
    end
  return closestMinion
end

function GTFO()
  local GTFOmin = getNearestMinion(mousePos)
  if GTFOmin and E:IsReady() then
    CastSpell(_E, GTFOmin)
  else
    myHero:MoveTo(mousePos.x, mousePos.z)
  end
end

function FarmQ()
  if Config.FSub.useQ then
    Orbwalker:EnableAttacks()
    for _, minion in pairs(EnemyMinions.objects) do
      local QdmgMinion = (getDmg("Q", minion, myHero)) or 0
      if ValidTarget(minion) then
        if GetDistance(minion, myHero) < SpellQ.Range then
          if Config.Farm then
            if minion.health <= QdmgMinion then
              CastSpell(_Q, minion.x, minion.z)
            end
          end
          if Config.FSub.LFarm then
            CastSpell(_Q, minion.x, minion.z)
          end
        end
      end
    end
    if Config.FSub.JFarm then
      Orbwalker:EnableAttacks()
      for _, minion1 in pairs (JungleMinions.objects) do
        if GetDistance(minion1, myhero) < SpellQ.Range then
          CastSpell(_Q, minion1.x, minion1.z)
        end
      end
    end
  end
end

function FarmE()
  if Config.FSub.useE then
    Orbwalker:EnableAttacks()
    for _, minion in pairs(EnemyMinions.objects) do
      local EdmgMinion = (getDmg("E", minion, myHero)) or 0
      if ValidTarget(minion) then
        if GetDistance(minion, myHero) < SpellE.Range then
          if minion.health <= EdmgMinion then
                  if Config.OOSub.nodive then
                    if not UnderTurret(eEndPos(minion)) then
                CastSpell(_E, minion)
                    end
                    else
                      CastSpell(_E, minion)
                    end
          end
        end
      end
    end
    if Config.FSub.JFarm then
      Orbwalker:EnableAttacks()
      for _, minion1 in pairs (JungleMinions.objects) do
        if GetDistance(minion1, myhero) < SpellE.Range then
          CastSpell(_E, minion1)
        end
      end
    end
  end
end

function Farm()
  --PrintChat("Farming")
  if not nofarm then
    FarmQ()
    FarmE()
  end
end

function Chase()
  if Config.ASub.GapE then
    local target = TS:GetTarget(1000)
    local gapclosem = getNearestMinion(target)
    if target then
      if gapclosem and E:IsReady() then
          if Config.OOSub.nodive then
              if not UnderTurret(eEndPos(gapclosem)) then
                CastSpell(_E, gapclosem)
              end
            else
          CastSpell(_E, gapclosem)
            end
      end
    end
  end
end
--((Harass))--
function Harass()
  Orbwalker:EnableAttacks()
  if not Config.Orbwalk.NOrbwalker.MMAOrb and not Config.Orbwalk.NOrbwalker.SACOrb then
    local Qfound = TS:GetTarget(SpellQ.Range)
    local QEfound = TS:GetTarget(SpellQEmpowered.Range)
    local Efound = TS:GetTarget(SpellE.Range)
    local Rfound = TS:GetTarget(SpellR.Range)
    if RDQ == false  then
        if Qfound and  Q:IsReady() and Config.HarassSub.useQ and not Config.ComboSub.Packet.useP then
          Q:Cast(Qfound)
        elseif Qfound and  Q:IsReady() and Config.HarassSub.useQ and  Config.ComboSub.Packet.useP  then
          CastQPacket(Qfound)
        end
    end
      if RDQ == true then
      if QEfound and  Q:IsReady() and Config.HarassSub.useQ and not Config.ComboSub.Packet.useP then
          Q:Cast(QEfound)
        elseif QEfound and  Q:IsReady() and Config.HarassSub.useQ and Config.ComboSub.Packet.useP then
          CastQPacket(QEfound)
        end
    end
    if Efound and  E:IsReady() and Config.HarassSub.useE  then
      E:Cast(Efound)
      end
    end 
end 
--((AutoUlti))--
function AutoUlt() 
  local Rfound = TS:GetTarget(SpellR.Range)
  if Config.ASub.useR then 
    if Config.ASub.Ronlyme then 
      if Rfound and R:IsReady() then 
        if KnockDetected then 
          R:Cast() 
        end 
      end 
    end 
  end 
  if Config.ASub.useR then 
    if Config.ASub.Reveryone then 
      if Rfound and R:IsReady() then 
        if KnockedByAlly then 
          R:Cast() 
        end 
      end 
    end 
  end 
end 

 
--((Killsteal))--
function Killsteal() 
  local Enemies = GetEnemyHeroes() 
  for i, enemy in pairs(Enemies) do 
    if ValidTarget(enemy,SpellQ.Range) and not enemy.dead and GetDistance(enemy) > SpellQ.Range and Config.KSSub.useQ then 
      Q:Cast(enemy)
    end 
  end
end 



--((OnTick))--
function OnTick()
    if myHero:CanUseSpell(_E) == COOLDOWN then
      isCastingE = true
      DelayAction(function() isCastingE = false end, 1)
    end
    local itarget = TS:GetTarget(600)
    if Loaded then
    if Config.Combo then Combo() end
    if Config.Harass then Harass() end 
    if Config.Farm then Farm() end
    if Config.Flee then GTFO() end
    if Config.FSub.LFarm then Farm() end
    if Config.FSub.Toggle then Farm() end 
    if Config.Combo then nofarm = true
      else nofarm = false
    end
    end 
    EnemyMinions:update()
    JungleMinions:update()
    if TS:GetTarget(1000) then
      AutoQ()
    end
    --((Calling))--
    AutoUlt() 
    Killsteal()
    if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
      ignite = SUMMONER_1
    elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
      ignite = SUMMONER_2
    end
    iReady = (ignite ~= nil and myHero:CanUseSpell(ignite) == READY)
end
--((OnGainBuff))--

local buffTable = {'monkeykingspinkknockup',
                    'unstoppablefrocestun',
                     'oriannastun',
                     'moveawaycollission',
                     'Pulverize',
                     'headbutttarget',
                     'HowlingGaleSpell',
                     'BlindMonkRKick',
                     'powerfistslow'}


function OnGainBuff(unit, buff)
  if unit.isMe and buff.name == 'yasuoq3w' then
    RDQ = true
      Init()
  end
  if unit and unit.team == TEAM_ENEMY and unit.type == 'obj_AI_Hero' and  buff.name ==   'yasuoq3mis' then
    KnockDetected = true
  end 
   for i, buffs in pairs(buffTable) do  
   if unit and unit.team == TEAM_ENEMY and unit.type == 'obj_AI_Hero' and buff.name == buffs then 
       KnockedByAlly = false 
   end 
 end   
end

--((OnUpdateBuff))--
function OnUpdateBuff(unit, buff)
   for i, buffs in pairs(buffTable) do  
   if unit and unit.team == TEAM_ENEMY and unit.type == 'obj_AI_Hero' and buff.name == buffs then 
       counter = counter + 1 
       KnockedByAlly = true 
   end 
 end   
end
--((OnLoseBuff))
function OnLoseBuff(unit, buff)
  if unit.isMe and buff.name == 'yasuoq3w' then
      RDQ = false
      Init()
  end
  if unit and unit.team == TEAM_ENEMY and unit.type == 'obj_AI_Hero' and  buff.name == 'yasuoq3mis' then
    KnockDetected = false
    end
for i, buffs in pairs(buffTable) do  
   if unit and unit.team == TEAM_ENEMY and unit.type == 'obj_AI_Hero' and buff.name == buffs then 
       KnockedByAlly = false 
   end 
 end                  

end

--((OnRecall))
function OnRecall(hero, channelTimeInMs) 
if hero.isMe then 
  RecallDetection = true 
  else return end 
end 
--((OnAbortRecall))
function OnAbortRecall(hero)
if hero.isMe then 
  RecallDetection = false 
  else return end 
end 
--((OnFinishRecall))
function OnFinishRecall(hero) 
  if hero.isMe then 
    RecallDetection = false 
    else return end 
end 

--((OnProcessSpell))--
function OnProcessSpell(unit, spell)
  if Config.WASub.AutoWA then
    if spell and unit and GetDistance(unit) < 2000 and unit.type == "obj_AI_Hero" and GetDistance(unit) > 400  and unit.team == TEAM_ENEMY then 
     
      if BlockableProjectiles[spell.name]
        then 
        
        if  BlockableProjectiles[spell.name].Blockable then 
          if BlockableProjectiles[spell.name].SpellType == "skillshot" then 
            local name = tostring(spell.name)
            local Sdelay , Swidth , Srange , Sspeed , Scollision = BlockableProjectiles[spell.name].delay , BlockableProjectiles[spell.name].width , BlockableProjectiles[spell.name].range , BlockableProjectiles[spell.name].speed , BlockableProjectiles[spell.name].collision
            local CastPosition , Hitchance , Pos = VP:GetLineCastPosition(myHero,Sdelay,Swidth,Srange,Sspeed,unit,Scollision)
            if Hitchance >=1 then
            
              if not _G.Evadeee and W:IsReady()  then 
                print('blockable')
                CastSpell(_W,spell.startPos.x,spell.startPos.z)
              end 
              if _G.Evadeee then 
                if _G.Evadeee_impossibleToEvade and W:IsReady()  then 
                  CastSpell(_W,spell.startPos.x,spell.startPos.z)
                end 
              end 
            end 
          end 
          elseif BlockableProjectiles[spell.name].SpellType == 'enemyCast' and spell.target ~= nil and  GetDistance(unit) > 400  then 
               if spell.target == myHero then 
              CastSpell(_W,spell.startPos.x,spell.startPos.z)
            end 
          end 
        end 
      end 
     end 
		end 
