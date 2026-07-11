// ============================================================================
//	DA2.da_weapons_LK2Shotgun:
//	By: aBsOlUt, Dante
// ============================================================================

class da_LK2Shotgun extends KFWeaponShotgun;

var() name Idle1; //Idle animation 1 (Fidgit1)
var() name Idle2; //Idle animation 2 (Fidgit2)
var() name postReloadAnim; //postReloadAnim animation
var() float LastFidgitTime;
var() float TweenTime;
var() bool bChamberThisReload; //if full reload is uninterrupted, play chambering animation
var() float FirstShellInsertTime; // Time for which the weapon raises before inserting the first shell (regardless of full or partial reload)
var() float ChamberTime; // Time it takes for the weapon to chamber a shell on full reloads
var bool bWideSpread;

replication
{
	reliable if(Role < ROLE_Authority)
		ServerFixReload;
	reliable if(Role == ROLE_Authority)
		ClientFixReload, ChamberShell;
}

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

simulated function float GetReloadMultiplier() // 1G: Having a return function for this so I don't have to C&P this whole bit
{
	local float ReloadMulti;

	if ( KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo) != none && KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill != none )
	{
		ReloadMulti = KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo).ClientVeteranSkill.Static.GetReloadSpeedModifier(KFPlayerReplicationInfo(Instigator.PlayerReplicationInfo), self);
	}
	else
	{
		ReloadMulti = 1.0;
	}

	return ReloadMulti;
}

simulated function ChamberShell()
{
	PlayAnim(ReloadAnim, ReloadAnimRate*GetReloadMultiplier(), 0.25); //added this
	SetAnimFrame(44, 0, 1);  // Chamber the last shell
}

// copy-pasted to add (MagCapacity+1)
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

simulated function ClientReload()
{
	bChamberThisReload = ( MagAmmoRemaining == 0 ); //for chambering animation
    Super.ClientReload();
}

simulated function ClientFinishReloading()
{
    bIsReloading = false;
    //play chambering animation if finished reloading from empty
    if ( !bChamberThisReload )
    {
        PlayAnim(postReloadAnim, ReloadAnimRate * 2.0, TweenTime);
        FireMode[0].NextFireTime = Level.TimeSeconds + (0.20/GetReloadMultiplier());
        //PlayIdle();
    }
    bChamberThisReload = false;

    if(Instigator.PendingWeapon != none && Instigator.PendingWeapon != self)
        Instigator.Controller.ClientSwitchToBestWeapon();
}

simulated function WeaponTick(float dt)
{
	local float LastSeenSeconds;

	if( bHasAimingMode )
	{
        if( bForceLeaveIronsights )
        {
        	if( bAimingRifle )
        	{
                ZoomOut(true);

            	if( Role < ROLE_Authority)
        			ServerZoomOut(false);
            }

            bForceLeaveIronsights = false;
        }

        if( ForceZoomOutTime > 0 )
        {
            if( bAimingRifle )
            {
        	    if( Level.TimeSeconds - ForceZoomOutTime > 0 )
        	    {
                    ForceZoomOutTime = 0;

                	ZoomOut(true);

                	if( Role < ROLE_Authority)
            			ServerZoomOut(false);
        		}
    		}
    		else
    		{
                ForceZoomOutTime = 0;
    		}
    	}
	}

	 if ( (Level.NetMode == NM_Client) || Instigator == None || KFFriendlyAI(Instigator.Controller) == none && Instigator.PlayerReplicationInfo == None)
		return;

	UpdateMagCapacity(Instigator.PlayerReplicationInfo);

	if(!bIsReloading)
	{
		if(!Instigator.IsHumanControlled())
		{
			LastSeenSeconds = Level.TimeSeconds - Instigator.Controller.LastSeenTime;
			if(MagAmmoRemaining == 0 || ((LastSeenSeconds >= 5 || LastSeenSeconds > MagAmmoRemaining) && MagAmmoRemaining < MagCapacity))
				ReloadMeNow();
		}
	}
	else
	{
		if((Level.TimeSeconds - ReloadTimer) >= ReloadRate)
		{
			if(AmmoAmount(0) <= MagCapacity && !bHoldToReload)
			{
				MagAmmoRemaining = AmmoAmount(0);
				ActuallyFinishReloading();
			}
			else
			{
				AddReloadedAmmo();

				if( bHoldToReload )
                {
                    NumLoadedThisReload++;
                    //	Reload Anim Fix above intended capacity
					// Subsequent Shells have the regular reload rate
                    if (NumLoadedThisReload == 1)
                        ReloadRate = default.ReloadRate / GetReloadMultiplier();
					// 1G: 	I initially tried checking if it's more than default.MagCapacity but it cuts off the sound of the shell inserting
					//		So now I just made it so that all reloads are playing the last shell insert animation before the chambering
                    if (NumLoadedThisReload < MagCapacity && !bChamberThisReload || NumLoadedThisReload < MagCapacity + 1 && !bChamberThisReload)
                        FixReload(GetReloadMultiplier());
                    else if (NumLoadedThisReload < MagCapacity || NumLoadedThisReload < MagCapacity)
                        FixReload(GetReloadMultiplier());
                    //
                }
				// Modified for +1 Capacity
				if ((MagAmmoRemaining < MagCapacity && MagAmmoRemaining < AmmoAmount(0) && bHoldToReload) || (!bChamberThisReload || MagAmmoRemaining + 1 < MagCapacity && MagAmmoRemaining < AmmoAmount(0) && bHoldToReload))
					ReloadTimer = Level.TimeSeconds;
				// +1 Capacity if a Shell is chambered
				if (bChamberThisReload && (MagAmmoRemaining >= MagCapacity || MagAmmoRemaining >= AmmoAmount(0) || !bHoldToReload || bDoSingleReload))
					ActuallyFinishReloading();
				else if (MagAmmoRemaining >= MagCapacity + 1 || MagAmmoRemaining >= AmmoAmount(0) || !bHoldToReload || bDoSingleReload)
					ActuallyFinishReloading();
				else if( Level.NetMode!=NM_Client )
					Instigator.SetAnimAction(WeaponReloadAnim);
			}
		}
		else if(bIsReloading && !bReloadEffectDone && Level.TimeSeconds - ReloadTimer >= ReloadRate / 2)
		{
			bReloadEffectDone = true;
			ClientReloadEffects();
		}
	}
}

