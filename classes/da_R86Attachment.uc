class da_R86Attachment extends KFWeaponAttachment;

var   bool              bUseTraces;

var bool bLoopFire;
var bool bUseSpewer;

simulated function PostNetBeginPlay()
{
    local rotator r;

	super.postNetBeginPlay();

    r.pitch=-16384;
    SetBoneRotation('Muzzle', r, 0, 1.f);
}

//Tip bone is hardcoded T-T
simulated function DoFlashEmitter()
{
    if (mMuzFlash3rd == None)
    {
        mMuzFlash3rd = Spawn(mMuzFlashClass);
        AttachToBone(mMuzFlash3rd, 'Muzzle');
    }
    if(mMuzFlash3rd != None)
        mMuzFlash3rd.SpawnParticle(1);
}

simulated function UpdateTracer()
{
    local vector SpawnLoc, SpawnDir;

    if (Level.NetMode == NM_DedicatedServer)
        return;

    SpawnLoc=GetTracerStart();
//    if(mHitLocation == mOldHitLocation)
		SpawnDir = vector( Instigator.GetViewRotation() );
//	else SpawnDir = Normal(mHitLocation - SpawnLoc);

    //if(mhitlocation!=vect(0,0,0))

    if (mTracer == None)
    {
    Spawn(mTracerClass,,, spawnloc, rotator(spawndir));
    AttachToBone(mTracer, 'Muzzle');
    }

	mOldHitLocation = mHitLocation;
}

simulated function WeaponLight()
{
    if ( (FlashCount > 0) && !Level.bDropDetail && (Instigator != None)
		&& ((Level.TimeSeconds - LastRenderTime < 0.2) || (PlayerController(Instigator.Controller) != None)) )
    {
		if ( Instigator.IsFirstPerson() )
		{
			LitWeapon = Instigator.Weapon;
			LitWeapon.LightBrightness=230+rand(50);
			LitWeapon.LightRadius=8+rand(5);
			LitWeapon.bDynamicLight=true;
		}
		else {
            LightBrightness=230+rand(60);
			LightRadius=8+rand(4);
			bDynamicLight = true;
		}

        SetTimer(0.1, false);
    }
    else
		Timer();
}

//##LEVI - Tracer Effects
//simulated function vector GetTracerStart()
//{
//    local Pawn p;
//    local weapon w;
//    local Vector X,Y,Z;
//
//
//    if(pawn(owner)!=none && pawn(owner).weapon!=none)
//    {
//        p=pawn(owner);
//        w=p.weapon;
//
//        if (Level.TimeSeconds-LastRenderTime>1) {
//            w.GetViewAxes(X, Y, Z);
//            w.SetLocation(p.Location+p.eyeposition()-6*Z);
//            return (p.Location+p.eyeposition()-6*Z);
//        }
//        else if(p.IsFirstPerson())
//             return w.GetBoneCoords('Muzzle').origin;
//
//          // 3rd person
//         return GetBoneCoords('Muzzle').origin;
//    }
//    return location;
//}

simulated event ThirdPersonEffects()
{
   // local rotator r;    Cancel rotation.

   		if ( KFPawn(Instigator) == None )
			return;

    if ( Level.NetMode != NM_DedicatedServer && FlashCount > 0 )
	{
      if (FiringMode == 0)
      {

        //Muzzle Flash
        if (mMuzFlash3rd == None)
        {
                mMuzFlash3rd = Spawn(mMuzFlashClass);
                if (mMuzFlash3rd != none)
                   AttachToBone(mMuzFlash3rd, 'Muzzle');
        }

        if ((mMuzFlash3rd) != none)
              (mMuzFlash3rd).SpawnParticle(1);

        //Shell Case
		if ( Level.DetailMode != DM_Low )
		{
			if ( mShellCaseEmitter == None && bUseSpewer)
			{
				mShellCaseEmitter = Spawn( mShellCaseEmitterClass,,,,Instigator.Rotation );
				if ( mShellCaseEmitter != None )
      				AttachToBone(mShellCaseEmitter, 'Shell_Ejector');
			}
			// Shellcase update
			if ( mShellCaseEmitter != None )
				mShellCaseEmitter.mStartParticles++;
		}

            WeaponLight();
            if(bUseTraces) UpdateTracer();

        Super.ThirdPersonEffects();
        }
    }

}

