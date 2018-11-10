class "MedicRadarClient"

function MedicRadarClient:__init()
	self:RegisterVars()
	self:RegisterEvents()
end

function MedicRadarClient:RegisterVars()
	self.m_DeathPos = {x=0, y=0, z=0}
	self.m_IsClientDead = false
	self.m_IsUIShown = true
	self.m_UpdateTimer = 0
	self.MAX_DISTANCE = 50
	self.UPDATE_RATE = 0.5
	self.MAX_DISPLAY_NUMBER = 6
end

function MedicRadarClient:RegisterEvents()
	self.m_OnLoadedEvent = Events:Subscribe('ExtensionLoaded', self, self.OnLoaded)
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

function MedicRadarClient:UpdateUI(p_Medics)
	WebUI:ExecuteJS('addText("' .. tostring(p_Medics) .. '")')
end
	
function MedicRadarClient:ClearUI()
	self.m_IsClientDead = false
	WebUI:ExecuteJS('removeAll()')
	WebUI:Hide()
end

function MedicRadarClient:ShowUI()
	--print("ShowUI")

	local s_LocalPlayer = PlayerManager:GetLocalPlayer()
	if s_LocalPlayer == nil then
		return
	end 

	local s_Position

	if s_LocalPlayer.corpse ~= nil then
		s_Position = s_LocalPlayer.corpse.transform
		self.m_DeathPos = {x = s_Position.x, y = s_Position.y, z = s_Position.z}
	else
		return
	end

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
			s_LocalPlayer.teamID == s_Player.teamID then

			----print("found player in same team")
			local s_Soldier = s_Player.soldier
			
			if s_Soldier ~= nil then

				if self:HasDefib(s_Soldier) then
					local distance2 =  
						(self.m_DeathPos.x - s_Soldier.transform.trans.x) * (self.m_DeathPos.x - s_Soldier.transform.trans.x) + 
						(self.m_DeathPos.y - s_Soldier.transform.trans.y) * (self.m_DeathPos.y - s_Soldier.transform.trans.y) +
						(self.m_DeathPos.z - s_Soldier.transform.trans.z) * (self.m_DeathPos.z - s_Soldier.transform.trans.z)
					local distance = math.floor( math.sqrt(distance2) )

					if distance < self.MAX_DISTANCE then
						s_MedicsWithDefib[distance] = s_Player.name
					end
				end
			end
		end
	end

	-- For debug:
	-- s_MedicsWithDefib[10] = "FoolHen"
	-- s_MedicsWithDefib[4] = "TestPlayer"
	-- s_MedicsWithDefib[1] = "TestPlayer2"

	local s_MedicsWithDefibString = ""

	local i = 1

	for distance, name in pairs(s_MedicsWithDefib) do
		s_MedicsWithDefibString = s_MedicsWithDefibString .. name .." - "..tostring(distance) .. "m.|"

		if i >= self.MAX_DISPLAY_NUMBER then
			break
		end
		i = i + 1
	end

	-- print(s_MedicsWithDefibString)

	self:UpdateUI(s_MedicsWithDefibString)
end

function MedicRadarClient:HasDefib(p_Soldier)
	local s_Gadget = tostring(p_Soldier:GetWeaponNameByIndex(5)):lower()

	return s_Gadget == "defib"
end
	
g_MedicRadarClient = MedicRadarClient()
