#****************************************************************************
#**
#**  File     :  /cdimage/units/UEA0001/UEA0001_script.lua
#**  Author(s):  John Comes
#**
#**  Summary  :  UEF CDR Pod Script
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local CAirUnit = import('/lua/cybranunits.lua').CAirUnit
local CWeapons = import('/lua/cybranweapons.lua')
local GCWeapons = import('/mods/Global Commanders Enhanced/lua/GCweapons.lua')
local CAAMissileNaniteWeapon = CWeapons.CAAMissileNaniteWeapon
local RedLaserGenerator = GCWeapons.RedLaserGenerator
local EffectUtil = import('/lua/EffectUtilities.lua')

GRA0002 = Class(CAirUnit) {

    Weapons = {
        AAMissiles = Class(CAAMissileNaniteWeapon) {},
        Laser = Class(RedLaserGenerator) {},
    },

    Parent = nil,

    SetParent = function(self, parent, droneName)
        self.Parent = parent
        self.Drone = droneName
    end,

    CreateBuildEffects = function( self, unitBeingBuilt, order )
       EffectUtil.CreateCybranBuildBeams( self, unitBeingBuilt, self:GetBlueprint().General.BuildBones.BuildEffectBones, self.BuildEffectsBag )
    end,

    OnCreate = function(self, builder, layer)
    	CAirUnit.OnCreate(self,builder,layer)
        self:ForkThread(self.HeartBeatDistanceCheck)
        self.DroneMaxSpeed = 22
        self.DistanceToTarget = nil
        self.MyTarget = {}
    end,

    HeartBeatDistanceCheck = function(self)
        self.AwayFromCarrier = false
        while self and not self:IsDead() and not self.Parent:IsDead() do
            WaitSeconds(0.33)
            if not self:IsDead() and not self.Parent:IsDead() then
				if self.Parent:IsIdleState() then
					local dronePos = self:GetPosition()
					local parentPos = self.Parent:GetPosition()
					local distance = VDist2(dronePos[1], dronePos[3], parentPos[1], parentPos[3])
					if distance > 40 and self.AwayFromCarrier == false then
						IssueStop({self})
						IssueClearCommands({self})
						self.AwayFromCarrier = true
						self:ForkThread(self.GuardCarrier)
					elseif distance <= 32 and self.AwayFromCarrier == true then
						self.AwayFromCarrier = false
					end
				elseif self:Parent:IsUnitState('Building') or self:Parent:IsUnitState('Upgrading') or self:Parent:IsUnitState('Repairing') or self:Parent:IsUnitState('Reclaiming') then
					IssueStop({self})
					IssueClearCommands({self})
					IssueFactoryAssist({self}, self.Parent)
				end
			end
		end
    end,

    GuardCarrier = function(self)
        if not self:IsDead() and not self.Parent:IsDead() then
            IssueClearCommands(self)
            IssueGuard({self}, self.Parent)
        end
    end,

    OnDamage = function(self, instigator, amount, vector, damagetype)
        CAirUnit.OnDamage(self, instigator, amount, vector, damagetype)
        if self:IsDead() == false and instigator and IsUnit(instigator) then
            IssueAttack({self}, instigator)
        end
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        if self.IsDying then 
            return 
        end
        
        local wep = self:GetWeaponByLabel('Laser')
        for k, v in wep.Beams do
            v.Beam:Disable()
        end      
        
        self.IsDying = true
        self:SetWeaponEnabledByLabel('AAMissiles', false)
        IssueClearCommands(self)
        if not self.Parent:IsDead() then
            self.Parent:NotifyOfDroneDeath(self.Drone)
            table.removeByValue(self.Parent.DroneTable, self)
            self.Parent = nil
        end
        CAirUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
}

TypeClass = GRA0002