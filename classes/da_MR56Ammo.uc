class da_MR56Ammo extends KFAmmunition;

defaultproperties
{
     MaxAmmo=240 //200 from base class but DA doesn't consider this as it's total ammo unlike KF so you add the magsize for KF
     AmmoPickupAmount=40
     InitialAmount=80
     PickupClass=Class'KFDA2Weapons.da_MR56AmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=413,Y1=82,X2=457,Y2=125)
     ItemName="556mm bullets"
}
