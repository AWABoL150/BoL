local version = 2.02
local AUTOUPDATE = false
local SCRIPT_NAME = "Queuer"

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
SourceUpdater(SCRIPT_NAME, version, "raw.github.com", "/honda7/BoL/master/"..SCRIPT_NAME..".lua", SCRIPT_PATH .. GetCurrentEnv().FILE_NAME, "/honda7/BoL/master/VersionFiles/"..SCRIPT_NAME..".version"):CheckUpdate()
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

class "Queuer"
function Queuer:__init()
	AddTickCallback(function() self:OnTick() end)
	self.queue = {}
	self.currentaction = nil
end

function Queuer:OnTick()
	if not self.currentaction and #self.queue > 0 then
		local action = self.queue[1]
		self.currentaction = action
		if self.currentaction.onstartcallback then
			if self.currentaction.onstartcallback() then
				action:start(self)
			end
		else
			action:start()
		end
		
		table.remove(self.queue, 1)
	elseif self.currentaction then
		if self.currentaction:checkfinished() then
			self.currentaction:OnFinish(self)
			self.currentaction = nil
		end
	end
end

function Queuer:AddAction(action, pos)
	table.insert(self.queue, pos or (#self.queue + 1), action)
end

function Queuer:GetLastAction()
	if self.currentaction and #self.queue == 0 then
		return self.currentaction
	elseif #self.queue > 0 then
		return self.queue[#self.queue]
	end
end

function Queuer:ClearQueue()
	self.queue = {}
end

function Queuer:StopCurrentAction()
	self.currentaction = nil
end

function Queuer:Draw()
	if self.currentaction then
		local from = Vector(myHero)
		local to = Vector(myHero)
		
		to = self.currentaction.to and self.currentaction.to or to

		self.currentaction:Draw(from, to)

		for i, action in ipairs(self.queue) do
			from = to
			if action.target and ValidTarget(action.target) then
				action.to = Vector(action.target)
			end
			to = action.to and action.to or to
			action:Draw(from, to)
		end
	end
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

class "MoveQ"
function MoveQ:__init(to)
	self.to = to
end

function MoveQ:start()
	WayPointManager.AddCallback(function(n) self:OnNewWaypoints(n) end)
	self.WaypointsReceived = false
	Packet('S_MOVE',{x = self.to.x, y = self.to.z, type = 2}):send()
end

function MoveQ:checkfinished()
	if self.WaypointsReceived or GetDistanceSqr(myHero.visionPos, self.to) < 400 then
		local waypoints = WayPointManager:GetWayPoints(myHero)
		if GetDistanceSqr(myHero.visionPos, waypoints[#waypoints]) <=  (myHero.ms * (GetLatency()/2000 + 0.1))^2  or #waypoints == 1 then
			return true
		end
	end
	Packet('S_MOVE',{x = self.to.x, y = self.to.z, type = 2}):send()
	return false
end

function MoveQ:OnNewWaypoints(networkID)
	if networkID == myHero.networkID then
		self.WaypointsReceived = true
	end
end

function MoveQ:OnFinish(parent)
end

function MoveQ:Draw(from, to)
	if self.WaypointsReceived then
		local waypoints = WayPointManager:GetWayPoints(myHero)
		for i = 1, #waypoints - 1 do
			from = Vector(waypoints[i].x, 0, waypoints[i].y)
			to = Vector(waypoints[i + 1].x, 0, waypoints[i + 1].y)

			DrawLineBorder3D(from.x, myHero.y, from.z, to.x, myHero.y, to.z, 2, self.color or ARGB(100, 0, 255, 0), 1)
		end
	else
		DrawLineBorder3D(from.x, myHero.y, from.z, to.x, myHero.y, to.z, 2, self.color or ARGB(100, 0, 255, 0), 1)
	end
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

class "AttackQ"
function AttackQ:__init(target)
	self.target = target
	self.to = Vector(target)
end

function AttackQ:start()
	
end

function AttackQ:OnFinish(parent)
end

function AttackQ:checkfinished()
	if not ValidTarget(self.target) then
		return true
	else
		Packet('S_MOVE', {type = 3, x = self.target.x, y = self.target.z, targetNetworkId = self.target.networkID}):send()
	end
	return false
end

function AttackQ:Draw(from, to)
	if ValidTarget(self.target) then
		self.to = Vector(self.target)
	end
	DrawLineBorder3D(from.x, myHero.y, from.z, to.x, myHero.y, to.z, 2, self.color or ARGB(100, 255, 0, 0), 1)
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

class "DelayQ"
function DelayQ:__init(time)
	self.time = time
end

function DelayQ:start()
	self.startTime = os.clock()
end

function DelayQ:checkfinished()
	if (os.clock() - self.startTime >= self.time) then
		return true
	end
	return false
end

function DelayQ:OnFinish(parent)
end

function DelayQ:Draw(from, to)
	if self.startTime then
		DrawText3D(tostring(math.floor((os.clock() - self.startTime)* 1000)), from.x, from.y, from.z, 13, self.color or ARGB(100, 255, 255, 255))
	else
		DrawText3D(tostring(math.floor(self.time * 1000)), from.x, from.y, from.z, 13, self.color or ARGB(100, 255, 255, 255))
	end
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

class "CastToPosQ"
function CastToPosQ:__init(slot, to)
	self.slot = slot
	self.to = to
	self.casted = false
end

function CastToPosQ:start()
	CastSpell(self.slot, self.to.x, self.to.z)
	self.casted = true
end

function CastToPosQ:checkfinished()
	if self.casted and myHero:CanUseSpell(self.slot) ~= READY then
		return true
	end
	return false
end

function CastToPosQ:OnFinish(parent)
end

function CastToPosQ:Draw(from, to)
	DrawLineBorder3D(from.x, myHero.y, from.z, to.x, myHero.y, to.z, 2, self.color or ARGB(100, 0, 0, 255), 1)
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

class "CastToTargetQ"
function CastToTargetQ:__init(slot, target)
	self.to = target
	self.target = target
	self.slot = slot
	self.originalname = myHero:GetSpellData(self.slot).name
end

function CastToTargetQ:start()
end

function CastToTargetQ:checkfinished()
	if myHero:CanUseSpell(self.slot) == READY and not self.casted then
		CastSpell(self.slot, self.target)
		self.casted = true
	end

	if self.casted and (myHero:CanUseSpell(self.slot) ~= READY or myHero:GetSpellData(self.slot).name ~= self.originalname)then
		return true
	end
	return false
end

function CastToTargetQ:OnFinish(parent)
end

function CastToTargetQ:Draw(from, to)
	DrawLineBorder3D(from.x, myHero.y, from.z, to.x, myHero.y, to.z, 2, self.color or ARGB(100, 0, 0, 255), 1)
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

class "RecallQ"
function RecallQ:__init()
	self.to = GetFountain()
	self.finished = false
	self.type = "Recall"
	self.starttime = math.huge
end

function RecallQ:start()
	self.starttime = os.clock()
	CastSpell(RECALL)
end

function RecallQ:OnFinish(parent)
end

function RecallQ:checkfinished()
	return os.clock() - self.starttime > 9
end

function RecallQ:Draw(from, to)
	DrawLineBorder3D(from.x, myHero.y, from.z, to.x, myHero.y, to.z, 2, self.color or ARGB(100, 0, 0, 255), 1)
end


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

class "WaitForObjectQ"
function WaitForObjectQ:__init(name, distance, timeout)
	self.name = name
	self.found = false
	self.startTime = math.huge
	self.timeout = timeout
	self.distancesqr = distance * distance
	AddCreateObjCallback(function(o) self:OnCreateObject(o) end)
end

function WaitForObjectQ:start()
	self.startTime = os.clock()
end

function WaitForObjectQ:OnCreateObject(obj)
	if obj and obj.valid and obj.name and obj.name:lower():find(self.name) and GetDistanceSqr(obj) < self.distancesqr then
		DelayAction(function(o) self:setobject(o) end, 0.0001, {obj})
		self.object = obj
	end
end

function WaitForObjectQ:setobject(o)
	if o.networkID ~= 0 then
		self.object = o
		self.found = true
	end
end

function WaitForObjectQ:OnFinish(parent)
	if (#parent.queue > 0) and self.object then
		parent.queue[1].target = self.object
		parent.queue[1].to = self.object
	end
end

function WaitForObjectQ:checkfinished()
	if (os.clock() - self.startTime) > self.timeout or self.found then
		return true
	end
	return false
end

function WaitForObjectQ:Draw(from, to)
	DrawText3D(tostring(self.name), from.x, from.y, from.z, 13, self.color or ARGB(255, 255, 255, 255))
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

class "WardJumpQ"
function WardJumpQ:__init(wardslot, spellslot, to)
	self.wardslot = wardslot
	self.spellslot = spellslot
	self.to = to
	self.type = 'WardJump'
	self.castward = CastToPosQ(wardslot, to)
	self.waitforward = WaitForObjectQ('ward', 700, 1)
	self.castjump = CastToTargetQ(spellslot, myHero)
	self.p = 1
end

function WardJumpQ:start()
end

function WardJumpQ:checkfinished()
	return true
end

function WardJumpQ:OnFinish(parent)
	if (myHero:CanUseSpell(self.wardslot) == READY) and (myHero:CanUseSpell(self.spellslot) == READY) then
		parent:AddAction(self.castjump, 1)
		parent:AddAction(self.waitforward, 1)
		parent:AddAction(self.castward, 1)
	end
end

function WardJumpQ:Draw(from, to)
	DrawLineBorder3D(from.x, myHero.y, from.z, to.x, myHero.y, to.z, 1, self.color or ARGB(255, 0, 0, 255), 1)
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

class "WaitForJungleMob"
function WaitForJungleMob:__init(distance, timeout)
	distance = distance or 2000
	timeout = timeout or 1
	self.name = name
	self.found = false
	self.startTime = math.huge
	self.timeout = timeout
	self.distancesqr = distance * distance
	self.JungleMinions = minionManager(MINION_JUNGLE, distance, myHero.visionPos, MINION_SORT_MAXHEALTH_DEC)
end

function WaitForJungleMob:start()
	self.startTime = os.clock()
end

function WaitForJungleMob:OnFinish(parent)
	if (#parent.queue > 0) and self.object then
		parent.queue[1].target = self.object
		parent.queue[1].to = self.object
	end
end

function WaitForJungleMob:checkfinished()
	self.JungleMinions:update()
	if (os.clock() - self.startTime) > self.timeout or self.JungleMinions.objects[1] then
		self.object = self.JungleMinions.objects[1]
		return true
	end
	return false
end

function WaitForJungleMob:Draw(from, to)
	DrawText3D(tostring("Jungle Mob"), from.x, from.y, from.z, 13, self.color or ARGB(255, 255, 255, 255))
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

class "WaitUntil"
function WaitUntil:__init(f, args)
	self.f = f
	self.args = args
end

function WaitUntil:start()
end

function WaitUntil:OnFinish(parent)
end

function WaitUntil:checkfinished()
	return self.f(table.unpack(self.args or {}))
end

function WaitUntil:Draw(from, to)
	DrawText3D(tostring("Wait"), from.x, from.y, from.z, 13, self.color or ARGB(255, 255, 255, 255))
end

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


local Q, Menu
local SRadius = 180
local DRadius = 100
local SRadiusSqr = SRadius * SRadius
local RecordLocations = false
local RecordingWards = false
local RecordedLocations = {}
local DrawS = {myHero.charName, 'Wards', 'Flash'}


local JumpSlot = 
{
	['Nidalee'] = _W,
	['Riven'] = _Q,
	['Ezreal'] = _E,
	['Jax'] = _Q,
	['LeeSin'] = _W,
	['Katarina'] = _E,
 	['Yasuo'] = _E,
	['Caitlyn'] = _E, 
	['Shaco'] = _Q,

 	--Not added yet
	['Tryndamere'] = _E,
	['Gragas'] = _E, 

}

local JumpSpots = 
{
	['Shaco'] = 
	{
		{From = Vector(5011, 54.409187316895, 2687),  To = Vector(5647, 54.784610748291, 2965), CastPos = Vector(5400.9018554688, 56.3544921875, 2820.1030273438)},
		{From = Vector(5647, 54.784610748291, 2965),  To = Vector(5101, 54.71484375, 3061), CastPos = Vector(5203.0678710938, 54.410888671875, 2748.9467773438)},
		{From = Vector(7583, 56.866790771484, 4019),  To = Vector(8125, 54.334560394287, 4407), CastPos = Vector(7937.7631835938, 54.445068359375, 4346.1342773438)},
		{From = Vector(8125.146484375, 54.859195709229, 4405.1000976563),  To = Vector(7649, 56.867446899414, 4019), CastPos = Vector(7796.5063476563, 56.868408203125, 4142.1870117188)},
		{From = Vector(10495, 54.86909866333, 6665),  To = Vector(10017, 55.122619628906, 6565), CastPos = Vector(10107.771484375, 55.1220703125, 6562.607421875)},
		{From = Vector(9917, 55.123802185059, 6563),  To = Vector(10293, 54.86909866333, 6713), CastPos = Vector(10237.192382813, 54.869140625, 6643.5561523438)},
		{From = Vector(10819, 70.182464599609, 8827),  To = Vector(10977, 50.348411560059, 9347), CastPos = Vector(10844.538085938, 50.348388671875, 9322.31640625)},
		{From = Vector(10977, 50.348411560059, 9347),  To = Vector(10701, 69.916030883789, 8871), CastPos = Vector(10880.168945313, 71.652587890625, 9038.80859375)},
		{From = Vector(5429, 54.954864501953, 9873),  To = Vector(5007, -63.082122802734, 10049), CastPos = Vector(5011.3798828125, -63.07958984375, 9988.625)},
		{From = Vector(4889, -62.863861083984, 10409),  To = Vector(5281, 54.15657043457, 10661), CastPos = Vector(5201.9067382813, 54.166748046875, 10661.407226563)},
		{From = Vector(5335, 53.978332519531, 10715),  To = Vector(4951, -63.107650756836, 10565), CastPos = Vector(5069.0483398438, -63.10986328125, 10601.42578125)},
		{From = Vector(4109, 52.087505340576, 7897),  To = Vector(3717, 53.708278656006, 7803), CastPos = Vector(3769.6264648438, 53.468505859375, 7773.8334960938)},
		{From = Vector(3717, 53.708278656006, 7803),  To = Vector(3993, 51.903327941895, 7859), CastPos = Vector(3970.0632324219, 51.85205078125, 7840.6127929688)},
		{From = Vector(8589, 56.195137023926, 3941),  To = Vector(8939, -63.263160705566, 4161), CastPos = Vector(8927.6328125, -63.257080078125, 4149.083984375)},
		{From = Vector(8939, -63.263160705566, 4161),  To = Vector(8655, 56.615940093994, 3899), CastPos = Vector(8621.89453125, 56.5458984375, 3865.6467285156)},
		{From = Vector(9045, 66.919609069824, 3295),  To = Vector(9281, -63.257892608643, 3703), CastPos = Vector(9247.3564453125, -63.2578125, 3706.8937988281)},
		{From = Vector(9281, -63.257892608643, 3703),  To = Vector(9165, 66.098937988281, 3335), CastPos = Vector(9164.248046875, 65.85400390625, 3328.4228515625)},
		{From = Vector(10495, 64.500053405762, 2415),  To = Vector(10985, -65.065406799316, 2857), CastPos = Vector(10806.250976563, -67.034423828125, 2723.4584960938)},
		{From = Vector(10899, -64.7412109375, 2963),  To = Vector(10459, 62.758094787598, 2481), CastPos = Vector(10595.377929688, 61.075927734375, 2629.4482421875)},
		{From = Vector(8995, -61.489925384521, 4465),  To = Vector(8649, 54.59614944458, 4623), CastPos = Vector(8650.8046875, 54.597900390625, 4621.4111328125)},
		{From = Vector(8649, 54.59614944458, 4623),  To = Vector(8981, -61.079662322998, 4529), CastPos = Vector(8959.2197265625, -61.072265625, 4548.0546875)},
		{From = Vector(4297, -62.924495697021, 10613),  To = Vector(4001, 52.194904327393, 11053), CastPos = Vector(4029.7243652344, 52.195068359375, 10951.375976563)},
		{From = Vector(4059, 51.933139801025, 11209),  To = Vector(4525, -62.866012573242, 10729), CastPos = Vector(4279.3203125, 0.186279296875, 10898.586914063)},
	},

	['Caitlyn'] =
	{
		{From = Vector(4197, 109.39225769043, 2465),  To = Vector(4687, 54.358558654785, 2459), CastPos = Vector(3611.9838867188, 109.71398925781, 2472.794921875)},
		{From = Vector(4647, 54.378612518311, 2365),  To = Vector(4159, 109.38554382324, 2393), CastPos = Vector(5579.7153320313, 55.28759765625, 2313.5844726563)},
		{From = Vector(7463, 56.865089416504, 4087),  To = Vector(7597, 54.517238616943, 4559), CastPos = Vector(7409.20703125, 56.941162109375, 3899.4633789063)},
		{From = Vector(7447, 53.714031219482, 4565),  To = Vector(7511, 56.865676879883, 4079), CastPos = Vector(7408.326171875, 52.88037109375, 4874.18359375)},
		{From = Vector(8619, 55.915893554688, 4149),  To = Vector(9105, -62.851936340332, 4203), CastPos = Vector(8121.0512695313, 53.953857421875, 4094.1938476563)},
		{From = Vector(9013, -63.287204742432, 4187),  To = Vector(8525, 56.126754760742, 4139), CastPos = Vector(9443.4638671875, -60.514526367188, 4228.6259765625)},
		{From = Vector(9325, 56.302845001221, 3225),  To = Vector(9535, -63.260673522949, 3669), CastPos = Vector(9288.8349609375, 54.651000976563, 3148.8662109375)},
		{From = Vector(9467, -63.259483337402, 3643),  To = Vector(9411, 54.607578277588, 3157), CastPos = Vector(9541.796875, -60.3046875, 4314.146484375)},
		{From = Vector(4755, -63.095085144043, 10703),  To = Vector(5123, 51.134494781494, 11025), CastPos = Vector(4701.42578125, -63.07421875, 10655.81640625)},
		{From = Vector(5085, 51.912288665771, 10967),  To = Vector(4819, -63.007617950439, 10555), CastPos = Vector(5139.7001953125, 50.786376953125, 11051.081054688)},
		{From = Vector(5047, -63.008247375488, 10213),  To = Vector(5537, 54.732528686523, 10173), CastPos = Vector(4655.9096679688, -63.069580078125, 10244.328125)},
		{From = Vector(5435, 54.97688293457, 10105),  To = Vector(4947, -63.088798522949, 10129), CastPos = Vector(5534.8208007813, 54.724853515625, 10099.921875)},
		{From = Vector(7095, 56.018997192383, 8763),  To = Vector(7403, 55.554676055908, 9143), CastPos = Vector(6811.1635742188, 56.019287109375, 8412.2373046875)},
		{From = Vector(7395, 55.606552124023, 9063),  To = Vector(7155, 56.01900100708, 8633), CastPos = Vector(7594.1962890625, 55.398193359375, 9420.564453125)},
		{From = Vector(3697, 53.977474212646, 7153),  To = Vector(3353, 55.313983917236, 7499), CastPos = Vector(3819.1354980469, 53.46240234375, 7026.0556640625)},
		{From = Vector(3353, 55.313983917236, 7499),  To = Vector(3627, 54.09268951416, 7093), CastPos = Vector(3238.12109375, 56.81298828125, 7669.7802734375)},
		{From = Vector(10003, 55.121444702148, 6589),  To = Vector(10473, 54.869094848633, 6727), CastPos = Vector(9918.1357421875, 55.12353515625, 6564.189453125)},
		{From = Vector(10351, 54.86909866333, 6669),  To = Vector(9915, 55.329231262207, 6447), CastPos = Vector(10892.943359375, 54.87158203125, 6944.1708984375)},
		{From = Vector(11495, -57.16189956665, 4015),  To = Vector(11829, 52.005832672119, 4373), CastPos = Vector(11280.94140625, -54.45849609375, 3786.4699707031)},
		{From = Vector(11729, 52.005821228027, 4347),  To = Vector(11515, -56.515480041504, 3977), CastPos = Vector(11818.330078125, 52.005859375, 4655.1650390625)},
		{From = Vector(10401, 4.9428877830505, 3065),  To = Vector(10341, 59.57954788208, 2579), CastPos = Vector(10452.850585938, -20.23681640625, 3489.7875976563)},

	},

	['Yasuo'] = 
	{
		{From = Vector(6897, 55.657649993896, 5665),  To = Vector(6897, 55.657649993896, 5665), CastPos = Vector(6700.81640625, 59.53173828125, 5311.6845703125)},
		{From = Vector(7745, 54.697273254395, 2915),  To = Vector(7745, 54.697273254395, 2915), CastPos = Vector(7894.3901367188, 54.276123046875, 2598.9365234375)},
		{From = Vector(3115, 54.029323577881, 6723),  To = Vector(3115, 54.029323577881, 6723), CastPos = Vector(3287.5073242188, 55.6064453125, 6420.1318359375)},
		{From = Vector(3597, 54.335319519043, 7215),  To = Vector(3597, 54.335319519043, 7215), CastPos = Vector(3583.5910644531, 54.431884765625, 7653.17578125)},
		{From = Vector(4047, 52.053657531738, 7813),  To = Vector(3111.0126953125, 56.369777679443, 7542.96875), CastPos = Vector(3657.2495117188, 54.125732421875, 7576.23046875)},
		{From = Vector(7923, 53.530361175537, 9351),  To = Vector(7924.5834960938, 53.530364990234, 9352.390625), CastPos = Vector(7643.2270507813, 55.2841796875, 9377.166015625)},
		{From = Vector(6247, 54.6325340271, 11513),  To = Vector(6247, 54.6325340271, 11513), CastPos = Vector(6041.3891601563, 39.564697265625, 11835.280273438)},
		{From = Vector(1303, 50.858093261719, 8049),  To = Vector(1301.8870849609, 50.905693054199, 8050.7934570313), CastPos = Vector(1641.4918212891, 54.923828125, 8180.41796875)},
		{From = Vector(9995, 55.122856140137, 6565),  To = Vector(9995, 55.122856140137, 6565), CastPos = Vector(10267.6953125, 54.868896484375, 6786.5400390625)},
		{From = Vector(10685, 55.350112915039, 7259),  To = Vector(10685.19140625, 55.350109100342, 7259.9765625), CastPos = Vector(10926.564453125, 54.87158203125, 6931.2880859375)},
		{From = Vector(6003, 51.673690795898, 5067),  To = Vector(6453, 56.158382415771, 5217), CastPos = Vector(6428.6826171875, 55.96630859375, 5215.4389648438)},
		{From = Vector(12745, 57.225742340088, 6265),  To = Vector(11776.25390625, 54.936988830566, 6338.19921875), CastPos = Vector(12362.098632813, 54.810791015625, 6256.3715820313)},
		{From = Vector(10845, 55.360466003418, 7663),  To = Vector(10845, 55.360462188721, 7663), CastPos = Vector(10709.568359375, 65.37255859375, 7916.1479492188)},
		{From = Vector(10131, 66.661392211914, 8451),  To = Vector(10132.009765625, 66.630798339844, 8452.7470703125), CastPos = Vector(10427.729492188, 66.00244140625, 8095.1313476563)},
		{From = Vector(3849, 55.39518737793, 5917),  To = Vector(3848.0046386719, 55.40189743042, 5916.0048828125), CastPos = Vector(3541.3232421875, 55.61181640625, 6199.46875)},
		{From = Vector(6099.205078125, 53.909534454346, 11015.212890625),  To = Vector(6986.888671875, 53.771095275879, 10910.369140625), CastPos = Vector(6526.3198242188, 54.635498046875, 10808.776367188)},
		{From = Vector(7195, 56.01900100708, 8713),  To = Vector(7195, 56.01900100708, 8713), CastPos = Vector(7224.130859375, 56.019287109375, 8767.552734375)},

	},


	['Jax'] = --WardJumpSpots
	{
		{From = Vector(2269, 108.90149688721, 4243),  To = Vector(2347, 56.319770812988, 4837), CastPos = Vector(2347, 56.319770812988, 4837)},
		{From = Vector(2365, 56.351909637451, 4787),  To = Vector(2285, 108.6291885376, 4225), CastPos = Vector(2285, 108.6291885376, 4225)},
		{From = Vector(4175, 109.3821182251, 2415),  To = Vector(4611, 54.23030090332, 2665), CastPos = Vector(4611, 54.23030090332, 2665)},
		{From = Vector(4597, 54.226581573486, 2665),  To = Vector(4051, 109.57878112793, 2471), CastPos = Vector(4051, 109.57878112793, 2471)},
		{From = Vector(3259, 55.854549407959, 5011),  To = Vector(3447, 55.649208068848, 5565), CastPos = Vector(3446, 0, 5564)},
		{From = Vector(3985.0356445313, 54.17444229126, 6825.4653320313),  To = Vector(3589, 55.610382080078, 6389), CastPos = Vector(3587, 0, 6387)},
		{From = Vector(3447, 55.649208068848, 5565),  To = Vector(3147, 56.551856994629, 5015), CastPos = Vector(3275.7810058594, 55.191650390625, 5187.5068359375)},
		{From = Vector(5021, 54.409656524658, 2491),  To = Vector(5569, 55.287437438965, 2315), CastPos = Vector(5563.6821289063, 55.287109375, 2316.4533691406)},
		{From = Vector(5497, 55.285724639893, 2315),  To = Vector(4997, 54.409217834473, 2615), CastPos = Vector(5143.7133789063, 54.41064453125, 2450.0354003906)},
		{From = Vector(5741.3759765625, 53.291137695313, 3281.7321777344),  To = Vector(6297, 52.041046142578, 3565), CastPos = Vector(6146.5014648438, 51.861083984375, 3447.3549804688)},
		{From = Vector(6297, 52.041049957275, 3565),  To = Vector(5897, 52.809177398682, 3365), CastPos = Vector(5964.6625976563, 52.606689453125, 3390.0422363281)},
		{From = Vector(8503, 56.043384552002, 4051),  To = Vector(9011, -62.780506134033, 4287), CastPos = Vector(9016.869140625, -62.760986328125, 4285.724609375)},
		{From = Vector(8975.4248046875, -63.104015350342, 4275.1416015625),  To = Vector(8523, 55.974411010742, 4007), CastPos = Vector(8523.8203125, 55.979248046875, 4006.0327148438)},
		{From = Vector(9454.3681640625, 53.820995330811, 3171.3386230469),  To = Vector(9513, -63.262584686279, 3703), CastPos = Vector(9514.064453125, -63.260986328125, 3701.3286132813)},
		{From = Vector(9495, -63.258186340332, 3665),  To = Vector(9467, 52.359985351563, 3207), CastPos = Vector(9467.9970703125, 52.404052734375, 3205.7817382813)},
		{From = Vector(10495, 64.500053405762, 2415),  To = Vector(10895, -64.748016357422, 2965), CastPos = Vector(10774.775390625, -66.05908203125, 2876.93359375)},
		{From = Vector(10895, -64.748016357422, 2965),  To = Vector(10445, 62.946357727051, 2465), CastPos = Vector(10572.70703125, 61.18115234375, 2613.291015625)},
		{From = Vector(11839, 52.005802154541, 4297),  To = Vector(11545, -55.301399230957, 3765), CastPos = Vector(11749.751953125, -56.992919921875, 3939.9418945313)},
		{From = Vector(11489.82421875, -55.467296600342, 3916.9665527344),  To = Vector(11743, 52.005805969238, 4311), CastPos = Vector(11743.921875, 52.005859375, 4309.9731445313)},
		{From = Vector(10045, 56.37202835083, 6315),  To = Vector(10645, 54.845199584961, 6315), CastPos = Vector(10476.33203125, 54.844970703125, 6407.541015625)},
		{From = Vector(10645, 54.845199584961, 6315),  To = Vector(10045, 55.140678405762, 6465), CastPos = Vector(10205.741210938, 56.679443359375, 6376.0473632813)},
		{From = Vector(10845, 70.216728210449, 8813),  To = Vector(10995, 50.348411560059, 9363), CastPos = Vector(10952.938476563, 50.348388671875, 9309.9072265625)},
		{From = Vector(10995, 50.348411560059, 9363),  To = Vector(10695, 69.844360351563, 8863), CastPos = Vector(10845.276367188, 71.2275390625, 8990.876953125)},
		{From = Vector(7436.1923828125, 54.481910705566, 5667.4423828125),  To = Vector(7637, -65.159523010254, 6027), CastPos = Vector(7637.1884765625, -65.150390625, 6025.7626953125)},
		{From = Vector(7665.8969726563, -65.009201049805, 6042.0483398438),  To = Vector(7581, 54.033210754395, 5617), CastPos = Vector(7581.41796875, 54.052734375, 5615.9072265625)},
		{From = Vector(4883.0288085938, -63.089008331299, 10155.950195313),  To = Vector(5397, 55.064910888672, 10063), CastPos = Vector(5330.5336914063, 55.233154296875, 10069.807617188)},
		{From = Vector(5507.814453125, 54.77848815918, 10020.806640625),  To = Vector(5047, -63.066371917725, 10163), CastPos = Vector(5077.431640625, -63.0791015625, 10114.29296875)},
		{From = Vector(4797, -63.122077941895, 10663),  To = Vector(5047, 52.083694458008, 10963), CastPos = Vector(5005.5229492188, 51.998046875, 10982.889648438)},
		{From = Vector(8745, -64.69164276123, 6265),  To = Vector(8995, 55.696590423584, 6765), CastPos = Vector(8897.25390625, 55.867431640625, 6686.7260742188)},
		{From = Vector(8995, 55.696594238281, 6765),  To = Vector(8645, -64.875717163086, 6315), CastPos = Vector(8778.8671875, -65.22216796875, 6410.998046875)},
		{From = Vector(3547, 55.608242034912, 6465),  To = Vector(3847, 53.370994567871, 6915), CastPos = Vector(3758.9880371094, 52.94677734375, 6812.87890625)},
		{From = Vector(4997, 54.827495574951, 7663),  To = Vector(5297, -59.408744812012, 8213), CastPos = Vector(5223.3212890625, -57.6865234375, 8128.7407226563)},
		{From = Vector(5297, -59.408744812012, 8213),  To = Vector(5097, 54.817230224609, 7663), CastPos = Vector(5176.3359375, 54.81494140625, 7772.6748046875)},
		{From = Vector(5114.0815429688, 50.592060089111, 11075.94921875),  To = Vector(4747, -63.064979553223, 10713), CastPos = Vector(4869.2333984375, -22.344482421875, 10807.032226563)},
		{From = Vector(2371, 53.364398956299, 10195),  To = Vector(2497, -64.806045532227, 10813), CastPos = Vector(2336.767578125, -64.802978515625, 10768.649414063)},
		{From = Vector(2597, -64.788803100586, 10613),  To = Vector(2347, 53.364402770996, 10213), CastPos = Vector(2419.0732421875, 53.364013671875, 10225.271484375)},
		{From = Vector(1355.9758300781, 36.004623413086, 10164.479492188),  To = Vector(1847, 53.360752105713, 9863), CastPos = Vector(1793.9096679688, 53.156494140625, 9867.8779296875)},
		{From = Vector(1847, 53.360752105713, 9863),  To = Vector(1347, 35.820129394531, 10263), CastPos = Vector(1466.400390625, 35.653564453125, 10153.978515625)},
		{From = Vector(7763, 53.826271057129, 10859),  To = Vector(8095, 49.935401916504, 11113), CastPos = Vector(8064.7504882813, 49.93505859375, 11067.237304688)},
		{From = Vector(8095, 49.935398101807, 11113),  To = Vector(7745, 53.937210083008, 10913), CastPos = Vector(7859.3388671875, 53.938720703125, 10934.78125)},
		{From = Vector(3347, -38.66491317749, 11363),  To = Vector(3747, 45.11442565918, 11813), CastPos = Vector(3692.8688964844, 44.678955078125, 11803.952148438)},
		{From = Vector(3747, 45.114429473877, 11813),  To = Vector(3297, -50.072170257568, 11363), CastPos = Vector(3377.8547363281, -20.74267578125, 11477.685546875)},
		{From = Vector(9458.8212890625, 52.484420776367, 11716.221679688),  To = Vector(9873, 106.22341918945, 11931), CastPos = Vector(9874.8251953125, 106.22338867188, 11932.614257813)},
		{From = Vector(5147, 43.582534790039, 11463),  To = Vector(5299, 39.659278869629, 12043), CastPos = Vector(5309.7690429688, 39.71240234375, 12045.11328125)},
		{From = Vector(5299, 39.659275054932, 12043),  To = Vector(5097, 43.239910125732, 11513), CastPos = Vector(5201.3051757813, 41.331298828125, 11547.881835938)},
		{From = Vector(6397, 54.634998321533, 10513),  To = Vector(5797, 54.012874603271, 10663), CastPos = Vector(5984.0434570313, 54.227783203125, 10481.641601563)},

	},

	['Ezreal'] = 
	{
		{From = Vector(4997, 54.408828735352, 2815),  To = Vector(5639, 54.840366363525, 2959), CastPos = Vector(5579, 0, 2837)},
		{From = Vector(5697, 54.939357757568, 2865),  To = Vector(5011, 54.399696350098, 3001), CastPos = Vector(5015, 0, 2744)},
		{From = Vector(7045, 54.861854553223, 2065),  To = Vector(6661, 52.592800140381, 1479), CastPos = Vector(6788, 0, 1555)},
		{From = Vector(6655, 52.592678070068, 1465),  To = Vector(6991, 55.036582946777, 2113), CastPos = Vector(6799, 0, 2167)},
		{From = Vector(11045, -65.04175567627, 2815),  To = Vector(10507, 64.480125427246, 2421), CastPos = Vector(10609, 0, 2400)},
		{From = Vector(10521, 66.618141174316, 2339),  To = Vector(11027, -65.386871337891, 2797), CastPos = Vector(11106, 0, 2834)},
		{From = Vector(9695, -63.170677185059, 3715),  To = Vector(9973, 51.627056121826, 3133), CastPos = Vector(9814, 0, 3209)},
		{From = Vector(3197, 56.234931945801, 5015),  To = Vector(3445, 55.649192810059, 5565), CastPos = Vector(3445, 55.649192810059, 5565)},
		{From = Vector(3391, 55.644214630127, 5613),  To = Vector(3119, 56.527641296387, 5079), CastPos = Vector(3119, 56.527641296387, 5079)},
		{From = Vector(4521, 53.784439086914, 6817),  To = Vector(5083, 54.800933837891, 7249), CastPos = Vector(5083, 54.800933837891, 7249)},
		{From = Vector(5849, 54.114547729492, 10109),  To = Vector(6383, 54.634998321533, 10461), CastPos = Vector(6383, 54.634998321533, 10461)},
		{From = Vector(6447, 54.634998321533, 10463),  To = Vector(5817, 53.700656890869, 10543), CastPos = Vector(5817, 53.700656890869, 10543)},
		{From = Vector(5053, 54.800956726074, 7261),  To = Vector(4563, 53.782844543457, 6869), CastPos = Vector(4563, 53.782844543457, 6869)},
		{From = Vector(5197, 54.956550598145, 6265),  To = Vector(4565, 53.788501739502, 6849), CastPos = Vector(4565, 53.788501739502, 6849)},
		{From = Vector(3897, 52.125400543213, 11013),  To = Vector(4073, -63.048614501953, 10437), CastPos = Vector(4073, -63.048614501953, 10437)},
		{From = Vector(4123, -63.025787353516, 10465),  To = Vector(3899, 51.787658691406, 11003), CastPos = Vector(3899, 51.787658691406, 11003)},
		{From = Vector(2747, -10.985368728638, 11813),  To = Vector(3389, 31.212337493896, 12257), CastPos = Vector(3389, 31.212337493896, 12257)},
		{From = Vector(3389, 31.212337493896, 12257),  To = Vector(2755, -11.011236190796, 11819), CastPos = Vector(2755, -11.011236190796, 11819)},
	},

	['Nidalee'] = 
	{
		{From = Vector(6478.0454101563, -64.045028686523, 8342.501953125),  To = Vector(6751, 56.019004821777, 8633), CastPos = Vector(6751, 56.019004821777, 8633)},
		{From = Vector(6447, 56.018882751465, 8663),  To = Vector(6413, -62.786361694336, 8289), CastPos = Vector(6413, -62.786361694336, 8289)},
		{From = Vector(6195.8334960938, -65.304061889648, 8559.810546875),  To = Vector(6327, 56.517200469971, 8913), CastPos = Vector(6327, 56.517200469971, 8913)},
		{From = Vector(7095, 56.018997192383, 8763),  To = Vector(7337, 55.616943359375, 9047), CastPos = Vector(7337, 55.616943359375, 9047)},
		{From = Vector(7269, 55.611968994141, 9055),  To = Vector(7027, 56.018997192383, 8767), CastPos = Vector(7027, 56.018997192383, 8767)},
		{From = Vector(5407, 55.045528411865, 10095),  To = Vector(5033, -63.082427978516, 10119), CastPos = Vector(5033, -63.082427978516, 10119)},
		{From = Vector(5047, -63.08129119873, 10113),  To = Vector(5423, 55.007797241211, 10109), CastPos = Vector(5423, 55.007797241211, 10109)},
		{From = Vector(4747, -62.445854187012, 9463),  To = Vector(4743, -63.093593597412, 9837), CastPos = Vector(4743, -63.093593597412, 9837)},
		{From = Vector(4769, -63.086654663086, 9677),  To = Vector(4775, -63.474864959717, 9301), CastPos = Vector(4775, -63.474864959717, 9301)},
		{From = Vector(6731, -64.655540466309, 8089),  To = Vector(7095, 56.051624298096, 8171), CastPos = Vector(7095, 56.051624298096, 8171)},
		{From = Vector(7629.0434570313, 55.042400360107, 9462.6982421875),  To = Vector(8019, 53.530429840088, 9467), CastPos = Vector(8019, 53.530429840088, 9467)},
		{From = Vector(7994.2685546875, 53.530174255371, 9477.142578125),  To = Vector(7601, 55.379856109619, 9441), CastPos = Vector(7601, 55.379856109619, 9441)},
		{From = Vector(6147, 54.117427825928, 11063),  To = Vector(6421, 54.63500213623, 10805), CastPos = Vector(6421, 54.63500213623, 10805)},
		{From = Vector(5952.1977539063, 54.240119934082, 11382.287109375),  To = Vector(5889, 39.546829223633, 11773), CastPos = Vector(5889, 39.546829223633, 11773)},
		{From = Vector(6003.1401367188, 39.562377929688, 11827.516601563),  To = Vector(6239, 54.632926940918, 11479), CastPos = Vector(6239, 54.632926940918, 11479)},
		{From = Vector(3947, 51.929698944092, 8013),  To = Vector(3647, 54.027297973633, 7789), CastPos = Vector(3647, 54.027297973633, 7789)},
		{From = Vector(1597, 54.923656463623, 8463),  To = Vector(1223, 50.640468597412, 8455), CastPos = Vector(1223, 50.640468597412, 8455)},
		{From = Vector(1247, 50.737510681152, 8413),  To = Vector(1623, 54.923782348633, 8387), CastPos = Vector(1623, 54.923782348633, 8387)},
		{From = Vector(2440.49609375, 53.364398956299, 10038.1796875),  To = Vector(2827, -64.97053527832, 10205), CastPos = Vector(2827, -64.97053527832, 10205)},
		{From = Vector(2797, -65.165946960449, 10213),  To = Vector(2457, 53.364398956299, 10055), CastPos = Vector(2457, 53.364398956299, 10055)},
		{From = Vector(2797, 53.640556335449, 9563),  To = Vector(3167, -63.810096740723, 9625), CastPos = Vector(3167, -63.810096740723, 9625)},
		{From = Vector(3121.9699707031, -63.448329925537, 9574.16015625),  To = Vector(2755, 53.722351074219, 9409), CastPos = Vector(2755, 53.722351074219, 9409)},
		{From = Vector(3447, 55.021110534668, 7463),  To = Vector(3581, 54.248985290527, 7113), CastPos = Vector(3581, 54.248985290527, 7113)},
		{From = Vector(3527, 54.452239990234, 7151),  To = Vector(3372.861328125, 55.13143157959, 7507.2211914063), CastPos = Vector(3372.861328125, 55.13143157959, 7507.2211914063)},
		{From = Vector(2789, 55.241321563721, 6085),  To = Vector(2445, 60.189605712891, 5941), CastPos = Vector(2445, 60.189605712891, 5941)},
		{From = Vector(2573, 60.192783355713, 5915),  To = Vector(2911, 55.503971099854, 6081), CastPos = Vector(2911, 55.503971099854, 6081)},
		{From = Vector(3005, 55.631782531738, 5797),  To = Vector(2715, 60.190528869629, 5561), CastPos = Vector(2715, 60.190528869629, 5561)},
		{From = Vector(2697, 60.190807342529, 5615),  To = Vector(2943, 55.629695892334, 5901), CastPos = Vector(2943, 55.629695892334, 5901)},
		{From = Vector(3894.1960449219, 53.4684715271, 7192.3720703125),  To = Vector(3641, 54.714691162109, 7495), CastPos = Vector(3641, 54.714691162109, 7495)},
		{From = Vector(3397, 55.605663299561, 6515),  To = Vector(3363, 53.412925720215, 6889), CastPos = Vector(3363, 53.412925720215, 6889)},
		{From = Vector(3347, 53.312397003174, 6865),  To = Vector(3343, 55.605716705322, 6491), CastPos = Vector(3343, 55.605716705322, 6491)},
		{From = Vector(3705, 53.67945098877, 7829),  To = Vector(4009, 51.996047973633, 8049), CastPos = Vector(4009, 51.996047973633, 8049)},
		{From = Vector(7581, -65.361351013184, 5983),  To = Vector(7417, 54.716590881348, 5647), CastPos = Vector(7417, 54.716590881348, 5647)},
		{From = Vector(7495, 53.744125366211, 5753),  To = Vector(7731, -64.48851776123, 6045), CastPos = Vector(7731, -64.48851776123, 6045)},
		{From = Vector(7345, -52.344753265381, 6165),  To = Vector(7249, 55.641929626465, 5803), CastPos = Vector(7249, 55.641929626465, 5803)},
		{From = Vector(7665.0073242188, 54.999004364014, 5645.7431640625),  To = Vector(7997, -62.778995513916, 5861), CastPos = Vector(7997, -62.778995513916, 5861)},
		{From = Vector(7995, -61.163398742676, 5715),  To = Vector(7709, 56.321662902832, 5473), CastPos = Vector(7709, 56.321662902832, 5473)},
		{From = Vector(8653, 55.073780059814, 4441),  To = Vector(9027, -61.594711303711, 4425), CastPos = Vector(9027, -61.594711303711, 4425)},
		{From = Vector(8931, -62.612571716309, 4375),  To = Vector(8557, 55.506855010986, 4401), CastPos = Vector(8557, 55.506855010986, 4401)},
		{From = Vector(8645, 55.960289001465, 4115),  To = Vector(9005, -63.280235290527, 4215), CastPos = Vector(9005, -63.280235290527, 4215)},
		{From = Vector(8948.08203125, -63.252712249756, 4116.5078125),  To = Vector(8605, 56.22159576416, 3953), CastPos = Vector(8605, 56.22159576416, 3953)},
		{From = Vector(9345, 67.37971496582, 2815),  To = Vector(9375, 67.509948730469, 2443), CastPos = Vector(9375, 67.509948730469, 2443)},
		{From = Vector(9355, 67.649841308594, 2537),  To = Vector(9293, 63.953853607178, 2909), CastPos = Vector(9293, 63.953853607178, 2909)},
		{From = Vector(8027, 56.071315765381, 3029),  To = Vector(8071, 54.276405334473, 2657), CastPos = Vector(8071, 54.276405334473, 2657)},
		{From = Vector(7995.0229492188, 54.276401519775, 2664.0703125),  To = Vector(7985, 55.659393310547, 3041), CastPos = Vector(7985, 55.659393310547, 3041)},
		{From = Vector(5785, 54.918552398682, 5445),  To = Vector(5899, 51.673694610596, 5089), CastPos = Vector(5899, 51.673694610596, 5089)},
		{From = Vector(5847, 51.673683166504, 5065),  To = Vector(5683, 54.923862457275, 5403), CastPos = Vector(5683, 54.923862457275, 5403)},
		{From = Vector(6047, 51.67359161377, 4865),  To = Vector(6409, 51.673400878906, 4765), CastPos = Vector(6409, 51.673400878906, 4765)},
		{From = Vector(6347, 51.673400878906, 4765),  To = Vector(5983, 51.673580169678, 4851), CastPos = Vector(5983, 51.673580169678, 4851)},
		{From = Vector(6995, 55.738128662109, 5615),  To = Vector(6701, 61.461639404297, 5383), CastPos = Vector(6701, 61.461639404297, 5383)},
		{From = Vector(6697, 61.083110809326, 5369),  To = Vector(6889, 55.628131866455, 5693), CastPos = Vector(6889, 55.628131866455, 5693)},
		{From = Vector(11245, -62.793098449707, 4515),  To = Vector(11585, 52.104347229004, 4671), CastPos = Vector(11585, 52.104347229004, 4671)},
		{From = Vector(11491.91015625, 52.506042480469, 4629.763671875),  To = Vector(11143, -63.063579559326, 4493), CastPos = Vector(11143, -63.063579559326, 4493)},
		{From = Vector(11395, -62.597496032715, 4315),  To = Vector(11579, 51.962089538574, 4643), CastPos = Vector(11579, 51.962089538574, 4643)},
		{From = Vector(11245, 53.017200469971, 4915),  To = Vector(10869, -63.132637023926, 4907), CastPos = Vector(10869, -63.132637023926, 4907)},
		{From = Vector(10923.66015625, -63.288948059082, 4853.9931640625),  To = Vector(11295, 53.402942657471, 4913), CastPos = Vector(11295, 53.402942657471, 4913)},
		{From = Vector(10595, 54.870422363281, 6965),  To = Vector(10351, 55.198459625244, 7249), CastPos = Vector(10351, 55.198459625244, 7249)},
		{From = Vector(10415, 55.269580841064, 7277),  To = Vector(10609, 54.870502471924, 6957), CastPos = Vector(10609, 54.870502471924, 6957)},
		{From = Vector(12645, 53.343021392822, 4615),  To = Vector(12349, 56.222766876221, 4849), CastPos = Vector(12349, 56.222766876221, 4849)},
		{From = Vector(12395, 52.525123596191, 4765),  To = Vector(12681, 53.853294372559, 4525), CastPos = Vector(12681, 53.853294372559, 4525)},
		{From = Vector(11918.497070313, 57.399909973145, 5471),  To = Vector(11535, 54.801097869873, 5471), CastPos = Vector(11535, 54.801097869873, 5471)},
		{From = Vector(11593, 54.610706329346, 5501),  To = Vector(11967, 56.541202545166, 5477), CastPos = Vector(11967, 56.541202545166, 5477)},
		{From = Vector(11140.984375, 65.858421325684, 8432.9384765625),  To = Vector(11487, 53.453464508057, 8625), CastPos = Vector(11487, 53.453464508057, 8625)},
		{From = Vector(11420.7578125, 53.453437805176, 8608.6923828125),  To = Vector(11107, 65.090522766113, 8403), CastPos = Vector(11107, 65.090522766113, 8403)},
		{From = Vector(11352.48046875, 57.916156768799, 8007.10546875),  To = Vector(11701, 55.458843231201, 8165), CastPos = Vector(11701, 55.458843231201, 8165)},
		{From = Vector(11631, 55.45885848999, 8133),  To = Vector(11287, 58.037368774414, 7979), CastPos = Vector(11287, 58.037368774414, 7979)},
		{From = Vector(10545, 65.745803833008, 7913),  To = Vector(10555, 55.338600158691, 7537), CastPos = Vector(10555, 55.338600158691, 7537)},
		{From = Vector(10795, 55.354972839355, 7613),  To = Vector(10547, 65.771072387695, 7893), CastPos = Vector(10547, 65.771072387695, 7893)},
		{From = Vector(10729, 55.352409362793, 7307),  To = Vector(10785, 54.87170791626, 6937), CastPos = Vector(10785, 54.87170791626, 6937)},
		{From = Vector(10745, 54.871494293213, 6965),  To = Vector(10647, 55.350120544434, 7327), CastPos = Vector(10647, 55.350120544434, 7327)},
		{From = Vector(10099, 66.309921264648, 8443),  To = Vector(10419, 66.106910705566, 8249), CastPos = Vector(10419, 66.106910705566, 8249)},
		{From = Vector(9203, 63.777507781982, 3309),  To = Vector(9359, -63.260040283203, 3651), CastPos = Vector(9359, -63.260040283203, 3651)},
		{From = Vector(9327, -63.258842468262, 3675),  To = Vector(9185, 65.192367553711, 3329), CastPos = Vector(9185, 65.192367553711, 3329)},
		{From = Vector(10045, 55.140678405762, 6465),  To = Vector(10353, 54.869094848633, 6679), CastPos = Vector(10353, 54.869094848633, 6679)},
		{From = Vector(10441.002929688, 65.793014526367, 8315.2333984375),  To = Vector(10133, 64.52165222168, 8529), CastPos = Vector(10133, 64.52165222168, 8529)},
		{From = Vector(8323, 54.89501953125, 9137),  To = Vector(8207, 53.530456542969, 9493), CastPos = Vector(8207, 53.530456542969, 9493)},
		{From = Vector(8295, 53.530418395996, 9363),  To = Vector(8359, 54.895038604736, 8993), CastPos = Vector(8359, 54.895038604736, 8993)},
		{From = Vector(8495, 52.768348693848, 9763),  To = Vector(8401, 53.643203735352, 10125), CastPos = Vector(8401, 53.643203735352, 10125)},
		{From = Vector(8419, 53.59920501709, 9997),  To = Vector(8695, 51.417175292969, 9743), CastPos = Vector(8695, 51.417175292969, 9743)},
		{From = Vector(7145, 55.597702026367, 5965),  To = Vector(7413, -66.513969421387, 6229), CastPos = Vector(7413, -66.513969421387, 6229)},
		{From = Vector(6947, 56.01900100708, 8213),  To = Vector(6621, -62.816535949707, 8029), CastPos = Vector(6621, -62.816535949707, 8029)},
		{From = Vector(6397, 54.634998321533, 10813),  To = Vector(6121, 54.092365264893, 11065), CastPos = Vector(6121, 54.092365264893, 11065)},
		{From = Vector(6247, 54.6325340271, 11513),  To = Vector(6053, 39.563938140869, 11833), CastPos = Vector(6053, 39.563938140869, 11833)},
		{From = Vector(4627, 41.618049621582, 11897),  To = Vector(4541, 51.561706542969, 11531), CastPos = Vector(4541, 51.561706542969, 11531)},
		{From = Vector(5179, 53.036727905273, 10839),  To = Vector(4881, -63.11701965332, 10611), CastPos = Vector(4881, -63.11701965332, 10611)},
		{From = Vector(4897, -63.125648498535, 10613),  To = Vector(5177, 52.773872375488, 10863), CastPos = Vector(5177, 52.773872375488, 10863)},
		{From = Vector(11367, 50.348838806152, 9751),  To = Vector(11479, 106.51720428467, 10107), CastPos = Vector(11479, 106.51720428467, 10107)},
		{From = Vector(11489, 106.53769683838, 10093),  To = Vector(11403, 50.349449157715, 9727), CastPos = Vector(11403, 50.349449157715, 9727)},
		{From = Vector(12175, 106.80973052979, 9991),  To = Vector(12143, 50.354927062988, 9617), CastPos = Vector(12143, 50.354927062988, 9617)},
		{From = Vector(12155, 50.354919433594, 9623),  To = Vector(12123, 106.81489562988, 9995), CastPos = Vector(12123, 106.81489562988, 9995)},
		{From = Vector(9397, 52.484146118164, 12037),  To = Vector(9769, 106.21959686279, 12077), CastPos = Vector(9769, 106.21959686279, 12077)},
		{From = Vector(9745, 106.2202835083, 12063),  To = Vector(9373, 52.484580993652, 12003), CastPos = Vector(9373, 52.484580993652, 12003)},
		{From = Vector(9345, 52.689178466797, 12813),  To = Vector(9719, 106.20919799805, 12805), CastPos = Vector(9719, 106.20919799805, 12805)},
		{From = Vector(4171, 109.72004699707, 2839),  To = Vector(4489, 54.030017852783, 3041), CastPos = Vector(4489, 54.030017852783, 3041)},
		{From = Vector(4473, 54.04020690918, 3009),  To = Vector(4115, 110.06342315674, 2901), CastPos = Vector(4115, 110.06342315674, 2901)},
		{From = Vector(2669, 105.9382019043, 4281),  To = Vector(2759, 57.061370849609, 4647), CastPos = Vector(2759, 57.061370849609, 4647)},
		{From = Vector(2761, 57.062965393066, 4653),  To = Vector(2681, 106.2310256958, 4287), CastPos = Vector(2681, 106.2310256958, 4287)},
		{From = Vector(1623, 108.56233215332, 4487),  To = Vector(1573, 56.13228225708, 4859), CastPos = Vector(1573, 56.13228225708, 4859)},
		{From = Vector(1573, 56.048126220703, 4845),  To = Vector(1589, 108.56234741211, 4471), CastPos = Vector(1589, 108.56234741211, 4471)},
		{From = Vector(2355.4450683594, 60.167724609375, 6366.453125),  To = Vector(2731, 54.617771148682, 6355), CastPos = Vector(2731, 54.617771148682, 6355)},
		{From = Vector(2669, 54.488224029541, 6363),  To = Vector(2295, 60.163955688477, 6371), CastPos = Vector(2295, 60.163955688477, 6371)},
		{From = Vector(2068.5336914063, 54.921718597412, 8898.5322265625),  To = Vector(2457, 53.765918731689, 8967), CastPos = Vector(2457, 53.765918731689, 8967)},
		{From = Vector(2447, 53.763805389404, 8913),  To = Vector(2099, 54.922241210938, 8775), CastPos = Vector(2099, 54.922241210938, 8775)},
		{From = Vector(1589, 49.631057739258, 9661),  To = Vector(1297, 38.928337097168, 9895), CastPos = Vector(1297, 38.928337097168, 9895)},
		{From = Vector(1347, 39.538192749023, 9813),  To = Vector(1609, 50.499561309814, 9543), CastPos = Vector(1609, 50.499561309814, 9543)},
		{From = Vector(3997, -63.152000427246, 10213),  To = Vector(3627, -64.785446166992, 10159), CastPos = Vector(3627, -64.785446166992, 10159)},
		{From = Vector(3709, -63.07014465332, 10171),  To = Vector(4085, -63.139434814453, 10175), CastPos = Vector(4085, -63.139434814453, 10175)},
		{From = Vector(9695, 106.20919799805, 12813),  To = Vector(9353, 95.629013061523, 12965), CastPos = Vector(9353, 95.629013061523, 12965)},
		{From = Vector(5647, 55.136940002441, 9563),  To = Vector(5647, -65.224411010742, 9187), CastPos = Vector(5647, -65.224411010742, 9187)},
		{From = Vector(2315, 108.66681671143, 4377),  To = Vector(2403, 56.444217681885, 4743), CastPos = Vector(2403, 56.444217681885, 4743)},
		{From = Vector(10345, 54.86909866333, 6665),  To = Vector(10009, 55.126476287842, 6497), CastPos = Vector(10009, 55.126476287842, 6497)},
		{From = Vector(12419, 54.801849365234, 6119),  To = Vector(12787, 57.748607635498, 6181), CastPos = Vector(12787, 57.748607635498, 6181)},
		{From = Vector(12723, 57.326282501221, 6253),  To = Vector(12393, 54.80948638916, 6075), CastPos = Vector(12393, 54.80948638916, 6075)},

	},

	['Riven'] = 
	{
		{From = Vector(6478.0454101563, -64.045028686523, 8342.501953125),  To = Vector(6751, 56.019004821777, 8633), CastPos = Vector(6751, 56.019004821777, 8633)},
		{From = Vector(6447, 56.018882751465, 8663),  To = Vector(6413, -62.786361694336, 8289), CastPos = Vector(6413, -62.786361694336, 8289)},
		{From = Vector(6195.8334960938, -65.304061889648, 8559.810546875),  To = Vector(6327, 56.517200469971, 8913), CastPos = Vector(6327, 56.517200469971, 8913)},
		{From = Vector(7095, 56.018997192383, 8763),  To = Vector(7337, 55.616943359375, 9047), CastPos = Vector(7337, 55.616943359375, 9047)},
		{From = Vector(7269, 55.611968994141, 9055),  To = Vector(7027, 56.018997192383, 8767), CastPos = Vector(7027, 56.018997192383, 8767)},
		{From = Vector(5407, 55.045528411865, 10095),  To = Vector(5033, -63.082427978516, 10119), CastPos = Vector(5033, -63.082427978516, 10119)},
		{From = Vector(5047, -63.08129119873, 10113),  To = Vector(5423, 55.007797241211, 10109), CastPos = Vector(5423, 55.007797241211, 10109)},
		{From = Vector(4747, -62.445854187012, 9463),  To = Vector(4743, -63.093593597412, 9837), CastPos = Vector(4743, -63.093593597412, 9837)},
		{From = Vector(4769, -63.086654663086, 9677),  To = Vector(4775, -63.474864959717, 9301), CastPos = Vector(4775, -63.474864959717, 9301)},
		{From = Vector(6731, -64.655540466309, 8089),  To = Vector(7095, 56.051624298096, 8171), CastPos = Vector(7095, 56.051624298096, 8171)},
		{From = Vector(7629.0434570313, 55.042400360107, 9462.6982421875),  To = Vector(8019, 53.530429840088, 9467), CastPos = Vector(8019, 53.530429840088, 9467)},
		{From = Vector(7994.2685546875, 53.530174255371, 9477.142578125),  To = Vector(7601, 55.379856109619, 9441), CastPos = Vector(7601, 55.379856109619, 9441)},
		{From = Vector(6147, 54.117427825928, 11063),  To = Vector(6421, 54.63500213623, 10805), CastPos = Vector(6421, 54.63500213623, 10805)},
		{From = Vector(5952.1977539063, 54.240119934082, 11382.287109375),  To = Vector(5889, 39.546829223633, 11773), CastPos = Vector(5889, 39.546829223633, 11773)},
		{From = Vector(6003.1401367188, 39.562377929688, 11827.516601563),  To = Vector(6239, 54.632926940918, 11479), CastPos = Vector(6239, 54.632926940918, 11479)},
		{From = Vector(3947, 51.929698944092, 8013),  To = Vector(3647, 54.027297973633, 7789), CastPos = Vector(3647, 54.027297973633, 7789)},
		{From = Vector(1597, 54.923656463623, 8463),  To = Vector(1223, 50.640468597412, 8455), CastPos = Vector(1223, 50.640468597412, 8455)},
		{From = Vector(1247, 50.737510681152, 8413),  To = Vector(1623, 54.923782348633, 8387), CastPos = Vector(1623, 54.923782348633, 8387)},
		{From = Vector(2440.49609375, 53.364398956299, 10038.1796875),  To = Vector(2827, -64.97053527832, 10205), CastPos = Vector(2827, -64.97053527832, 10205)},
		{From = Vector(2797, -65.165946960449, 10213),  To = Vector(2457, 53.364398956299, 10055), CastPos = Vector(2457, 53.364398956299, 10055)},
		{From = Vector(2797, 53.640556335449, 9563),  To = Vector(3167, -63.810096740723, 9625), CastPos = Vector(3167, -63.810096740723, 9625)},
		{From = Vector(3121.9699707031, -63.448329925537, 9574.16015625),  To = Vector(2755, 53.722351074219, 9409), CastPos = Vector(2755, 53.722351074219, 9409)},
		{From = Vector(3447, 55.021110534668, 7463),  To = Vector(3581, 54.248985290527, 7113), CastPos = Vector(3581, 54.248985290527, 7113)},
		{From = Vector(3527, 54.452239990234, 7151),  To = Vector(3372.861328125, 55.13143157959, 7507.2211914063), CastPos = Vector(3372.861328125, 55.13143157959, 7507.2211914063)},
		{From = Vector(2789, 55.241321563721, 6085),  To = Vector(2445, 60.189605712891, 5941), CastPos = Vector(2445, 60.189605712891, 5941)},
		{From = Vector(2573, 60.192783355713, 5915),  To = Vector(2911, 55.503971099854, 6081), CastPos = Vector(2911, 55.503971099854, 6081)},
		{From = Vector(3005, 55.631782531738, 5797),  To = Vector(2715, 60.190528869629, 5561), CastPos = Vector(2715, 60.190528869629, 5561)},
		{From = Vector(2697, 60.190807342529, 5615),  To = Vector(2943, 55.629695892334, 5901), CastPos = Vector(2943, 55.629695892334, 5901)},
		{From = Vector(3894.1960449219, 53.4684715271, 7192.3720703125),  To = Vector(3641, 54.714691162109, 7495), CastPos = Vector(3641, 54.714691162109, 7495)},
		{From = Vector(3397, 55.605663299561, 6515),  To = Vector(3363, 53.412925720215, 6889), CastPos = Vector(3363, 53.412925720215, 6889)},
		{From = Vector(3347, 53.312397003174, 6865),  To = Vector(3343, 55.605716705322, 6491), CastPos = Vector(3343, 55.605716705322, 6491)},
		{From = Vector(3705, 53.67945098877, 7829),  To = Vector(4009, 51.996047973633, 8049), CastPos = Vector(4009, 51.996047973633, 8049)},
		{From = Vector(7581, -65.361351013184, 5983),  To = Vector(7417, 54.716590881348, 5647), CastPos = Vector(7417, 54.716590881348, 5647)},
		{From = Vector(7495, 53.744125366211, 5753),  To = Vector(7731, -64.48851776123, 6045), CastPos = Vector(7731, -64.48851776123, 6045)},
		{From = Vector(7345, -52.344753265381, 6165),  To = Vector(7249, 55.641929626465, 5803), CastPos = Vector(7249, 55.641929626465, 5803)},
		{From = Vector(7665.0073242188, 54.999004364014, 5645.7431640625),  To = Vector(7997, -62.778995513916, 5861), CastPos = Vector(7997, -62.778995513916, 5861)},
		{From = Vector(7995, -61.163398742676, 5715),  To = Vector(7709, 56.321662902832, 5473), CastPos = Vector(7709, 56.321662902832, 5473)},
		{From = Vector(8653, 55.073780059814, 4441),  To = Vector(9027, -61.594711303711, 4425), CastPos = Vector(9027, -61.594711303711, 4425)},
		{From = Vector(8931, -62.612571716309, 4375),  To = Vector(8557, 55.506855010986, 4401), CastPos = Vector(8557, 55.506855010986, 4401)},
		{From = Vector(8645, 55.960289001465, 4115),  To = Vector(9005, -63.280235290527, 4215), CastPos = Vector(9005, -63.280235290527, 4215)},
		{From = Vector(8948.08203125, -63.252712249756, 4116.5078125),  To = Vector(8605, 56.22159576416, 3953), CastPos = Vector(8605, 56.22159576416, 3953)},
		{From = Vector(9345, 67.37971496582, 2815),  To = Vector(9375, 67.509948730469, 2443), CastPos = Vector(9375, 67.509948730469, 2443)},
		{From = Vector(9355, 67.649841308594, 2537),  To = Vector(9293, 63.953853607178, 2909), CastPos = Vector(9293, 63.953853607178, 2909)},
		{From = Vector(8027, 56.071315765381, 3029),  To = Vector(8071, 54.276405334473, 2657), CastPos = Vector(8071, 54.276405334473, 2657)},
		{From = Vector(7995.0229492188, 54.276401519775, 2664.0703125),  To = Vector(7985, 55.659393310547, 3041), CastPos = Vector(7985, 55.659393310547, 3041)},
		{From = Vector(5785, 54.918552398682, 5445),  To = Vector(5899, 51.673694610596, 5089), CastPos = Vector(5899, 51.673694610596, 5089)},
		{From = Vector(5847, 51.673683166504, 5065),  To = Vector(5683, 54.923862457275, 5403), CastPos = Vector(5683, 54.923862457275, 5403)},
		{From = Vector(6047, 51.67359161377, 4865),  To = Vector(6409, 51.673400878906, 4765), CastPos = Vector(6409, 51.673400878906, 4765)},
		{From = Vector(6347, 51.673400878906, 4765),  To = Vector(5983, 51.673580169678, 4851), CastPos = Vector(5983, 51.673580169678, 4851)},
		{From = Vector(6995, 55.738128662109, 5615),  To = Vector(6701, 61.461639404297, 5383), CastPos = Vector(6701, 61.461639404297, 5383)},
		{From = Vector(6697, 61.083110809326, 5369),  To = Vector(6889, 55.628131866455, 5693), CastPos = Vector(6889, 55.628131866455, 5693)},
		{From = Vector(11245, -62.793098449707, 4515),  To = Vector(11585, 52.104347229004, 4671), CastPos = Vector(11585, 52.104347229004, 4671)},
		{From = Vector(11491.91015625, 52.506042480469, 4629.763671875),  To = Vector(11143, -63.063579559326, 4493), CastPos = Vector(11143, -63.063579559326, 4493)},
		{From = Vector(11395, -62.597496032715, 4315),  To = Vector(11579, 51.962089538574, 4643), CastPos = Vector(11579, 51.962089538574, 4643)},
		{From = Vector(11245, 53.017200469971, 4915),  To = Vector(10869, -63.132637023926, 4907), CastPos = Vector(10869, -63.132637023926, 4907)},
		{From = Vector(10923.66015625, -63.288948059082, 4853.9931640625),  To = Vector(11295, 53.402942657471, 4913), CastPos = Vector(11295, 53.402942657471, 4913)},
		{From = Vector(10595, 54.870422363281, 6965),  To = Vector(10351, 55.198459625244, 7249), CastPos = Vector(10351, 55.198459625244, 7249)},
		{From = Vector(10415, 55.269580841064, 7277),  To = Vector(10609, 54.870502471924, 6957), CastPos = Vector(10609, 54.870502471924, 6957)},
		{From = Vector(12395, 54.809947967529, 6115),  To = Vector(12759, 57.640727996826, 6201), CastPos = Vector(12759, 57.640727996826, 6201)},
		{From = Vector(12745, 57.225738525391, 6265),  To = Vector(12413, 54.803039550781, 6089), CastPos = Vector(12413, 54.803039550781, 6089)},
		{From = Vector(12645, 53.343021392822, 4615),  To = Vector(12349, 56.222766876221, 4849), CastPos = Vector(12349, 56.222766876221, 4849)},
		{From = Vector(12395, 52.525123596191, 4765),  To = Vector(12681, 53.853294372559, 4525), CastPos = Vector(12681, 53.853294372559, 4525)},
		{From = Vector(11918.497070313, 57.399909973145, 5471),  To = Vector(11535, 54.801097869873, 5471), CastPos = Vector(11535, 54.801097869873, 5471)},
		{From = Vector(11593, 54.610706329346, 5501),  To = Vector(11967, 56.541202545166, 5477), CastPos = Vector(11967, 56.541202545166, 5477)},
		{From = Vector(11140.984375, 65.858421325684, 8432.9384765625),  To = Vector(11487, 53.453464508057, 8625), CastPos = Vector(11487, 53.453464508057, 8625)},
		{From = Vector(11420.7578125, 53.453437805176, 8608.6923828125),  To = Vector(11107, 65.090522766113, 8403), CastPos = Vector(11107, 65.090522766113, 8403)},
		{From = Vector(11352.48046875, 57.916156768799, 8007.10546875),  To = Vector(11701, 55.458843231201, 8165), CastPos = Vector(11701, 55.458843231201, 8165)},
		{From = Vector(11631, 55.45885848999, 8133),  To = Vector(11287, 58.037368774414, 7979), CastPos = Vector(11287, 58.037368774414, 7979)},
		{From = Vector(10545, 65.745803833008, 7913),  To = Vector(10555, 55.338600158691, 7537), CastPos = Vector(10555, 55.338600158691, 7537)},
		{From = Vector(10795, 55.354972839355, 7613),  To = Vector(10547, 65.771072387695, 7893), CastPos = Vector(10547, 65.771072387695, 7893)},
		{From = Vector(10729, 55.352409362793, 7307),  To = Vector(10785, 54.87170791626, 6937), CastPos = Vector(10785, 54.87170791626, 6937)},
		{From = Vector(10745, 54.871494293213, 6965),  To = Vector(10647, 55.350120544434, 7327), CastPos = Vector(10647, 55.350120544434, 7327)},
		{From = Vector(10099, 66.309921264648, 8443),  To = Vector(10419, 66.106910705566, 8249), CastPos = Vector(10419, 66.106910705566, 8249)},
		{From = Vector(9203, 63.777507781982, 3309),  To = Vector(9359, -63.260040283203, 3651), CastPos = Vector(9359, -63.260040283203, 3651)},
		{From = Vector(9327, -63.258842468262, 3675),  To = Vector(9185, 65.192367553711, 3329), CastPos = Vector(9185, 65.192367553711, 3329)},
		{From = Vector(10045, 55.140678405762, 6465),  To = Vector(10353, 54.869094848633, 6679), CastPos = Vector(10353, 54.869094848633, 6679)},
		{From = Vector(10441.002929688, 65.793014526367, 8315.2333984375),  To = Vector(10133, 64.52165222168, 8529), CastPos = Vector(10133, 64.52165222168, 8529)},
		{From = Vector(8323, 54.89501953125, 9137),  To = Vector(8207, 53.530456542969, 9493), CastPos = Vector(8207, 53.530456542969, 9493)},
		{From = Vector(8295, 53.530418395996, 9363),  To = Vector(8359, 54.895038604736, 8993), CastPos = Vector(8359, 54.895038604736, 8993)},
		{From = Vector(8495, 52.768348693848, 9763),  To = Vector(8401, 53.643203735352, 10125), CastPos = Vector(8401, 53.643203735352, 10125)},
		{From = Vector(8419, 53.59920501709, 9997),  To = Vector(8695, 51.417175292969, 9743), CastPos = Vector(8695, 51.417175292969, 9743)},
		{From = Vector(7145, 55.597702026367, 5965),  To = Vector(7413, -66.513969421387, 6229), CastPos = Vector(7413, -66.513969421387, 6229)},
		{From = Vector(6947, 56.01900100708, 8213),  To = Vector(6621, -62.816535949707, 8029), CastPos = Vector(6621, -62.816535949707, 8029)},
		{From = Vector(6397, 54.634998321533, 10813),  To = Vector(6121, 54.092365264893, 11065), CastPos = Vector(6121, 54.092365264893, 11065)},
		{From = Vector(6247, 54.6325340271, 11513),  To = Vector(6053, 39.563938140869, 11833), CastPos = Vector(6053, 39.563938140869, 11833)},
		{From = Vector(4627, 41.618049621582, 11897),  To = Vector(4541, 51.561706542969, 11531), CastPos = Vector(4541, 51.561706542969, 11531)},
		{From = Vector(5179, 53.036727905273, 10839),  To = Vector(4881, -63.11701965332, 10611), CastPos = Vector(4881, -63.11701965332, 10611)},
		{From = Vector(4897, -63.125648498535, 10613),  To = Vector(5177, 52.773872375488, 10863), CastPos = Vector(5177, 52.773872375488, 10863)},
		{From = Vector(11367, 50.348838806152, 9751),  To = Vector(11479, 106.51720428467, 10107), CastPos = Vector(11479, 106.51720428467, 10107)},
		{From = Vector(11489, 106.53769683838, 10093),  To = Vector(11403, 50.349449157715, 9727), CastPos = Vector(11403, 50.349449157715, 9727)},
		{From = Vector(12175, 106.80973052979, 9991),  To = Vector(12143, 50.354927062988, 9617), CastPos = Vector(12143, 50.354927062988, 9617)},
		{From = Vector(12155, 50.354919433594, 9623),  To = Vector(12123, 106.81489562988, 9995), CastPos = Vector(12123, 106.81489562988, 9995)},
		{From = Vector(9397, 52.484146118164, 12037),  To = Vector(9769, 106.21959686279, 12077), CastPos = Vector(9769, 106.21959686279, 12077)},
		{From = Vector(9745, 106.2202835083, 12063),  To = Vector(9373, 52.484580993652, 12003), CastPos = Vector(9373, 52.484580993652, 12003)},
		{From = Vector(9345, 52.689178466797, 12813),  To = Vector(9719, 106.20919799805, 12805), CastPos = Vector(9719, 106.20919799805, 12805)},
		{From = Vector(4171, 109.72004699707, 2839),  To = Vector(4489, 54.030017852783, 3041), CastPos = Vector(4489, 54.030017852783, 3041)},
		{From = Vector(4473, 54.04020690918, 3009),  To = Vector(4115, 110.06342315674, 2901), CastPos = Vector(4115, 110.06342315674, 2901)},
		{From = Vector(2669, 105.9382019043, 4281),  To = Vector(2759, 57.061370849609, 4647), CastPos = Vector(2759, 57.061370849609, 4647)},
		{From = Vector(2761, 57.062965393066, 4653),  To = Vector(2681, 106.2310256958, 4287), CastPos = Vector(2681, 106.2310256958, 4287)},
		{From = Vector(1623, 108.56233215332, 4487),  To = Vector(1573, 56.13228225708, 4859), CastPos = Vector(1573, 56.13228225708, 4859)},
		{From = Vector(1573, 56.048126220703, 4845),  To = Vector(1589, 108.56234741211, 4471), CastPos = Vector(1589, 108.56234741211, 4471)},
		{From = Vector(2355.4450683594, 60.167724609375, 6366.453125),  To = Vector(2731, 54.617771148682, 6355), CastPos = Vector(2731, 54.617771148682, 6355)},
		{From = Vector(2669, 54.488224029541, 6363),  To = Vector(2295, 60.163955688477, 6371), CastPos = Vector(2295, 60.163955688477, 6371)},
		{From = Vector(2068.5336914063, 54.921718597412, 8898.5322265625),  To = Vector(2457, 53.765918731689, 8967), CastPos = Vector(2457, 53.765918731689, 8967)},
		{From = Vector(2447, 53.763805389404, 8913),  To = Vector(2099, 54.922241210938, 8775), CastPos = Vector(2099, 54.922241210938, 8775)},
		{From = Vector(1589, 49.631057739258, 9661),  To = Vector(1297, 38.928337097168, 9895), CastPos = Vector(1297, 38.928337097168, 9895)},
		{From = Vector(1347, 39.538192749023, 9813),  To = Vector(1609, 50.499561309814, 9543), CastPos = Vector(1609, 50.499561309814, 9543)},
		{From = Vector(3997, -63.152000427246, 10213),  To = Vector(3627, -64.785446166992, 10159), CastPos = Vector(3627, -64.785446166992, 10159)},
		{From = Vector(3709, -63.07014465332, 10171),  To = Vector(4085, -63.139434814453, 10175), CastPos = Vector(4085, -63.139434814453, 10175)},
		{From = Vector(9695, 106.20919799805, 12813),  To = Vector(9353, 95.629013061523, 12965), CastPos = Vector(9353, 95.629013061523, 12965)},
		{From = Vector(5647, 55.136940002441, 9563),  To = Vector(5647, -65.224411010742, 9187), CastPos = Vector(5647, -65.224411010742, 9187)},
		{From = Vector(5895, 52.799312591553, 3389),  To = Vector(6339, 51.669734954834, 3633), CastPos = Vector(6339, 51.669734954834, 3633)},
		{From = Vector(6225, 51.669948577881, 3605),  To = Vector(5793, 53.080261230469, 3389), CastPos = Vector(5793, 53.080261230469, 3389)},
		{From = Vector(8201, 54.276405334473, 1893),  To = Vector(8333, 52.60326385498, 1407), CastPos = Vector(8333, 52.60326385498, 1407)},
		{From = Vector(8185, 52.598056793213, 1489),  To = Vector(8015, 54.276405334473, 1923), CastPos = Vector(8015, 54.276405334473, 1923)},
		{From = Vector(2351, 56.366249084473, 4743),  To = Vector(2355, 107.71157836914, 4239), CastPos = Vector(2355, 107.71157836914, 4239)},
		{From = Vector(2293, 109.00361633301, 4389),  To = Vector(2187, 56.207984924316, 4883), CastPos = Vector(2187, 56.207984924316, 4883)},
		{From = Vector(4271, 108.56426239014, 2065),  To = Vector(4775, 54.37939453125, 2033), CastPos = Vector(4775, 54.37939453125, 2033)},
		{From = Vector(4675, 54.971534729004, 2013),  To = Vector(4173, 108.41383361816, 1959), CastPos = Vector(4173, 108.41383361816, 1959)},
		{From = Vector(7769, 53.940235137939, 10925),  To = Vector(8257, 49.935401916504, 11049), CastPos = Vector(8257, 49.935401916504, 11049)},
		{From = Vector(8123, 49.935398101807, 11051),  To = Vector(7689, 53.834579467773, 10831), CastPos = Vector(7689, 53.834579467773, 10831)},

	},
	
	['Tryndamere'] = 
	{
		{From = Vector(3881, -55.396286010742, 8875),  To = Vector(3361, 53.330867767334, 8567), CastPos = Vector(3360, 0, 8567)},
	},

	['Flash'] = 
	{
		{From = Vector(2947, -64.889228820801, 11663),  To = Vector(3483, 35.631851196289, 12103), CastPos = Vector(3555, 0, 12179)},
		{From = Vector(3547, 37.303478240967, 12063),  To = Vector(2961, -64.888778686523, 11675), CastPos = Vector(2961, -64.888778686523, 11675)},
		{From = Vector(10645, 69.051124572754, 2165),  To = Vector(11231, -47.342067718506, 2655), CastPos = Vector(11231, -47.342067718506, 2655)},
		{From = Vector(11045, -65.04175567627, 2815),  To = Vector(10591, 69.168502807617, 2265), CastPos = Vector(10591, 69.168502807617, 2265)},

	},

	['Wards'] = 
	{
		{From = Vector(3724.28125, 108.49638366699, 1755.2712402344),  To = Vector(4696.0971679688, 55.26212310791, 1864.8077392578), CastPos = Vector(4547, 0, 1976)},
		{From = Vector(4670.115234375, 81.434982299805, 1433.9256591797),  To = Vector(4246.0971679688, 108.72006988525, 2114.8076171875), CastPos = Vector(4419, 0, 1950)},
		{From = Vector(4997, 54.408828735352, 2815),  To = Vector(5152.7348632813, 54.565265655518, 3380.1889648438), CastPos = Vector(5152, 0, 3380)},
		{From = Vector(5802.6293945313, 53.363063812256, 3164.1020507813),  To = Vector(6433.1987304688, 54.930030822754, 2792.5739746094), CastPos = Vector(6433, 0, 2792)},
		{From = Vector(5639.1323242188, 52.244163513184, 4083.8139648438),  To = Vector(6139.9619140625, 51.673439025879, 4457.0463867188), CastPos = Vector(6139, 0, 4457)},
		{From = Vector(6699.4018554688, 52.594158172607, 1003.7911376953),  To = Vector(7359.857421875, 52.58959197998, 682.76007080078), CastPos = Vector(7359, 0, 682)},
		{From = Vector(8621.494140625, 52.60466003418, 1431.9832763672),  To = Vector(8762.9482421875, 61.924690246582, 1913.5200195313), CastPos = Vector(8762, 0, 1913)},
		{From = Vector(7995, 54.276401519775, 2665),  To = Vector(7783.8198242188, 54.954864501953, 3198.6767578125), CastPos = Vector(7783, 0, 3198)},
		{From = Vector(9495, 68.016799926758, 2515),  To = Vector(9936.8740234375, 52.180801391602, 2803.4829101563), CastPos = Vector(9936, 0, 2803)},
		{From = Vector(7993, 54.820846557617, 4825),  To = Vector(8188.4755859375, 55.205299377441, 4655.4091796875), CastPos = Vector(8188, 0, 4655)},
		{From = Vector(8658.564453125, -65.190353393555, 5868.6826171875),  To = Vector(9028.1142578125, -63.971069335938, 5437.6733398438), CastPos = Vector(9028, 0, 5437)},
		{From = Vector(8803, -64.178421020508, 6059),  To = Vector(9464.3505859375, 10.230813980103, 6155.9692382813), CastPos = Vector(9464, 0, 6155)},
		{From = Vector(8883, -64.273574829102, 6071),  To = Vector(8000.9228515625, -64.103622436523, 6219.3149414063), CastPos = Vector(8000, 0, 6219)},
		{From = Vector(5511, 54.800945281982, 7453),  To = Vector(5746.0971679688, -54.631282806396, 7914.8076171875), CastPos = Vector(5583, 0, 7775)},
		{From = Vector(4238.5859375, 53.518417358398, 7178.3979492188),  To = Vector(4273.9521484375, 54.125839233398, 6849.6748046875), CastPos = Vector(4273, 0, 6849)},
		{From = Vector(1703.3422851563, 56.000003814697, 4862.05078125),  To = Vector(2046.0969238281, 110.08967590332, 4414.8076171875), CastPos = Vector(2171, 0, 4564)},
		{From = Vector(3001, 55.037502288818, 7165),  To = Vector(2824.5280761719, 55.025344848633, 7629.6123046875), CastPos = Vector(2824, 0, 7629)},
		{From = Vector(2524.2890625, 53.528335571289, 9556.4091796875),  To = Vector(1935.1058349609, 54.214004516602, 9479.98828125), CastPos = Vector(1935, 0, 9479)},
		{From = Vector(2225, 53.364398956299, 10195),  To = Vector(2446.0969238281, -64.818786621094, 10914.807617188), CastPos = Vector(2115, 0, 10784)},
		{From = Vector(1447, 35.723152160645, 10963),  To = Vector(2396.0969238281, -64.847946166992, 11064.807617188), CastPos = Vector(1927, 0, 10679)},
		{From = Vector(1301, 39.333183288574, 11519),  To = Vector(1016.2835693359, 41.279140472412, 12287.830078125), CastPos = Vector(1016, 0, 12287)},
		{From = Vector(1626.7888183594, 34.167728424072, 12241.125976563),  To = Vector(1508.8809814453, 34.801139831543, 12862.686523438), CastPos = Vector(1508, 0, 12862)},
		{From = Vector(2233, 29.105813980103, 13151),  To = Vector(2265.4782714844, 29.594945907593, 13290.818359375), CastPos = Vector(2265, 0, 13290)},
		{From = Vector(3087, -61.398155212402, 11095),  To = Vector(2763.6437988281, -63.596355438232, 10603.704101563), CastPos = Vector(2763, 0, 10603)},
		{From = Vector(3671, 25.021741867065, 11321),  To = Vector(4020.3000488281, 48.20325088501, 11614.2109375), CastPos = Vector(4020, 0, 11614)},
		{From = Vector(4347, -62.91813659668, 10663),  To = Vector(4096.0966796875, 52.203323364258, 11214.807617188), CastPos = Vector(4212, 0, 11100)},
		{From = Vector(4503, -64.021156311035, 8697),  To = Vector(4814.193359375, -63.246570587158, 8916.669921875), CastPos = Vector(4814, 0, 8916)},
		{From = Vector(4503, -64.021156311035, 8697),  To = Vector(4566.7529296875, -12.307863235474, 8289.1484375), CastPos = Vector(4566, 0, 8289)},
		{From = Vector(6881, 57.446823120117, 9805),  To = Vector(5773.271484375, 54.083835601807, 10035.961914063), CastPos = Vector(5773, 0, 10035)},
		{From = Vector(7285, 55.806526184082, 9975),  To = Vector(7861.36328125, 53.097526550293, 10008.204101563), CastPos = Vector(7861, 0, 10008)},
		{From = Vector(6937, 53.486282348633, 11177),  To = Vector(6361.7387695313, 54.635105133057, 11285.702148438), CastPos = Vector(6361, 0, 11285)},
		{From = Vector(6937, 53.486282348633, 11177),  To = Vector(7302.7368164063, 52.357833862305, 11585.358398438), CastPos = Vector(7302, 0, 11585)},
		{From = Vector(10943, 53.671604156494, 5879),  To = Vector(11087.841796875, 54.870971679688, 6794.1220703125), CastPos = Vector(11087, 0, 6794)},
		{From = Vector(10719, -11.485263824463, 5329),  To = Vector(10202.693359375, -62.148941040039, 4852.36328125), CastPos = Vector(10202, 0, 4852)},
		{From = Vector(9595, -63.259185791016, 3651),  To = Vector(9946.0966796875, 52.180717468262, 3064.8076171875), CastPos = Vector(9829, 0, 3108)},
		{From = Vector(11209, -59.272621154785, 3991),  To = Vector(11315.450195313, -54.63402557373, 3752.0634765625), CastPos = Vector(11315, 0, 3752)},
		{From = Vector(11995, 52.005813598633, 4315),  To = Vector(11596.096679688, -54.498565673828, 3564.8076171875), CastPos = Vector(11928, 0, 3837)},
		{From = Vector(11787, 53.960861206055, 1083),  To = Vector(12101.8125, 56.686729431152, 1319.0690917969), CastPos = Vector(12101, 0, 1319)},
		{From = Vector(12782.307617188, 43.157390594482, 2026.2133789063),  To = Vector(13050.96875, 39.86092376709, 2373.3486328125), CastPos = Vector(13050, 0, 2373)},
		{From = Vector(12645, 55.836288452148, 4115),  To = Vector(12246.096679688, 54.022102355957, 4664.8076171875), CastPos = Vector(12344, 0, 4519)},
		{From = Vector(12476.041015625, 51.939735412598, 4965.8994140625),  To = Vector(12086.690429688, 52.597213745117, 4952.9140625), CastPos = Vector(12086, 0, 4952)},
		{From = Vector(10028.2109375, 54.813400268555, 7547.5297851563),  To = Vector(9665.5263671875, 54.936721801758, 7662.2451171875), CastPos = Vector(9665, 0, 7662)},
		{From = Vector(4776.1098632813, 41.423122406006, 12144.823242188),  To = Vector(5247.107421875, 40.152732849121, 12531.134765625), CastPos = Vector(5247, 0, 12531)},
		{From = Vector(6015, 39.539405822754, 11747),  To = Vector(6236.6875, 54.635395050049, 11257.928710938), CastPos = Vector(6236, 0, 11257)},
		{From = Vector(7555.9506835938, 52.610252380371, 12122.868164063),  To = Vector(7768.6005859375, 50.194828033447, 11667.94921875), CastPos = Vector(7768, 0, 11667)},
		{From = Vector(8439.884765625, 49.935398101807, 11304.088867188),  To = Vector(8903.216796875, 56.921333312988, 11101.126953125), CastPos = Vector(8903, 0, 11101)},
		{From = Vector(9545, 52.483745574951, 11413),  To = Vector(9896.0966796875, 106.22301483154, 11564.807617188), CastPos = Vector(9810, 0, 11586)},
		{From = Vector(9319, 52.487682342529, 12335),  To = Vector(9696.0966796875, 106.20935058594, 12414.807617188), CastPos = Vector(9612, 0, 12449)},
		{From = Vector(6367, 56.132125854492, 9567),  To = Vector(6348.7504882813, 56.017074584961, 9519.931640625), CastPos = Vector(6348, 0, 9519)},
		{From = Vector(6103, -64.506004333496, 8385),  To = Vector(6265.3017578125, -63.100578308105, 8260.78515625), CastPos = Vector(6265, 0, 8260)},
		{From = Vector(3802.7902832031, -59.188068389893, 9418.751953125),  To = Vector(4286.3940429688, -61.645568847656, 9814.9873046875), CastPos = Vector(4286, 0, 9814)},
		{From = Vector(7521, 54.841407775879, 5519),  To = Vector(7750.8784179688, 55.962356567383, 4959.4697265625), CastPos = Vector(7750, 0, 4959)},
		{From = Vector(10433.07421875, 68.126663208008, 8756.607421875),  To = Vector(10896.096679688, 50.348419189453, 9414.8076171875), CastPos = Vector(10705, 0, 9281)},
		{From = Vector(11692.188476563, 50.352027893066, 9472.44140625),  To = Vector(11692.94921875, 106.83708953857, 10066.624023438), CastPos = Vector(11692, 0, 10066)},
		{From = Vector(13266.453125, 54.536972045898, 6841.609375),  To = Vector(13631.72265625, 53.963649749756, 6754.8159179688), CastPos = Vector(13631, 0, 6754)},
		{From = Vector(6889, 52.659908294678, 11707),  To = Vector(6661.4194335938, 53.834930419922, 11101.125976563), CastPos = Vector(6661, 0, 11101)},
		{From = Vector(411, 47.50146484375, 7997),  To = Vector(490.9775390625, 48.493495941162, 7922.2836914063), CastPos = Vector(490, 0, 7922)},
		{From = Vector(4497, 54.043472290039, 3015),  To = Vector(4146.0971679688, 109.73500823975, 2814.8076171875), CastPos = Vector(4234, 0, 2931)},

	}
}

JumpSpots['Katarina'] = JumpSpots['Jax']
JumpSpots['LeeSin'] = JumpSpots['Jax']

function OnLoad()
	Q = Queuer()
	Menu = scriptConfig("Queuer", "Queuer2.0")
	Menu:addParam("Enabled", "Enabled", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("Queue", "Queue orders",  SCRIPT_PARAM_ONKEYDOWN, false, 17)
	Menu:addParam("QRecall", "Queue Recall",  SCRIPT_PARAM_ONKEYDOWN, false, string.byte("B"))
	Menu:addParam("QFlash", "Queue Flash",  SCRIPT_PARAM_ONKEYDOWN, false, string.byte("F"))
	
	if myHero.charName == 'Jax' or myHero.charName == 'Katarina' or myHero.charName == 'LeeSin' then
		Menu:addParam("QWJump", "Queue Ward Jump",  SCRIPT_PARAM_ONKEYDOWN, false, string.byte("G"))
	end
	Menu:addParam("DrawD", "Don't draw circles if the distance >", SCRIPT_PARAM_SLICE, 2000, 0, 10000, 0)
	
	if JumpSpots[myHero.charName] then
		Menu:addSubMenu(myHero.charName.." jump helper", myHero.charName)
		Menu[myHero.charName]:addParam("Enabled", "Enabled",  SCRIPT_PARAM_ONOFF, true)
		
		Menu[myHero.charName]:addParam("DrawJ", "Draw jump points",  SCRIPT_PARAM_ONOFF, true)
		Menu[myHero.charName]:addParam("DrawL", "Draw landing points",  SCRIPT_PARAM_ONOFF, false)

		Menu[myHero.charName]:addSubMenu("Colors", "Colors")
		Menu[myHero.charName].Colors:addParam("JColor", "Jump point color", SCRIPT_PARAM_COLOR, {100, 0, 100, 255})
		Menu[myHero.charName].Colors:addParam("LColor", "Landing point color", SCRIPT_PARAM_COLOR, {100, 255, 255, 0})

	end

	if (GetFlashSlot() ~= nil) then
		Menu:addSubMenu("Flash helper", "Flash")
		Menu.Flash:addParam("Enabled", "Enabled",  SCRIPT_PARAM_ONOFF, true)
		Menu.Flash:addParam("Cooldown", "Show spots only if we have ward(s) available",  SCRIPT_PARAM_ONOFF, true)

		Menu.Flash:addParam("DrawJ", "Draw Flash points",  SCRIPT_PARAM_ONOFF, true)
		Menu.Flash:addParam("DrawL", "Draw landing points",  SCRIPT_PARAM_ONOFF, false)

		Menu.Flash:addSubMenu("Colors", "Colors")
		Menu.Flash.Colors:addParam("JColor", "Flash point color", SCRIPT_PARAM_COLOR, {100, 255, 255, 0})
		Menu.Flash.Colors:addParam("LColor", "Landing point color", SCRIPT_PARAM_COLOR, {100, 0, 255, 0})
	end

	Menu:addSubMenu("Ward helper", "Wards")
	Menu.Wards:addParam("Enabled", "Enabled",  SCRIPT_PARAM_ONOFF, true)
	Menu.Wards:addParam("Cooldown", "Show spots only if we have ward(s) available",  SCRIPT_PARAM_ONOFF, true)
		
	Menu.Wards:addParam("DrawJ", "Draw ward cast position",  SCRIPT_PARAM_ONOFF, true)
	Menu.Wards:addParam("DrawL", "Draw ward landing position",  SCRIPT_PARAM_ONOFF, false)

	Menu.Wards:addSubMenu("Colors", "Colors")
	Menu.Wards.Colors:addParam("JColor", "Ward cast point color", SCRIPT_PARAM_COLOR, {100, 0, 255, 0})
	Menu.Wards.Colors:addParam("LColor", "Landing point color", SCRIPT_PARAM_COLOR, {100, 255, 0, 0})
end

function GetFlashSlot()
	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerFlash") then
		return SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerFlash") then
		return SUMMONER_2
	end
end

function GetWardsSlot(pink)
	local _wards = 
	{
		{Name = "WardingTotem", ItemID = 3340},
		{Name = "GreaterTotem", ItemID = 3350},
		{Name = "GreaterStealthTotem", ItemID = 3361},
		{Name = "WriggleLantern", ItemID = 3154},
		{Name = "Sightstone", ItemID = 2049},
		{Name = "RSightstone", ItemID = 2045},
		{Name = "ItemMiniWard", ItemID = 2050},
		{Name = "SightWard", ItemID = 2044},
		{Name = "GreaterVisionTotem", ItemID = 3362, IsPink = true},
		{Name = "VisionWard", ItemID = 2043, IsPink = true}
	}
	for i, ward in ipairs(_wards) do
		local Slot = GetInventorySlotItem(ward.ItemID)
		if Slot and (myHero:CanUseSpell(Slot) == READY) and (not pink or ward.IsPink) then
			return Slot 
		end
	end
	return nil
end

function OnTick()
	if not Menu.Enabled then return end
	RecallT = RecallT or 0
	if Menu.QRecall and (not Q:GetLastAction() or Q:GetLastAction().type ~= "Recall") and os.clock() - RecallT > 1 then
		local Action = RecallQ()
		local point = GetFountain() + 850*(Vector(myHero) - Vector(GetFountain())):normalized()
		Q:AddAction(Action)
		Q:AddAction(MoveQ(point))
		Q:AddAction(WaitUntil(function() return myHero.health >= 0.9*myHero.maxHealth end))
		Q:AddAction(WaitUntil(function() return myHero.mana >= 0.8*myHero.maxMana end))

		RecallT = os.clock()
	end

	if Menu.Queue and Menu.QFlash and (not Q:GetLastAction() or Q:GetLastAction().type ~= "Flash") and #Q.queue > 0 then
		local Action = CastToPosQ(GetFlashSlot(), Vector(mousePos))
		Q:AddAction(Action)
	end

	if Menu.QWJump and (not Q:GetLastAction() or Q:GetLastAction().type ~= "WardJump") and myHero:CanUseSpell(JumpSlot[myHero.charName]) == READY and GetWardsSlot() then
		local CastPosition
		if not Q:GetLastAction() then
			if GetDistanceSqr(myHero.visionPos, mousePos) > 600 * 600 then
				CastPos = Vector(myHero.visionPos) + 600 * (Vector(mousePos) - Vector(myHero)):normalized()
			else
				CastPos = Vector(mousePos)
			end
		else
			CastPos = Vector(mousePos)
		end
		Q:AddAction(WardJumpQ(GetWardsSlot(), JumpSlot[myHero.charName], CastPos))
	end
	
	if RecordLocations and Timer and (os.clock() - Timer) > 2 then
		if not RecordingWards then
			LandingPos = Vector(myHero.visionPos)
			print(LandingPos)
		else
			LandingPos = WardPoint
		end
		Timer = math.huge
		table.insert(RecordedLocations, {To = LandingPos, From = MyPosition, CastPos = CastPosition})
		print("Location saved")
		local from = MyPosition
		local cp = CastPosition
		local to = LandingPos
		Text = "\t\t{From = Vector("..from.x..", "..from.y..", "..from.z.."),  To = Vector("..to.x..", "..to.y..", "..to.z.."), CastPos = Vector("..cp.x..", "..cp.y..", "..cp.z..")},\n"
		SetClipboardText(Text)
	end
end

function OnSendPacket(p)
	if Menu.Enabled and Menu.Queue and p.header == Packet.headers.S_MOVE then
		local packet = Packet(p)
		local to = Vector(packet:get('x'), myHero.y, packet:get('y'))
		local target = packet:get('targetNetworkId')
		local Added = false

		local Spots = JumpSpots[myHero.charName]
		if Spots and Menu[myHero.charName].Enabled then
			local MaxDistance = Menu.DrawD
			for i, spot in ipairs(Spots) do
				if GetDistanceSqr(spot.From) < MaxDistance*MaxDistance then
					if GetDistanceSqr(spot.From, to) < SRadiusSqr then
						--Nidalee and riven
						if myHero.charName == 'Nidalee' or myHero.charName == 'Riven' then
							local v = Vector(spot.From) - 40 * (Vector(spot.To) - Vector(spot.From)):normalized()
							Q:AddAction(MoveQ(v))
							Q:AddAction(DelayQ(0.05))
							Q:AddAction(MoveQ(spot.From))
							Q:AddAction(DelayQ(0.05))
							Q:AddAction(CastToPosQ(JumpSlot[myHero.charName], spot.CastPos))
							Q:AddAction(DelayQ(0.1))

						--Ward jumps
						elseif (myHero.charName == 'LeeSin' or myHero.charName == 'Katarina' or myHero.charName == 'Jax') and GetWardsSlot() then
							Q:AddAction(MoveQ(spot.From))
							Q:AddAction(WardJumpQ(GetWardsSlot(), JumpSlot[myHero.charName], spot.CastPos))
						elseif (myHero.charName == 'Yasuo') then
							Q:AddAction(MoveQ(spot.From))

							if myHero:CanUseSpell(_W) == READY then
								Q:AddAction(CastToPosQ(_W, spot.CastPos))
							elseif GetWardsSlot()  then
								Q:AddAction(CastToPosQ(GetWardsSlot(), spot.CastPos))
							end

							Q:AddAction(WaitForJungleMob(475, 2))
							Q:AddAction(CastToTargetQ(JumpSlot[myHero.charName], myHero))
						--Normal dashes and blinks
						else
							Q:AddAction(MoveQ(spot.From))
							Q:AddAction(CastToPosQ(JumpSlot[myHero.charName], spot.CastPos))
						end
						Added = true
						break
					end
				end
			end
		end

		Spots = JumpSpots['Wards']
		if Spots and Menu['Wards'].Enabled and GetWardsSlot() and not Added then
			local MaxDistance = Menu.DrawD
			for i, spot in ipairs(Spots) do
				if GetDistanceSqr(spot.CastPos) < MaxDistance*MaxDistance then
					if GetDistanceSqr(spot.CastPos, to) < SRadiusSqr then

						Q:AddAction(CastToPosQ(GetWardsSlot(), spot.CastPos))

						Added = true
						break
					end
				end
			end
		end

		Spots = JumpSpots['Flash']
		if Spots and Menu['Flash'] and Menu['Flash'].Enabled and not Added then
			local MaxDistance = Menu.DrawD
			for i, spot in ipairs(Spots) do
				if GetDistanceSqr(spot.From) < MaxDistance*MaxDistance then
					if GetDistanceSqr(spot.From, to) < SRadiusSqr then

						Q:AddAction(MoveQ(spot.From))
						Q:AddAction(CastToPosQ(GetFlashSlot(), spot.CastPos))

						Added = true
						break
					end
				end
			end
		end

		if not Added then
			if target == 0 then
				local Action = MoveQ(to)
				Q:AddAction(Action)
			else
				local unit = objManager:GetObjectByNetworkId(target)
				if ValidTarget(unit) then
					local Action = AttackQ(unit)
					Q:AddAction(Action)
					Q:AddAction(DelayQ(0.1))
				end
			end
		end

		p:Block()
	elseif Menu.Enabled and p.header == Packet.headers.S_MOVE then
		Q:ClearQueue()
		Q:StopCurrentAction()
	end

	if RecordLocations and p.header == Packet.headers.S_CAST then
		local packet = Packet(p)
		MyPosition = Vector(myHero.visionPos)
		CastPosition = Vector(math.floor(packet:get('toX')), 0, math.floor(packet:get('toY')))
		CastPosition = Vector(mousePos)
		Timer = os.clock()
	end
end

function OnWndMsg(msg, key)
	if RecordLocations then
		if msg == KEY_DOWN and key == string.byte("R") then
			print("Locations saved to clipboard")
			local Text = ""--"['"..myHero.charName.."'] = \n"
			--Text = Text .. "{\n"
			for i, spot in ipairs(RecordedLocations) do
				local from = spot.From
				local to = spot.To
				local cp = spot.CastPos
				Text = Text .. "\t\t{From = Vector("..from.x..", "..from.y..", "..from.z.."),  To = Vector("..to.x..", "..to.y..", "..to.z.."), CastPos = Vector("..cp.x..", "..cp.y..", "..cp.z..")},\n"
			end
			--Text = Text .. "}\n"
			SetClipboardText(Text)
		elseif msg == KEY_DOWN and key == string.byte("D") then
			print("Last location removed")
			if #RecordedLocations > 0 then
				table.remove(RecordedLocations, #RecordedLocations)
			end
		elseif msg == KEY_DOWN and key == string.byte("C") then
			--Q:AddAction(WardJumpQ(GetWardsSlot(), _W, Vector(mousePos)))
			print(Vector(mousePos))
		end
	end
end

function TARGB(t)
	return ARGB(t[1], t[2], t[3], t[4])
end

function DrawCoolArrow(from, to, color)
	DrawLineBorder3D(from.x, myHero.y, from.z, to.x, myHero.y, to.z, 2, color, 1)
end

function OnDraw()
	if not Menu.Enabled then return end

	for i, s in ipairs(DrawS) do
		local Spots = JumpSpots[s]
		if Spots and Menu[s] and Menu[s].Enabled then
			local MaxDistance = Menu.DrawD
			for i, spot in ipairs(Spots) do
				if GetDistanceSqr(spot.From) < MaxDistance*MaxDistance and (s ~= 'Wards' or GetWardsSlot()) then
					if Menu[s].DrawJ then
						local color = TARGB(Menu[s].Colors.JColor)
						local pos = s ~= 'Wards' and spot.From or spot.CastPos
						if GetDistanceSqr(pos, mousePos) < SRadiusSqr then
							color = ARGB(100, 255, 61, 236)
							DrawCoolArrow(pos, spot.To, color)
						end
						DrawCircle2(pos.x, myHero.y, pos.z, DRadius, color)
					end

					if Menu[s].DrawL then
						local color = TARGB(Menu[s].Colors.LColor)
						local pos = spot.To
						DrawCircle2(pos.x, myHero.y, pos.z, DRadius, color)
					end
				end
			end
		end
	end
	
	for i, loc in ipairs(RecordedLocations) do
		DrawCircle2(loc.From.x, myHero.y, loc.From.z, DRadius, ARGB(100, 255, 255, 255))
	end

	Q:Draw()
end

--[[Credits to barasia, vadash and viceversa for anti-lag circles]]
function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
	radius = radius or 300
	quality = math.max(16,math.floor(180/math.deg((math.asin((chordlength/(2*radius)))))))
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
		DrawCircleNextLvl(x, y, z, radius, 2, color, 75)	
	end
end

function OnCreateObj(object)
	--print(object)
	if RecordLocations and (object.name:find("Ward")) and RecordLocations then
		WardPoint = Vector(object.x, object.y, object.z)
	end
end
