//=============================================================================
// Coded by Dante
// Improved by Leviathan
// The DA Grenade.
// Characteristics: Not a lot of bounce, fast versatile and can cause a lot of
// damage.
//=============================================================================
class da_weapons_BasicGrenade extends ScrnNade;

var() class<Emitter> ExplosionEmitter, MaterialFX[20];
var() sound HitMetalSound, ExplosionSound, ExplosionSounds[5];
var() int ExpSoundsNum;
var() float Dispersion, Armor, BlastPenetration;
var() class<actor> ProjFX, ProjTrail;
var int MatType;
var actor FX, Trail;

//#EXEC OBJ LOAD FILE=DA2_StaticMeshes.usx
//#EXEC OBJ LOAD FILE=DA2_WeaponSounds.uax
//#EXEC OBJ LOAD FILE=DA2_Various.uax

//var() float DampenFactor, DampenFactorParallel;
//var AvoidMarker botFear;
//var class<AvoidMarker> BotFearClass;

simulated function PostNetReceive()
{
	if( bHidden && !bDisintegrated )
	{
		Disintegrate(Location, vect(0,0,1));
	}
}

simulated function PostBeginPlay()
{
    if ( Role == ROLE_Authority )
    {
        RandSpin(25000);
        Velocity = Speed*Vector(Rotation) + VRand()*Dispersion;
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

//simulated function ProcessTouch( actor Other, vector HitLocation )
//{
//	local vector HitNormal, VNorm;
//
//    VNorm = (Velocity dot HitNormal) * HitNormal;
//    Velocity = -VNorm * 0.5;
//
//    return;
//
//    hitnormal=Normal(HitLocation-Other.Location);
//
//    if(Other!=Instigator)
//	{
//        if(pawn(other)!=none && vehicle(other)==none) mattype=6;
//        else mattype=3;
//
//        if(damageradius==0) Other.TakeDamage(Damage,instigator,HitLocation,MomentumTransfer*Normal(Velocity),MyDamageType);
//		else {
//			setRotation(rotator(-velocity));
//			destroy();
//		}
//    }
//}

simulated function HitWall( vector HitNormal, actor Wall )
{
    local Vector VNorm;

	if ( (Pawn(Wall) != None) || (GameObjective(Wall) != None) )
	{
		setRotation(rotator(hitNormal));
		destroy();
		return;
	}

    if(Level.NetMode!=NM_DedicatedServer && Speed>150)
	    PlaySound(ImpactSound,SLOT_None,0.9,,80,0.9+frand()*0.2);

    // Reflect off Wall w/damping
    VNorm = (Velocity dot HitNormal) * HitNormal;
    Velocity = -VNorm * DampenFactor + (Velocity - VNorm) * DampenFactorParallel;

    RandSpin(200000);
    DesiredRotation.Roll = 0;
    RotationRate.Roll = 0;
    Speed = VSize(Velocity);

    if(Speed < 20)
    {
        bBounce = False;
        SetPhysics(PHYS_None);
		DesiredRotation = Rotation;
		DesiredRotation.Roll = 0;
		DesiredRotation.Pitch = 0;
		SetRotation(DesiredRotation);
    }
    else
    {
		bFixedRotationDir = false;
		bRotateToDesired = true;
		DesiredRotation.Pitch = 0;
		RotationRate.Pitch = 50000;
    }
}

function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType, optional int HitIndex)
{
    if( damageType == class'SirenScreamDamage')
    {
        Explode(HitLocation, vect(0,0,1));//Disintegrate(HitLocation, vect(0,0,1));
    }

	if(damage>=armor && armor>0) {
      SetTimer(0.1+frand()*0.1, false);
      bProjTarget=false;
    }
}

function Timer()
{
    Destroy();
}

simulated function Destroyed()
{
	explode(location, vector(rotation));

    if(FX!=none) fx.Destroy();
    if(emitter(trail)!=none) emitter(trail).Kill();

	Super.Destroyed();
}

simulated function vector GetMatType()
{
    local vector HL,HN;
    local material WallMat;

    if(vsize(velocity)<50) Trace(hl,hn,location-vect(0,0,16),Location,false,,WallMat);
    else Trace(hl,hn,location+Normal(velocity)*32,Location,false,,WallMat);

    if(WallMat!=None)
    {
        matType=WallMat.SurfaceType;
        if(mattype==0) mattype=1;
    }
    return HN;
}

simulated function Explode(vector HitLocation, vector HitNormal)
{
    local PlayerController  LocalPlayer;
    local Projectile P;
    local byte i;

    hitnormal=GetMatType();
    if(hitnormal==vect(0,0,0))
        hitnormal=vect(0,0,1);

    if (bHasExploded)
        return;

    bHasExploded = True;
    BlowUp(HitLocation);

    // null reference fix
    if ( ExplodeSounds.length > 0 )
        PlaySound(ExplodeSounds[rand(ExplodeSounds.length)],,2.0);

    // Shrapnel
    for( i=Rand(6); i<10; i++ )
    {
        P = Spawn(ShrapnelClass,,,,RotRand(True));
        if( P!=None )
            P.RemoteRole = ROLE_None;
    }
    if ( EffectIsRelevant(Location,false) )
    {
        Spawn(MaterialFX[matType],,, HitLocation, rotator(hitnormal));
        Spawn(ExplosionEmitter,,, HitLocation, rotator(hitnormal));
		Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
    }

    // Shake nearby players screens
    LocalPlayer = Level.GetLocalPlayerController();
    if ( (LocalPlayer != None) && (VSize(Location - LocalPlayer.ViewTarget.Location) < (DamageRadius * 1.5)) )
        LocalPlayer.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);

    Destroy();
}

