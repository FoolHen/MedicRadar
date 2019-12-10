class "MedicRadarClient"

function MedicRadarClient:__init()
	self:RegisterVars()
	self:RegisterEvents()
end

function MedicRadarClient:RegisterVars()
	self.m_DeathPos = { x = 0, y = 0, z = 0 }
	self.m_IsClientDead = false
	self.m_IsUIShown = true
	self.m_UpdateTimer = 0
	self.MAX_DISTANCE = 50
	self.UPDATE_RATE = 0.5
	self.MAX_DISPLAY_NUMBER = 6
end

function MedicRadarClient:RegisterEvents()
	self.m_OnLoadedEvent = Events:Subscribe('Extension:Loaded', self, self.OnLoaded)
	self.m_ClientFrameUpdateEvent = Events:Subscribe('Client:PostFrameUpdate', self, self.OnPostFrameUpdate)
	self.m_ScreenHook = Hooks:Install('UI:PushScreen', 10, self, self.OnPushScreen)
	self.m_HealthActionEvent = Events:Subscribe('ClientSoldier:HealthAction', self, self.OnHealthAction)
end

function MedicRadarClient:OnLoaded()
	--print("onloaded called")
	WebUI:Init()
	WebUI:Hide()
end

function MedicRadarClient:OnHealthAction(p_Soldier, p_HealthStateAction)
	if p_Soldier == nil then
		return
	end

	local s_LocalPlayer = PlayerManager:GetLocalPlayer()
	if s_LocalPlayer == nil then
		return
	end

	local s_LocalSoldier = s_LocalPlayer.soldier

	if s_LocalSoldier == nil then
		s_LocalSoldier = s_LocalPlayer.corpse

		if s_LocalSoldier == nil then
			return
		end
	end

	if  s_LocalSoldier ~= p_Soldier then
		return
	end

	if p_HealthStateAction == HealthStateAction.OnManDown then
		--print("OnManDown")
		self:ShowUI()
	elseif p_HealthStateAction == HealthStateAction.OnDead then
		--print("OnDead")
		self:ClearUI()
	end
end

function MedicRadarClient:OnPushScreen(p_Hook, p_Screen, p_GraphPriority, p_ParentGraph)
	if not self.m_IsClientDead then
		return
	end

	local s_Screen = UIScreenAsset(p_Screen)
	local s_Name = s_Screen.name

	if s_Name == "UI/Flow/Screen/IngameMenuMP" then
		--print("IngameMenuMP, hidding ui")
		self.m_IsUIShown = false
		WebUI:Hide()
	end

	if s_Name == "UI/Flow/Screen/SpawnScreenPC" then
		--print("SpawnScreenPC, showing ui")
		self.m_IsUIShown = true
		WebUI:Show()
	end

	p_Hook:Next()
end

function MedicRadarClient:UpdateUI(p_MedicsTable)
	WebUI:ExecuteJS(string.format("addMedics(%s)", json.encode(p_MedicsTable)))
end
	
function MedicRadarClient:ClearUI()
	self.m_IsClientDead = false
	WebUI:ExecuteJS("removeAllMedics()")
	WebUI:Hide()
end

function MedicRadarClient:ShowUI()
	--print("ShowUI")

	local s_LocalPlayer = PlayerManager:GetLocalPlayer()
	if s_LocalPlayer == nil then
		return
	end 

	if s_LocalPlayer.corpse == nil then
		return
	end

	local s_Position = s_LocalPlayer.corpse.transform
	self.m_DeathPos = {x = s_Position.x, y = s_Position.y, z = s_Position.z}
	--print("Got position: " .. tostring(s_Position))
	self.m_IsClientDead = true
	self.m_IsUIShown = true

	WebUI:Show()
end

function MedicRadarClient:OnPostFrameUpdate(p_Delta)
	if not self.m_IsClientDead then 
		return
	end

	if not self.m_IsUIShown then 
		return
	end

	self.m_UpdateTimer = self.m_UpdateTimer + p_Delta

	if self.m_UpdateTimer < self.UPDATE_RATE then
		return
	end
	self.m_UpdateTimer = 0

	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	-- if the local player has a soldier he respawned or got revived.
	if s_LocalPlayer.soldier ~= nil then
		self:ClearUI()
		return
	end

	local s_Players = PlayerManager:GetPlayers()
	local s_MedicsWithDefib = {}

	for s_Index, s_Player in pairs(s_Players) do 
				
		if s_LocalPlayer.name ~= s_Player.name and
			s_LocalPlayer.teamId == s_Player.teamId then

			----print("found player in same team")
			local s_Soldier = s_Player.soldier
			
			if s_Soldier ~= nil then

				if self:HasDefib(s_Soldier) then
					local distance2 =  
						(self.m_DeathPos.x - s_Soldier.transform.trans.x) * (self.m_DeathPos.x - s_Soldier.transform.trans.x) + 
						(self.m_DeathPos.y - s_Soldier.transform.trans.y) * (self.m_DeathPos.y - s_Soldier.transform.trans.y) +
						(self.m_DeathPos.z - s_Soldier.transform.trans.z) * (self.m_DeathPos.z - s_Soldier.transform.trans.z)
					local distance =  math.floor(math.sqrt(distance2))

					if distance <= self.MAX_DISTANCE then
						table.insert(s_MedicsWithDefib,  { distance = distance, name = name })
					end
				end
			end
		end
	end

	-- For debug:
	-- table.insert(s_MedicsWithDefib,  { distance = MathUtils:GetRandomInt(1, 49), name = "FoolHen" })
	-- table.insert(s_MedicsWithDefib,  { distance = MathUtils:GetRandomInt(1, 49), name = "TestPlayer" })
	-- table.insert(s_MedicsWithDefib,  { distance = MathUtils:GetRandomInt(1, 49), name = "TestPlayer2" })
	-- table.insert(s_MedicsWithDefib,  { distance = MathUtils:GetRandomInt(1, 49), name = "TestPlayer3" })
	-- table.insert(s_MedicsWithDefib,  { distance = MathUtils:GetRandomInt(1, 49), name = "TestPlayer4" })
	-- table.insert(s_MedicsWithDefib,  { distance = MathUtils:GetRandomInt(1, 49), name = "TestPlayer5" })
	-- table.insert(s_MedicsWithDefib,  { distance = 50, name =  "ShouldNeverShow" })

	-- Sort table by distance
	table.sort(s_MedicsWithDefib, function(a, b) 
		return a.distance < b.distance
	end)
	
	-- Remove farthest players if the array exceeds the maximum number of displayed players.
	for i = #s_MedicsWithDefib, 1, -1 do
		if i >= self.MAX_DISPLAY_NUMBER then
			s_MedicsWithDefib[i] = nil
		end
	end

	self:UpdateUI(s_MedicsWithDefib)
end

function MedicRadarClient:HasDefib(p_Soldier)

	if s_Soldier == nil then
		return false
	end

	local s_WeaponsComponent = s_Soldier.weaponsComponent

	if s_WeaponsComponent == nil then
		return false
	end

	for i = 1, s_WeaponsComponent.weaponCount do
		local s_Weapon = s_WeaponsComponent:GetWeapon(i - 1)

		if s_Weapon ~= nil then
			if string.find(s_Weapon.name:lower(), "defib") then
				return true
			end
		end
	end

	return false
end
	
g_MedicRadarClient = MedicRadarClient()
