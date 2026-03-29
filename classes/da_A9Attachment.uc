class da_A9Attachment extends KFWeaponAttachment;

#EXEC OBJ LOAD FILE= KF_DA2_Weapons.ukx

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

defaultproperties
{
    mMuzFlashClass=Class'KFDA2Weapons.da_XD40Muzzle3rd'
    SplashEffect=Class'BulletSplashEmitter'
    CullDistance=5000.000000
    MeshRef="KF_DA2_Weapons.KF_A9_3rd"
    Mesh=SkeletalMesh'KF_DA2_Weapons.KF_A9_3rd'
    ShellEjectBoneName=Shell_Ejector
    bRapidFire=True
    bAltRapidFire=True

    mShellCaseEmitterClass=Class'KFDA2Weapons.da_ShellSpewer'
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

    MovementAnims(0)=JogF_MP7
    MovementAnims(1)=JogB_MP7
    MovementAnims(2)=JogL_MP7
    MovementAnims(3)=JogR_MP7
    CrouchAnims(0)=CHwalkF_MP7
    CrouchAnims(1)=CHwalkB_MP7
    CrouchAnims(2)=CHwalkL_MP7
    CrouchAnims(3)=CHwalkR_MP7
    WalkAnims(0)=WalkF_MP7
    WalkAnims(1)=WalkB_MP7
    WalkAnims(2)=WalkL_MP7
    WalkAnims(3)=WalkR_MP7
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

    TurnRightAnim=TurnR_MP7
    TurnLeftAnim=TurnL_MP7
    CrouchTurnRightAnim=CH_TurnR_MP7
    CrouchTurnLeftAnim=CH_TurnL_MP7
    IdleRestAnim=Idle_MP7//Idle_Rest
    IdleCrouchAnim=CHIdle_MP7
    IdleSwimAnim=Swim_Tread
    IdleWeaponAnim=Idle_MP7//Idle_Rifle
    IdleHeavyAnim=Idle_MP7//Idle_Biggun
    IdleRifleAnim=Idle_MP7//Idle_Rifle
    IdleChatAnim=Idle_MP7
    FireAnims(0)=Fire_MP7
    FireAnims(1)=Fire_MP7
    FireAnims(2)=Fire_MP7
    FireAnims(3)=Fire_MP7
    FireAltAnims(0)=Fire_MP7
    FireAltAnims(1)=Fire_MP7
    FireAltAnims(2)=Fire_MP7
    FireAltAnims(3)=Fire_MP7
    FireCrouchAnims(0)=CHFire_MP7
    FireCrouchAnims(1)=CHFire_MP7
    FireCrouchAnims(2)=CHFire_MP7
    FireCrouchAnims(3)=CHFire_MP7
    FireCrouchAltAnims(0)=CHFire_MP7
    FireCrouchAltAnims(1)=CHFire_MP7
    FireCrouchAltAnims(2)=CHFire_MP7
    FireCrouchAltAnims(3)=CHFire_MP7
    HitAnims(0)=HitF_MP7
    HitAnims(1)=HitB_MP7
    HitAnims(2)=HitL_MP7
    HitAnims(3)=HitR_MP7
    PostFireBlendStandAnim=Blend_MP7
    PostFireBlendCrouchAnim=CHBlend_MP7
}
