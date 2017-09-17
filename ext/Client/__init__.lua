class "MedicRadarClient"

function MedicRadarClient:__init()
  self:RegisterVars()
  self:RegisterEvents()
end

function MedicRadarClient:RegisterVars()
  self.m_DeathPos = {x=0, y=0, z=0}
  self.m_IsClientDead = false
  self.m_IsUIShown = true
  self.MAX_DISTANCE = 50
end

function MedicRadarClient:RegisterEvents()
  self.m_ShowUI = NetEvents:Subscribe('medicradar:showui', self, self.ShowUI)
  self.m_OnLoadedEvent = Events:Subscribe('ExtensionLoaded', self, self.OnLoaded)
  self.m_ClientFrameUpdateEvent = Events:Subscribe('Client:PostFrameUpdate', self, self.OnPostFrameUpdate)
  self.m_ScreenHook = Hooks:Install('UI:PushScreen', 999, self, self.OnPushScreen)
  self.m_EngineMessageEvent = Events:Subscribe('Engine:Message', self, self.OnEngineMessage)
end

function MedicRadarClient:OnLoaded()
  print("onloaded called")
  WebUI:Init()
  WebUI:Hide()
end

function MedicRadarClient:OnEngineMessage(p_Message)
  if p_Message.type == MessageType.ClientPlayerKilledMessage then 
    print("ClientPlayerKilledMessage")

    self:ClearUI()
  end

  if p_Message.type == MessageType.ClientPlayerSwitchTeamMessage then 
    print("ClientPlayerSwitchTeamMessage")

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
    print("IngameMenuMP, hidding ui")
    self.m_IsUIShown = false
    WebUI:Hide()
  end

  if s_Name == "UI/Flow/Screen/SpawnScreenPC" then
    print("SpawnScreenPC, showing ui")
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

function MedicRadarClient:ShowUI(p_Position)
  print("Call from server: showui")

  self.m_DeathPos = {x = p_Position.x, y = p_Position.y, z = p_Position.z}
  print("Got position: " .. tostring(p_Position))
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

  local s_LocalPlayer = PlayerManager:GetLocalPlayer()

  local s_Players = PlayerManager:GetPlayers()
  local s_MedicsWithDefib = ""

  for s_Index, s_Player in pairs(s_Players) do 
        
    if s_LocalPlayer.name ~= s_Player.name and
      s_LocalPlayer.teamID == s_Player.teamID then

      --print("found player in same team")
      local s_Soldier = s_Player.soldier
      
      if s_Soldier ~= nil then

        if self:HasDefib(s_Soldier) then
          local distance2 =  
            (self.m_DeathPos.x - s_Soldier.transform.trans.x) * (self.m_DeathPos.x - s_Soldier.transform.trans.x) + 
            (self.m_DeathPos.y - s_Soldier.transform.trans.y) * (self.m_DeathPos.y - s_Soldier.transform.trans.y) +
            (self.m_DeathPos.z - s_Soldier.transform.trans.z) * (self.m_DeathPos.z - s_Soldier.transform.trans.z)
          local distance = math.floor( math.sqrt(distance2) )

          if distance < self.MAX_DISTANCE then
            s_MedicsWithDefib = s_MedicsWithDefib .. s_Player.name .. ": " .. tostring(distance) .. "m.|"
          end
        end
      end
    end
  end
  -- s_MedicsWithDefib = s_MedicsWithDefib .. "Test" .. ": " .. 1 .. "m.|"
  -- s_MedicsWithDefib = s_MedicsWithDefib .. "Test" .. ": " .. 2 .. "m.|"
  -- s_MedicsWithDefib = s_MedicsWithDefib .. "Test" .. ": " .. 3 .. "m.|"
  self:UpdateUI(s_MedicsWithDefib)
end

function MedicRadarClient:HasDefib(p_Soldier)
  local s_Gadget = tostring(p_Soldier:GetWeaponNameByIndex(5)):lower()

  return s_Gadget == "defib"
end
  
g_MedicRadarClient = MedicRadarClient()
