local SStructureUnit = import('/lua/seraphimunits.lua').SStructureUnit
local RemoteTracking = import('/mods/Global Commanders/lua/RemoteTracking.lua').RemoteTracking
SStructureUnit = RemoteTracking( SStructureUnit )

GSB3301 = Class(SStructureUnit) {}

TypeClass = GSB3301
