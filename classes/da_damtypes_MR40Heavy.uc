class da_damtypes_MR40Heavy extends KFWeaponDamageType
	abstract;

defaultproperties
{
     WeaponClass=Class'KFDA2Weapons.da_MR40Heavy'
     HeadShotDamageMult=2.0 // Taken from da_weapons_BasicFire
     DeathString="%k > MR-40 Machine Gun > %o"
     FemaleSuicide="%o > MR-40 Machine Gun > herself."
     MaleSuicide="%o > MR-40 Machine Gun > himself."
     bRagdollBullet=True
     bBulletHit=True
     FlashFog=(X=600.000000)
     KDamageImpulse=2000.000000
     KDeathVel=80.000000
     KDeathUpKick=8.000000
     VehicleDamageScaling=0.400000
}
