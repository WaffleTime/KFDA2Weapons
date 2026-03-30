class da_R86Ammo_SR extends KFAmmunition;

defaultproperties
{
     MaxAmmo=54 //48 from base class but DA doesn't consider this as it's total ammo unlike KF so you add the magsize for KF
     AmmoPickupAmount=6
     InitialAmount=12
     PickupClass=Class'KFDA2Weapons.da_R86AmmoPickup'
     IconMaterial=Texture'KillingFloorHUD.Generic.HUD'
     IconCoords=(X1=413,Y1=82,X2=457,Y2=125)
     ItemName="R86 Sniper Bullets"
}
