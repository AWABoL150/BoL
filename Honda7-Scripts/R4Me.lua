--[[
R4Me

Introduction:
This script will handle your champion ultimate (Supported list below) and cast it (using Flash + R if needed) depending on the target(s) you choose.

Supported champions:

	Line ultimates: 
		Sona
		Nami
		Sejuani: Does not check for collisions.
		Varus: Same as sejuani.
	
	Circular ultimates:
		Zyra
		Ziggs
		Leona
		Gragas
		Evelynn
		Malphite
		Annie
	
	Self-Circular ultimates (no flash support atm):
		Amumu: Does not cast Q, only ultimate.
		Morgana
	
	Rumble (no flash support atm):
		Rumble
		
	Targeteable AOE:
		Fiora
		
3 Diferent modes:
	-Auto: Will auto-ultimate when all targets in the selected group(s) can be hit.
	-Initiate: Same as Auto but with Flash support and a hotkey has to be pressed.
	-Chain: Will auto-ultimate when all targets in the selected group(s) can be hit and are immobile.
	

]]

require "VPrediction"

local Menu = nil

--[[types]]
local _LINE = 0
local _CIRCULAR = 1
local _SELF_CIRCULAR = 2
local _RUMBLE = 3
local _TARGETEABLE = 4


--[[Number of groups]]
local groupnumber = 4

--[[Prediction]]
local VP = nil

local UltimateList = {}
local MyUlt = nil
local Slot = _R
local FlashRange = 400

--[[Debugging]]
local Drawpointsgreen = {}
local Drawpointsred = {}
local Drawpointsblue = {}
local debug = false

