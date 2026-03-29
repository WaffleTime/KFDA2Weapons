//-----------------------------------------------------------
//
//-----------------------------------------------------------
class da_XD40Handgun extends da_weapons_Reloadable;

var         name            ReloadShortAnim;
var         float           ReloadShortRate;

var transient bool  bShortReload;
var transient bool bTweeningSlide;
var float TweenEndTime;
var vector PistolSlideOffset; //for tactical reload

var bool bFiringLastRound;

simulated function PostNetReceive()
{
    super.PostNetReceive();

    if ( Role < ROLE_Authority ) {
        if ( MagAmmoRemaining == 0 && !bIsReloading ) {
            LockSlideBack();
        }
    }
}

simulated function Fire(float F)
{
    bFiringLastRound = MagAmmoRemaining == 1;
    super.Fire(f);
}

simulated function BringUp(optional Weapon PrevWeapon)
{
    Super.BringUp(PrevWeapon);
    if (Level.NetMode != NM_DedicatedServer)
    {
        if (MagAmmoRemaining == 0)
            LockSlideBack(); //lock Slide back
    }

    if ( Instigator.IsLocallyControlled() && ((Mesh!=None) && SelectAnim == 'Ready' && HasAnim('Select')) ) // At this point, go back to the standard Select anim
    {
        SelectAnim = 'Select';
        BringUpTime = 0.33;
    }
}

simulated function LockSlideBack()
{
    SetBoneLocation( 'SlideR', -PistolSlideOffset, 100 ); //lock Slide back
}

//allowing +1 reload with full mag
simulated function bool AllowReload()
{
    UpdateMagCapacity(Instigator.PlayerReplicationInfo);

    if( !Instigator.IsHumanControlled() ) {
        return !bIsReloading && MagAmmoRemaining <= MagCapacity && AmmoAmount(0) > MagAmmoRemaining;
    }

    return !( FireMode[0].IsFiring() || FireMode[1].IsFiring() || bIsReloading || ClientState == WS_BringUp
            || MagAmmoRemaining >= MagCapacity + 1 || AmmoAmount(0) <= MagAmmoRemaining
            || (FireMode[0].NextFireTime - Level.TimeSeconds) > 0.1 );
}

simulated function ClientFinishReloading()
{
    PlayIdle();
    if(bShortReload)
        StartTweeningSlide(); //start tweening Slide back
    bIsReloading = false;

    if(Instigator.PendingWeapon != none && Instigator.PendingWeapon != self)
        Instigator.Controller.ClientSwitchToBestWeapon();
}

exec function ReloadMeNow()
{
    local float ReloadMulti;

    if(!AllowReload())
        return;
    if ( bHasAimingMode && bAimingRifle )
    {
        FireMode[1].bIsFiring = False;

        ZoomOut(false);
        if( Role < ROLE_Authority)
            ServerZoomOut(false);
    }

    if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
        ReloadMulti = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetReloadSpeedModifier(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self);
    else
        ReloadMulti = 1.0;

    bIsReloading = true;
    ReloadTimer = Level.TimeSeconds;
    bShortReload = MagAmmoRemaining > 0;
    if ( bShortReload )
        ReloadRate = Default.ReloadShortRate / ReloadMulti;
    else
        ReloadRate = Default.ReloadRate / ReloadMulti;

    if( bHoldToReload )
    {
        NumLoadedThisReload = 0;
    }
    ClientReload();
    Instigator.SetAnimAction(WeaponReloadAnim);
    if ( Level.Game.NumPlayers > 1 && KFGameType(Level.Game).bWaveInProgress && KFPlayerController(Instigator.Controller) != none &&
        Level.TimeSeconds - KFPlayerController(Instigator.Controller).LastReloadMessageTime > KFPlayerController(Instigator.Controller).ReloadMessageDelay )
    {
        KFPlayerController(Instigator.Controller).Speech('AUTO', 2, "");
        KFPlayerController(Instigator.Controller).LastReloadMessageTime = Level.TimeSeconds;
    }
}

simulated function ClientReload()
{
    local float ReloadMulti;
    if ( bHasAimingMode && bAimingRifle )
    {
        FireMode[1].bIsFiring = False;

        ZoomOut(false);
        if( Role < ROLE_Authority)
            ServerZoomOut(false);
    }

    if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
        ReloadMulti = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetReloadSpeedModifier(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self);
    else
        ReloadMulti = 1.0;

    bIsReloading = true;
    if (MagAmmoRemaining <= 0)
    {
        bShortReload = false;
        PlayAnim(ReloadAnim, ReloadAnimRate*ReloadMulti, 0.001);
        SetBoneLocation( 'SlideR', PistolSlideOffset, 0 ); //reset Slide so that the animation's Slide position gets used
    }
    else if (MagAmmoRemaining >= 1)
    {
        bShortReload = true;
        PlayAnim(ReloadShortAnim, ReloadAnimRate*ReloadMulti, 0.001); //reduced tween time to prevent Slide from sliding
        SetBoneLocation( 'SlideR', PistolSlideOffset, 0 ); //move the Slide forward
    }
}

