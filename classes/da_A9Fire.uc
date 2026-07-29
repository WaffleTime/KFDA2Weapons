//-----------------------------------------------------------
//
//-----------------------------------------------------------
class da_A9Fire extends da_BasicFire;

// Overwritten to switch damage types for the firebug
function DoTrace(Vector Start, Rotator Dir)
{
	if ((KFPlayerReplicationInfo(Weapon.Instigator.PlayerReplicationInfo).ClientVeteranSkill.default.PerkIndex==5) || (KFPlayerReplicationInfo(Weapon.Instigator.PlayerReplicationInfo).ClientVeteranSkill.default.PerkIndex==18))
		DamageType = Class'KFDA2Weapons.da_damtypes_A9SMG_SR';
	else 
		DamageType = Class'KFDA2Weapons.da_damtypes_A9SMG';
     
     Super.DoTrace(Start,Dir);
}

function StartFiring()
{
    if( !bWaitForRelease )
    {
        GotoState('FireLoop');
    }
    else
    {
        Super.StartFiring();
    }
}

event ModeDoFire()
{
    if( !bWaitForRelease )
    {
    	if( AllowFire() && IsInState('FireLoop'))
    	{
    	    Super.ModeDoFire();
    	}
	}
	else
	{
	   Super.ModeDoFire();
	}
}

state FireLoop
{
    function BeginState()
    {
        super.BeginState();

        if( KFWeap.bAimingRifle )
		{
            Weapon.LoopAnim(FireLoopAimedAnim, FireLoopAnimRate, TweenTime);
		}
		else
		{
            Weapon.LoopAnim(FireLoopAnim, FireLoopAnimRate, TweenTime);
		}

        NextFireTime = Level.TimeSeconds - 0.000001; //fire now!
    }

	// Overriden because we play an anbient fire sound
    //function PlayFiring() {}
	//function ServerPlayFiring() {}

function PlayFiring()
{
	if( Weapon.Instigator != none && Weapon.Instigator.IsLocallyControlled() &&
	   Weapon.Instigator.IsFirstPerson() && StereoFireSound != none )
	{
        Weapon.PlayOwnedSound(StereoFireSound,SLOT_Interact,TransientSoundVolume * 0.85,,TransientSoundRadius,(1.0),false);
    }
    else
    {
        Weapon.PlayOwnedSound(FireSound,SLOT_Interact,TransientSoundVolume,,TransientSoundRadius,(1.0),false);
    }
    ClientPlayForceFeedback(FireForce);  // jdf
    //FireCount++;
}
    function ServerPlayFiring()
    {
        Super.ServerPlayFiring();
    }

    function EndState()
    {
        Weapon.AnimStopLooping();
        Weapon.StopFire(ThisModeNum);
    }

    function StopFiring()
    {
        GotoState('');
    }

    function ModeTick(float dt)
    {
	    Super.ModeTick(dt);
		if ( !bIsFiring ||  !AllowFire()  )  // stopped firing, magazine empty
        {
			GotoState('');
			return;
		}
    }
}

function PlayFireEnd()
{
    if( !bWaitForRelease )
    {
        Super.PlayFireEnd();
    }
}

defaultproperties
{
     MuzEmitterClass=Class'KFDA2Weapons.da_XD40Muzzle1st'
     FlashEmitterClass=Class'KFDA2Weapons.da_XD40Muzzle1st'
     DamageType=Class'KFDA2Weapons.da_damtypes_A9SMG'
     DamageMin=12
     DamageMax=29 //18 OG
     Momentum=1100.000000
     TransientSoundVolume=1.8
     TransientSoundRadius=250.000000
     FireLoopAnimRate=1.0
     FireAnim="Fire_Loop"
     FireLoopAnim="Fire_Loop"
     FireEndAnim="Fire_End"
     FireAimedAnim=Fire_Loop
     FireLoopAimedAnim=Fire_Loop
     FireEndAimedAnim=Fire_End
     FireAnimRate=1.0
     FireSound=Sound'DA2_WeaponSounds.Gunshots.A-9_Fire'
     StereoFireSoundRef="DA2_WeaponSounds.Gunshots.A-9_Fire"
     NoAmmoSound=Sound'KF_9MMSnd.9mm_DryFire'
     FireRate=0.08
     AmmoClass=Class'KFDA2Weapons.da_A9Ammo'
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=50.000000)
     ShakeRotRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeRotTime=1.500000
     ShakeOffsetMag=(X=-7.000000,Y=6.500000,Z=9.000000)
     ShakeOffsetTime=1.000000
     BotRefireRate=0.990000
     aimerror=30.000000
     Spread=0.038000

     ShellEjectClass=class'KFDA2Weapons.da_ShellEjectPistol'
     ShellEjectBoneName=Shell_Ejector
     bRandomPitchFireSound=false
     bPawnRapidFireAnim=True
     bAttachSmokeEmitter=True
     RecoilRate=0.07
     maxVerticalRecoilAngle=124
     maxHorizontalRecoilAngle=75
     RecoilVelocityScale=0.3
     TweenTime=0.05
     AmmoPerFire=1
     SpreadStyle=SS_Random
     bWaitForRelease=false
}