function OnLoad()

	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerFlash") then
		_FLASH = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerFlash") then
		_FLASH = SUMMONER_2
	else
		_FLASH = nil
	end
	
	--[[Line]]
	table.insert(UltimateList, {charName = "Sona", type = _LINE, width=140, range=1000, speed=2400, delay=0.250})
	table.insert(UltimateList, {charName = "Nami", type = _LINE, width=325, range=2750, speed=1200, delay=0.250})
	table.insert(UltimateList, {charName = "Sejuani", type = _LINE, width=110, range=1175, speed=1400, delay=0.250})
	table.insert(UltimateList, {charName = "Varus", type = _LINE, width=100, range=1075, speed=1200, delay=0.250})
	--table.insert(UltimateList, {charName = "Zyra", type = _LINE, width=70, range=1150, speed=1150, delay=0.250})--for testing
	
	--[[Circular]]
	table.insert(UltimateList, {charName = "Zyra", type = _CIRCULAR, width=500, range=700, speed=math.huge, delay=1})
	table.insert(UltimateList, {charName = "Ziggs", type = _CIRCULAR, width=500, range=5300, speed=math.huge, delay=1})
	table.insert(UltimateList, {charName = "Leona", type = _CIRCULAR, width=300, range=1200, speed=math.huge, delay=0.5})
	table.insert(UltimateList, {charName = "Gragas", type = _CIRCULAR, width=400, range=1050, speed=1100, delay=0.250})
	table.insert(UltimateList, {charName = "Evelynn", type = _CIRCULAR, width=350, range=650, speed=math.huge, delay=0.250})
	table.insert(UltimateList, {charName = "Malphite", type = _CIRCULAR, width=300, range=1000, speed=2000, delay=0.250})
	table.insert(UltimateList, {charName = "Annie", type = _CIRCULAR, width=300, range=600, speed=math.huge, delay=0.250})
	
	--[[Amumu type]]
	table.insert(UltimateList, {charName = "Amumu", type = _SELF_CIRCULAR, width=550, range=0, speed=math.huge, delay=0.250})
	table.insert(UltimateList, {charName = "Morgana", type = _SELF_CIRCULAR, width=600, range=0, speed=math.huge, delay=0.250})
	
	--[[Rumble]]
	table.insert(UltimateList, {charName = "Rumble", type = _RUMBLE, width=120, range=700, speed=1000, length=900, delay=0.250})

	--[[Targetted AOE]]
	table.insert(UltimateList, {charName = "Fiora", type = _TARGETEABLE, width=350, range=400, speed=math.huge, delay=0.250})
	
	
	for i, ultimate in ipairs(UltimateList) do
		if ultimate.charName == myHero.charName then
			MyUlt = ultimate
			MyUlt.width = MyUlt.width - 20
			print("[R4Me] - Supported ultimate detected for "..myHero.charName)
		end
	end
	
	Menu = scriptConfig("R4Me", "R4Me")
	
	Menu:addSubMenu("Targets", "Targets")
	for k=1, groupnumber do
		Menu.Targets:addSubMenu("Group"..k, "G"..k)
		for i, enemy in ipairs(GetEnemyHeroes()) do
			Menu.Targets['G'..k]:addParam('C'..enemy.charName, tostring(enemy.charName), SCRIPT_PARAM_ONOFF, true)
			Menu.Targets['G'..k]['C'..enemy.charName] = false --Ignore the saved config
		end
	end
	
	Menu:addSubMenu("Auto", "Auto")
	for k=1, groupnumber do
		Menu.Auto:addParam("G"..k, "Group"..k, SCRIPT_PARAM_ONOFF, false)
	end
	Menu.Auto:addParam("Enabled", "Enabled auto ultimate", SCRIPT_PARAM_ONOFF, false)
	Menu.Auto['Enabled'] = false


	Menu:addSubMenu("Initiate", "Initiate")
	for k=1, groupnumber do
		Menu.Initiate:addParam("G"..k, "Group"..k, SCRIPT_PARAM_ONOFF, false)
	end
	Menu.Initiate:addParam("Flash", "Use Flash?", SCRIPT_PARAM_ONOFF, false)
	Menu.Initiate:addParam("Enabled", "Initiate!", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Menu.Initiate['Enabled'] = false

	
	Menu:addSubMenu("Chain", "Chain")
	for k=1, groupnumber do
		Menu.Chain:addParam("G"..k, "Group"..k, SCRIPT_PARAM_ONOFF, false)
	end
	Menu.Chain:addParam("Flash", "Use Flash?", SCRIPT_PARAM_ONOFF, false)
	Menu.Chain:addParam("Enabled", "Enable chain", SCRIPT_PARAM_ONOFF, false)
	Menu.Chain['Enabled'] = false
	
	if debug then
			Drawpointsred = {}
			Drawpointsblue = {}
	end
	VP = VPrediction()
end

--[[Returns the MEC that catches all the given points]]
function GetCircular(Points)
	local mec = MEC(Points)
	local Circle = mec:Compute()
	local Center = Circle.center
	local Radius = Circle.radius
	
	return Center, Radius
end

--[[Returns the line that will catch all the given points (Line centered in one point)]]
--GetLine(myHero, Points, MyUlt.width , MyUlt.range)

function GetLine(From, Points, Radius, Range)
	for j, point in ipairs(Points) do
		local castPoint = point
		local k = 0
		for i, point2 in ipairs(Points) do
			LSPoint, whocares, isOnSegment = VectorPointProjectionOnLineSegment(From, From + Range * Vector(castPoint.x - From.x, 0, castPoint.z - From.z):normalized(), point2)
			if isOnSegment and GetDistance(LSPoint, point2) <= Radius then
				k = k + 1
			end
		end
		if k == #Points then 
			return castPoint
		end
	end
	
	return nil
end

--[[From:http://snippets.luacode.org/snippets/Linear_Least_Squares_Fit_115]]
function least_squares_fit(xx,yy)
	local xsum,ysum,xxsum,yysum,xysum = 0,0,0,0,0
	local m,c,d
	local n = #xx
	for i = 1,n do
		local x,y = xx[i],yy[i]
		xsum = xsum + x
		ysum = ysum + y
		xxsum = xxsum + x*x
		yysum = yysum + y*y
		xysum = xysum + x*y
	end
	d = n*xxsum - xsum*xsum
	if d ~= 0 then
		m = (n*xysum - xsum*ysum)/d
		c = (xxsum*ysum - xysum*xsum)/d
	else
		return 0, 0
	end
	return m,c
end

function GetRumble(Points, Range, Length, Width)
	local StartPoint = nil 
	local EndPoint = nil
	local xx = {}
	local yy = {}

	if #Points == 1 then
		return Vector(Points[1].x, 0, Points[1].z) + 100 * Vector(Points[1].x-myHero.x, 0, Points[1].z-myHero.x):normalized() , Vector(Points[1].x, 0, Points[1].z)
	elseif #Points == 2 then
		local p1 = Points[1]
		local p2 = Points[2]
		StartPoint = p1
		EndPoint = p2
	else

		for i, point in ipairs(Points) do
			table.insert(xx, point.x)
			table.insert(yy, point.z)
		end
		--[[Get the line using least squares fit method]]
		local m,c = least_squares_fit(xx, yy)
		local Point1 = Vector(0, 0, c)
		local Point2 = Vector(1, 0, m + c)
	
		local projections = {}

		for i, point in ipairs(Points) do
			local proj = VectorPointProjectionOnLine(Point1, Point2, point)
			if GetDistance(proj, point) < Width then
				table.insert(projections, proj)
			else--[[Point to far from the line]]
				return nil, nil
			end
		end
	
		--[[Get the Start and EndPoint from our line segment (the pair of points with most distance between)]]
		local tmpSP, tmpEP = nil, nil
		local MaxDist = 0
	
		for i, proj in ipairs(projections) do
			for j, proj2 in ipairs(projections) do
				local Dist = GetDistanceSqr(proj, proj2)
				if (Dist > MaxDist) or tmpSP == nil then
					MaxDist = Dist
					tmpSP = proj
					tmpEP = proj2
				end
			end
		end
	
		StartPoint, EndPoint = tmpSP, tmpEP
	end
	
	
	if GetDistance(StartPoint, EndPoint) <= Length then
		local Remaining = Length - GetDistance(StartPoint, EndPoint)
		local Direction = (Vector(StartPoint) - Vector(EndPoint)):normalized()

		local CastPoint1 = Vector(StartPoint) + Remaining * Direction
		local CastPoint2 = Vector(EndPoint) - Remaining * Direction
		
		if GetDistance(CastPoint1) < Range then
			return CastPoint1, EndPoint
		elseif GetDistance(CastPoint2) < Range then
			return CastPoint2, StartPoint
		else
			return nil, nil
		end
	else
		return nil, nil
	end
end


function CastUltimate(Points, UseFlash)
	local doable = true
	local FlashR = UseFlash and FlashRange or 0
	
	if #Points > 0  then
		for i, point in ipairs(Points) do	
			--[[target out of range]]
			if MyUlt.type == _CIRCULAR then
				if GetDistance(Vector(point)) > (MyUlt.range + MyUlt.width + FlashR) then
					doable = false
				end
			elseif MyUlt.type == _LINE then
				if GetDistance(Vector(point)) > (MyUlt.range + FlashR) then
					doable = false
				end
			elseif MyUlt.type == _SELF_CIRCULAR then
				if GetDistance(Vector(point)) > (MyUlt.width) then
					doable = false
				end
			elseif MyUlt.type == _RUMBLE then
				if GetDistance(Vector(point)) > (MyUlt.range + MyUlt.Length) then
					doable = false
				end
			elseif MyUlt.type == _TARGETEABLE then
				if i == 1 then 
					doable = false 
				end
				if GetDistance(Vector(point)) < (MyUlt.range + FlashR) then
					doable = true
				end
			end	
		end
	
		
		
		if doable then
			if MyUlt.type == _CIRCULAR then
				local Center, Radius = GetCircular(Points)
				if GetDistance(Vector(Center)) <= MyUlt.range and Radius <= MyUlt.width then
					CastSpell(Slot, Center.x, Center.z)
				elseif GetDistance(Vector(Center)) <= MyUlt.range + FlashRange and Radius <= MyUlt.width and UseFlash and _FLASH ~= nil then
					FlashNult = (myHero:CanUseSpell(_FLASH) == READY) 
					FlashNultPoint = Center
					if FlashNult then
						CastSpell(_FLASH, Center.x, Center.z)
					end
				end
			elseif MyUlt.type == _LINE then
				local mPosition = GetLine(myHero, Points, MyUlt.width , MyUlt.range)
				if mPosition ~= nil and GetDistance(Vector(mPosition)) <= MyUlt.range then
					CastSpell(Slot, mPosition.x, mPosition.z)
				elseif UseFlash  and _FLASH ~= nil then
					--[[Flasing + Casting a line skillshots is like casting rumbles ultimate]]
					local StartPoint, EndPoint = GetRumble(Points, FlashRange,  MyUlt.range, MyUlt.width)
					if StartPoint then
						FlashNult = (myHero:CanUseSpell(_FLASH) == READY) 
						FlashNultPoint = EndPoint
						if FlashNult then
							CastSpell(_FLASH, StartPoint.x, StartPoint.z)
						end
					end
				end
			
			elseif MyUlt.type == _SELF_CIRCULAR then
				CastSpell(Slot)
			elseif MyUlt.type == _RUMBLE then
				local StartPoint, EndPoint = GetRumble(Points, MyUlt.range, MyUlt.length, MyUlt.width)
				if StartPoint then
					if debug then
						table.insert(Drawpointsred, StartPoint)
						table.insert(Drawpointsblue, EndPoint)
					end
					Packet('S_CAST', {spellId = Slot, fromX = StartPoint.x, fromY = StartPoint.z, toX = EndPoint.x, toY = EndPoint.z}):send()
				end
			elseif MyUlt.type == _TARGETEABLE then
				local Center, Radius = GetCircular(Points)
				local Casted = false
				if Radius <= MyUlt.width then
					for i, point in ipairs(Points) do
						for k, target in ipairs(GetEnemyHeroes()) do
							if GetDistance(target, point) < 300 and GetDistance(target) < MyUlt.range then
								CastSpell(_R, target)
								Casted = true
							end
						end
					end
					
					FlashNult = (myHero:CanUseSpell(_FLASH) == READY) 
									
									
					if not Casted and FlashNult then
						for i, point in ipairs(Points) do
							for k, target in ipairs(GetEnemyHeroes()) do
								if GetDistance(target, point) < 300 and GetDistance(target) < MyUlt.range + FlashRange then
									FlashNultTarget = target
									CastSpell(_FLASH, Center.x, Center.z)
								end
							end
						end
					end
				end
			end
		end
	end
end

function OnProcessSpell(unit, spell)
	if unit.isMe and spell.name:lower():find("summonerflash") then
		if FlashNult and FlashNultPoint then
			CastSpell(Slot, FlashNultPoint.x, FlashNultPoint.z)
			FlashNult = false
		elseif FlashNult and FlashNultTarget then
			CastSpell(Slot, FlashNultTarget)
			FlashNult = false
		end
	end
end

function OnTick()
	if not MyUlt then return end --Character not supported
	if not (myHero:CanUseSpell(Slot) == READY) then return end --Ultimate not ready
	
	Position = {}
	Immobile = {}
	
	--[[Get the predicted position of the targets]]
	if debug then
		Drawpointsgreen = {}
	end
	
	for i, target in pairs(GetEnemyHeroes()) do
		if ValidTarget(target, 2000) then
			local Position1,  HitChance = VP:GetPredictedPos(target, MyUlt.delay, MyUlt.speed, myHero)
			local Inmo, k = VP:IsImmobile(target, MyUlt.delay, MyUlt.width, MyUlt.speed, myHero) 
			if debug then
				if CanMove then
					table.insert(Drawpointsgreen, Position1)
				else
					table.insert(Drawpointsred, Position1)
				end
			end
			Position[target.charName] = Position1
			Immobile[target.charName] = Inmo
		end
	end
	
	if Menu.Auto.Enabled then
		for k=1, groupnumber do
			if Menu.Auto['G'..k] then
				Points = {}
				doable = true
				--[[ Check if the selected targets in the group K are valid ]]
				for i, target in ipairs(GetEnemyHeroes()) do
					if Menu.Targets['G'..k]['C'..target.charName] and not Position[target.charName] then
						doable = false
					elseif Menu.Targets['G'..k]['C'..target.charName] and Position[target.charName] then
						table.insert(Points, Position[target.charName])
					end
				end
				if doable then
					CastUltimate(Points, false)
				end
			end
		end
	end
	
	if Menu.Initiate.Enabled then
		for k=1, groupnumber do
			if Menu.Initiate['G'..k] then
				Points = {}
				doable = true
				
				--[[ Check if the selected targets in the group K are valid ]]
				for i, target in ipairs(GetEnemyHeroes()) do
					if Menu.Targets['G'..k]['C'..target.charName] and not Position[target.charName] then
						doable = false
					elseif Menu.Targets['G'..k]['C'..target.charName] and Position[target.charName] then
						table.insert(Points, Position[target.charName])
					end
				end
				if doable then
					CastUltimate(Points, Menu.Initiate.Flash)
				end
			end
		end
	end
	
	if Menu.Chain.Enabled then
		for k=1, groupnumber do
			if Menu.Chain['G'..k] then
				Points = {}
				doable = true
				
				--[[ Check if the selected targets in the group K are valid ]]
				for i, target in ipairs(GetEnemyHeroes()) do
					if Menu.Targets['G'..k]['C'..target.charName] and (not Position[target.charName] or not Immobile[target.charName]) then
						doable = false
					elseif Menu.Targets['G'..k]['C'..target.charName] and Position[target.charName] then
						table.insert(Points, Position[target.charName])
					end
				end
				if doable then
					CastUltimate(Points, Menu.Chain.Flash)
				end
			end
		end
	end
end


--[[Credits to barasia, vadash and viseversa for anti-lag circles]]
function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
	radius = radius or 300
	quality = math.max(8,math.floor(180/math.deg((math.asin((chordlength/(2*radius)))))))
	quality = 2 * math.pi / quality
	radius = radius*.92
	local points = {}
	for theta = 0, 2 * math.pi + quality, quality do
		local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
		points[#points + 1] = D3DXVECTOR2(c.x, c.y)
	end
	DrawLines2(points, width or 1, color or 4294967295)
end

function DrawCircle2(x, y, z, radius, color)
	local vPos1 = Vector(x, y, z)
	local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
	local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
	local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
	if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y })  then
		DrawCircleNextLvl(x, y, z, radius, 1, color, 75)	
	end
end


function OnDraw()
	if debug then
		for i, circle in ipairs(Drawpointsgreen) do
			DrawCircle2(circle.x, circle.y, circle.z, 100, ARGB(255,0,255,0))
		end
		for i, circle in ipairs(Drawpointsred) do
			DrawCircle2(circle.x, circle.y, circle.z, 100, ARGB(255,255,0,0))
		end
		for i, circle in ipairs(Drawpointsblue) do
			DrawCircle2(circle.x, circle.y, circle.z, 100, ARGB(255,0,0,255))
		end
		
	end
end
