class da_damtypes_MR56Rifle extends KFWeaponDamageType
	abstract;

defaultproperties
{
     WeaponClass=Class'KFDA2Weapons.da_MR56AR'
     HeadShotDamageMult=1.5 //2.0 Taken from da_weapons_BasicFire
     DeathString="%k > MR-56 Assault Rifle > %o"
     FemaleSuicide="%o > MR-56 Assault Rifle > herself."
     MaleSuicide="%o > MR-56 Assault Rifle > himself."
     bRagdollBullet=True
     bBulletHit=True
     FlashFog=(X=400.000000)
     KDamageImpulse=5500.000000
     KDeathVel=175.000000
     KDeathUpKick=15.000000
     VehicleDamageScaling=0.260000
     //bDealBurningDamage=True //This is here for some reason
}
