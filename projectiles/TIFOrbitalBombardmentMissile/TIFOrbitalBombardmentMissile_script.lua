local TIFMissileNuke = import('/lua/terranprojectiles.lua').TIFMissileNuke
local EffectTemplate = import('/lua/EffectTemplates.lua')

TIFOrbitalBombardmentMissile = Class(TIFMissileNuke) {

    InitialEffects = {
	'/effects/emitters/nuke_munition_launch_trail_02_emit.bp',
    },
    LaunchEffects = {
        '/effects/emitters/nuke_munition_launch_trail_03_emit.bp',
        '/effects/emitters/nuke_munition_launch_trail_05_emit.bp',
    },
    ThrustEffects = {
	'/effects/emitters/nuke_munition_launch_trail_04_emit.bp',
    },

    FxImpactTrajectoryAligned = false,
    FxImpactUnit = EffectTemplate.TAntiMatterShellHit01,
    FxImpactProp = EffectTemplate.TAntiMatterShellHit01,
    FxImpactLand = EffectTemplate.TAntiMatterShellHit01,
    FxImpactWater = EffectTemplate.TAntiMatterShellHit01,
    FxImpactShield = EffectTemplate.TAntiMatterShellHit01,

    OnCreate = function(self)
        TIFMissileNuke.OnCreate(self)
        self:SetCollisionShape('Sphere', 0, 0, 0, 2)
        self.MoveThread = self:ForkThread(self.MovementThread)
    end,

    MovementThread = function(self)        
        self.WaitTime = 0.1
        self:SetTurnRate(8)
        WaitSeconds(0.1)        
        while not self:BeenDestroyed() do
            self:SetTurnRateByDist()
            WaitSeconds(self.WaitTime)
        end
    end,

    CreateEffects = function( self, EffectTable, army, scale)
        for k, v in EffectTable do
            self.Trash:Add(CreateAttachedEmitter(self, -1, army, v):ScaleEmitter(scale))
        end
    end,

    SetTurnRateByDist = function(self)
	local army = self:GetArmy()
	local dist = VDist3(self:GetPosition(), self:GetCurrentTargetPosition())
        if dist > 25 and dist <= 768 then
		self:SetTurnRate(1080)
		WaitSeconds(2)
		--speed boost!! and effects
		self.CreateEffects( self, self.InitialEffects, army, 1 )
		self.CreateEffects( self, self.LaunchEffects, army, 1 )
		self.CreateEffects( self, self.ThrustEffects, army, 3 ) 
		self:SetMaxSpeed(70)
		self:SetAcceleration(50)
	end
    end,        

    GetDistanceToTarget = function(self)
        local tpos = self:GetCurrentTargetPosition()
        local mpos = self:GetPosition()
        local dist = VDist2(mpos[1], mpos[3], tpos[1], tpos[3])
        return dist
    end,
}

TypeClass = TIFOrbitalBombardmentMissile
