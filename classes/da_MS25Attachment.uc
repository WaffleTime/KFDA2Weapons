class da_MS25Attachment extends KFWeaponAttachment;

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

simulated event ThirdPersonEffects()
{
    super.ThirdPersonEffects();

    if(mMuzFlash3rd!= none)
        AttachToBone(mMuzFlash3rd, 'Muzzle');
}

defaultproperties
{
    mMuzFlashClass=Class'KFDA2Weapons.da_MS25RocketLaunch'
    SplashEffect=Class'BulletSplashEmitter'
    CullDistance=5000.000000
    MeshRef="KF_DA2_Weapons.KF_MS25_3rd"
    Mesh=SkeletalMesh'KF_DA2_Weapons.KF_MS25_3rd'
    ShellEjectBoneName=Shell_Ejector
    bRapidFire=True
    bAltRapidFire=True

    mShellCaseEmitterClass=None
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

    MovementAnims(0)=JogF_LAW
    MovementAnims(1)=JogB_LAW
    MovementAnims(2)=JogL_LAW
    MovementAnims(3)=JogR_LAW
    CrouchAnims(0)=CHwalkF_LAW
    CrouchAnims(1)=CHwalkB_LAW
    CrouchAnims(2)=CHwalkL_LAW
    CrouchAnims(3)=CHwalkR_LAW
    WalkAnims(0)=WalkF_LAW
    WalkAnims(1)=WalkB_LAW
    WalkAnims(2)=WalkL_LAW
    WalkAnims(3)=WalkR_LAW
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

    TurnRightAnim=TurnR_LAW
    TurnLeftAnim=TurnL_LAW
    CrouchTurnRightAnim=CH_TurnR_LAW
    CrouchTurnLeftAnim=CH_TurnL_LAW
    IdleRestAnim=Idle_LAW//Idle_Rest
    IdleCrouchAnim=CHIdle_LAW
    IdleSwimAnim=Swim_Tread
    IdleWeaponAnim=Idle_LAW//Idle_Rifle
    IdleHeavyAnim=Idle_LAW//Idle_Biggun
    IdleRifleAnim=Idle_LAW//Idle_Rifle
    IdleChatAnim=Idle_LAW
    FireAnims(0)=Fire_LAW
    FireAnims(1)=Fire_LAW
    FireAnims(2)=Fire_LAW
    FireAnims(3)=Fire_LAW
    FireAltAnims(0)=Fire_LAW
    FireAltAnims(1)=Fire_LAW
    FireAltAnims(2)=Fire_LAW
    FireAltAnims(3)=Fire_LAW
    FireCrouchAnims(0)=CHFire_LAW
    FireCrouchAnims(1)=CHFire_LAW
    FireCrouchAnims(2)=CHFire_LAW
    FireCrouchAnims(3)=CHFire_LAW
    FireCrouchAltAnims(0)=CHFire_LAW
    FireCrouchAltAnims(1)=CHFire_LAW
    FireCrouchAltAnims(2)=CHFire_LAW
    FireCrouchAltAnims(3)=CHFire_LAW
    HitAnims(0)=HitF_LAW
    HitAnims(1)=HitB_LAW
    HitAnims(2)=HitL_LAW
    HitAnims(3)=HitR_LAW
    PostFireBlendStandAnim=Blend_LAW
    PostFireBlendCrouchAnim=CHBlend_LAW
}
