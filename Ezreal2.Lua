local VERSION = "0.9"

if myHero.charName ~= "Ezreal" then return end

require 'VPrediction'
require 'SourceLib'
require 'SOW'

local Config = nil

local VP = VPrediction()

local SpellQ = {Speed = 2000, Range = 1200, Delay = 0.25, Width = 60}

local SpellW = {Speed = 1600, Range = 1050, Delay = 0.25, Width = 80}

local SpellR = {Range= 3000 ,Width = 160, Speed = 2000, Delay= 1}

local FullCombo = {_Q , _W , _AA , _Q , _R}

local WRange, RRange = nil, nil

local QReady, WReady, EReady, RReady = nil, nil, nil, nil

function OnLoad()

Menu()
Init()
PrintChat("<font color=\"#81BEF7\">Awa Ezreal loaded</font>")
end

function Init()
	ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1300, DAMAGE_PHYSICAL)
	ts2 = TargetSelector(TARGET_LESS_CAST_PRIORITY, 3000, DAMAGE_PHYSICAL)
	ts.name = "Ranged Main"
	ts2.name = "Ultimate TS"
  Config:addTS(ts)
	Config:addTS(ts2)
	EnemyMinions = minionManager(MINION_ENEMY, 1100, myHero, MINION_SORT_MAXHEALTH_DEC)
  initDone = true
end



