//-----------------------------------------------------------
//
//-----------------------------------------------------------
class da_A9SMG extends da_weapons_Reloadable;

#EXEC OBJ LOAD FILE=KF_DA2_Weapons.ukx

var         name            ReloadShortAnim;
var         float           ReloadShortRate;
var transient bool  bShortReload;

simulated function BringUp(optional Weapon PrevWeapon)
{
    Super.BringUp(PrevWeapon);

    if ( Instigator.IsLocallyControlled() && ((Mesh!=None) && SelectAnim == 'Ready' && HasAnim('Select')) ) // At this point, go back to the standard Select anim
    {
        SelectAnim = 'Select';
        BringUpTime = 0.33;
    }
}

// copy-pasted to add (MagCapacity+1)fD
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

simulated function bool StartFire(int Mode)
{
	if( Mode == 1 )
		return super.StartFire(Mode);

	if( !super.StartFire(Mode) )  // returns false when mag is empty
	   return false;

	if( AmmoAmount(0) <= 0 )
	{
    	return false;
    }

	AnimStopLooping();

	if( !FireMode[Mode].IsInState('FireLoop') && (AmmoAmount(0) > 0) )
	{
		FireMode[Mode].StartFiring();
		return true;
	}
	else
	{
		return false;
	}

	return true;
}

simulated function AnimEnd(int channel)
{
    local name anim;
    local float frame, rate;

	if(!FireMode[0].IsInState('FireLoop'))
	{
        GetAnimParams(0, anim, frame, rate);

        if (ClientState == WS_ReadyToFire)
        {
             if ((FireMode[0] == None || !FireMode[0].bIsFiring) && (FireMode[1] == None || !FireMode[1].bIsFiring))
            {
                PlayIdle();
            }
        }
	}
}

defaultproperties
{
    SelectAnim="Ready"
    BringUpTime=1.0
    bHasAimingMode=True
    MagCapacity=30
    ReloadAnim="Reload_Empty"
    ReloadShortRate=1.6
    ReloadShortAnim="Reload"
    ReloadRate=2.5
    ReloadAnimRate=1.000000
    FireModeClass(0)=Class'KFDA2Weapons.da_A9Fire'
    FireModeClass(1)=Class'KFMod.NoFire'
    IdleAnim="Idle"
    IdleAimAnim=Idle_Iron
    PutDownAnim="PutDown"
    //SelectSound=Sound'Inf_Weapons_Foley.g43.g43_reloadempty04_139'
    SelectSoundRef="KF_MAC10MPSnd.MAC10_Select"
    AIRating=0.200000
    Priority=10
    AttachmentClass=Class'KFDA2Weapons.da_A9Attachment'
    ItemName="A9 Submachine Gun"
    Skins(0)=Shader'KF_DA2Weapons.Skins.A9_Final'
    MeshRef="KF_DA2_Weapons.KF_A9_1st"
    Mesh=SkeletalMesh'KF_DA2_Weapons.KF_A9_1st'
    SleeveNum=0

    FlashBoneName="Muzzle"
        
    DisplayFOV=60.000000
    StandardDisplayFOV=60.0
    PlayerIronSightFOV=75
    ZoomedDisplayFOV=60
        
    WeaponReloadAnim=Reload_Single9mm

    Weight=3.0
    bModeZeroCanDryFire=false
    Description="A9 Submachine Gun."
    InventoryGroup=3
    GroupOffset=5
    PickupClass=Class'KFDA2Weapons.da_A9Pickup'
    PlayerViewOffset=(X=18.000000,Y=12.000000,Z=-6.000000) //(X=18.000000,Y=10.000000,Z=-8.000000)
    BobDamping=6.000000
    IconCoords=(X1=434,Y1=253,X2=506,Y2=292)
        
    HudImage=texture'KF_DA2Weapons.Icons.A9_Unselect'
    SelectedHudImage=texture'KF_DA2Weapons.Icons.A9_Select'
    TraderInfoTexture=texture'KF_DA2Weapons.Icons.A9_Trader'
	HudImageRef="KF_DA2Weapons.Icons.A9_Unselect"
    SelectedHudImageRef="KF_DA2Weapons.Icons.A9_Select"
}
