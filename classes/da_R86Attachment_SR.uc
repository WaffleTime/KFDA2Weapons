class da_R86Attachment_SR extends KFWeaponAttachment;

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
    mMuzFlashClass=Class'KFDA2Weapons.da_R86Muzzle3rd'
    MeshRef="KF_DA2_Weapons.KF_R86_3rd"
    Mesh=SkeletalMesh'KF_DA2_Weapons.KF_R86_3rd'

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
    FireAnims(0)=Fire_M99
    FireAnims(1)=Fire_M99
    FireAnims(2)=Fire_M99
    FireAnims(3)=Fire_M99
    FireAltAnims(0)=Fire_M99
    FireAltAnims(1)=Fire_M99
    FireAltAnims(2)=Fire_M99
    FireAltAnims(3)=Fire_M99
    FireCrouchAnims(0)=CHFire_M99
    FireCrouchAnims(1)=CHFire_M99
    FireCrouchAnims(2)=CHFire_M99
    FireCrouchAnims(3)=CHFire_M99
    FireCrouchAltAnims(0)=CHFire_M99
    FireCrouchAltAnims(1)=CHFire_M99
    FireCrouchAltAnims(2)=CHFire_M99
    FireCrouchAltAnims(3)=CHFire_M99
    HitAnims(0)=HitF_M4203
    HitAnims(1)=HitB_M4203
    HitAnims(2)=HitL_M4203
    HitAnims(3)=HitR_M4203
    PostFireBlendStandAnim=Blend_M4203
    PostFireBlendCrouchAnim=CHBlend_M4203
}
