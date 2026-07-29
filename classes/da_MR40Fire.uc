//-----------------------------------------------------------
//
//-----------------------------------------------------------
class da_MR40Fire extends da_BasicFire;

//
simulated function PostNetBeginPlay()
{
    local rotator r;

    r.pitch=-16384; //
    weapon.SetBoneRotation('Muzzle', r, 0, 1.f);
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
    //ClientPlayForceFeedback(FireForce);  // jdf
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
    MaxPenetrations=1
    PenDmgReduction=0.75
    MuzEmitterClass=Class'KFDA2Weapons.da_MR40Muzzle1st'
    FlashEmitterClass=Class'KFDA2Weapons.da_MR40Muzzle1st'
    DamageType=Class'KFDA2Weapons.da_damtypes_MR40Heavy'
    DamageMin=26
    DamageMax=56 //32 OG
    Momentum=1500.000000
    TransientSoundVolume=2.500000
    TransientSoundRadius=400.000000
    FireLoopAnimRate=1.0
    FireAnim="Fire_Loop"
    FireLoopAnim="Fire_Loop"
    FireEndAnim="Fire_End"
    FireAimedAnim="Fire_Loop"
    FireLoopAimedAnim="Fire_Loop"
    FireEndAimedAnim="Fire_End"
    FireAnimRate=1.0
    FireSound=Sound'DA2_WeaponSounds.Gunshots.MR40_Fire'
    StereoFireSoundRef="DA2_WeaponSounds.Gunshots.MR40_Fire"
    NoAmmoSound=Sound'KF_9MMSnd.9mm_DryFire'
    FireRate=0.130000
    AmmoClass=Class'KFDA2Weapons.da_MR40Ammo'
    ShakeRotMag=(X=130.000000,Y=130.000000,Z=255.000000)
    ShakeRotRate=(X=5000.000000,Y=5000.000000,Z=5000.000000)
    ShakeRotTime=1.500000
    ShakeOffsetMag=(X=-15.000000,Y=9.000000,Z=14.000000)
    ShakeOffsetTime=1.000000
    BotRefireRate=0.990000
    aimerror=140.000000
    Spread=0.025000
    
    ShellEjectClass=class'KFDA2Weapons.da_ShellEjectRifle'
    ShellEjectBoneName=Shell_Ejector
    bRandomPitchFireSound=true
    bPawnRapidFireAnim=True
    bAttachSmokeEmitter=True
    RecoilRate=0.07
    maxVerticalRecoilAngle=325
    maxHorizontalRecoilAngle=135
    RecoilVelocityScale=0.3
    TweenTime=0.05
    AmmoPerFire=1
    SpreadStyle=SS_Random
    bWaitForRelease=false
}