//called by clientfinishreloading()
simulated function StartTweeningSlide()
{
    bTweeningSlide = true; //start Slide tweening
    TweenEndTime = Level.TimeSeconds + 0.2;
}

function AddReloadedAmmo()
{
    local int a;

    UpdateMagCapacity(Instigator.PlayerReplicationInfo);

    a = MagCapacity;
    //StartTweeningSlide(); //putting this here fixed tactical reload but broke empty
    if ( bShortReload )
    {
        //StartTweeningSlide(); //trying this again
        a++; // 1 bullet already bolted
    }
    if ( AmmoAmount(0) >= a )
        MagAmmoRemaining = a;
    else
        MagAmmoRemaining = AmmoAmount(0);

    // this seems redudant -- PooSH
    // if( !bHoldToReload )
    // {
        // ClientForceKFAmmoUpdate(MagAmmoRemaining,AmmoAmount(0));
    // }

    if ( PlayerController(Instigator.Controller) != none && KFSteamStatsAndAchievements(PlayerController(Instigator.Controller).SteamStatsAndAchievements) != none )
    {
        KFSteamStatsAndAchievements(PlayerController(Instigator.Controller).SteamStatsAndAchievements).OnWeaponReloaded();
    }
}

defaultproperties
{
    Idle2="Fidgit1"
    SelectAnim="Ready"
    BringUpTime=1.0
    bHasAimingMode=True
    //IronsightOffset=(X=2.000000,Y=-3.500000,Z=6.500000)
    //minZoom=0.140000
    //maxZoom=0.140000
    //zoomStep=0.140000
    //allMeleeTime=2.100000
    //DACrosshair=Texture'DA2Crosshairs.Weapon.pistolcross'
    //RecoilAddPerSec=7.000000
    //RecoilMax=7.000000
    //RecoilRegenPerSec=5.000000
    //RecoilMoveMalus=0.200000
    ReloadAnim="Reload_Empty"
    //reloadEmptyAnim="Reload"
    ReloadShortRate=1.33
    ReloadShortAnim="Reload"
    //ReloadSound=Sound'DA2_WeaponSounds.XD40_Reload'
    //reloadEmptySound=Sound'DA2_WeaponSounds.XD40_Reload_Empty'
    FireModeClass(0)=Class'KFDA2Weapons.da_XD40Fire'
    FireModeClass(1)=Class'KFMod.NoFire'
    IdleAnim="Idle"
    IdleAimAnim=Idle_Iron
    PutDownAnim="PutDown"
    //PutDownTime=0.000050
    //BringUpTime=0.920000
    //SelectSound=Sound'KF_9MMSnd.9mm_Dual_Reload_093'
    SelectSound=Sound'KF_9MMSnd.9mm_Select'
    AIRating=0.200000
    //DisplayFOV=60.000000
    Priority=4
    //PlayerViewPivot=(Yaw=-16384,Roll=16384)
    //BobDamping=1.900000
    AttachmentClass=Class'KFDA2Weapons.da_XD40Attachment'
    ItemName="XD-40 Pistol"
    Skins(0)=Shader'KF_DA2Weapons.Skins.XD40_Final'
    MeshRef="KF_DA2_Weapons.KF_XD40_1st"
    Mesh=SkeletalMesh'KF_DA2_Weapons.KF_XD40_1st'
    SleeveNum=1

    PistolSlideOffset=(X=0,Y=0.0,Z=0.016833)
    FlashBoneName="Muzzle"
        
    DisplayFOV=70.000000
    StandardDisplayFOV=70.0
    PlayerIronSightFOV=75
    ZoomedDisplayFOV=70
        
    WeaponReloadAnim=Reload_Single9mm
        
    MagCapacity=17
    ReloadRate=1.33
    ReloadAnimRate=1.000000
    Weight=1.000000
    bModeZeroCanDryFire=True
    Description="A 9mm Pistol"
    InventoryGroup=2
    GroupOffset=1
    PickupClass=Class'KFDA2Weapons.da_XD40Pickup'
    PlayerViewOffset=(X=22.000000,Y=18.000000,Z=-8.000000)
    BobDamping=6.000000
    IconCoords=(X1=434,Y1=253,X2=506,Y2=292)
        
    HudImage=texture'KF_DA2Weapons.Icons.XD40_Unselect'
    SelectedHudImage=texture'KF_DA2Weapons.Icons.XD40_Select'
    TraderInfoTexture=texture'KF_DA2Weapons.Icons.XD40_Trader'
    HudImageRef="KF_DA2Weapons.Icons.XD40_Unselect"
    SelectedHudImageRef="KF_DA2Weapons.Icons.X40_Select"
}
