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

//simulated function ProcessTouch (Actor Other, vector HitLocation)
//{
//    local vector X;
//    local Vector TempHitLocation, HitNormal;
//    local array<int>    HitPoints;
//    local KFPlayerReplicationInfo KFPRI;
//    local KFPawn Human;
//    local Pawn Victim;
//    local KFMonster KFM;
//    local bool bNoDamageReduction;
//	local Vector HitNormal;
//	local vector outvec;
//
//    if ( Other == none || Other == Instigator || Other.Base == Instigator || !Other.bBlockHitPointTraces  )
//        return;
//
//	outvec=Velocity-2.0*HitNormal*(Velocity dot HitNormal);
//    outvec=normal(outvec);
//	if ( EffectIsRelevant(Location,false) && Other.IsA('KFMonster'))
//			Spawn(Class'KFDA2Weapons.da_effects_BulletHitFlesh_Shotgun',,,Location+outvec*ExploWallOut,rotator(outvec));
//    Super(ScrnCustomShotgunBullet).ProcessTouch(Other,HitLocation);
//
//    X = Vector(Rotation);
//
//    if ( Instigator != none && ROBulletWhipAttachment(Other) != none ) {
//        // we touched player's auxilary collision cylinder, now let's trace to the player himself
//        // Other.Base = KFPawn
//        if( Other.Base == none || Other.Base.bDeleteMe )
//            return;
//
//        Other = Instigator.HitPointTrace(TempHitLocation, HitNormal, HitLocation + (200 * X), HitPoints, HitLocation,, 1);
//
//        if( Other == none || HitPoints.Length == 0 || Other.bDeleteMe )
//            return; // bullet didn't hit a pawn
//
//        Human = KFPawn(Other);
//        if ( Human != none ) {
//            if (class'ScrnF'.static.SearchObj(IgnoreActors, Human) != -1)
//                return;
//            Victim = Human;
//            // cannot hit a player more than once
//            SameVictimCounter = 3;
//            bNoDamageReduction = Victim.Health <= 0;
//            Human.ProcessLocationalDamage(Damage * PlayerDamageMult, Instigator, TempHitLocation, MomentumTransfer * X, MyDamageType,HitPoints);
//            IgnoreActors[IgnoreActors.Length] = Human;
//        }
//    }
//    else {
//        if ( ExtendedZCollision(Other) != none)
//            Victim = Pawn(Other.Owner); // ExtendedZCollision is attached to KFMonster
//        else if ( Pawn(Other) != none )
//            Victim = Pawn(Other);
//
//
//        if ( Victim != none ) {
//            KFM = KFMonster(Victim);
//            Human = KFPawn(Victim);
//
//            if (Human != none) {
//                // XXX: is this even possible?
//                // Can we hit a KFPawn without hitting its surrounding KFBulletWhipAttachment first?
//                if (class'ScrnF'.static.SearchObj(IgnoreActors, Human) != -1)
//                    return;
//                IgnoreActors[IgnoreActors.Length] = Human;
//            }
//
//            // kick dead bodies for visual fx but no gameplay impact
//            bNoDamageReduction = Victim.Health <= 0;
//
//            if ( OldVictim != Victim ) {
//                OldVictim = Victim;
//                SameVictimCounter = 1;
//            }
//            else if ( ++SameVictimCounter > 2 ) {
//                // the same target can hit twice max: body and head (ExtendedZCollision)
//                return;
//            }
//
//            bHeadshot = Victim.IsHeadShot(HitLocation, X, 1.0);
//            if ( bHeadshot ) {
//                Victim.TakeDamage(Damage * HeadShotDamageMult, Instigator, HitLocation, MomentumTransfer * X, MyDamageType);
//            }
//            else if (SameVictimCounter == 1) {
//                Victim.TakeDamage(Damage, Instigator, HitLocation, MomentumTransfer * X, MyDamageType);
//            }
//            else {
//                // only headshots can damage the same target twice.
//                return;
//            }
//        }
//        else {
//            Other.TakeDamage(Damage, Instigator, HitLocation, MomentumTransfer * X, MyDamageType);
//        }
//    }
//
//    if (bNoDamageReduction)
//        return;
//
//    if ( Instigator != none )
//        KFPRI = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo);
//    if ( KFPRI != none && KFPRI.ClientVeteranSkill != none ) {
//        PenDamageReduction = KFPRI.ClientVeteranSkill.static.GetShotgunPenetrationDamageMulti(KFPRI,
//                default.PenDamageReduction);
//    }
//    else {
//        PenDamageReduction = default.PenDamageReduction;
//    }
//
//    if ( Victim != none && Victim.Health <= 0 ) {
//        // dead bodies reduce damage less
//        PenDamageReduction += (1.0 - PenDamageReduction) * 0.5;
//    }
//    else if ( KFM != none ) {
//        // loose penetrational damage after hitting specific zeds -- PooSH
//        PenDamageReduction *= ZedPenDamageReduction(KFM);
//    }
//
//    Damage *= PenDamageReduction;
//    if ( Damage < MinDamage )
//        Destroy();
//}

defaultproperties
{
    DamageAtten=5.000000
    MaxPenetrations=3
    PenDamageReduction=0.75 //0.5
    BigZedPenDmgReduction=1.0 // No extra reduction
    BigZedMinHealth=1000
    MediumZedPenDmgReduction=1.0 // No extra reduction
    MediumZedMinHealth=500
    HeadShotDamageMult=1.500000 // 2.000000
    ExploWallOut=2.000000
    Speed=6500.000000
    MaxSpeed=8000.000000
    Damage=40.000000 //18 OG
    MinDamage=5.0
    DamageRadius=0.000000
    MomentumTransfer=15000.000000
    MyDamageType=Class'KFDA2Weapons.da_damtypes_LK2Shotgun'
    ImpactEffect=class'KFDA2Weapons.da_BulletHitEffect' //Using this doesn't cause the blood hit effects play for some reason
    LifeSpan=3.000000 //1

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
}
