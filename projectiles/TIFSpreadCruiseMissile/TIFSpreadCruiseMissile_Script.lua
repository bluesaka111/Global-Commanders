local TMissileCruiseProjectile = import('/lua/terranprojectiles.lua').TMissileCruiseProjectile02
local EffectTemplate = import('/lua/EffectTemplates.lua')
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

TIFSpreadCruiseMissile = Class(TMissileCruiseProjectile) {

    FxImpactUnit = EffectTemplate.TNapalmCarpetBombHitLand01,
    FxImpactProp = EffectTemplate.TNapalmCarpetBombHitLand01,
    FxImpactLand = EffectTemplate.TNapalmCarpetBombHitLand01,
    FxImpactWater = EffectTemplate.TNapalmHvyCarpetBombHitWater01,
	FxUnitHitScale = 2,
	FxPropHitScale = 2, 
	FxLandHitScale = 2,
	FxWaterHitScale = 2,

    BeamName = '/effects/emitters/missile_exhaust_fire_beam_06_emit.bp',
    InitialEffects = {'/effects/emitters/nuke_munition_launch_trail_02_emit.bp',},
    LaunchEffects = {
        '/effects/emitters/nuke_munition_launch_trail_03_emit.bp',
        '/effects/emitters/nuke_munition_launch_trail_05_emit.bp',
    },
    ThrustEffects = {'/effects/emitters/nuke_munition_launch_trail_04_emit.bp',},  

    OnCreate = function(self)
        TMissileCruiseProjectile.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 2.0)
        self.MovementTurnLevel = 1
        self:ForkThread( self.MovementThread )
    end,
    
    CreateEffects = function( self, EffectTable, army, scale)
        for k, v in EffectTable do
            self.Trash:Add(CreateAttachedEmitter(self, -1, army, v):ScaleEmitter(scale))
        end
    end,

     MovementThread = function(self)   
        local army = self:GetArmy()
        local target = self:GetTrackingTarget()
        local launcher = self:GetLauncher()            
        self.CreateEffects( self, self.InitialEffects, army, 1 )      
        self.WaitTime = 0.1
        self:SetTurnRate(8)
        WaitSeconds(0.3)   
        self.CreateEffects( self, self.LaunchEffects, army, 1 )
        self.CreateEffects( self, self.ThrustEffects, army, 1 )        
        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
            WaitSeconds(self.WaitTime)
        end
    end,

    SetTurnRateByDist = function(self)
        local dist = self:GetDistanceToTarget()
        if dist > 160 then        
            WaitSeconds(2)
            self:SetTurnRate(25)
        elseif dist > 120 and dist <= 160 then
	    self:SetTurnRate(50)
        elseif dist > 80 and dist <= 120 then
	    self:SetTurnRate(100)
        elseif dist > 40 and dist <= 80 then
            self:SetTurnRate(150)
	elseif dist > 0 and dist <= 40 then            
            self:SetTurnRate(200)   
            KillThread(self.MoveThread)         
        end
    end,        

    GetDistanceToTarget = function(self)
        local tpos = self:GetCurrentTargetPosition()
        local mpos = self:GetPosition()
        local dist = VDist2(mpos[1], mpos[3], tpos[1], tpos[3])
        return dist
    end,
    
    OnEnterWater = function(self)
        TMissileCruiseProjectile.OnEnterWater(self)
        self:SetDestroyOnWater(false)
    end,   

    OnImpact = function(self, TargetType, targetEntity)
	if TargetType != 'Water' then 
	    local rotation = RandomFloat(0,2*math.pi)
	    local size = RandomFloat(7.5,9.0)	        
	    CreateDecal(self:GetPosition(), rotation, 'scorch_001_albedo', '', 'Albedo', size, size, 150, 15, self:GetArmy())
	end	 
	TMissileCruiseProjectile.OnImpact( self, TargetType, targetEntity )
    end,
}
TypeClass = TIFSpreadCruiseMissile

