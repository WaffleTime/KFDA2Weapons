class da_damtypes_XD40Pistol extends KFWeaponDamageType
	abstract;

defaultproperties
{
     bSniperWeapon=True
     WeaponClass=Class'KFDA2Weapons.da_XD40Handgun'
     HeadShotDamageMult=2.0 // Taken from da_weapons_BasicFire
     DeathString="%k > XD-40 Pistol > %o"
     FemaleSuicide="%o > XD-40 Pistol > herself."
     MaleSuicide="%o > XD-40 Pistol > himself."
     bRagdollBullet=True
     bBulletHit=True
     FlashFog=(X=500.000000)
     KDamageImpulse=750.000000
     KDeathVel=100.000000
     KDeathUpKick=0.000000
     VehicleDamageScaling=0.150000
}
