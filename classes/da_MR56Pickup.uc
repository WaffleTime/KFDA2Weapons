class da_MR56Pickup extends KFWeaponPickup;

defaultproperties
{
     Weight=5.0
     cost=1500
     AmmoCost=30
     BuyClipSize=40
     PowerValue=40
     SpeedValue=60
     RangeValue=55
     Description="MR-56 Assault Rifle."
     ItemName="MR-56 Assault Rifle" // Inventory Name
     ItemShortName="MR-56 Assault Rifle" // Trader Name
     AmmoItemName="556mm Rounds"
     AmmoMesh=StaticMesh'KillingFloorStatics.DualiesAmmo'
     InventoryType=Class'KFDA2Weapons.da_MR56AR'
     PickupMessage="You got the MR-56 Assault Rifle"
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_DA2KarmaStatics.KF_MR56_Pickup'
     CollisionHeight=5.000000
     PickupSound=Sound'KF_M7A3Snd.M7A3_Pickup'
}
