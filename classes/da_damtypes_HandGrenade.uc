class da_damtypes_HandGrenade extends DamTypeFrag
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
     bIsExplosive=True
     bCheckForHeadShots=False
     DeathString="%k > Frag Grenade > %o."
     FemaleSuicide="%o > Frag Grenade > herself."
     MaleSuicide="%o > Frag Grenade > himself."
     bLocationalHit=False
     bDetonatesGoop=True
     bDelayedDamage=True
     bThrowRagdoll=True
     bExtraMomentumZ=True
     KDamageImpulse=2500.000000
     KDeathVel=300.000000
     KDeathUpKick=220.000000
     VehicleDamageScaling=0.700000
}
