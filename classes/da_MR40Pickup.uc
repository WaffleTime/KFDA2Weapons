class da_MR40Pickup extends KFWeaponPickup;

defaultproperties
{
     Weight=7.0
     cost=2500
     AmmoCost=100
     BuyClipSize=100
     PowerValue=40
     SpeedValue=60
     RangeValue=55
     Description="MR-40 Machine Gun"
     ItemName="MR-40 Machine Gun" // Inventory Name
     ItemShortName="MR-40 Machine Gun" // Trader Name
     AmmoItemName="556mm Rounds"
     AmmoMesh=StaticMesh'KillingFloorStatics.DualiesAmmo'
     InventoryType=Class'KFDA2Weapons.da_MR40Heavy'
     PickupMessage="You got the MR-40 Machine Gun"
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_DA2KarmaStatics.KF_MR40_Pickup'
     CollisionHeight=5.000000
     PickupSound=Sound'KF_FNFALSnd.FNFAL_Pickup'
}
