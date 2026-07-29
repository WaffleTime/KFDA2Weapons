class da_damtypes_A9SMG_SR extends KFWeaponDamageType
	abstract;

static function AwardDamage(KFSteamStatsAndAchievements KFStatsAndAchievements, int Amount)
{
	KFStatsAndAchievements.AddFlameThrowerDamage(Amount);
	KFStatsAndAchievements.AddMac10BurnDamage(Amount);
}

defaultproperties
{
     WeaponClass=Class'KFDA2Weapons.da_A9SMG'
     HeadShotDamageMult=1.5 //2.0 Taken from da_weapons_BasicFire
     DeathString="%k > A9 Submachine Gun > %o"
     FemaleSuicide="%o > A9 Submachine Gun > herself."
     MaleSuicide="%o > A9 Submachine Gun > himself."
     bRagdollBullet=True
     bBulletHit=True
     FlashFog=(X=300.000000)
     KDamageImpulse=850.000000
     KDeathVel=115.000000
     KDeathUpKick=2.000000
     VehicleDamageScaling=0.200000
     bDealBurningDamage=True
}
