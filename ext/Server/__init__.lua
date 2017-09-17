class "MedicRadarServer"

function MedicRadarServer:__init()
	self.m_PlayerKilledEvent = Events:Subscribe("Player:Killed", self, self.OnPlayerKilled)
end

function MedicRadarServer:OnPlayerKilled(p_Victim, p_Inflictor, p_Position, p_Weapon, p_RoadKill, p_HeadShot, p_VictimInReviveState)  
  if p_Victim == nil then
		return
	end
  -- print("Victim: " .. tostring(p_Victim.name))

  NetEvents:SendTo('medicradar:showui', p_Victim, p_Position)

end

g_MedicRadarServer = MedicRadarServer()