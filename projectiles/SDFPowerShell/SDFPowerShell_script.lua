local SSuthanusArtilleryShell = import('/lua/seraphimprojectiles.lua').SSuthanusArtilleryShell
local RandomFloat = import('/lua/utilities.lua').GetRandomFloat

SDFPowerShell = Class(SSuthanusArtilleryShell) {
	OnImpact = function(self, TargetType, TargetEntity)
		SSuthanusArtilleryShell.OnImpact(self, TargetType, TargetEntity)
		if TargetType != 'Shield' and TargetType != 'Water' and TargetType != 'UnitAir' then
			local rotation = RandomFloat(0,2*math.pi)
	        
			CreateDecal(self:GetPosition(), rotation, 'crater_radial01_normals', '', 'Alpha Normals', 10, 10, 300, 0, self:GetArmy())
			CreateDecal(self:GetPosition(), rotation, 'crater_radial01_albedo', '', 'Albedo', 12, 12, 300, 0, self:GetArmy())
		end
	end,
}

TypeClass = SDFPowerShell
