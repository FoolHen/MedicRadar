class "MedicRadarServer"

function MedicRadarServer:__init()
	self.m_PlayerKilledEvent = Events:Subscribe("Player:Killed", self, self.OnPlayerKilled)
  self.m_PlayerDeletedEvent = Events:Subscribe("Player:Deleted", self, self.OnPlayerDeleted)
  self.m_PlayerDestroyedEvent = Events:Subscribe("Player:Destroyed", self, self.OnPlayerDestroyed)
  self.m_PlayerTeamChangeEvent = Events:Subscribe("Player:TeamChange", self, self.OnPlayerTeamChange)
end



function MedicRadarServer:OnPlayerKilled(p_Victim, p_Inflictor, p_Position, p_Weapon, p_RoadKill, p_HeadShot, p_VictimInReviveState)  
  if p_Victim == nil then
		return
	end

  --print("Victim: " .. tostring(p_Victim.name))
  NetEvents:SendTo('medicradar:showui', p_Victim, p_Position)

end

function MedicRadarServer:OnPlayerDeleted(p_Player)
  --print(p_Player.name .. " OnPlayerDeleted")
  NetEvents:SendTo('medicradar:clearui', p_Victim)
end

function MedicRadarServer:OnPlayerDestroyed(p_Player)
  --print(p_Player.name .. " OnPlayerDestroyed")
  NetEvents:SendTo('medicradar:clearui', p_Victim)

end

function MedicRadarServer:OnPlayerTeamChange(p_Player)
  --print(p_Player.name .. " OnPlayerTeamChange")
  NetEvents:SendTo('medicradar:clearui', p_Victim)

end

g_MedicRadarServer = MedicRadarServer()