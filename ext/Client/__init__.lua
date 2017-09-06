class "MedicRadarClient"

function MedicRadarClient:__init()
  self.m_GetMedics = NetEvents:Subscribe('medicradar:nearbymedics', self, self.OnGetMedics)
  self.m_ClearMR = NetEvents:Subscribe('medicradar:clearui', self, self.OnClearUI)
  self.m_ShowUI = NetEvents:Subscribe('medicradar:showui', self, self.OnShowUI)
  self.m_Medics = {}
  self.m_DeathPos = {x = 0, z = 0}
end

function MedicRadarClient:OnGetMedics(p_Medics)
 -- use table to get position and id of nerby medics and calculate distance TODO
 -- display with webui
  --print("Recived call from server nearbymedics")
  --WebUI:ExecuteJS('removeAll()')
  print(tostring(p_Medics))
  --print(tostring(self.m_DeathPos.x) .. ", " .. tostring(self.m_DeathPos.z))

  -- for s_MedicName, s_MedicPos in pairs(p_Medics) do
  --   --WebUI:ExecuteJS('addText("' .. tostring(s_MedicID) .. ' - ' .. tostring(s_MedicPos) .. '")')
  --   print(tostring(s_MedicName) .. ' - ' .. tostring(s_MedicPos))
  --   --ChatManager:SendMessage("p")
  -- end
  
end
  
function MedicRadarClient:OnClearUI()
  print("Recived call from server clearui")
  --WebUI:ExecuteJS('removeAll()')
  --WebUI:ExecuteJS('hideUI()')
end

function MedicRadarClient:OnShowUI(x, z)
  print("Recived call from server showui")
  --WebUI:ExecuteJS('showUI()')
  self.m_DeathPos = { x, z}
end
  
g_MedicRadarClient = MedicRadarClient()
