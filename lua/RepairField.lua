#****************************************************************************
#**
#**  File     :  /cdimage/lua/shield.lua
#**
#**  Summary  :  RepairFields
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************
local Entity = import('/lua/sim/Entity.lua').Entity
local EffectUtil = import('/lua/effectutilities.lua')
local EffectTemplate = import('/lua/effecttemplates.lua')

RepairField = Class(Entity) {
    
    OnCreate = function(self,spec)
	Entity.OnCreate(self)
        self.Trash = TrashBag()
        self.Owner = spec.Owner
        self.Size = spec.Size
        self.UnitsBeingRep = {}
        self:AttachBoneTo(-1,spec.Owner,0)

        ChangeState(self, self.OnState)
    end,

    TurnOn = function(self)
        ChangeState(self, self.OnState)
    end,

    TurnOff = function(self)
        ChangeState(self, self.OffState)
    end,
    
    Jump = function(self)
    	self:DetachFrom()
        self:AttachBoneTo(-1, self.UnitToJumpTo, -1)
        self.Owner = self.UnitToJumpTo
        self.Owner.MyRepairField = self
        self.Size = self.UnitToJumpTo:GetBlueprint().Weapon[1].MaxRadius
        ChangeState(self, self.OffState)
        ChangeState(self, self.OnState)
    end,

    ApplyRepairFieldToUnit = function(self, unit, regenrate)
	unit.BeingRepaired = true
	table.insert(self.UnitsBeingRep, unit)
	#LOG('unit added ; ', LOC(unit:GetBlueprint().Description))
	local defregenrate = unit:GetBlueprint().Defense.RegenRate
	if defregenrate then
	    unit:SetRegenRate(regenrate+defregenrate)
	else
	    unit:SetRegenRate(regenrate)
	end
	if EntityCategoryContains(categories.MOBILE, unit) then
	    unit.RepairEffectThread = ForkThread(EffectThread, unit)
	end
    end,
    
    RemoveRepairFieldFromUnit = function(self, unit) 
	unit:RevertRegenRate()
	if unit.RepairEffectThread then
	    KillThread(unit.RepairEffectThread)
	end
	for k, unit1 in self.UnitsBeingRep do
	    if unit1 == unit then
		table.remove(self.UnitsBeingRep, k)
	    end
	end
	unit.BeingRepaired = false
	#LOG('unit removed ; ', LOC(unit:GetBlueprint().Description))
    end,
	
    OnDestroy = function(self)
	self.RemoveThread = ForkThread(RemoveThread, self)
    end,
	
    OnState = State {
        Main = function(self)
        	LOG('ON')
		local aiBrain =  self.Owner:GetAIBrain()
	        LOG('resetting fieldFx')
		self.Owner.RepairFieldEffectsBag = {}
		self.Owner.CreateTerrainTypeEffects( self.Owner, self.Owner.RepairFieldEffect, 'FXIdle',  self.Owner:GetCurrentLayer(), nil, self.Owner.RepairFieldEffectsBag )
		for k, v in self.Owner.Emitters do
		    table.insert( self.Owner.RepairFieldEffectsBag, CreateAttachedEmitter( self.Owner, 0, self.Owner:GetArmy(), v ) )
		end
			
            WaitSeconds(0.5)
            
            local fraction = self.Owner:GetResourceConsumed()
            local on = true
            local test = false
            while on and not self.Owner:IsDead() do
				local units = aiBrain:GetUnitsAroundPoint(categories.MOBILE + categories.STRUCTURE, self.Owner:GetPosition(), self.Size, 'ALLY')
				for k, unit in units do
					if not unit.BeingRepaired and not unit:IsUnitState('BeingBuilt') then
						self.ApplyRepairFieldToUnit(self, unit, self.Size / 3.5)
					end
				end
				for k,unit in self.UnitsBeingRep do 
					if not table.find(units,unit) then 
						self.RemoveRepairFieldFromUnit(self, unit)
					end	
				end 
                WaitTicks(1)
                fraction = self.Owner:GetResourceConsumed()
                if fraction != 1 then
                    if test then
                        on = false
                    else
                        test = true
                    end
                else
                    on = true
                    test = false
                end
            end
            ChangeState(self, self.OffState)
        end,

        IsOn = function(self)
            return true
        end,

    },

    OffState = State {
        Main = function(self)
        	LOG('offstart')
	        EffectUtil.CleanupEffectBag(self.Owner,'RepairFieldEffectsBag')
	        self.Owner.FieldFxOn = false
	        --self.Owner.Rotator1:SetTargetSpeed(0)
	        --self.Owner.Rotator2:SetTargetSpeed(0)
            WaitSeconds(0.5)
            local fraction = self.Owner:GetResourceConsumed()
            local off = true
            local test = false
            while off and not self.Owner:IsDead() do
                WaitTicks(1)
                if table.getn(self.UnitsBeingRep) > 0 then
					for k, unit in self.UnitsBeingRep do
						self.RemoveRepairFieldFromUnit(self, unit)
					end	
				end
                fraction = self.Owner:GetResourceConsumed()
                if fraction == 1 then
                    if test then
                        off = false
                    else
                        test = true
                    end
                else
                    off = true
                    test = false
                end
            end
            if not self.Owner:IsDead() then
            	ChangeState(self, self.OnState)
            end
        end,
        
        IsOn = function(self)
            return false
        end,
    },

}

function RemoveThread(self)
	while true do
		for k, unit in self.UnitsBeingRep do
			LOG('removing ; ', k)
			self.RemoveRepairFieldFromUnit(self, unit)
		end
		if table.getn(self.UnitsBeingRep) == 0 and self.Owner:IsDead() then
			Entity.OnDestroy(self)
			KillThread(self.RemoveThread)
		end
		WaitTicks(1)
	end
end

function EffectThread(self)
	local army = self:GetArmy()
	local bp = self:GetBlueprint()
	while true and not self:IsDead() do
		for k, v in EffectTemplate.CSGTestEffect2 do
           local emitter = CreateEmitterOnEntity( self, army, v ):ScaleEmitter(math.sqrt(bp.SizeX + bp.SizeZ) * math.sqrt(math.sqrt(bp.SizeX / bp.SizeZ)) * 0.37)
       	end
		WaitSeconds(10)
	end
end
