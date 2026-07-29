class da_A9Pickup extends KFWeaponPickup;

defaultproperties
{
     Weight=3.0
     cost=1250
     AmmoCost=20
     BuyClipSize=30
     PowerValue=30
     SpeedValue=85
     RangeValue=45
     Description="A9 Submachine Gun."
     ItemName="A9 Submachine Gun"
     ItemShortName="A9 SMG"
     AmmoItemName="9mm Rounds"
     AmmoMesh=StaticMesh'KillingFloorStatics.DualiesAmmo'
     InventoryType=Class'KFDA2Weapons.da_A9SMG'
     PickupMessage="You got the A9 Submachine Gun"
     PickupForce="AssaultRiflePickup"
     StaticMesh=StaticMesh'KF_DA2KarmaStatics.KF_A9_Pickup'
     CollisionHeight=5.000000
     PickupSound=Sound'KF_MAC10MPSnd.MAC10_Pickup'
}