// 1G: 	This whole bit here I've tried following the code that was written in ScrN's M32
//		because I know nothing about replication :(
simulated function bool FixReload(float ReloadMulti)
{
    ServerFixReload(ReloadMulti);
    ClientFixReload(ReloadMulti);
    return true;
}

function ServerFixReload(float ReloadMulti)
{
    if ( Role == ROLE_Authority ) {
        if ( Level.NetMode != NM_DedicatedServer && Instigator.IsLocallyControlled() ) {
            PlayAnim(ReloadAnim, ReloadAnimRate*ReloadMulti, 0.1); //added this
            SetAnimFrame(21, 0, 1);  // loop to the last shell
        }
    }
}

simulated function ClientFixReload(float ReloadMulti)
{
    if ( Role < ROLE_Authority ) {
        PlayAnim(ReloadAnim, ReloadAnimRate*ReloadMulti, 0.1); //added this
        SetAnimFrame(21, 0, 1);  // loop to the last shell
    }
}
//
exec function ReloadMeNow()
{
	if(!AllowReload())
		return;

	if ( bHasAimingMode && bAimingRifle )
	{
		FireMode[1].bIsFiring = False;

		ZoomOut(false);
		if( Role < ROLE_Authority)
			ServerZoomOut(false);
	}

	bIsReloading = true;
	ReloadTimer = Level.TimeSeconds;
    // First Shell Load (Raising the weapon + putting in the shell)
	ReloadRate = (default.ReloadRate + FirstShellInsertTime) / GetReloadMultiplier();
    //
	// 1G: Need to know this server side, or else the second condition in an my added if check in the firing class will always return false
	bChamberThisReload = ( MagAmmoRemaining == 0 ); //for chambering animation

	if( bHoldToReload )
	{
		NumLoadedThisReload = 0;
	}

	ClientReload();
	Instigator.SetAnimAction(WeaponReloadAnim);

	// Reload message commented out for now - Ramm
	if ( Level.Game.NumPlayers > 1 && KFGameType(Level.Game).bWaveInProgress && KFPlayerController(Instigator.Controller) != none &&
		 Level.TimeSeconds - KFPlayerController(Instigator.Controller).LastReloadMessageTime > KFPlayerController(Instigator.Controller).ReloadMessageDelay )
	{
		KFPlayerController(Instigator.Controller).Speech('AUTO', 2, "");
		KFPlayerController(Instigator.Controller).LastReloadMessageTime = Level.TimeSeconds;
	}
}

simulated function ServerInterruptReload()
{
	bDoSingleReload = false;
	bIsReloading = false;
	bReloadEffectDone = false;
	if (!bChamberThisReload || MagAmmoRemaining <= 0 && Instigator.IsLocallyControlled() && Role == ROLE_Authority)
    {	// This doesn't play well on real servers
        // PlayAnim(postReloadAnim, ReloadAnimRate * 2.0, TweenTime);
        // FireMode[0].NextFireTime = Level.TimeSeconds + (0.20/GetReloadMultiplier());
		PlayIdle();
    }
    else
	{
		ChamberShell();
		// Wait until it's fully chambered
		// 1G:	Trying out ScrN's M99, I found that the code for setting the next firetime puts
		//		the weapon out of sync on the client side when players fire it earlier than intended
		//		on the server side. Not specifically for the M99, no. I tried this on other weapons
		//		during my time figuring out how to switch weapons TF2 style before finding out about
		//		MinReloadPct.
		FireMode[0].NextFireTime = Level.TimeSeconds + (ChamberTime/GetReloadMultiplier());
		bChamberThisReload = false;
	}
}

