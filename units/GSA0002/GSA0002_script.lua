local SConstructionUnit = import('/lua/seraphimunits.lua').SConstructionUnit
local WeaponsFile = import ('/lua/seraphimweapons.lua')
local SDFExperimentalPhasonProj = WeaponsFile.SDFExperimentalPhasonProj
local SDFUnstablePhasonBeam = WeaponsFile.SDFUnstablePhasonBeam

local EffectTemplate = import('/lua/EffectTemplates.lua')

GSA0002 = Class(SConstructionUnit) {

    Weapons = {
        AL = Class(SDFExperimentalPhasonProj) {},
        AA = Class(SDFUnstablePhasonBeam) {},
    },

    OnCreate = function(self)
        SConstructionUnit.OnCreate(self)
        for k, v in EffectTemplate.SDFExperimentalPhasonProjFXTrails01 do
            CreateAttachedEmitter(self,'XSA0001', self:GetArmy(), v):ScaleEmitter(0.5)
        end
    end,

    Parent = nil,

    SetParent = function(self, parent, podName)
        self.Parent = parent
        self.Pod = podName
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        self.Parent:NotifyOfPodDeath(self.Pod)
        self.Parent = nil
        SConstructionUnit.OnKilled(self, instigator, type, overkillRatio)
    end,
}

TypeClass = GSA0002