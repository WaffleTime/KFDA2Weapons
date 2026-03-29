class da_P280Pickup extends KFWeaponPickup;

defaultproperties
{
     Weight=2.0
     cost=750
     AmmoCost=20
     BuyClipSize=10
     PowerValue=20
     SpeedValue=50
     RangeValue=35
     Description="High Caliber Pistol chambered in 12.4x10.2mm munitions."
     ItemName="P2-80 Pistol"
     ItemShortName="P2-80"
     AmmoItemName="9mm Rounds"
     AmmoMesh=StaticMesh'KillingFloorStatics.DualiesAmmo'
     InventoryType=Class'KFDA2Weapons.da_P280Handgun'
     PickupMessage="You got a P2-80 Handgun"
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_DA2KarmaStatics.KF_P280_Pickup'
     CollisionHeight=5.000000
     PickupSound=Sound'KF_HandcannonSnd.50AE_Pickup'
     EquipmentCategoryID=1
     CorrespondingPerkIndex=2
}
