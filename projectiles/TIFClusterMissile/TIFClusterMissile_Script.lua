#
# Terran Land-Based Cruise Missile
#
local TMissileCruiseProjectile = import('/lua/terranprojectiles.lua').TMissileCruiseProjectile
local Explosion = import('/lua/defaultexplosions.lua')
local EffectTemplate = import('/lua/EffectTemplates.lua')
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local VizMarker = import('/lua/sim/VizMarker.lua').VizMarker

TIFClusterMissile = Class(TMissileCruiseProjectile) {

    BeamName = '/effects/emitters/missile_exhaust_fire_beam_06_emit.bp',
    InitialEffects = {'/effects/emitters/nuke_munition_launch_trail_02_emit.bp',},
    LaunchEffects = {
        '/effects/emitters/nuke_munition_launch_trail_03_emit.bp',
        '/effects/emitters/nuke_munition_launch_trail_05_emit.bp',
    },
    ThrustEffects = {'/effects/emitters/nuke_munition_launch_trail_04_emit.bp',
                     '/effects/emitters/nuke_munition_launch_trail_06_emit.bp',
    }, 

    OnCreate = function(self)
        TMissileCruiseProjectile.OnCreate(self)
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

    SetTurnRateByDist = function(self)
	local dist = VDist3(self:GetPosition(), self:GetCurrentTargetPosition())
        if dist > 50 then        
            #Freeze the turn rate as to prevent steep angles at long distance targets
			self:SetTurnRate(15)
            WaitSeconds(0.5)
            self:SetTurnRate(90)
			WaitSeconds(0.1)
			self:SetTurnRate(50)
        elseif dist > 35 and dist <= 50 then
			# Increase check intervals
			self:SetTurnRate(15)
			WaitSeconds(0.1)
            self:SetTurnRate(90)
			WaitSeconds(0.1)
            self:SetTurnRate(15)
        elseif dist > 25 and dist <= 35 then
			self:SetTurnRate(15)
			WaitSeconds(0.1)
            self:SetTurnRate(90)
			WaitSeconds(0.1)
			self:SetTurnRate(15)
        elseif dist > 8 and dist <= 25 then
			self:SetTurnRate(45)
            WaitSeconds(0.1)
            self:SetTurnRate(100)
		elseif dist > 0 and dist <= 8 then
			# Further increase check intervals            
            self:SetTurnRate(360)   
			WaitSeconds(0.1)
			--LOG('Distance Split : ', dist)
			--ForkThread(self.OnImpact)
            --KillThread(self.MoveThread)         

			local FxFragEffect = EffectTemplate.SThunderStormCannonProjectileSplitFx 
			local ChildProjectileBP = '/mods/Global Commanders/projectiles/TIFClusterMissileChild/TIFClusterMissileChild_proj.bp'  
              
			### Split effects
			for k, v in FxFragEffect do
			    CreateEmitterAtEntity( self, self:GetArmy(), v )
			end
			
			local vx, vy, vz = self:GetVelocity()
			local velocity = 20
		
			# One initial projectile following same directional path as the original
			#self:CreateChildProjectile(ChildProjectileBP):SetVelocity(vx, vy, vz):SetVelocity(velocity):PassDamageData(self.DamageData)
   		
			# Create several other projectiles in a dispersal pattern
			local numProjectiles = 3
			
			local angle = (2*math.pi) / numProjectiles
			local angleInitial = RandomFloat( 0, angle )
			
			# Randomization of the spread
			local angleVariation = angle * 3 # Adjusts angle variance spread
			local spreadMul = 1.25 # Adjusts the width of the dispersal        
        
			--vy= -0.8
        
			local xVec = 0
			local yVec = vy
			local zVec = 0
    
			# Launch projectiles at semi-random angles away from split location
			for i = 0, (numProjectiles -1) do
				xVec = vx + (math.sin(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul
				zVec = vz + (math.cos(angleInitial + (i*angle) + RandomFloat(-angleVariation, angleVariation))) * spreadMul 
				local proj = self:CreateChildProjectile(ChildProjectileBP)
				proj:SetVelocity(xVec,yVec,zVec)
				proj:SetVelocity(velocity)
				proj:PassDamageData(self.DamageData)                        
			end
        
			self:Destroy()

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
}

TypeClass = TIFClusterMissile

