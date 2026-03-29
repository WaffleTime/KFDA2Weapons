class da_damtypes_LK2Shotgun extends KFProjectileWeaponDamageType
	abstract;

defaultproperties
{
     bIsPowerWeapon=True
     WeaponClass=Class'KFDA2Weapons.da_LK2Shotgun'
     HeadShotDamageMult=1.0 //2.0 Set to 1 to keep the 2x HS mult across all weapons the same
     DeathString="%k > Shotgun > %o"
     FemaleSuicide="%o > Shotgun > herself."
     MaleSuicide="%o > Shotgun > himself."
     bRagdollBullet=True
     bBulletHit=True
     FlashFog=(X=600.000000)
     KDamageImpulse=10000.000000
     KDeathVel=300.000000
     VehicleDamageScaling=0.220000
}
