local Entity = import('/lua/sim/Entity.lua').Entity
local EffectUtil = import('/lua/EffectUtilities.lua')
VizMarker = Class(Entity) {
    FieldEffect = '/mods/Global Commanders/effects/emitters/cybran_cloak_aura_01_emit.bp',
    
    __init = function(self, spec)
        #LOG('__VizMarker')
        Entity.__init(self, spec)
        self.X = spec.X
        self.Z = spec.Z
        self.Y = spec.Y
        self.LifeTime = spec.LifeTime
        self.Radius = spec.Radius
        self.Army = spec.Army
        self.Omni = spec.Omni
        self.Radar = spec.Radar
        self.Vision = spec.Vision
        self.WaterVision = spec.WaterVision
        self.CloakField = spec.CloakField
        self.RadarStealthField = spec.RadarStealthField
        self.CloakFieldRadius = spec.CloakFieldRadius
        self.RadarStealthFieldRadius = spec.RadarStealthFieldRadius
    end,

    OnCreate = function(self)
        Entity.OnCreate(self)
        #LOG('VizMarker OnCreate')
        Warp(self, Vector(self.X, self.Y, self.Z))
        self.EffectsBag = {}
        if self.Omni != false then
            self:InitIntel(self.Army, 'Omni', self.Radius)
            self:EnableIntel('Omni')
        end
        if self.Radar != false then
            self:InitIntel(self.Army, 'Radar', self.Radius)
            self:EnableIntel('Radar')
        end        
        if self.Vision != false then
            self:InitIntel(self.Army, 'Vision', self.Radius)
            self:EnableIntel('Vision')
        end
        if self.WaterVision != false then
            self:InitIntel(self.Army, 'WaterVision', self.Radius)
            self:EnableIntel('WaterVision')
        end
        if self.RadarStealthField != false then
            self:InitIntel(self.Army, 'RadarStealthField', self.RadarStealthFieldRadius)
            self:EnableIntel('RadarStealthField')
        end
        if self.CloakField != false then
            self:InitIntel(self.Army, 'CloakField', self.CloakFieldRadius)
            self:EnableIntel('CloakField')
            local effect = nil
            effect = CreateEmitterOnEntity(self, self.Army, self.FieldEffect):ScaleEmitter(10):OffsetEmitter(0,3,0)
            table.insert(self.EffectsBag, effect)
        end
        if self.LifeTime > 0 then
            self.LifeTimeThread = ForkThread(self.VisibleLifeTimeThread, self)
        end
    end,

    VisibleLifeTimeThread = function(self)
        WaitSeconds(self.LifeTime)
        self:Destroy()
    end,

    OnDestroy = function(self)
        Entity.OnDestroy(self)
        for k, v in self.EffectsBag do
            v:Destroy()
        end
        self.EffectsBag = {}
        if self.LifeTimeThread then
            self.LifeTimeThread:Destroy()
        end
    end,
    
    IntelOn = function(self)
        if self.Omni != false then
            self:EnableIntel('Omni')
        end
        if self.Radar != false then
            self:EnableIntel('Radar')
        end        
        if self.Vision != false then
            self:EnableIntel('Vision')
        end
        if self.WaterVision != false then
            self:EnableIntel('WaterVision')
        end
        if self.RadarStealthField != false then
            self:EnableIntel('RadarStealthField')
        end
        if self.CloakField != false then
            self:EnableIntel('CloakField')
            local effect = nil
            effect = CreateEmitterOnEntity(self, self.Army, self.FieldEffect):ScaleEmitter(10):OffsetEmitter(0,3,0)
            table.insert(self.EffectsBag, effect)
        end
    end,
    
    IntelOff = function(self)
        if self.Omni != false then
            self:DisableIntel('Omni')
        end
        if self.Radar != false then
            self:DisableIntel('Radar')
        end        
        if self.Vision != false then
            self:DisableIntel('Vision')
        end
        if self.WaterVision != false then
            self:DisableIntel('WaterVision')
        end
        if self.RadarStealthField != false then
            self:DisableIntel('RadarStealthField')
        end
        if self.CloakField != false then
            self:DisableIntel('CloakField')
        end
        for k, v in self.EffectsBag do
            v:Destroy()
        end
        self.EffectsBag = {}
    end,
}

# TODO: make sure each new instance is using a previous metatable
function RemoteIntel(SuperClass)
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
                self.RemoteViewingData.Satellite:IntelOff()
            end
            self:SetMaintenanceConsumptionInactive()
        end,
        
        DisableRemoteViewingButtons = function(self)
            self.Sync.Abilities = self:GetBlueprint().Abilities
            self.Sync.Abilities.TargetLocation.Active = false
            #self:RemoveToggleCap('RULEUTC_IntelToggle')
        end,
        
        EnableRemoteViewingButtons = function(self)
            self.Sync.Abilities = self:GetBlueprint().Abilities
            self.Sync.Abilities.TargetLocation.Active = true
            #self:AddToggleCap('RULEUTC_IntelToggle')
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
                        Omni = bp.Intel.RemoteOmni or false,
                        Radar = bp.Intel.RemoteRadar or false,
                        Vision = bp.Intel.RemoteVision or false,
                        WaterVision = bp.Intel.RemoteWaterVision or false,
                        RadarStealthFieldRadius = bp.Intel.RemoteRadarStealthFieldRadius,
                        RadarStealthField = bp.Intel.RemoteRadarStealthField or false,
                        CloakFieldRadius = bp.Intel.RemoteCloakFieldRadius,
                        CloakField = bp.Intel.RemoteCloakField or false,
                        Army = self:GetAIBrain():GetArmyIndex(),
                    }
                    self.RemoteViewingData.Satellite = VizMarker(spec)
                    self.Trash:Add(self.RemoteViewingData.Satellite)
                else
                    # Move and reactivate old visible area
                    if not self.RemoteViewingData.Satellite:BeenDestroyed() then
                        Warp( self.RemoteViewingData.Satellite, self.RemoteViewingData.VisibleLocation )
                        self.RemoteViewingData.Satellite:IntelOn()
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
                self.RemoteViewingData.Satellite:IntelOff()
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