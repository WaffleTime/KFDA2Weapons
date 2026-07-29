class da_damtypes_p280Pistol extends KFWeaponDamageType
	abstract;

defaultproperties
{
     bSniperWeapon=True
     WeaponClass=Class'KFDA2Weapons.da_p280Handgun'
     HeadShotDamageMult=1.5 //2.0 Taken from da_weapons_BasicFire
     DeathString="%k > P2-80 Pistol > %o"
     FemaleSuicide="%o > P2-80 Pistol > herself."
     MaleSuicide="%o > P2-80 Pistol > himself."
     bRagdollBullet=True
     bBulletHit=True
     FlashFog=(X=700.000000)
     KDamageImpulse=4500.000000
     KDeathVel=200.000000
     KDeathUpKick=20.000000
     VehicleDamageScaling=0.150000
}
