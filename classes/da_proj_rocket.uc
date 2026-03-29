class da_proj_rocket extends ScrnRocketProjectile;

var int MatType;
//var() class<actor> ProjFX, ProjTrail;
var() class<Emitter> ProjFX, ProjTrail;
//var() sound HitMetalSound, ExplosionSound, ExplosionSounds[5];
var actor FX, Trail;
var() class<Emitter> ExplosionEmitter, MaterialFX[20];
//var Emitter RocketTrail;
var() float Dispersion;
//
//simulated function PostBeginPlay()
//{
//    super.PostBeginPlay();
//
//    if ( Role == ROLE_Authority )
//    {
//        if (instigator!=none && Instigator.HeadVolume.bWaterVolume)
//        {
//            bHitWater = true;
//            Velocity = 0.6*Velocity;
//        }
//    }
//
//    Velocity = Speed*Vector(Rotation);
//    Acceleration = Velocity+Vrand()*dispersion;
//
//     SetTimer(1, true);
//}

//overrided to change smoke emiter
simulated function PostBeginPlay()
{
    super.PostBeginPlay();

    if ( Role == ROLE_Authority )
    {
        Velocity = Speed*Vector(Rotation) + VRand()*Dispersion;
        SetRotation(rotator(velocity));

        if(instigator!=none && Instigator.HeadVolume.bWaterVolume)
        {
            bHitWater = true;
            Velocity = 0.6*Velocity;
        }
    }
    
    if ( Level.NetMode != NM_DedicatedServer)
    {
        FX=Spawn(ProjFX, self,, Location, Rotation);
        if(FX!=none) FX.SetBase(self);
        Trail=Spawn(ProjTrail, self,, Location, Rotation);
        if(Trail!=none) Trail.SetBase(self);
    }

     Velocity = Speed*Vector(Rotation);
     Acceleration = Velocity+Vrand()*dispersion;
}

simulated function Destroyed()
{
    if(FX!=none) fx.Destroy();
    if(emitter(trail)!=none) emitter(trail).Kill();
    Super.Destroyed();
}

simulated function vector GetMatType()
{
    local vector HL,HN;
    local material WallMat;

    Trace(hl,hn,location+normal(velocity)*64,Location,false,,WallMat);

    if(WallMat!=None) matType=WallMat.SurfaceType;

    return hn;
}

//function TakeDamage(int Damage, Pawn instigatedBy, Vector hitlocation, Vector momentum, class<DamageType> damageType, optional int HitIndex)
//{
//    if( damageType == class'SirenScreamDamage')
//    {
//        Explode(HitLocation, HitNormal);
//    }
//
//	if(damage>=armor && armor>0) destroy();
//}

// Overwritten to have the custom effects
simulated function Explode(vector HitLocation, vector HitNormal)
{
    local Controller C;
    local PlayerController LocalPlayer;
    //local Emitter Explosion;

    GetMatType();

    if (bHasExploded)
        return;
    bHasExploded = True;

    // Don't explode if this is a dud
    if (bDud) {
        Velocity = vect(0,0,0);
        LifeSpan=1.0;
        SetPhysics(PHYS_Falling);
        return;
    }

    PlaySound(ExplosionSound,,ExplosionSoundVolume);
    if (EffectIsRelevant(Location,false)) {
        Spawn(MaterialFX[matType],,, HitLocation, rotator(hitnormal));
        Spawn(ExplosionEmitter,,, HitLocation, rotator(hitnormal));
        Spawn(ExplosionDecal,self,,HitLocation, rotator(-HitNormal));
    }

    BlowUp(HitLocation);

    // Shake nearby players screens
    LocalPlayer = Level.GetLocalPlayerController();
    if ((LocalPlayer != None) && (VSize(Location - LocalPlayer.ViewTarget.Location) < DamageRadius)) {
        LocalPlayer.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);
    }

    for (C=Level.ControllerList; C != none; C = C.NextController)  {
        if (C.bIsPlayer && PlayerController(C) != none && C != LocalPlayer
                && (VSize(Location - PlayerController(C).ViewTarget.Location) < DamageRadius)) {
            C.ShakeView(RotMag, RotRate, RotTime, OffsetMag, OffsetRate, OffsetTime);
        }
    }

    if (bBegunPlay || Role < ROLE_Authority) {
        Destroy();
    }
}

//function Timer()
//{
//  local Controller C;
//
//    //DFA Turrets as long as they can shoot down enemy rockets
//    for(C=Level.ControllerList; C!=None; C=C.NextController)
//      if(da_turrets_TurretController(C)!=None && da_Turrets_DFATurret(C.Pawn)!=None && C.GetTeamNum()!=Team
//          && !C.Pawn.IsFiring() && (C.focus==None || C.Pawn.Health<250) && C.Pawn.CanAttack(self) )
//      {
//        C.Focus = self;
//        C.Target = self;
//        if ( !C.IsInState('Engaged') );
//            C.GotoState('Engaged');
//        }
//}

function Tick(float deltatime)
{
    Super.Tick(DeltaTime);
    SetRotation(rotator(velocity));
}

defaultproperties
{
     ExplosionEmitter=Class'KFDA2Weapons.da_effects_HGExplosion'
     ExplosionClass=class'KFDA2Weapons.da_effects_HGExplosion'
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
     //HitMetalSound=Sound'DA2_WeaponSounds.MS25_BlastArmor'
     ExplosionSound=Sound'DA2_WeaponSounds.MS25_Explosion'
     ExplosionSoundRef="DA2_WeaponSounds.MS25_Explosion"
     AmbientSoundRef="DA2_WeaponSounds.MS25_Launch"
     Dispersion=10.000000
     //Armor=5.000000
     //BlastPenetration=0.600000
     ProjFX=Class'KFDA2Weapons.da_effects_RocketFX'
     ProjTrail=Class'KFDA2Weapons.da_effects_RocketTrail'
     SmokeTrailClass=class'da_effects_RocketTrail' // This doesn't work cause stupid ass smoketrail code
     Speed=800 //700.000000
     MaxSpeed=3000.000000
     Damage=600//120.000000
     DamageRadius=400.000000
     MomentumTransfer=50000.000000
     MyDamageType=Class'KFDA2Weapons.da_damtypes_MS25RocketLauncher'
     DrawType=DT_StaticMesh
     StaticMesh=StaticMesh'KF_DA2KarmaStatics.122mm_shell'
     StaticMeshRef="KF_DA2KarmaStatics.122mm_shell"
     bNetTemporary=False
     bUpdateSimulatedPosition=True
     //LifeSpan=10.000000 //6
     DrawScale=0.700000
     TransientSoundVolume=6.000000
     TransientSoundRadius=400.000000
     CollisionRadius=4.000000
     CollisionHeight=4.000000
     ForceType=FT_Constant
     ForceRadius=100.000000
     ForceScale=5.000000
     ArmDistSquared=17000
}
