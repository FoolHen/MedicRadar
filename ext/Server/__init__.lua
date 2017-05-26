
class "MedicRadarServer"

function MedicRadarServer:__init()
	self.m_PlayerKilledEvent = Events:Subscribe("Player:Killed", self, self.OnPlayerKilled)
  self.m_UpdateEvent = Events:Subscribe("Engine:Update", self, self.OnUpdate)

  self.m_DeadPlayers = {}
  self.m_CurrentRoundTime = 0.0	
end

function MedicRadarServer:OnUpdate(p_Delta, p_SimulationDelta)
  self.m_CurrentRoundTime = self.m_CurrentRoundTime + p_Delta
  
  if self.m_CurrentRoundTime % 0.2 ~= 0 then --check 5 times every second
    return
  end
  
  local s_Players = PlayerManager:GetPlayers()
  
  for s_Index, s_Victim in pairs(self.m_DeadPlayers) do -- Select a dead player waiting for revive
    local s_MedicsWithDefib = {}
    
    if s_Victim.time <= 0 then
      self.m_DeadPlayers[s_Index] = nil
      NetEvents:SendTo(s_Victim, 'MedicRadar:ClearMR')
      break
    end
    
    s_Victim.time = s_Victim.time - p_Delta
    
    -- Check all players that have defib and are on the same team as the victim
    for j, s_Player in pairs(s_Players) do 
      if s_Index ~= s_Player.id and s_Victim.team == s_Player.teamID then
        local s_Soldier = s_Player.soldier
        
        if s_Soldier ~= nil then
          --self:CheckIfMedic(s_Soldier)
          s_MedicsWithDefib[s_Player.id] = s_Soldier.transform
        end
      end
    end
    
    NetEvents:SendTo(s_Victim, 'MedicRadar:NearbyMedics', s_MedicsWithDefib)
    s_MedicsWithDefib = nil
  end
end

--check if player is medic and has a defib
function MedicRadarServer:CheckIfMedic(p_Soldier)
  
  --TODO
  
end

function MedicRadarServer:OnPlayerKilled(p_Victim, p_Inflictor, p_Position, p_Weapon, p_RoadKill, p_HeadShot, p_VictimInReviveState)
  
	if p_VictimInReviveState == false then
    return
  end
  
  if p_Victim == nil then
		return
	end
  
  self.m_DeadPlayers[p_Victim.id] = {pos = p_Position, team = p_Victim.teamID, time = 5}
  NetEvents:SendTo(s_Victim, 'MedicRadar:ShowUI')

end
g_MedicRadarServer = MedicRadarServer()