class da_A9Ammo extends KFAmmunition;

defaultproperties
{
     MaxAmmo=300 //270 from base class but DA doesn't consider this as it's total ammo unlike KF so you add the magsize for KF
     AmmoPickupAmount=30
     InitialAmount=60
     PickupClass=Class'KFDA2Weapons.da_A9AmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=413,Y1=82,X2=457,Y2=125)
     ItemName="9mm bullets"
}
