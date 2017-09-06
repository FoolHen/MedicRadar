class "MedicRadarServer"

function MedicRadarServer:__init()
	self.m_PlayerKilledEvent = Events:Subscribe("Player:Killed", self, self.OnPlayerKilled)
  self.m_UpdateEvent = Events:Subscribe("Engine:Update", self, self.OnUpdate)

  self.m_DeadPlayers = {}
  self.m_Timer = 0.0	
end

function MedicRadarServer:OnUpdate(p_Delta, p_SimulationDelta)

  self.m_Timer = self.m_Timer + p_Delta

  -- if self.m_Timer % 0.2 ~= 0 then --check 5 times every second
  --   return
  -- end
  if self.m_Timer < 1 then --check every second
    return
  end

  self.m_Timer = 0

  local s_Players = PlayerManager:GetPlayers()
  
  for s_Index, s_Victim in pairs(self.m_DeadPlayers) do -- Select a dead player waiting for revive
    local s_MedicsWithDefib = ""

    if s_Victim.player == nil or s_Victim.player.soldier ~= nil or
        s_Victim.time <= 0 then
      self.m_DeadPlayers[s_Index] = nil
      NetEvents:SendTo('medicradar:clearui', s_Victim.player )
      goto continue
    end

    s_Victim.time = s_Victim.time - 1
    print("time: " .. tostring(s_Victim.time))

    -- Check all players that have defib and are on the same team as the victim
    for j, s_Player in pairs(s_Players) do 
      if --s_Index ~= s_Player.name and 
        s_Victim.player.teamID == s_Player.teamID then

        print("found player in same team")
        local s_Soldier = s_Player.soldier
        
        if s_Soldier ~= nil then
          --self:CheckIfMedic(s_Soldier)
          print("soldier alive")

          local distance2 =  (s_Victim.x - s_Soldier.transform.trans.x) * (s_Victim.x - s_Soldier.transform.trans.x) + 
            (s_Victim.z - s_Soldier.transform.trans.z) * (s_Victim.z - s_Soldier.transform.trans.z)
          s_MedicsWithDefib = s_MedicsWithDefib .. s_Player.name .. tostring(distance2)
        end

        --just for testing
        local distance2 = (s_Victim.x - 15) * (s_Victim.x - 15) +  (s_Victim.z - 15)*(s_Victim.z - 15)
        local distance = math.floor( math.sqrt(distance2) )
        s_MedicsWithDefib = s_MedicsWithDefib .. s_Player.name .. ": " .. tostring(distance) .. " "
      end
    end
    
    NetEvents:SendTo('medicradar:nearbymedics', s_Victim.player, s_MedicsWithDefib)
    s_MedicsWithDefib = nil

    ::continue::
  end
end

--check if player is medic and has a defib
function MedicRadarServer:CheckIfMedic(p_Soldier)
  
  --TODO
  
end

function MedicRadarServer:OnPlayerKilled(p_Victim, p_Inflictor, p_Position, p_Weapon, p_RoadKill, p_HeadShot, p_VictimInReviveState)
  --print("Position: " .. tostring(p_Position))
  local x = p_Position.x
  local z = p_Position.z
  
  if p_Victim == nil then
		return
	end

 -- if p_VictimInReviveState == false then
 --    return
 --  end
  
  print("Victim: " .. tostring(p_Victim.name))
  table.insert(self.m_DeadPlayers,{player = p_Victim, time = 10, x = p_Position.x, z = p_Position.z})
  --self.m_DeadPlayers[p_Victim] = {time = 5}
  NetEvents:SendTo('medicradar:showui', p_Victim, x, z )

end
g_MedicRadarServer = MedicRadarServer()