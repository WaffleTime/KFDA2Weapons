//-----------------------------------------------------------
//
//-----------------------------------------------------------
class da_P280Handgun extends da_weapons_Reloadable;

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
    SelectAnim="Ready"
    BringUpTime=1.0
    bHasAimingMode=True
    MagCapacity=10
    ReloadAnim="Reload_Empty"
    ReloadShortRate=1.86
    ReloadShortAnim="Reload"
    ReloadRate=2.53
    ReloadAnimRate=1.000000
    FireModeClass(0)=Class'KFDA2Weapons.da_P280Fire'
    FireModeClass(1)=Class'KFMod.NoFire'
    IdleAnim="Idle"
    IdleAimAnim=Idle_Iron
    PutDownAnim="PutDown"
    SelectSound=Sound'KF_9MMSnd.9mm_Select'
    AIRating=0.200000
    Priority=8
    AttachmentClass=Class'KFDA2Weapons.da_P280Attachment'
    ItemName="P2-80 Pistol"
    Skins(0)=Shader'KF_DA2Weapons.Skins.P280_Final'
    MeshRef="KF_DA2_Weapons.KF_P280_1st"
    Mesh=SkeletalMesh'KF_DA2_Weapons.KF_P280_1st'
    SleeveNum=1

    PistolSlideOffset=(X=0,Y=0.0,Z=0.016833)
    FlashBoneName="Muzzle"
        
    DisplayFOV=60.000000
    StandardDisplayFOV=60.0
    PlayerIronSightFOV=75
    ZoomedDisplayFOV=60
        
    WeaponReloadAnim=Reload_Single9mm

    Weight=2.0
    bModeZeroCanDryFire=True
    Description="High Caliber Pistol chambered in 12.4x10.2mm munitions."
    InventoryGroup=2
    GroupOffset=1
    PickupClass=Class'KFDA2Weapons.da_P280Pickup'
    PlayerViewOffset=(X=20.000000,Y=10.000000,Z=-4.000000)
    BobDamping=6.000000
    IconCoords=(X1=434,Y1=253,X2=506,Y2=292)
        
    HudImage=texture'KF_DA2Weapons.Icons.P280_Unselect'
    SelectedHudImage=texture'KF_DA2Weapons.Icons.P280_Select'
    TraderInfoTexture=texture'KF_DA2Weapons.Icons.P280_Trader'
    HudImageRef="KF_DA2Weapons.Icons.P280_Unselect"
    SelectedHudImageRef="KF_DA2Weapons.Icons.P280_Select"
}
