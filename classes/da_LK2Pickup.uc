class da_LK2Pickup extends KFWeaponPickup;

defaultproperties
{
     Weight=5.0
     cost=2000
     AmmoCost=20
     BuyClipSize=8
     PowerValue=70
     SpeedValue=60
     RangeValue=30
     Description="LK2 AutoShotgun hold the trigger to keep the pellets coming."
     ItemName="LK2 AutoShotgun"
     ItemShortName="LK2 AutoShotgun"
     AmmoItemName="12 Gauge Shells"
     AmmoMesh=StaticMesh'KillingFloorStatics.DualiesAmmo'
     InventoryType=Class'KFDA2Weapons.da_LK2Shotgun'
     PickupMessage="You got the LK2 AutoShotgun"
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_DA2KarmaStatics.KF_LK2_Pickup'
     CollisionHeight=5.000000
     PickupSound=Sound'KF_M4ShotgunSnd.WEP_Benelli_Foley_Pickup'
}
