class da_GK2Pickup extends KFWeaponPickup;

defaultproperties
{
     Weight=5.0
     cost=2000
     AmmoCost=24
     BuyClipSize=8
	PowerValue=70
	SpeedValue=50
	RangeValue=20
     Description="GK2 Shotgun."
     ItemName="GK2 Shotgun"
     ItemShortName="GK2 Shotgun"
     AmmoItemName="12 Gauge Shells"
     AmmoMesh=StaticMesh'KillingFloorStatics.DualiesAmmo'
     InventoryType=Class'KFDA2Weapons.da_GK2Shotgun'
     PickupMessage="You got the GK2 Shotgun"
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_DA2KarmaStatics.KF_GK2_Pickup'
     CollisionHeight=5.000000
     PickupSound=Sound'KF_KSGSnd.KSG_Pickup'
}
