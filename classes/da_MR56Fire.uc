//-----------------------------------------------------------
//
//-----------------------------------------------------------
class da_MR56Fire extends da_BasicFire;

// MR56 is special in which I had to edit the bone in blender 90 degrees one way to get it to match DA2
simulated function PostNetBeginPlay()
{
    local rotator r;

    r.pitch=16384; // This is negative for every other gun, is there something Im missing because I had to edit the bone on this gun to get it looking correct
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
     MuzEmitterClass=Class'KFDA2Weapons.da_MR56Muzzle1st'
     FlashEmitterClass=Class'KFDA2Weapons.da_MR56Muzzle1st'
     DamageType=Class'KFDA2Weapons.da_damtypes_MR56Rifle'
     DamageMin=12
     DamageMax=39 //18 OG
     Momentum=8500.000000
     TransientSoundVolume=2.250000
     TransientSoundRadius=250.000000
     FireLoopAnimRate=1.0
     FireAnim="Fire_Loop"
     FireLoopAnim="Fire_Loop"
     FireEndAnim="Fire_End"
     FireAimedAnim="Fire_Loop"
     FireLoopAimedAnim="Fire_Loop"
     FireEndAimedAnim="Fire_End"
     FireAnimRate=1.0
     FireSound=Sound'DA2_WeaponSounds.Gunshots.MR-56_Fire'
     StereoFireSoundRef="DA2_WeaponSounds.Gunshots.MR-56_Fire"
     NoAmmoSound=Sound'KF_9MMSnd.9mm_DryFire'
     FireRate=0.096000
     AmmoClass=Class'KFDA2Weapons.da_MR56Ammo'
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=300.000000)
     ShakeRotRate=(X=7500.000000,Y=7500.000000,Z=7500.000000)
     ShakeRotTime=0.650000
     ShakeOffsetMag=(X=-8.000000,Y=3.000000,Z=7.500000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000)
     ShakeOffsetTime=1.150000
     BotRefireRate=0.990000
     aimerror=42.000000
     Spread=0.012500 //0.025000

     ShellEjectClass=class'KFDA2Weapons.da_ShellEjectRifle'
     ShellEjectBoneName=Shell_Ejector
     bRandomPitchFireSound=true
     bPawnRapidFireAnim=True
     bAttachSmokeEmitter=True
     RecoilRate=0.07
     maxVerticalRecoilAngle=250
     maxHorizontalRecoilAngle=100
     RecoilVelocityScale=0.3
     TweenTime=0.05
     AmmoPerFire=1
     SpreadStyle=SS_Random
     bWaitForRelease=false
}