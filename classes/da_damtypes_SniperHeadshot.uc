class da_damtypes_sniperheadshot extends da_damtypes_Sniper
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth )
{
    HitEffects[0] = class'da_HitSmoke';

    if( VictimHealth <= 0 )
        HitEffects[1] = class'da_HitFlameBig';
    else if ( FRand() < 0.5 )
        HitEffects[1] = class'da_HitFlame';
}

defaultproperties
{
     bSniperWeapon=True
     WeaponClass=Class'KFDA2Weapons.da_R86Sniper'
     DeathString="*** %k > R86 Sniper Rifle Headshot > %o"
     FemaleSuicide="*** %o > R86 Sniper Rifle Headshot > herself."
     MaleSuicide="*** %o > R86 Sniper Rifle Headshot > himself."
     bSpecial=True
     bCauseConvulsions=True
     bBulletHit=True
     FlashFog=(X=2000.000000)
     KDamageImpulse=500.000000
     KDeathVel=200.000000
     KDeathUpKick=20.000000
     VehicleDamageScaling=0.200000
}
