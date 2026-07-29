class da_MS25Pickup extends KFWeaponPickup;

defaultproperties
{
     Weight=7.0
     cost=3000
     AmmoCost=100
     BuyClipSize=4
     PowerValue=100
     SpeedValue=20
     RangeValue=64
     Description="MS-25 Rocket Launcher"
     ItemName="MS-25 Rocket Launcher" // Inventory Name
     ItemShortName="MS-25 Rocket Launcher" // Trader Name
     AmmoItemName="122mm Rocket"
     AmmoMesh=StaticMesh'KillingFloorStatics.DualiesAmmo'
     InventoryType=Class'KFDA2Weapons.da_MS25RocketLauncher'
     PickupMessage="You got the MS-25 Rocket Launcher"
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_DA2KarmaStatics.KF_MS25_Pickup'
     CollisionHeight=5.000000
     PickupSound=Sound'KF_LAWSnd.LAW_Pickup'
}