simulated function ClientInterruptReload()
{
	bIsReloading = false;
	if (!bChamberThisReload || MagAmmoRemaining <= 0 && Instigator.IsLocallyControlled() && Role < ROLE_Authority)
    {   // This doesn't play well on real servers
        // PlayAnim(postReloadAnim, ReloadAnimRate * 2.0, TweenTime);
        // FireMode[0].NextFireTime = Level.TimeSeconds + (0.20/GetReloadMultiplier());
		PlayIdle();
    }
	else
	{
		ChamberShell();
		// Wait until it's fully chambered
		FireMode[0].NextFireTime = Level.TimeSeconds + (ChamberTime/GetReloadMultiplier());
		bChamberThisReload = false;
	}
}

// If on empty reloads, pause for the chamber animation (InterruptReload() calls the chambering animation)
simulated function bool PutDown()
{
	// 1G:	Since in the base PutDown function, Interrupt reload is called, only the time to delay
	//		is needed after the fact
	if (bChamberThisReload && MagAmmoRemaining > 0)
	{
		DownDelay += (ChamberTime/GetReloadMultiplier());
	}
	return super.PutDown();
}

// Use alt fire to switch fire modes
simulated function AltFire(float F)
{
    if(ReadyToFire(0))
    {
        DoToggle();
    }
}

// Toggle semi/auto fire
simulated function DoToggle ()
{
	local PlayerController Player;
	Player = Level.GetLocalPlayerController();
	if ( Player!=None )
	{
		bWideSpread = !bWideSpread;
		if (bWideSpread )
		{
			Player.ReceiveLocalizedMessage(class'KFDA2Weapons.da_LK2SwitchMessage',1);
			ItemName="(Semi) "$default.ItemName;
		}
		else
		{
			Player.ReceiveLocalizedMessage(class'KFDA2Weapons.da_LK2SwitchMessage',0);
			ItemName="(Auto) "$default.ItemName;		
		}
	}

	PlayOwnedSound(ToggleSound,SLOT_None,2.0,,,,false);

	ServerChangeFireMode(bWideSpread);
}

// Set the new fire mode on the server
function ServerChangeFireMode(bool bNewbWideSpread)
{
    bWideSpread = bNewbWideSpread;
}

exec function SwitchModes()
{
	DoToggle();
}

defaultproperties
{
	Idle1="Fidgit1"
	Idle2="Fidgit1"
	ReloadAnim="Reload_Short"
	postReloadAnim="Reload_End"
	FireModeClass(0)=Class'KFDA2Weapons.da_LK2Fire'
	FireModeClass(1)=Class'KFMod.NoFire'
	//SelectSound=Sound'DA2_WeaponSounds.Reload.LK2_Reload_2'
	SelectSoundRef="KF_M4ShotgunSnd.WEP_Benelli_Foley_Select"
	AIRating=0.800000
	DisplayFOV=60.000000
	InventoryGroup=3
	BobDamping=6.000000
	AttachmentClass=Class'KFDA2Weapons.da_LK2Attachment'
	ItemName="LK2 AutoShotgun"
	MeshRef="KF_DA2_Weapons.KF_LK2_1st"
	Mesh=SkeletalMesh'KF_DA2_Weapons.KF_LK2_1st'

	TweenTime=0.150000
	ReloadRate=0.542 //0.571 //0.6
	FirstShellInsertTime=0.2 //0.2
	ChamberTime=0.65

	SelectAnim="Ready"
	BringUpTime=1.0
	bHasAimingMode=True
	MagCapacity=8
	ReloadAnimRate=1.000000
	IdleAnim="Idle"
	IdleAimAnim="Idle_Iron"
	PutDownAnim="PutDown"
	Priority=10
	Skins(0)=Shader'KF_DA2Weapons.Skins.LK2_Final'
	Skins(1)=Shader'KF_DA2Weapons.Skins.LK2_Shell_Final'
	SleeveNum=2
	FlashBoneName="Muzzle"
	    
	StandardDisplayFOV=65.0
	PlayerIronSightFOV=70 // Fov of the World in ADS
	ZoomedDisplayFOV=40 //60 Fov of the GUN in ADS
	    
	WeaponReloadAnim=Reload_Shotgun
		
	Weight=5.0
	bModeZeroCanDryFire=True
	Description="LK2 AutoShotgun hold the trigger to keep the pellets coming."
	GroupOffset=2
	PickupClass=Class'KFDA2Weapons.da_LK2Pickup'
	PlayerViewOffset=(X=5.000000,Y=10.000000,Z=-4.000000)
	IconCoords=(X1=169,Y1=172,X2=245,Y2=208)
	    
	HudImage=texture'KF_DA2Weapons.Icons.LK2_Unselect'
	SelectedHudImage=texture'KF_DA2Weapons.Icons.LK2_Select'
	TraderInfoTexture=texture'KF_DA2Weapons.Icons.LK2_Trader'
    HudImageRef="KF_DA2Weapons.Icons.LK2_Unselect"
    SelectedHudImageRef="KF_DA2Weapons.Icons.LK2_Select"

	bHoldToReload=True
}