function Menu()

	orbwalker = SOW(VP)
	DamageCalculator = DamageLib()

	DamageCalculator:RegisterDamageSource(_Q, _PHYSICAL , 25 , 45 , _PHYSCAL , _AD , 1 ,function() return (player:CanUseSpell(_Q) == READY)end)
	DamageCalculator:RegisterDamageSource(_W,_MAGIC, 25 , 45 , _MAGIC , _AP , 0.8 ,function() return (player:CanUseSpell(_W) == READY)end)
	DamageCalculator:RegisterDamageSource(_R, _MAGIC , 200 , 150 ,_PHYSICAL , _AD, 1 ,function() return (player:CanUseSpell(_R) == READY)end)


	Config = scriptConfig("Ezreal", "Ezreal")
	Config:addParam("Combo", "Combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Config:addParam("Harass", "Harass", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('C'))
	Config:addParam("Farm", "Farm with Q only", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('V'))
	Config:addParam("Laneclear", "will use Mystic shot to lane clear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte('C'))
	Config:addSubMenu("Combo options", "ComboSub")
	Config:addSubMenu("Harass options", "HarassSub")
	Config:addSubMenu("Orbwalker","Orbwalker")
	Config:addSubMenu("Farm options", "FarmSub")
	Config:addSubMenu("KS", "KS")
	Config:addSubMenu("Ultimate", "Ultimate")
	Config:addSubMenu("Extra Config", "Extras")
	Config:addSubMenu("Draw", "Draw")

	--Combo
	Config.ComboSub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	Config.ComboSub:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)

	--Harass
	Config.HarassSub:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	Config.HarassSub:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)
	Config.HarassSub:addParam("Enabled2", "Harass (TOGGLE)!", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))

	--Orbwalker
	orbwalker:LoadToMenu(Config.Orbwalker) 

    --farm
    Config.FarmSub:addParam("useQ", "Use Q to farm", SCRIPT_PARAM_ONOFF, true)
	
	--Ks
	Config.KS:addParam("useQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
	Config.KS:addParam("useW", "Use W", SCRIPT_PARAM_ONOFF, true)
	Config.KS:addParam("useR", "execute targets with R", SCRIPT_PARAM_ONOFF, true)
	
	--Ultimate
    Config.Ultimate:addParam("AutoR",  "Auto ultimate if ", SCRIPT_PARAM_LIST, 1, { "No", ">0 hit", ">1 hit", ">2 hit", ">3 hit", ">4 hit" })
    Config.Ultimate:addParam("UltBuff","Buff Dmg",SCRIPT_PARAM_SLICE,200,1,200,0)
	Config.Ultimate:addParam("AutoAim", "AutoAim your R ", SCRIPT_PARAM_ONKEYDOWN, false,string.byte('A'))


	--Draw
	Config.Draw:addParam("DrawQ", "Draw Q Range", SCRIPT_PARAM_ONOFF, true)
	Config.Draw:addParam("DrawW", "Draw W Range", SCRIPT_PARAM_ONOFF, true)
	Config.Draw:addParam("Drawkillable", "Draw killable enemy with ulti", SCRIPT_PARAM_ONOFF, true)
	DamageCalculator:AddToMenu(Config.Draw,FullCombo)

	--Extras
	Config.Extras:addParam("Debug", "Debug", SCRIPT_PARAM_ONOFF, false)
	
--Permashow
	Config:permaShow("Combo")
	Config:permaShow("Harass")
	Config:permaShow("Farm")
	Config:permaShow("Laneclear")
	end

	
--Credit Trees	
function GetCustomTarget()

	ts:update()
	
	ts2:update()
	
 if _G.MMA_Target and _G.MMA_Target.type == myHero.type then 
 return _G.MMA_Target 
end

if _G.AutoCarry and _G.AutoCarry.Crosshair and _G.AutoCarry.Attack_Crosshair and _G.AutoCarry.Attack_Crosshair.target and _G.AutoCarry.Attack_Crosshair.target.type == myHero.type then 
return _G.AutoCarry.Attack_Crosshair.target
end

return ts.target

end
--End Credit Trees

function OnTick()
	if initDone then
EnemyMinions:update()
Check()
target = GetCustomTarget()
Qtarget = ts.target
Rtarget = ts2.target
	if Config.Combo and target ~= nil then
     	Combo(target)
elseif  Config.Combo and Qtarget ~= nil then

  Combo(Qtarget)

	end

if Config.Harass and target ~= nil then
 Harass(target)

elseif Config.Harass and Qtarget ~= nil then
Harass(Qtarget)
end

if	Config.HarassSub.Enabled2 and target ~= nil then
Harass(target)
elseif Config.HarassSub.Enabled2 and Qtarget ~= nil then
Harass(Qtarget)
end

if Config.Farm  and Config.FarmSub.useQ then farmQ() end 

if Config.Laneclear then farm() end 


if Config.Ultimate.AutoAim then CastR(Rtarget) end
if Config.Ultimate.AutoR - 1 >= 2 then
if target ~= nil then
if RReady then
local Mintargets = Config.Ultimate.AutoR - 1
local AOECastPosition, MainTargetHitChance, nTargets = VP:GetLineAOECastPosition(Rtarget, SpellR.Delay, SpellR.Width, SpellR.Range, SpellR.Speed, myHero)
if MainTargetHitChance >= 2 then
if nTargets >= Mintargets then
CastSpell(_R, AOECastPosition.x, AOECastPosition.z)
end
end
end
end
end
KillSteal()
end
end

function Combo(Target)
	if QReady and Config.ComboSub.useQ then
	CastQ(Target)
	end

	if WReady and Config.ComboSub.useW then
		CastW(Target)
	end


end

function Harass(Target)
	if QReady and Config.HarassSub.useQ  then
		CastQ(Target)
	end
if WReady and Config.HarassSub.useW then
		CastW(Target)
	end
end

function CastQ(Target)
	if Target ~= nil and ValidTarget(Target, 1300) and QReady then
		local CastPosition, HitChance, Pos = VP:GetLineCastPosition(Target, SpellQ.Delay, SpellQ.Width, SpellQ.Range, SpellQ.Speed, myHero, true)
		if HitChance >= 2 and GetDistance(CastPosition) < SpellQ.Range then
			CastSpell(_Q, CastPosition.x, CastPosition.z)
		end
	end
end

function CastW(Target)
	if Target ~= nil and ValidTarget(Target, 1300) and WReady then
		local CastPosition, HitChance, Pos = VP:GetLineCastPosition(Target, SpellW.Delay, SpellW.Width, SpellW.Range, SpellW.Speed, myHero, false)
		if HitChance >= 2 and GetDistance(CastPosition) < SpellW.Range then
			CastSpell(_W, CastPosition.x, CastPosition.z)
		end
	end
end
function CastR(Target)
	if Target ~= nil and ValidTarget(Target, 3000) and RReady then
		local CastPosition, HitChance, Pos = VP:GetLineCastPosition(Target, SpellR.Delay, SpellR.Width, SpellR.Range, SpellR.Speed, myHero, false)
		if HitChance >= 2 and GetDistance(CastPosition) < SpellR.Range then
			CastSpell(_R, CastPosition.x, CastPosition.z)
		end
	end
end


function KillSteal()
	local Enemies = GetEnemyHeroes()
	local buffer = Config.Ultimate.UltBuff
	for i, enemy in pairs(Enemies) do
		if ValidTarget(enemy, 1800) and not enemy.dead and GetDistance(enemy) < 1800 then
			if getDmg("Q", enemy, myHero) > enemy.health and  Config.KS.useQ then
				CastQ(enemy)
			end

			if getDmg("E", enemy, myHero) > enemy.health and Config.KS.useE then
				CastE(enemy)
			end

			if getDmg("R", enemy, myHero) + buffer > enemy.health and  Config.KS.useR then
				CastR(enemy)
			end
		end
	end

end


function OnDraw()
if Config.Draw.Drawkillable then  warning() end

 if Config.Draw.DrawQ then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, SpellQ.Range, 1,  ARGB(255, 0, 255, 255))
	end

	if Config.Draw.DrawW then
		DrawCircle3D(myHero.x, myHero.y, myHero.z, SpellW.Range, 1,  ARGB(255, 0, 255, 255))
	end

end

function Check()
	QReady = (myHero:CanUseSpell(_Q) == READY)
	WReady = (myHero:CanUseSpell(_W) == READY)
	RReady = (myHero:CanUseSpell(_R) == READY)
end


function farmQ()
for _, minion in pairs(EnemyMinions.objects) do
local qMiniyoDmg = getDmg("Q", minion, myHero) +50
if QReady  then
if minion.health <= (qMiniyoDmg) then
CastQ(minion)
end
end
end
end


function farm()
for _, minion in pairs(EnemyMinions.objects) do
if QReady  then
CastQ(minion)
end
end
end

function warning()
local Enemies = GetEnemyHeroes()
for i, enemy in pairs(Enemies) do
		if ValidTarget(enemy, 1300) and not enemy.dead and GetDistance(enemy) < 1300 then
			if getDmg("R", enemy, myHero) > enemy.health and GetDistance(enemy) < 1300 and RReady then
DrawText3D("Enemy killable with ulti", enemy.x, enemy.y, enemy.z, 15,  ARGB(255,0,255,0), true)
			end
		end
	end
	end


--end--
