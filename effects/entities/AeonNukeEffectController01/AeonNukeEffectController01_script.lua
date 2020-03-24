local NullShell = import('/lua/sim/defaultprojectiles.lua').NullShell
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat
local RandomInt = import('/lua/utilities.lua').GetRandomInt
local EffectTemplate = import('/lua/EffectTemplates.lua')
local GCEffectTemplate = import('/mods/Global Commanders/lua/GCEffectTemplates.lua')

local AeonNukeEffect04 = '/mods/Global Commanders/effects/Entities/AeonNukeEffect04/AeonNukeEffect04_proj.bp' 
local AeonNukeEffect05 = '/mods/Global Commanders/effects/Entities/AeonNukeEffect05/AeonNukeEffect05_proj.bp'
local AeonNukeEffect06 = '/mods/Global Commanders/effects/Entities/AeonNukeEffect06/AeonNukeEffect06_proj.bp'


AeonNukeEffectController01 = Class(NullShell) {
    NukeInnerRingDamage = 0,
    NukeInnerRingRadius = 0,
    NukeInnerRingTicks = 0,
    NukeInnerRingTotalTime = 0,
    NukeOuterRingDamage = 0,
    NukeOuterRingRadius = 0,
    NukeOuterRingTicks = 0,
    NukeOuterRingTotalTime = 0,
	

    PassData = function(self, Data)
        if Data.NukeOuterRingDamage then self.NukeOuterRingDamage = Data.NukeOuterRingDamage end
        if Data.NukeOuterRingRadius then self.NukeOuterRingRadius = Data.NukeOuterRingRadius end
        if Data.NukeOuterRingTicks then self.NukeOuterRingTicks = Data.NukeOuterRingTicks end
        if Data.NukeOuterRingTotalTime then self.NukeOuterRingTotalTime = Data.NukeOuterRingTotalTime end
        if Data.NukeInnerRingDamage then self.NukeInnerRingDamage = Data.NukeInnerRingDamage end
        if Data.NukeInnerRingRadius then self.NukeInnerRingRadius = Data.NukeInnerRingRadius end
        if Data.NukeInnerRingTicks then self.NukeInnerRingTicks = Data.NukeInnerRingTicks end
        if Data.NukeInnerRingTotalTime then self.NukeInnerRingTotalTime = Data.NukeInnerRingTotalTime end
  
        self:CreateNuclearExplosion()
    end,

    CreateNuclearExplosion = function(self)
        local bp = self:GetBlueprint()
		local army = self:GetArmy()
		CreateLightParticle(self, -1, army, 200, 200, 'beam_white_01', 'beam_white_01')
			
		--Moving damage threads to be activated later
		--# Create Damage Threads only if damage is being delivered (prevents DamageArea script error for passing in 0 value)
		--if (self.NukeInnerRingDamage != 0) then
		--	self:ForkThread(self.InnerRingDamage)
		--end
        --if (self.NukeOuterRingDamage != 0) then
		--	self:ForkThread(self.OuterRingDamage)
		--end

		# Create thread that spawns and controls effects
		self:ForkThread(self.DistortionField)
        self:ForkThread(self.EffectThread)
        self:ForkThread(self.CreateEffectInnerPlasma)
        --self:ForkThread(self.SoundThread)
		--self:ForkThread(self.ForceThread)
    end,    
	
    OuterRingDamage = function(self)
        local myPos = self:GetPosition()
        if self.NukeOuterRingTotalTime == 0 then
            DamageArea(self:GetLauncher(), myPos, self.NukeOuterRingRadius, self.NukeOuterRingDamage, 'Normal', true, true)
        else
            local ringWidth = ( self.NukeOuterRingRadius / self.NukeOuterRingTicks )
            local tickLength = ( self.NukeOuterRingTotalTime / self.NukeOuterRingTicks )
            # Since we're not allowed to have an inner radius of 0 in the DamageRing function,
            # I'm manually executing the first tick of damage with a DamageArea function.
            DamageArea(self:GetLauncher(), myPos, ringWidth, self.NukeOuterRingDamage, 'Normal', true, true)
            WaitSeconds(tickLength)
            for i = 2, self.NukeOuterRingTicks do
                #print('Damage Ring: MaxRadius:' .. 2*i)
                DamageRing(self:GetLauncher(), myPos, ringWidth * (i - 1), ringWidth * i, self.NukeOuterRingDamage, 'Normal', true, true)
                WaitSeconds(tickLength)
            end
        end
    end,

    InnerRingDamage = function(self)
        local myPos = self:GetPosition()
        if self.NukeInnerRingTotalTime == 0 then
            DamageArea(self:GetLauncher(), myPos, self.NukeInnerRingRadius, self.NukeInnerRingDamage, 'Normal', true, true)
        else
            local ringWidth = ( self.NukeInnerRingRadius / self.NukeInnerRingTicks )
            local tickLength = ( self.NukeInnerRingTotalTime / self.NukeInnerRingTicks )
            # Since we're not allowed to have an inner radius of 0 in the DamageRing function,
            # I'm manually executing the first tick of damage with a DamageArea function.
            DamageArea(self:GetLauncher(), myPos, ringWidth, self.NukeInnerRingDamage, 'Normal', true, true)
            WaitSeconds(tickLength)
            for i = 2, self.NukeInnerRingTicks do
                #LOG('Damage Ring: MaxRadius:' .. ringWidth * i)
                DamageRing(self:GetLauncher(), myPos, ringWidth * (i - 1), ringWidth * i, self.NukeInnerRingDamage, 'Normal', true, true)
                WaitSeconds(tickLength)
            end
        end
    end,   
	
	
	# Create inner explosion plasma
    CreateEffectInnerPlasma = function(self)
		#LOG('inner plasma')
        local vx, vy, vz = self:GetVelocity()
        local num_projectiles = 25        
        local horizontal_angle = (2*math.pi) / num_projectiles
        local angleInitial = RandomFloat( 0, horizontal_angle )  
        local xVec, zVec
        local offsetMultiple = 5.0
        local px, pz

		WaitSeconds( 3.5 )
        for i = 0, (num_projectiles -1) do            
            xVec = (math.sin(angleInitial + (i*horizontal_angle)))
            zVec = (math.cos(angleInitial + (i*horizontal_angle)))
            px = (offsetMultiple*xVec)
            pz = (offsetMultiple*zVec)
            
            local proj = self:CreateProjectile( AeonNukeEffect05, px, -10, pz, xVec, 0, zVec )
            proj:SetLifetime(5.0)
            proj:SetVelocity(7.0)
            proj:SetAcceleration(-0.35)            
        end
	end,
	
	# Create random wavy electricity lines
    CreateEffectElectricity = function(self)
		#LOG('electricity effects')
        local vx, vy, vz = self:GetVelocity()
        local num_projectiles = 15        
        local horizontal_angle = (2*math.pi) / num_projectiles
        local angleInitial = RandomFloat( 0, horizontal_angle )  
        local xVec, zVec
        local offsetMultiple = 0.0
        local px, pz

		--WaitSeconds( 3.5 )
        for i = 0, (num_projectiles -1) do            
            xVec = (math.sin(angleInitial + (i*horizontal_angle)))
            zVec = (math.cos(angleInitial + (i*horizontal_angle)))
            px = (offsetMultiple*xVec)
            pz = (offsetMultiple*zVec)
            
            local proj = self:CreateProjectile( AeonNukeEffect06, px, -8, pz, xVec, 0, zVec )
            proj:SetLifetime(4.0)
            proj:SetVelocity(RandomFloat( 15, 25 ))
            proj:SetAcceleration(-0.35)            
        end
	end,  
	 
    
    EffectThread = function(self)
        local army = self:GetArmy()
        local position = self:GetPosition()
		
		#WaitSeconds(2.5)
		
        ####Create a light for this thing's flash.
        CreateLightParticle(self, -1, self:GetArmy(), 80, 14, 'flare_lens_add_03', 'ramp_white_07' )
    
		# Create explosion effects
        for k, v in GCEffectTemplate.AeonNukeHit01 do
            emit = CreateEmitterAtEntity(self,army,v):ScaleEmitter(0.3)
        end	
        
        ###self:ShakeCamera( radius, maxShakeEpicenter, minShakeAtRadius, interval )
        self:ShakeCamera( 105, 10, 0, 2 )
        WaitSeconds( 2 )
        self:ShakeCamera( 75, 1, 0, 15 )   
			

		WaitSeconds(1)
		
		# Knockdown force rings
        DamageRing(self, position, 0.1, 45, 1, 'Force', true)
        WaitSeconds(0.1)
        DamageRing(self, position, 0.1, 45, 1, 'Force', true)
		
		CreateLightParticle(self, -1, army, 80, 150, 'beam_white_01', 'ramp_quantum_warhead_flash_01')	
		local bp = self:GetBlueprint()
		# Play the "NukeExplosion" sound
        if bp.Audio.NukeExplosion then
            self:PlaySound(bp.Audio.NukeExplosion)
        end
        # Create explosion effects
        for k, v in GCEffectTemplate.AeonNukeDetonate01 do
            emit = CreateEmitterAtEntity(self,army,v):ScaleEmitter(1.5)
        end
		
		# Create ground decals
        local orientation = RandomFloat(0,2*math.pi)  
        CreateDecal(position, orientation, 'Scorch_012_albedo', '', 'Albedo', 250, 250, 1200, 0, army)
        CreateDecal(position, orientation, 'Crater01_normals', '', 'Normals', 100, 100, 1200, 0, army) 
		
		if (self.NukeInnerRingDamage != 0) then
			self:ForkThread(self.InnerRingDamage)
		end
        if (self.NukeOuterRingDamage != 0) then
			self:ForkThread(self.OuterRingDamage)
		end
        
		
		# Create fireball plumes to accentuate the explosive detonation
        local num_projectiles = 15        
        local horizontal_angle = (2*math.pi) / num_projectiles
        local angleInitial = RandomFloat( 0, horizontal_angle )  
        local xVec, yVec, zVec
        local angleVariation = 0.5        
        local px, py, pz       
     
        for i = 0, (num_projectiles -1) do            
            xVec = math.sin(angleInitial + (i*horizontal_angle) + RandomFloat(-angleVariation, angleVariation) ) 
            yVec = RandomFloat( 0.3, 1.5 ) + 1.2
            zVec = math.cos(angleInitial + (i*horizontal_angle) + RandomFloat(-angleVariation, angleVariation) ) 
            px = RandomFloat( 0.5, 1.0 ) * xVec
            py = RandomFloat( 0.5, 1.0 ) * yVec
            pz = RandomFloat( 0.5, 1.0 ) * zVec
            
            local proj = self:CreateProjectile( AeonNukeEffect04, px, py, pz, xVec, yVec, zVec )
            proj:SetVelocity(RandomFloat( 10, 25  ))
            proj:SetBallisticAcceleration(-9.8)            
        end        
		--CreateLightParticle(self, -1, army, 13, 3, 'beam_white_01', 'ramp_quantum_warhead_flash_01')
        CreateEmitterAtEntity( self, army, '/effects/emitters/quantum_warhead_ring_01_emit.bp' )
    end,
	
	DistortionField = function( self )
        local proj = self:CreateProjectile('/effects/QuantumWarhead/QuantumWarheadEffect01_proj.bp')
        local scale = proj:GetBlueprint().Display.UniformScale

        proj:SetScaleVelocity(0.123 * scale,0.123 * scale,0.123 * scale)
        WaitSeconds(17.0)
        proj:SetScaleVelocity(0.01 * scale,0.01 * scale,0.01 * scale)
    end,
	
}
TypeClass = AeonNukeEffectController01
