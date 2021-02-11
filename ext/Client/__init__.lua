class "MedicRadarClient"

function MedicRadarClient:__init()
	print("Initializing MedicRadar")
	self:RegisterVars()
	self:RegisterEvents()
end

function MedicRadarClient:RegisterVars()
	self.m_DeathPos = Vec3()
	self.m_IsUIShown = true
	self.m_UpdateTimer = 0
	self.MAX_DISTANCE = 50
	self.UPDATE_RATE = 0.5
	self.MAX_DISPLAY_NUMBER = 6
end

function MedicRadarClient:RegisterEvents()
	self.m_OnLoadedEvent = Events:Subscribe('Extension:Loaded', self, self.OnLoaded)
	self.m_ClientFrameUpdateEvent = Events:Subscribe('Client:PostFrameUpdate', self, self.OnPostFrameUpdate)
	self.m_HealthActionEvent = Events:Subscribe('Soldier:HealthAction', self, self.OnHealthAction)
end

function MedicRadarClient:OnLoaded()
	WebUI:Init()
	WebUI:Hide()
end

-- This function is called when the health satate of a soldier (including other players' soldiers) is changed.
function MedicRadarClient:OnHealthAction(p_Soldier, p_HealthStateAction)
	if p_Soldier == nil then
		return
	end

	-- We only care about the local player's soldier, so we need to get it and compare with the given soldier.
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()
	if s_LocalPlayer == nil then
		return
	end

	-- Player.soldier returns a SoldierEntity if the player is alive. Player.corpse returns a SoldierEntity if the player is down (revivable).
	-- In Lua this will assign Player.soldier to s_LocalSoldier, and if it's nil it will assign Player.corpse
	local s_LocalSoldier = s_LocalPlayer.soldier or s_LocalPlayer.corpse

	-- If both .soldier and .corpse are nil it means that the player is completely dead (unrevivable).
	if s_LocalSoldier == nil then
		return
	end

	-- We now can check if the given SoldierEntity is the local player's.
	if  s_LocalSoldier ~= p_Soldier then
		return
	end

	-- If it is, we can finally show/hide UI based on the health state.
	if p_HealthStateAction == HealthStateAction.OnManDown then
		self:ShowUI()
	elseif p_HealthStateAction == HealthStateAction.OnDead or 
		p_HealthStateAction == HealthStateAction.OnRevive or 
		p_HealthStateAction == HealthStateAction.OnReviveDone then
		self:ClearUI()
	end
end

function MedicRadarClient:UpdateUI(p_MedicsTable)
	WebUI:ExecuteJS(string.format("addMedics(%s)", json.encode(p_MedicsTable)))
end
	
function MedicRadarClient:ClearUI()
	self.m_IsUIShown = false
	WebUI:ExecuteJS("removeAllMedics()")
	WebUI:Hide()
end

function MedicRadarClient:ShowUI()
	-- Check if player exists and if he is down.
	local s_LocalPlayer = PlayerManager:GetLocalPlayer()
	if s_LocalPlayer == nil or s_LocalPlayer.corpse == nil then
		return
	end

	-- Get and save death position.
	local s_Position = s_LocalPlayer.corpse.transform.trans
	self.m_DeathPos = s_LocalPlayer.corpse.transform.trans:Clone()

	self.m_IsUIShown = true

	-- Show the mod UI.
	WebUI:Show()
end

function MedicRadarClient:OnPostFrameUpdate(p_Delta)
	-- Don't update if the UI is hidden.
	if not self.m_IsUIShown then 
		return
	end

	-- We make a simple timer so we only udpate UI every so often.
	self.m_UpdateTimer = self.m_UpdateTimer + p_Delta

	if self.m_UpdateTimer < self.UPDATE_RATE then
		return
	end

	self.m_UpdateTimer = 0

	local s_LocalPlayer = PlayerManager:GetLocalPlayer()

	-- Only continue if the local player is in man down state
	if s_LocalPlayer == nil or s_LocalPlayer.corpse == nil then
		self:ClearUI()
		return
	end

	local s_MedicsWithDefib = {}

	-- Now we loop through all players.
	for s_Index, s_Player in pairs(PlayerManager:GetPlayers()) do 
		-- We filter players in the team and exclude the local player. 
		if s_LocalPlayer.name ~= s_Player.name and s_LocalPlayer.teamId == s_Player.teamId then			
			if s_Player.soldier ~= nil then
				-- If they have a soldier we check if they have a defib in their kits.
				if self:HasDefib(s_Player) then
					local s_Pos = s_Player.soldier.transform.trans
					-- Some math to calc the distance between the player and the death position.
					local distance = s_Pos:Distance(self.m_DeathPos)
					-- We filter those players that are out of range. The rest are saved in an array.
					if distance <= self.MAX_DISTANCE then
						table.insert(s_MedicsWithDefib,  { distance = math.floor(distance), name = s_Player.name })
					end
				end
			end
		end
	end

	-- For debug:
	-- table.insert(s_MedicsWithDefib, { distance = MathUtils:GetRandomInt(1, 49), name = "FoolHen" })
	-- table.insert(s_MedicsWithDefib, { distance = MathUtils:GetRandomInt(1, 49), name = "TestPlayer1" })
	-- table.insert(s_MedicsWithDefib, { distance = MathUtils:GetRandomInt(1, 49), name = "TestPlayer2" })
	-- table.insert(s_MedicsWithDefib, { distance = MathUtils:GetRandomInt(1, 49), name = "TestPlayer3" })
	-- table.insert(s_MedicsWithDefib, { distance = MathUtils:GetRandomInt(1, 49), name = "TestPlayer4" })
	-- table.insert(s_MedicsWithDefib, { distance = MathUtils:GetRandomInt(1, 49), name = "TestPlayer5" })
	-- table.insert(s_MedicsWithDefib, { distance = 50, name =  "ShouldNeverShow" })

	-- Sort medics array by distance
	table.sort(s_MedicsWithDefib, function(a, b) 
		return a.distance < b.distance
	end)
	
	-- Remove farthest players if the array exceeds the maximum number of allowed players in UI.
	for i = #s_MedicsWithDefib, 1, -1 do
		if i >= self.MAX_DISPLAY_NUMBER then
			s_MedicsWithDefib[i] = nil
		end
	end

	self:UpdateUI(s_MedicsWithDefib)
end

function MedicRadarClient:HasDefib(s_Player)
	if s_Player == nil or s_Player.soldier == nil then
		return false
	end

	local s_WeaponsComponent = s_Player.soldier.weaponsComponent

	if s_WeaponsComponent == nil then
		return false
	end

	-- Loop through all weapons the soldier has, and check their names.
	for _, l_Weapon in pairs(s_WeaponsComponent.weapons) do
		if l_Weapon ~= nil then
			-- Check if the name has defib in it.
			if string.find(l_Weapon.name:lower(), "defib") then
				return true
			end
		end
	end

	return false
end
	
g_MedicRadarClient = MedicRadarClient()
