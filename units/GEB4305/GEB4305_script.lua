local QuantumTeleporterUnit = import('/mods/Global Commanders/lua/GCunits.lua').QuantumTeleporterUnit

GEB4305 = Class(QuantumTeleporterUnit) {

    GateEffectVerticalOffset = 0.35,
    GateEffectScale = 0.42,

    OnStopBeingBuilt = function(self,builder,layer)
        QuantumTeleporterUnit.OnStopBeingBuilt(self, builder, layer)
        CreateAttachedEmitter(self,'Gate_FX01',self:GetArmy(),'/effects/emitters/terran_gate_01_emit.bp')
        CreateAttachedEmitter(self,'Gate_FX02',self:GetArmy(),'/effects/emitters/terran_gate_01_emit.bp')
        CreateAttachedEmitter(self,'Gate_FX03',self:GetArmy(),'/effects/emitters/terran_gate_01_emit.bp')
        CreateAttachedEmitter(self,'Gate_FX04',self:GetArmy(),'/effects/emitters/terran_gate_01_emit.bp')
    end,
}

TypeClass = GEB4305