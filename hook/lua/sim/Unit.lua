#****************************************************************************
#**
#**  File     :  /lua/unit.lua
#**  Author(s):  John Comes, David Tomandl, Gordon Duclos
#**
#**  Summary  : The Unit lua module
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local oldUnit=Unit
local EffectTemplate = import('/lua/EffectTemplates.lua')

Unit = Class(oldUnit) {

    OnTransportAttach = function(self, attachBone, unit)
        self:PlayUnitSound('Load')
        self:MarkWeaponsOnTransport(unit, true)
        if not EntityCategoryContains(categories.PODSTAGINGPLATFORM, self) then
            self:RequestRefreshUI()
        end
    end,

    OnWorkBegin = function(self, work)
        local unitEnhancements = import('/lua/enhancementcommon.lua').GetEnhancements(self:GetEntityId())
        local bp = self:GetBlueprint()
        if not bp then return false end
        local tempEnhanceBp = bp.Enhancements[work]
        local iscommander = false
        if EntityCategoryContains(categories.COMMAND,self) 
	or EntityCategoryContains(categories.SUBCOMMANDER,self) then
		iscommander = true
    	end
    		
        if tempEnhanceBp.Prerequisite then
            if unitEnhancements[tempEnhanceBp.Slot] != tempEnhanceBp.Prerequisite and not iscommander then
                error('*ERROR: Ordered enhancement does not have the proper prereq!', 2)
                return false
            end
        elseif unitEnhancements[tempEnhanceBp.Slot] and not iscommander then
            error('*ERROR: Ordered enhancement does not have the proper slot available!', 2)
            return false
        end
        self.WorkItem = tempEnhanceBp
        self.WorkItemBuildCostEnergy = tempEnhanceBp.BuildCostEnergy
        self.WorkItemBuildCostMass = tempEnhanceBp.BuildCostEnergy
        self.WorkItemBuildTime = tempEnhanceBp.BuildTime
        self.WorkProgress = 0
        self:SetActiveConsumptionActive()
        self:PlayUnitSound('EnhanceStart')
        self:PlayUnitAmbientSound('EnhanceLoop')
        self:UpdateConsumptionValues()
        self:CreateEnhancementEffects(work)
        ChangeState(self,self.WorkingState)
    end,

    -- Like PlayTeleportChargeEffects, but scaled based on the size of the unit
    -- After calling this, you should still call CleanupTeleportChargeEffects
    PlayScaledTeleportChargeEffects = function(self)
	local army = self:GetArmy()
	local bp = self:GetBlueprint()

	local scaleFactor = self:GetFootPrintSize() * 1.1 or 1
	local yOffset = (bp.Physics.MeshExtentsY or bp.SizeY or 1) / 2

	self.TeleportChargeBag = { }
	for k, v in EffectTemplate.GenericTeleportCharge01 do
		local fx = CreateEmitterAtEntity(self, army, v):OffsetEmitter(0, yOffset, 0):ScaleEmitter(scaleFactor)
		self.Trash:Add(fx)
		table.insert(self.TeleportChargeBag, fx)
	end
    end,

    -- Like PlayTeleportOutEffects, but scaled based on the size of the unit 
    PlayScaledTeleportOutEffects = function(self)
	local army = self:GetArmy()

	local scaleFactor = self:GetFootPrintSize() * 1.1 or 1

	for k, v in EffectTemplate.GenericTeleportOut01 do
		CreateEmitterAtEntity(self, army, v):ScaleEmitter(scaleFactor)
	end
    end,


    -- Like PlayTeleportInEffects, but scaled based on the size of the unit
    PlayScaledTeleportInEffects = function(self)
	local army = self:GetArmy()
	local bp = self:GetBlueprint()

	local scaleFactor = self:GetFootPrintSize() * 1.1 or 1
	local yOffset = (bp.Physics.MeshExtentsY or bp.SizeY or 1) / 2

	for k, v in EffectTemplate.GenericTeleportIn01 do
		CreateEmitterAtEntity(self, army, v):OffsetEmitter(0, yOffset, 0):ScaleEmitter(scaleFactor)
	end
    end,
}