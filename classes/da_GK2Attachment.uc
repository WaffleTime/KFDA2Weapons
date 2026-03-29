class da_GK2Attachment extends KFWeaponAttachment;

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

// Copied from Kvolt
simulated event ThirdPersonEffects()
{
	local PlayerController PC;

	if ( (Level.NetMode == NM_DedicatedServer) || (Instigator == None) )
		return;

	// new Trace FX - Ramm
	if (FiringMode == 0)
	{
		PlayAnim('Fire'); //GK2 has a Fire anim for 3p
		if ( OldSpawnHitCount != SpawnHitCount )
		{
			OldSpawnHitCount = SpawnHitCount;
			GetHitInfo();
			PC = Level.GetLocalPlayerController();
			if ( ((Instigator != None) && (Instigator.Controller == PC)) || (VSize(PC.ViewTarget.Location - mHitLocation) < 4000) )
			{
				if( mHitActor!=None )
					Spawn(class'KFDA2Weapons.da_HitEffect',,, mHitLocation, Rotator(-mHitNormal));
				CheckForSplash();
				SpawnTracer();
			}
		}
	}

  	if ( FlashCount>0 )
	{
		if( KFPawn(Instigator)!=None )
		{
			if (FiringMode == 0)
			{
				KFPawn(Instigator).StartFiringX(false,bRapidFire);
			}
			else
            {
                KFPawn(Instigator).StartFiringX(true,bRapidFire);
            }
		}

		if( bDoFiringEffects )
		{
    		PC = Level.GetLocalPlayerController();

    		if ( (Level.TimeSeconds - LastRenderTime > 0.2) && (Instigator.Controller != PC) )
    			return;

    		WeaponLight();

    		DoFlashEmitter();

    		if ( (mShellCaseEmitter == None) && (Level.DetailMode != DM_Low) && !Level.bDropDetail )
    		{
    			mShellCaseEmitter = Spawn(mShellCaseEmitterClass);
    			if ( mShellCaseEmitter != None )
    			    AttachToBone(mShellCaseEmitter, ShellEjectBoneName);
    		}
    		if (mShellCaseEmitter != None)
    			mShellCaseEmitter.mStartParticles++;
		}
	}
	else
	{
		GotoState('');
		if( KFPawn(Instigator)!=None )
			KFPawn(Instigator).StopFiring();
	}
}

defaultproperties
{
    mMuzFlashClass=Class'KFDA2Weapons.da_GK2Muzzle3rd'
    SplashEffect=Class'BulletSplashEmitter'
    CullDistance=5000.000000
    MeshRef="KF_DA2_Weapons.KF_GK2_3rd"
    Mesh=SkeletalMesh'KF_DA2_Weapons.KF_GK2_3rd'
    ShellEjectBoneName=Shell_Ejector

    mShellCaseEmitterClass=Class'KFMod.KFShotgunShellSpewer'
    mShellEmitterOffset=(X=28.000000,Y=-40.000000,Z=62.000000)
    mTracerClass=Class'KFDA2Weapons.da_TraceMaker'
    mTracerPullback=25.000000
    mTracerSpeed=7500.000000
    LightType=LT_Steady
    LightEffect=LE_NonIncidence
    LightHue=30
    LightSaturation=160
    LightBrightness=220.000000
    LightRadius=8.000000
    LightPeriod=3
    DrawScale=1.000000

    MovementAnims(0)=JogF_Shotgun
    MovementAnims(1)=JogB_Shotgun
    MovementAnims(2)=JogL_Shotgun
    MovementAnims(3)=JogR_Shotgun
    CrouchAnims(0)=CHwalkF_Shotgun
    CrouchAnims(1)=CHwalkB_Shotgun
    CrouchAnims(2)=CHwalkL_Shotgun
    CrouchAnims(3)=CHwalkR_Shotgun
    WalkAnims(0)=WalkF_Shotgun
    WalkAnims(1)=WalkB_Shotgun
    WalkAnims(2)=WalkL_Shotgun
    WalkAnims(3)=WalkR_Shotgun
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

    TurnRightAnim=TurnR_Shotgun
    TurnLeftAnim=TurnL_Shotgun
    CrouchTurnRightAnim=CH_TurnR_Shotgun
    CrouchTurnLeftAnim=CH_TurnL_Shotgun
    IdleRestAnim=Idle_Shotgun//Idle_Rest
    IdleCrouchAnim=CHIdle_Shotgun
    IdleSwimAnim=Swim_Tread
    IdleWeaponAnim=Idle_Shotgun//Idle_Rifle
    IdleHeavyAnim=Idle_Shotgun//Idle_Biggun
    IdleRifleAnim=Idle_Shotgun//Idle_Rifle
    IdleChatAnim=Idle_Shotgun
    FireAnims(0)=Fire_Shotgun
    FireAnims(1)=Fire_Shotgun
    FireAnims(2)=Fire_Shotgun
    FireAnims(3)=Fire_Shotgun
    FireAltAnims(0)=Fire_Shotgun
    FireAltAnims(1)=Fire_Shotgun
    FireAltAnims(2)=Fire_Shotgun
    FireAltAnims(3)=Fire_Shotgun
    FireCrouchAnims(0)=CHFire_Shotgun
    FireCrouchAnims(1)=CHFire_Shotgun
    FireCrouchAnims(2)=CHFire_Shotgun
    FireCrouchAnims(3)=CHFire_Shotgun
    FireCrouchAltAnims(0)=CHFire_Shotgun
    FireCrouchAltAnims(1)=CHFire_Shotgun
    FireCrouchAltAnims(2)=CHFire_Shotgun
    FireCrouchAltAnims(3)=CHFire_Shotgun
    HitAnims(0)=HitF_Shotgun
    HitAnims(1)=HitB_Shotgun
    HitAnims(2)=HitL_Shotgun
    HitAnims(3)=HitR_Shotgun
    PostFireBlendStandAnim=Blend_Shotgun
    PostFireBlendCrouchAnim=CHBlend_Shotgun
}