simulated function Destroyed()
{
    if (mTracer != None)
        mTracer.Destroy();

    if (mMuzFlash3rd != None)
        mMuzFlash3rd.Destroy();

    if (mShellCaseEmitter != None)
        mShellCaseEmitter.Destroy();

	Super.Destroyed();
}

function UpdateHit(Actor HitActor, vector HitLocation, vector HitNormal) {
    mHitLocation = HitLocation;
}

defaultproperties
{
    mMuzFlashClass=Class'KFDA2Weapons.da_R86Muzzle3rd'
    mTracerClass=Class'KFDA2Weapons.da_effects_SniperTraceMaker'
    mTracerPullback=0.000000
    mTracerSpeed=16000.000000
    MeshRef="KF_DA2_Weapons.KF_R86_3rd"
    Mesh=SkeletalMesh'KF_DA2_Weapons.KF_R86_3rd'

    mShellCaseEmitterClass=Class'KFDA2Weapons.da_ShellSpewer'
    mShellEmitterOffset=(X=28.000000,Y=-40.000000,Z=62.000000)
    bUseTraces=True
    bUseSpewer=True
    LightType=LT_Steady
    LightEffect=LE_NonIncidence
    LightHue=30
    LightSaturation=160
    LightBrightness=220.000000
    LightRadius=8.000000
    LightPeriod=3
    DrawScale=1.000000

    MovementAnims(0)=JogF_M4203
    MovementAnims(1)=JogB_M4203
    MovementAnims(2)=JogL_M4203
    MovementAnims(3)=JogR_M4203
    CrouchAnims(0)=CHwalkF_M4203
    CrouchAnims(1)=CHwalkB_M4203
    CrouchAnims(2)=CHwalkL_M4203
    CrouchAnims(3)=CHwalkR_M4203
    WalkAnims(0)=WalkF_M4203
    WalkAnims(1)=WalkB_M4203
    WalkAnims(2)=WalkL_M4203
    WalkAnims(3)=WalkR_M4203
    AirStillAnim=JumpF_Mid
    AirAnims(0)=JumpF_Mid
    AirAnims(1)=JumpF_Mid
    AirAnims(2)=JumpL_Mid
    AirAnims(3)=JumpR_Mid
    TakeoffStillAnim=JumpF_Takeoff
    TakeoffAnims(0)=JumpF_Takeoff
    TakeoffAnims(1)=JumpF_Takeoff
    TakeoffAnims(2)=JumpL_Takeoff
    TakeoffAnims(3)=JumpR_Takeoff
    LandAnims(0)=JumpF_Land
    LandAnims(1)=JumpF_Land
    LandAnims(2)=JumpL_Land
    LandAnims(3)=JumpR_Land

    TurnRightAnim=TurnR_M4203
    TurnLeftAnim=TurnL_M4203
    CrouchTurnRightAnim=CH_TurnR_M4203
    CrouchTurnLeftAnim=CH_TurnL_M4203
    IdleRestAnim=Idle_M4203
    IdleCrouchAnim=CHIdle_M4203
    IdleSwimAnim=Swim_Tread
    IdleWeaponAnim=Idle_M4203
    IdleHeavyAnim=Idle_M4203
    IdleRifleAnim=Idle_M4203
    IdleChatAnim=Idle_M4203
    FireAnims(0)=Fire_AK47
    FireAnims(1)=Fire_AK47
    FireAnims(2)=Fire_AK47
    FireAnims(3)=Fire_AK47
    FireAltAnims(0)=Fire_AK47
    FireAltAnims(1)=Fire_AK47
    FireAltAnims(2)=Fire_AK47
    FireAltAnims(3)=Fire_AK47
    FireCrouchAnims(0)=CHFire_AK47
    FireCrouchAnims(1)=CHFire_AK47
    FireCrouchAnims(2)=CHFire_AK47
    FireCrouchAnims(3)=CHFire_AK47
    FireCrouchAltAnims(0)=CHFire_AK47
    FireCrouchAltAnims(1)=CHFire_AK47
    FireCrouchAltAnims(2)=CHFire_AK47
    FireCrouchAltAnims(3)=CHFire_AK47
    HitAnims(0)=HitF_M4203
    HitAnims(1)=HitB_M4203
    HitAnims(2)=HitL_M4203
    HitAnims(3)=HitR_M4203
    PostFireBlendStandAnim=Blend_M4203
    PostFireBlendCrouchAnim=CHBlend_M4203
}
