//=============================================================================
// Shotgun Bullet
//=============================================================================
class da_proj_Shotgun extends ScrnCustomShotgunBullet;

var class<actor> HitMatFX[20];

simulated singular function HitWall(vector HitNormal, actor Wall)
{
local vector HL,HN;
local vector outvec;
local int matType;
local material WallMat;

    outvec=Velocity-2.0*HitNormal*(Velocity dot HitNormal);
    outvec=normal(outvec);

    if(wall.surfacetype!=0) matType=wall.surfacetype;
        else
        {
            Trace(hl,hn,location+vect(32,0,0)*vector(rotation),Location,false,,WallMat);
            if(WallMat!=None) matType=WallMat.SurfaceType;
        }

    if ( Role == ROLE_Authority )
	{
		if ( !Wall.bStatic && !Wall.bWorldGeometry )
		{
			if ( Instigator == None || Instigator.Controller == None )
				Wall.SetDelayedDamageInstigatorController( InstigatorController );
			Wall.TakeDamage( Damage, instigator, Location, MomentumTransfer * Normal(Velocity), MyDamageType);
			if (DamageRadius > 0 && Vehicle(Wall) != None && Vehicle(Wall).Health > 0)
				Vehicle(Wall).DriverRadiusDamage(Damage, DamageRadius, InstigatorController, MyDamageType, MomentumTransfer, Location);
			HurtWall = Wall;
		}
		MakeNoise(1.0);
	}
	Explode(Location + ExploWallOut * HitNormal, HitNormal);

	if (ImpactEffect != None && (Level.NetMode != NM_DedicatedServer))
	{
			Spawn(ImpactEffect,,, Location, rotator(-HitNormal));
	}

    if ( EffectIsRelevant(Location,false) )
    	    Spawn(HitMatFX[matType],,,Location+outvec*ExploWallOut,rotator(outvec));

	HurtWall = None;


    if (Trail != None)
    {
        Trail.mRegen=False;
        Trail.SetPhysics(PHYS_None);
        //Trail.mRegenRange[0] = 0.0;//trail.mRegenRange[0] * 0.6;
        //Trail.mRegenRange[1] = 0.0;//trail.mRegenRange[1] * 0.6;
    }

    Destroy();
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	local Vector HitNormal;
	local vector outvec;

	outvec=Velocity-2.0*HitNormal*(Velocity dot HitNormal);
    outvec=normal(outvec);
	if ( EffectIsRelevant(Location,false) && Other.IsA('KFMonster'))
			Spawn(Class'KFDA2Weapons.da_effects_BulletHitFlesh_Shotgun',,,Location+outvec*ExploWallOut,rotator(outvec));
    Super(ScrnCustomShotgunBullet).ProcessTouch(Other,HitLocation);
 }

defaultproperties
{
    DamageAtten=5.000000
    MaxPenetrations=3
    PenDamageReduction=0.75 //0.5
    BigZedPenDmgReduction=0.65
    BigZedMinHealth=1000
    MediumZedPenDmgReduction=0.7
    MediumZedMinHealth=500
    HeadShotDamageMult=2.000000
    HitMatFX(0)=Class'KFDA2Weapons.da_effects_BulletHitRock_Shotgun'
    HitMatFX(1)=Class'KFDA2Weapons.da_effects_BulletHitRock_Shotgun'
    HitMatFX(2)=Class'KFDA2Weapons.da_effects_BulletHitDirt_Shotgun'
    HitMatFX(3)=Class'KFDA2Weapons.da_effects_BulletHitMetal_Shotgun'
    HitMatFX(4)=Class'KFDA2Weapons.da_effects_BulletHitWood_Shotgun'
    HitMatFX(5)=Class'KFDA2Weapons.da_effects_BulletHitDirt_Shotgun'
    HitMatFX(6)=Class'KFDA2Weapons.da_effects_BulletHitFlesh_Shotgun'
    HitMatFX(7)=Class'KFDA2Weapons.da_effects_BulletHitSnow_Shotgun'
    HitMatFX(8)=Class'KFDA2Weapons.da_effects_BulletHitSnow_Shotgun'
    HitMatFX(10)=Class'KFMod.GlassHitEmitter'
    HitMatFX(11)=Class'KFDA2Weapons.da_effects_BulletHitDirt_Shotgun'
    HitMatFX(12)=Class'KFDA2Weapons.da_effects_BulletHitRock_Shotgun'
    HitMatFX(13)=Class'KFDA2Weapons.da_effects_BulletHitWood_Shotgun'
    HitMatFX(14)=Class'KFDA2Weapons.da_effects_BulletHitDirt_Shotgun'
    HitMatFX(15)=Class'KFDA2Weapons.da_effects_BulletHitMetal_Shotgun'
    HitMatFX(16)=Class'KFDA2Weapons.da_effects_BulletHitWood_Shotgun'
    HitMatFX(17)=Class'KFDA2Weapons.da_effects_BulletHitDirt_Shotgun'
    HitMatFX(18)=Class'KFDA2Weapons.da_effects_BulletHitDirt_Shotgun'
    HitMatFX(19)=Class'KFDA2Weapons.da_effects_BulletHitDirt_Shotgun'
    ExploWallOut=2.000000
    Speed=6500.000000
    MaxSpeed=8000.000000
    Damage=40.000000 //18 OG
    DamageRadius=0.000000
    MomentumTransfer=15000.000000
    MyDamageType=Class'KFDA2Weapons.da_damtypes_LK2Shotgun'
    ImpactEffect=class'KFDA2Weapons.da_BulletHitEffect' //Using this doesn't cause the blood hit effects play for some reason
    LifeSpan=3.000000 //1
}
