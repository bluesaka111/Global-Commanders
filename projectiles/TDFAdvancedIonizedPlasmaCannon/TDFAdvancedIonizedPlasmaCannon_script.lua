local TIonizedPlasmaGatlingCannon = import('/lua/terranprojectiles.lua').TIonizedPlasmaGatlingCannon

TDFAdvancedIonizedPlasmaCannon = Class(TIonizedPlasmaGatlingCannon) {

	FxWaterHitScale = 2.5,
	FxLandHitScale = 2.5,
	FxNoneHitScale = 2.5,
	FxPropHitScale = 2.5,      
	FxUnitHitScale = 2.5,  
	FxTrailScale = 2.5,
	PolyTrailScale = 2.5,
}
TypeClass = TDFAdvancedIonizedPlasmaCannon