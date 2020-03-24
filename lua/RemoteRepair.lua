local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker
local Buff = import('/lua/sim/Buff.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local AIUtils = import('/lua/AI/aiutilities.lua')


RegenVizMarker = Class(VizMarker) {
	    AmbientEffects = 'ST2PowerAmbient',
	    AuraEffect = '/effects/emitters/seraphim_regenerative_aura_01_emit.bp',
        
    __init = function(self, spec)
        VizMarker.__init(self, spec)
        self.RegenRadius = spec.RegenRadius
        self.RegenPerSecond = spec.RegenPerSecond
        self.RegenCeiling = spec.RegenCeiling
        self.RegenFloor = spec.RegenFloor
        self.AiBrain = spec.AiBrain
        self.Y = spec.Y
        #LOG(' RegenRadius='..self.RegenRadius..' RegenPerSecond='..self.RegenPerSecond..' RegenCeiling='..self.RegenCeiling..' RegenFloor='..self.RegenFloor)
    end,
    
    RegenBuffThread = function(self)
        while not self:BeenDestroyed() do
            # Get friendly units in the area
            #LOG(repr(self:GetPosition()))
            local units = self.AiBrain:GetUnitsAroundPoint(categories.ALLUNITS, self:GetPosition(), self.RegenRadius, 'ALLY')
            # Give them a 5 second regen buff
            for _,unit in units do
                #LOG(unit:GetBlueprint().Description)
                Buff.ApplyBuff(unit, 'RemoteRegenField')
            end

            #Wait 5 seconds
            WaitSeconds(5)
        end
    end,
    
    OnCreate = function(self)
        VizMarker.OnCreate(self)
        Warp(self, Vector(self.X, self.Y, self.Z))
        if not Buffs['RemoteRegenField'] then
            BuffBlueprint {
                Name = 'RemoteRegenField',
                DisplayName = 'RemoteRegenField',
                BuffType = 'COMMANDERAURA',
                Stacks = 'REPLACE',
                Duration = 5,
                Affects = {
                    RegenPercent = {
                        Add = 0,
                        Mult = self.RegenPerSecond or 0.1,
                        Ceil = self.RegenCeiling,
                        Floor = self.RegenFloor,
                    },                   
                },
            }
        end
        self.EffectsBag = {}
        self:EnableRegen()
    end,
    
    EnableRegen = function(self)
        local effect = nil
        self.RegenThreadHandle = ForkThread(self.RegenBuffThread, self)
        #if self.AmbientEffects then
        #    for k, v in EffectTemplate[self.AmbientEffects] do
        #        effect = CreateEmitterOnEntity(self, self.Army, v):ScaleEmitter(3)
		#		table.insert(self.EffectsBag, effect)
        #    end
        #end
        effect = CreateEmitterOnEntity(self, self.Army, self.AuraEffect):ScaleEmitter(3)
        table.insert(self.EffectsBag, effect)
        LOG('RegenEnabled')
    end,
    
    DisableRegen = function(self)
        if self.RegenThreadHandle then
            self.RegenThreadHandle:Destroy()
            self.RegenThreadHandle = nil
        end
        for k, v in self.EffectsBag do
            v:Destroy()
        end
        self.EffectsBag = {}
        LOG('RegenDisabled')
    end,
    
    OnDestroy = function(self)
        self:DisableRegen()
        VizMarker.OnDestroy(self)
    end,
    
    IntelEnable = function(self, inteltype)
        if not self.RegenThreadHandle then
            self:EnableRegen()
        end
        self:EnableIntel(inteltype)
    end,

    IntelDisable = function(self, inteltype)
        self:DisableRegen()
        self:DisableIntel(inteltype)
    end,
}


# TODO: make sure each new instance is using a previous metatable
function RemoteViewingRegen(SuperClass)
    return Class(SuperClass) {
        OnCreate = function(self)
            SuperClass.OnCreate(self)
            self.RemoteViewingData = {}
            self.RemoteViewingData.RemoteViewingFunctions = {}
            self.RemoteViewingData.DisableCounter = 0
            self.RemoteViewingData.IntelButton = true
        end,

        OnStopBeingBuilt = function(self,builder,layer)
            self.Sync.Abilities = self:GetBlueprint().Abilities
            self:SetMaintenanceConsumptionInactive()
            SuperClass.OnStopBeingBuilt(self,builder,layer)
        end,

        OnKilled = function(self, instigator, type, overkillRatio)
            SuperClass.OnKilled(self, instigator, type, overkillRatio)
            if self.RemoteViewingData.Satellite then
                self.RemoteViewingData.Satellite:IntelDisable('Vision')
                self.RemoteViewingData.Satellite:Destroy()
            end
            self:SetMaintenanceConsumptionInactive()
        end,
        
        DisableRemoteViewingButtons = function(self)
            self.Sync.Abilities = self:GetBlueprint().Abilities
            self.Sync.Abilities.TargetLocation.Active = false
            self:RemoveToggleCap('RULEUTC_IntelToggle')
        end,
        
        EnableRemoteViewingButtons = function(self)
            self.Sync.Abilities = self:GetBlueprint().Abilities
            self.Sync.Abilities.TargetLocation.Active = true
            self:AddToggleCap('RULEUTC_IntelToggle')
        end,

        OnTargetLocation = function(self, location)
            # Initial energy drain here - we drain resources instantly when an eye is relocated (including initial move)
            local aiBrain = self:GetAIBrain()
            local bp = self:GetBlueprint()
            local have = aiBrain:GetEconomyStored('ENERGY')
            local need = bp.Economy.InitialRemoteViewingEnergyDrain
            if not ( have > need ) then
                return
            end
            
            # Drain economy here
            aiBrain:TakeResource( 'ENERGY', bp.Economy.InitialRemoteViewingEnergyDrain )

            self.RemoteViewingData.VisibleLocation = location
            self:CreateVisibleEntity()
        end,

        CreateVisibleEntity = function(self)
            # Only give a visible area if we have a location and intel button enabled
            if not self.RemoteViewingData.VisibleLocation then
                self:SetMaintenanceConsumptionInactive()
                return
            end
            
            if self.RemoteViewingData.VisibleLocation and self.RemoteViewingData.DisableCounter == 0 and self.RemoteViewingData.IntelButton then
                local bp = self:GetBlueprint()
                self:SetMaintenanceConsumptionActive()
                # Create new visible area
                if not self.RemoteViewingData.Satellite then
                    local spec = {
                        X = self.RemoteViewingData.VisibleLocation[1],
                        Y = self.RemoteViewingData.VisibleLocation[2],
                        Z = self.RemoteViewingData.VisibleLocation[3],
                        Radius = bp.Intel.RemoteViewingRadius,
                        LifeTime = -1,
                        Omni = false,
                        Radar = false,
                        Vision = false,
                        Army = self:GetAIBrain():GetArmyIndex(),
                        RegenRadius = bp.RegenAura.RegenRadius,
                        RegenPerSecond = bp.RegenAura.RegenPerSecond,
                        RegenCeiling = bp.RegenAura.RegenCeiling,
                        RegenFloor = bp.RegenAura.RegenFloor,
                        AiBrain = self:GetAIBrain(),
                    }
                    self.RemoteViewingData.Satellite = RegenVizMarker(spec)
                    self.Trash:Add(self.RemoteViewingData.Satellite)
                else
                    # Move and reactivate old visible area
                    if not self.RemoteViewingData.Satellite:BeenDestroyed() then
                        Warp( self.RemoteViewingData.Satellite, self.RemoteViewingData.VisibleLocation )
                        self.RemoteViewingData.Satellite:IntelEnable('Vision')
                    end
                end
                # monitor resources
                if self.RemoteViewingData.ResourceThread then
                    self.RemoteViewingData.ResourceThread:Destroy()
                end
                self.RemoteViewingData.ResourceThread = self:ForkThread(self.DisableResourceMonitor)
            end
        end,

        DisableVisibleEntity = function(self)
            # visible entity already off
            if self.RemoteViewingData.DisableCounter > 1 then return end
            # disable vis entity and monitor resources
            if not self:IsDead() and self.RemoteViewingData.Satellite then
                self.RemoteViewingData.Satellite:IntelDisable('Vision')
            end
        end,

        OnIntelEnabled = function(self)
            # Make sure the button is only calculated once rather than once per possible intel type
            if not self.RemoteViewingData.IntelButton then
                self.RemoteViewingData.IntelButton = true
                self.RemoteViewingData.DisableCounter = self.RemoteViewingData.DisableCounter - 1
                self:CreateVisibleEntity()
            end
            SuperClass.OnIntelEnabled(self)
        end,

        OnIntelDisabled = function(self)
            # make sure button is only calculated once rather than once per possible intel type
            if self.RemoteViewingData.IntelButton then
                self.RemoteViewingData.IntelButton = false
                self.RemoteViewingData.DisableCounter = self.RemoteViewingData.DisableCounter + 1
                self:DisableVisibleEntity()
            end
            SuperClass.OnIntelDisabled(self)
        end,

        DisableResourceMonitor = function(self)
            WaitSeconds(0.5)
            local fraction = self:GetResourceConsumed()
            while fraction == 1 do
                WaitSeconds(0.5)
                fraction = self:GetResourceConsumed()
            end
            if self.RemoteViewingData.IntelButton then
                self.RemoteViewingData.DisableCounter = self.RemoteViewingData.DisableCounter + 1
                self.RemoteViewingData.ResourceThread = self:ForkThread(self.EnableResourceMonitor)
                self:DisableVisibleEntity()
            end
        end,

        EnableResourceMonitor = function(self)
            local recharge = self:GetBlueprint().Intel.ReactivateTime or 10
            WaitSeconds(recharge)
            self.RemoteViewingData.DisableCounter = self.RemoteViewingData.DisableCounter - 1
            self:CreateVisibleEntity()
        end,
    }    
end