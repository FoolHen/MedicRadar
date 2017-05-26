class "MedicRadarClient"

function MedicRadarClient:__init()
  self.m_GetMedics = NetEvents:Subscribe('MedicRadar:NearbyMedics', self, self.OnGetMedics)
  self.m_ClearMR = NetEvents:Subscribe('MedicRadar:ClearMR', self, self.OnClearMR)
  self.m_ShowUI = NetEvents:Subscribe('MedicRadar:ShowUI', self, self.OnShowUI)
  self.m_Medics = {}
end

function MedicRadarClient:OnGetMedics(p_Medics)
 -- use table to get position and id of nerby medics and calculate distance TODO
 -- display with webui
  WebUI:ExecuteJS('removeAll()')
  
  for s_MedicID, s_MedicPos in pairs(p_Medics) do
    WebUI:ExecuteJS('addText("' .. tostring(s_MedicID) .. ' - ' .. tostring(s_MedicPos) .. '")')
    
  end
  
end
  
function MedicRadarClient:OnClearMR()
  WebUI:ExecuteJS('removeAll()')
  WebUI:ExecuteJS('hideUI()')
end

function MedicRadarClient:OnShowUI()
  WebUI:ExecuteJS('showUI()')
end
  
g_MedicRadar = MedicRadar()
