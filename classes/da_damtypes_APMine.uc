class da_damtypes_APMine extends DamTypeFrag
	abstract;

static function GetHitEffects(out class<xEmitter> HitEffects[4], int VictimHealth )
{
    HitEffects[0] = class'da_HitSmoke';

    if( VictimHealth <= 0 )
        HitEffects[1] = class'da_HitFlameBig';
    else if ( FRand() < 0.8 )
        HitEffects[1] = class'da_HitFlame';
}

defaultproperties
{
     bIsExplosive=True
     bCheckForHeadShots=False
     DeathString="%k > AP-Mine > %o."
     FemaleSuicide="%o > AP-Mine > herself."
     MaleSuicide="%o > AP-Mine > himself."
     bLocationalHit=False
     bDetonatesGoop=True
     bDelayedDamage=True
     bThrowRagdoll=True
     bExtraMomentumZ=True
     KDamageImpulse=2500.000000
     KDeathVel=300.000000
     KDeathUpKick=200.000000
     VehicleDamageScaling=0.350000
}
