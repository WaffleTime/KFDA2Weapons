//=============================================================================
// Sniper Bullet
//=============================================================================
class da_proj_Sniper extends ScrnCustomShotgunBullet;

var() class<actor> ProjFX, ProjTrail;
var actor FX, Trail;
var bool bHitWater;
var class<actor> HitMatFX[20];

//simulated event PreBeginPlay()
//{
//    Super.PreBeginPlay();
//
//    if( Pawn(Owner) != None )
//        Instigator = Pawn( Owner );
//		
//		if ( Instigator.PlayerReplicationInfo != none )
//		{
//			if (da_players_PRI(Instigator.PlayerReplicationInfo).enableIncendiary) 
//			{
//				MyDamageType=Class'KFmod.DamTypeFlamethrower';
//				//DamageTypeHeadShot=Class'KFmod.DamTypeFlamethrower';
//				Damage=275; 
//			}
//			else 
//			{
//				MyDamageType=Class'DA2.da_damtypes_Sniper';
//				//DamageTypeHeadShot=Class'DA2.da_damtypes_SniperHeadshot';
//				Damage=400;
//			}
//		}
//}


simulated function PostNetBeginPlay()
{
	local PlayerController PC;

	Super.PostNetBeginPlay();

	if ( Level.NetMode == NM_DedicatedServer )
		return;

	PC = Level.GetLocalPlayerController();
	if ( (Instigator != None) && (PC == Instigator.Controller) )
		return;
	if ( Level.bDropDetail || (Level.DetailMode == DM_Low) )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}
	else if ( (PC == None) || (PC.ViewTarget == None) || (VSize(PC.ViewTarget.Location - Location) > 3000) )
	{
		bDynamicLight = false;
		LightType = LT_None;
	}
}

simulated function PostBeginPlay()
{
    if ( Role == ROLE_Authority )
    {
        Velocity = Speed*Vector(Rotation);
        SetRotation(rotator(velocity));

        if(instigator!=none && Instigator.HeadVolume.bWaterVolume)
        {
            bHitWater = true;
            Velocity = 0.6*Velocity;
        }
    }

    if (Level.NetMode!=NM_DedicatedServer)
    {
        FX=Spawn(ProjFX, self,, Location, Rotation);
        if(FX!=none) FX.SetBase(self);
        Trail=Spawn(ProjTrail, self,, Location, Rotation);
        if(Trail!=none) Trail.SetBase(self);
    }

    super.PostBeginPlay();
}

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

    if ( EffectIsRelevant(Location,false) )
    	    Spawn(HitMatFX[matType],,,Location+outvec*ExploWallOut,rotator(outvec));

	HurtWall = None;

    Destroy();
}

simulated function ProcessTouch (Actor Other, vector HitLocation)
{
	local Vector HitNormal;
	local vector outvec;

	outvec=Velocity-2.0*HitNormal*(Velocity dot HitNormal);
    outvec=normal(outvec);
	if ( EffectIsRelevant(Location,false) && Other.IsA('KFMonster'))
			Spawn(Class'KFDA2Weapons.da_effects_BulletHitFlesh',,,Location+outvec*ExploWallOut,rotator(outvec));
    Super(ScrnCustomShotgunBullet).ProcessTouch(Other,HitLocation);
 }

simulated function Destroyed()
{
    if(FX!=none) fx.Destroy();
    if(emitter(trail)!=none) emitter(trail).Kill();

	Super.Destroyed();
}

defaultproperties
{
     DamageAtten=5.000000
     MaxPenetrations=20
     PenDamageReduction=0.200000
     HeadShotDamageMult=1.0 //4.000000
     ProjTrail=Class'KFDA2Weapons.da_effects_SniperTrailNew'
     Speed=12000.000000
     MaxSpeed=12000.000000
     bSwitchToZeroCollision=True
     Damage=400.000000
     DamageRadius=0.000000
     MomentumTransfer=150000.000000
     MyDamageType=Class'KFDA2Weapons.da_damtypes_Sniper'
     ExplosionDecal=Class'KFDA2Weapons.da_effects_LongBulletHole'
     DrawType=DT_StaticMesh
     LifeSpan=15.000000
     Style=STY_Alpha

     HitMatFX(0)=Class'KFDA2Weapons.da_effects_BulletHitRock'
     HitMatFX(1)=Class'KFDA2Weapons.da_effects_BulletHitRock'
     HitMatFX(2)=Class'KFDA2Weapons.da_effects_BulletHitDirt'
     HitMatFX(3)=Class'KFDA2Weapons.da_effects_BulletHitMetal'
     HitMatFX(4)=Class'KFDA2Weapons.da_effects_BulletHitWood'
     HitMatFX(5)=Class'KFDA2Weapons.da_effects_BulletHitDirt'
     HitMatFX(6)=Class'KFDA2Weapons.da_effects_BulletHitFlesh'
     HitMatFX(7)=Class'KFDA2Weapons.da_effects_BulletHitSnow'
     HitMatFX(8)=Class'KFDA2Weapons.da_effects_BulletHitSnow'
     HitMatFX(10)=Class'KFMod.GlassHitEmitter'
     HitMatFX(11)=Class'KFDA2Weapons.da_effects_BulletHitDirt'
     HitMatFX(12)=Class'KFDA2Weapons.da_effects_BulletHitRock'
     HitMatFX(13)=Class'KFDA2Weapons.da_effects_BulletHitWood'
     HitMatFX(14)=Class'KFDA2Weapons.da_effects_BulletHitDirt'
     HitMatFX(15)=Class'KFDA2Weapons.da_effects_BulletHitMetal'
     HitMatFX(16)=Class'KFDA2Weapons.da_effects_BulletHitWood'
     HitMatFX(17)=Class'KFDA2Weapons.da_effects_BulletHitDirt'
     HitMatFX(18)=Class'KFDA2Weapons.da_effects_BulletHitDirt'
     HitMatFX(19)=Class'KFDA2Weapons.da_effects_BulletHitDirt'
}
