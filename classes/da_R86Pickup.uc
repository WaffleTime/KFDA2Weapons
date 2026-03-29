class da_R86Pickup extends KFWeaponPickup;

defaultproperties
{
     Weight=7.0
     cost=3000
     AmmoCost=27
     BuyClipSize=6
     PowerValue=95
     SpeedValue=30
     RangeValue=100
     Description="High Caliber Sniper."
     ItemName="R86 Sniper Rifle"
     ItemShortName="R86 Sniper Rifle"
     AmmoItemName="R86 Sniper Rounds"
     AmmoMesh=StaticMesh'KillingFloorStatics.DualiesAmmo'
     InventoryType=Class'KFDA2Weapons.da_R86Sniper'
     PickupMessage="You got the R86 Sniper Rifle"
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_DA2KarmaStatics.KF_R86_Pickup'
     CollisionHeight=5.000000
     PickupSound=Sound'KF_M99Snd.M99_Pickup'
     EquipmentCategoryID=3
     CorrespondingPerkIndex=2
}
