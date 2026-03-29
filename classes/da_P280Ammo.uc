class da_P280Ammo extends KFAmmunition;

defaultproperties
{
     MaxAmmo=70 //60 from base class but DA doesn't consider this as it's total ammo unlike KF so you add the magsize for KF
     AmmoPickupAmount=10
     InitialAmount=20
     PickupClass=Class'KFDA2Weapons.da_XD40AmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=413,Y1=82,X2=457,Y2=125)
     ItemName="9mm bullets"
}
