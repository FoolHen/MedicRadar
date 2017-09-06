class "MedicRadarClient"

function MedicRadarClient:__init()
  self.m_GetMedics = NetEvents:Subscribe('medicradar:nearbymedics', self, self.OnGetMedics)
  self.m_ClearMR = NetEvents:Subscribe('medicradar:clearui', self, self.OnClearUI)
  self.m_ShowUI = NetEvents:Subscribe('medicradar:showui', self, self.OnShowUI)
  self.m_Medics = {}
end

function MedicRadarClient:OnGetMedics(p_Medics)
 -- gets name and distance of nerby medics and calculate
 -- display with webui

  --print("Recived call from server nearbymedics")

  --WebUI:ExecuteJS('removeAll()')
  print(tostring(p_Medics))
  
end
  
function MedicRadarClient:OnClearUI()
  print("Recived call from server clearui")
  --WebUI:ExecuteJS('removeAll()')
  --WebUI:ExecuteJS('hideUI()')
end

function MedicRadarClient:OnShowUI()
  print("Recived call from server showui")
  --WebUI:ExecuteJS('showUI()')
end
  
g_MedicRadarClient = MedicRadarClient()
