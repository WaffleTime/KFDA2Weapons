// ============================================================================
//	DA2.da_weapons_GK2Shotgun:
//	By: aBsOlUt, Dante
// ============================================================================

class da_GK2Shotgun extends KFWeaponShotgun;

var() name Idle1; //Idle animation 1 (Fidgit1)
var() name Idle2; //Idle animation 2 (Fidgit2)
var() float LastFidgitTime;

//Time
var() float TweenTime;

var         name             ReloadShortAnim;
var         float             ReloadShortRate;
var transient bool  bShortReload;

simulated function PlayIdle()
{
    super.PlayIdle();
    if (ClientState == WS_ReadyToFire && !bIsReloading && !bAimingRifle && LastFidgitTime<Level.TimeSeconds) 
    {
        LastFidgitTime = Level.TimeSeconds + 25 + frand() * 15; //* 5
        if (frand() < 0.5 && hasAnim(Idle1))
            playAnim(Idle1, ReloadAnimRate, TweenTime);
        else if (hasAnim(Idle2))
            playAnim(Idle2, ReloadAnimRate, TweenTime);
    }
}

simulated function BringUp(optional Weapon PrevWeapon)
{
    Super.BringUp(PrevWeapon);
    if ( Instigator.IsLocallyControlled() && ((Mesh!=None) && SelectAnim == 'Ready' && HasAnim('Select')) ) // At this point, go back to the standard Select anim
    {
        SelectAnim = 'Select';
        BringUpTime = 0.33;
    }
}

//allow reloading with full mag for +1
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
        ReloadRate = default.ReloadShortRate / ReloadMulti;
    else
        ReloadRate = default.ReloadRate / ReloadMulti;
        
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
        PlayAnim(ReloadAnim, ReloadAnimRate*ReloadMulti, 0.1);
    }
    else if (MagAmmoRemaining >= 1)
    {
        PlayAnim(ReloadShortAnim, ReloadAnimRate*ReloadMulti, 0.1);
    }
}

function AddReloadedAmmo()
{
    local int a;
    
    UpdateMagCapacity(Instigator.PlayerReplicationInfo);

    a = MagCapacity;
    if ( bShortReload )
        a++; // 1 bullet already bolted
    
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

//this does a shell eject triggered by anim notify
simulated function Notify_EjectShell()
{
    if ( da_GK2Fire(FireMode[0]).ShellEjectEmitter != None )
    {
        if (!bIsReloading)
        da_GK2Fire(FireMode[0]).ShellEjectEmitter.Trigger(Self, Instigator);
    }
}

defaultproperties
{
    ReloadShortAnim="Reload"
    ReloadShortRate=1.6
    Idle1="Fidgit1"
    Idle2="Fidgit1"
    ReloadAnim="reload_empty"
    ReloadRate=2.16
    ReloadAnimRate=1.000000
    FireModeClass(0)=Class'KFDA2Weapons.da_GK2Fire'
    FireModeClass(1)=Class'KFMod.NoFire'
    SelectSoundRef="KF_M4ShotgunSnd.WEP_Benelli_Foley_Select"
    AIRating=0.800000
    DisplayFOV=60.000000
    InventoryGroup=3
    BobDamping=6.000000
    AttachmentClass=Class'KFDA2Weapons.da_GK2Attachment'
    ItemName="GK2 Shotgun"
    MeshRef="KF_DA2_Weapons.KF_GK2_1st"
    Mesh=SkeletalMesh'KF_DA2_Weapons.KF_GK2_1st'
    TweenTime=0.150000
    SelectAnim="Ready"
    BringUpTime=1.0
    bHasAimingMode=True
    MagCapacity=8
    IdleAnim="Idle"
    IdleAimAnim="Idle_Iron"
    PutDownAnim="PutDown"
    Priority=15
    Skins(0)=Shader'KF_DA2Weapons.Skins.GK2_Final'
    SleeveNum=1
    FlashBoneName="Muzzle"
        
    StandardDisplayFOV=65.0
    PlayerIronSightFOV=70 // Fov of the World in ADS
    ZoomedDisplayFOV=40   //60 Fov of the Gun in ADS
        
    WeaponReloadAnim=Reload_AK47
        
    Weight=5.0
    bModeZeroCanDryFire=True
    Description="Pump-Action Shotgun."
    GroupOffset=2
    PickupClass=Class'KFDA2Weapons.da_GK2Pickup'
    PlayerViewOffset=(X=5.000000,Y=10.000000,Z=-4.000000)
    IconCoords=(X1=169,Y1=172,X2=245,Y2=208)
        
    HudImage=texture'KF_DA2Weapons.Icons.GK2_Unselect'
    SelectedHudImage=texture'KF_DA2Weapons.Icons.GK2_Select'
    TraderInfoTexture=texture'KF_DA2Weapons.Icons.GK2_Trader'
    HudImageRef="KF_DA2Weapons.Icons.GK2_Unselect"
    SelectedHudImageRef="KF_DA2Weapons.Icons.GK2_Select"
     

    bHoldToReload=False
}
