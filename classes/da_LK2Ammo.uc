class da_LK2Ammo extends KFAmmunition;

defaultproperties
{
     MaxAmmo=48 //40 from base class but DA doesn't consider this as it's total ammo unlike KF so you add the magsize for KF
     AmmoPickupAmount=8
     InitialAmount=16
     PickupClass=Class'KFDA2Weapons.da_LK2AmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=413,Y1=82,X2=457,Y2=125)
     ItemName="12 Gauge Shells"
}
