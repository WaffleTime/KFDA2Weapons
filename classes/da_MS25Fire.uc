//-----------------------------------------------------------
//
//-----------------------------------------------------------
class da_MS25Fire extends ScrnLAWFire;

#EXEC OBJ LOAD FILE=DA2_WeaponSounds.uax

//
simulated function PostNetBeginPlay()
{
    local rotator r;

    r.pitch=-16384; //
    weapon.SetBoneRotation('Muzzle', r, 0, 1.f);
}

function ServerPlayFiring()
{
    Weapon.PlayOwnedSound(FireSound,SLOT_None,TransientSoundVolume,,TransientSoundRadius,0.95+(frand()*0.1),false);
    Weapon.PlayOwnedSound(Sound'DA2_WeaponSounds.MS25_Fire',SLOT_None,TransientSoundVolume/3,,TransientSoundRadius*15,0.95+(frand()*0.1),false);
    Super(KFShotgunFire).ServerPlayFiring();
}

//disabled instant zoom out
function PlayFiring()
{
    Super(KFShotgunFire).PlayFiring();
}

//function PlayFiring()
//{
//	if ( Weapon.Mesh != none && FireCount > 0 )
//	{
//		if ( Weapon.HasAnim(FireLoopAnim) )
//			Weapon.PlayAnim(FireLoopAnim, FireLoopAnimRate, 0.0);
//		else
//			Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
//	}
//	else
//		Weapon.PlayAnim(FireAnim, FireAnimRate, TweenTime);
//
//    Weapon.PlayOwnedSound(FireSound,SLOT_None,TransientSoundVolume,,TransientSoundRadius,0.95+(frand()*0.1),false);
//    Weapon.PlayOwnedSound(Sound'DA2_WeaponSounds.MS25_Fire',SLOT_None,TransientSoundVolume/3,,TransientSoundRadius*15,0.95+(frand()*0.1),false);
//
//    ClientPlayForceFeedback(FireForce);
//    FireCount++;
//}

simulated function bool AllowFire()
{
	if(KFWeapon(Weapon).bIsReloading)
		return false;
	if(KFPawn(Instigator).SecondaryItem!=none)
		return false;
	if(KFPawn(Instigator).bThrowingNade)
		return false;

	if(KFWeapon(Weapon).MagAmmoRemaining < 1)
	{
    	if( Level.TimeSeconds - LastClickTime>FireRate )
    	{
    		LastClickTime = Level.TimeSeconds;
    	}

		if( AIController(Instigator.Controller)!=None )
			KFWeapon(Weapon).ReloadMeNow();
		return false;
	}

    //log("Spread = "$Spread);

	return super(WeaponFire).AllowFire();
}

defaultproperties
{
    ProjPerFire=1
    ProjSpawnOffset=(X=35.000000,Y=8.000000,Z=-6.000000)
    bWaitForRelease=True //True
    TransientSoundVolume=2.800000
    TransientSoundRadius=350.000000
    FireSoundRef="DA2_WeaponSounds.Gunshots.MS25_Fire"
    StereoFireSoundRef="DA2_WeaponSounds.Gunshots.MS25_Fire"
    StereoFireSound=Sound'DA2_WeaponSounds.Gunshots.MS25_Fire'
    FireRate=0.9 //2.5
    AmmoClass=Class'KFDA2Weapons.da_MS25Ammo'
    AmmoPerFire=1
    ShakeRotMag=(X=200.000000,Y=200.000000,Z=200.000000)
    ShakeRotRate=(X=3000.000000,Y=3000.000000,Z=3000.000000)
    ShakeRotTime=2.000000
    ShakeOffsetMag=(X=-40.000000,Y=23.000000,Z=27.000000)
    ShakeOffsetTime=1.500000
    ProjectileClass=Class'KFDA2Weapons.da_proj_rocket'
    aimerror=0.000000
    Spread=1.000000
    SpreadStyle=SS_Random

    FireAnim="Fire"
    FireAnimRate=1.0
    NoAmmoSound=Sound'KF_9MMSnd.9mm_DryFire'

    bRandomPitchFireSound=false
    FireAimedAnim="Fire_Iron"
    bPawnRapidFireAnim=True
    bAttachSmokeEmitter=True
    RecoilRate=0.10
    maxVerticalRecoilAngle=800
    maxHorizontalRecoilAngle=250
    TweenTime=0.025
    bFiringDoesntAffectMovement=true
}