simulated function Landed( vector HitNormal )
{
    HitWall( HitNormal, none );
}

defaultproperties
{
     DampenFactor=0.200000
     DampenFactorParallel=0.400000
     //BotFearClass=Class'da2.da_triggers_BotFearSpot'
     ExplosionSounds(0)=Sound'DA2_WeaponSounds.explosions.Grenade_Explosion1'
     ExplosionSounds(1)=Sound'DA2_WeaponSounds.explosions.Grenade_Explosion2'
     ExplosionSounds(2)=Sound'DA2_WeaponSounds.explosions.Grenade_Explosion3'
     ExplosionSounds(3)=Sound'DA2_WeaponSounds.explosions.Grenade_Explosion4'
     ExpSoundsNum=4
     Dispersion=300.000000
     Armor=20.000000
     Speed=1000.000000
     MaxSpeed=1000.000000
     Damage=300.000000
     DamageRadius=300.000000
     MomentumTransfer=100000.000000
     MyDamageType=Class'KFDA2Weapons.da_damtypes_HandGrenade'
     ImpactSound=Sound'DA2_WeaponSounds.Misc.GrenadeBounce'
     DrawType=DT_StaticMesh
     //StaticMesh=StaticMesh'DA2_StaticMeshes.Grenades.FragGrenade'
     Physics=PHYS_Falling
     LifeSpan=2.500000
     DrawScale=2.000000
     AmbientGlow=16
     bUnlit=False
     FluidSurfaceShootStrengthMod=2.500000
     TransientSoundVolume=5.000000
     TransientSoundRadius=600.000000
     CollisionRadius=1.000000
     CollisionHeight=1.000000
     bBounce=True
     bFixedRotationDir=True
     DesiredRotation=(Pitch=12000,Yaw=5666,Roll=2334)
     bNetInitial=True

     ExplosionEmitter=Class'KFDA2Weapons.da_effects_HGExplosion'
     MaterialFX(1)=Class'KFDA2Weapons.da_effects_BlastRock'
     MaterialFX(2)=Class'KFDA2Weapons.da_effects_BlastDirt'
     MaterialFX(3)=Class'KFDA2Weapons.da_effects_BlastMetal'
     MaterialFX(4)=Class'KFDA2Weapons.da_effects_BlastDirt'
     MaterialFX(5)=Class'KFDA2Weapons.da_effects_BlastDirt'
     MaterialFX(7)=Class'KFDA2Weapons.da_effects_BlastSnow'
     MaterialFX(8)=Class'KFDA2Weapons.da_effects_BlastSnow'
     MaterialFX(10)=Class'KFDA2Weapons.da_effects_BlastDirt'
     MaterialFX(11)=Class'KFDA2Weapons.da_effects_BlastRock'
     MaterialFX(12)=Class'KFDA2Weapons.da_effects_BlastRock'
     MaterialFX(13)=Class'KFDA2Weapons.da_effects_BlastDirt'
     MaterialFX(14)=Class'KFDA2Weapons.da_effects_BlastDirt'
     MaterialFX(15)=Class'KFDA2Weapons.da_effects_BlastMetal'
     MaterialFX(16)=Class'KFDA2Weapons.da_effects_BlastDirt'
     MaterialFX(17)=Class'KFDA2Weapons.da_effects_BlastDirt'
     MaterialFX(18)=Class'KFDA2Weapons.da_effects_BlastDirt'
     MaterialFX(19)=Class'KFDA2Weapons.da_effects_BlastDirt'
     BlastPenetration=0.300000
     ExplosionDecal=Class'KFDA2Weapons.da_effects_NadeDecal'
     ExploWallOut=2.000000
     bProjTarget=True
}
