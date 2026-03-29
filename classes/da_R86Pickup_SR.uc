class da_R86Pickup_SR extends KFWeaponPickup;

defaultproperties
{
     Weight=7.0
     cost=750
     AmmoCost=18
     BuyClipSize=6
     PowerValue=95
     SpeedValue=30
     RangeValue=100
     Description="High Caliber Sniper."
     ItemName="R86 Sniper Rifle SR"
     ItemShortName="R86 Sniper Rifle SR"
     AmmoItemName="R86 Sniper Rounds"
     AmmoMesh=StaticMesh'KillingFloorStatics.DualiesAmmo'
     InventoryType=Class'KFDA2Weapons.da_R86Sniper_SR'
     PickupMessage="You got the R86 Sniper Rifle SR"
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_DA2KarmaStatics.KF_P280_Pickup'
     CollisionHeight=5.000000
     PickupSound=Sound'KF_HandcannonSnd.50AE_Pickup'
     EquipmentCategoryID=3
     CorrespondingPerkIndex=2
}
