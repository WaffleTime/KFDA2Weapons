class da_MR40Ammo extends KFAmmunition;

defaultproperties
{
     MaxAmmo=300 //200 from base class but DA doesn't consider this as it's total ammo unlike KF so you add the magsize for KF
     AmmoPickupAmount=100
     InitialAmount=100
     PickupClass=Class'KFDA2Weapons.da_MR40AmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=413,Y1=82,X2=457,Y2=125)
     ItemName="556mm bullets"
}
