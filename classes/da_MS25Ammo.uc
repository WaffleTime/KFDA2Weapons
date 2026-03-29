class da_MS25Ammo extends KFAmmunition;

defaultproperties
{
     MaxAmmo=16 //8 Adding more because without it kinda blows //4 from base class but DA doesn't consider this as it's total ammo unlike KF so you add the magsize for KF
     AmmoPickupAmount=4
     InitialAmount=4
     PickupClass=Class'KFDA2Weapons.da_MS25AmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=413,Y1=82,X2=457,Y2=125)
     ItemName="122mm Rocket"
}
