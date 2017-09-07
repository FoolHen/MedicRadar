class "MedicRadarClient"

function MedicRadarClient:__init()
  self.m_GetMedics = NetEvents:Subscribe('medicradar:nearbymedics', self, self.OnGetMedics)
  self.m_ClearMR = NetEvents:Subscribe('medicradar:clearui', self, self.OnClearUI)
  self.m_ShowUI = NetEvents:Subscribe('medicradar:showui', self, self.OnShowUI)
  self.m_OnLoadedEvent = Events:Subscribe('ExtensionLoaded', self, self.OnLoaded)
  self.m_ClientUpdateInputEvent = Events:Subscribe('Client:UpdateInput', self, self.OnUpdateInput)

  self.m_Medics = {}
end

function MedicRadarClient:OnLoaded()
  print("onloaded called")
  WebUI:Init()
  WebUI:Hide()
end

function MedicRadarClient:OnGetMedics(p_Medics)
 -- gets name and distance of nerby medics and calculate
 -- display with webui

  --print("Recived call from server nearbymedics")
  WebUI:ExecuteJS('removeAll()')

  local s_Messages = split(p_Medics, "|")
  
  for i, s_Message in ipairs(s_Messages) do
    if s_Message ~= nil then
      WebUI:ExecuteJS('addText("' .. tostring(s_Message) .. '")')
    end
  end
end
  
function MedicRadarClient:OnClearUI()
  print("Recived call from server clearui")
  WebUI:ExecuteJS('removeAll()')
  WebUI:Hide()
end

function MedicRadarClient:OnShowUI()
  print("Recived call from server showui")
  WebUI:Show()
end

function split(pString, pPattern)
   local Table = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pPattern
   local last_end = 1
   local s, e, cap = pString:find(fpat, 1)
   while s do
    if s ~= 1 or cap ~= "" then
   table.insert(Table,cap)
    end
    last_end = e+1
    s, e, cap = pString:find(fpat, last_end)
   end
   if last_end <= #pString then
    cap = pString:sub(last_end)
    table.insert(Table, cap)
   end
   return Table
end

function MedicRadarClient:OnUpdateInput(p_Delta)
  if InputManager:WentKeyDown(InputDeviceKeys.IDK_F1) then
    local s_Player = PlayerManager:GetLocalPlayer()
    if s_Player == nil then
      return
    end
    
    local s_Soldier = s_Player.soldier
       if s_Soldier == nil then
      return
    end
    print(tostring(s_Soldier:GetWeaponNameByIndex(5)))

  end

end
  
g_MedicRadarClient = MedicRadarClient()
