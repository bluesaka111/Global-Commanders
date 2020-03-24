#****************************************************************************
#**
#**  File     :  /cdimage/units/UEA0001/UEA0001_script.lua
#**  Author(s):  John Comes
#**
#**  Summary  :  UEF CDR Pod Script
#**
#**  Copyright © 2005 Gas Powered Games, Inc.  All rights reserved.
#****************************************************************************

local TConstructionUnit = import('/lua/terranunits.lua').TConstructionUnit
local TSAMLauncher = import('/lua/terranweapons.lua').TSAMLauncher
local TIFCarpetBombWeapon = import('/lua/terranweapons.lua').TIFCarpetBombWeapon

GEA0002 = Class(TConstructionUnit) {

    Weapons = {
        MissileRack = Class(TSAMLauncher) {},
        MissileWeapon = Class(TIFCarpetBombWeapon) {},
    },

    Parent = nil,


    SetParent = function(self, parent, podName)
        self.Parent = parent
        self.Pod = podName
    end,

    OnKilled = function(self, instigator, type, overkillRatio)
        self.Parent:NotifyOfPodDeath(self.Pod)
        self.Parent = nil
        TConstructionUnit.OnKilled(self, instigator, type, overkillRatio)
    end,

}

TypeClass = GEA0002