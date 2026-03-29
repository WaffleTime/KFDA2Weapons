class da_XD40Pickup extends KFWeaponPickup;

defaultproperties
{
     Weight=1.000000
     cost=400
     AmmoCost=10
     BuyClipSize=17
     PowerValue=20
     SpeedValue=50
     RangeValue=35
     Description="A 9mm handgun."
     ItemName="XD-40 Pistol"
     ItemShortName="XD-40"
     AmmoItemName="9mm Rounds"
     AmmoMesh=StaticMesh'KillingFloorStatics.DualiesAmmo'
     InventoryType=Class'KFDA2Weapons.da_XD40Handgun'
     PickupMessage="You got an XD40 Handgun"
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_DA2KarmaStatics.KF_XD40_Pickup'
     CollisionHeight=5.000000
     PickupSound=Sound'KF_9MMSnd.9mm_Pickup'
     EquipmentCategoryID=1
     CorrespondingPerkIndex=2
}
