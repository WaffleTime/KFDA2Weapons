//-----------------------------------------------------------
//
//-----------------------------------------------------------
class da_GK2Fire extends KFShotgunFire;

var()           class<Emitter>  ShellEjectClass;            // class of the shell eject emitter
var()           Emitter         ShellEjectEmitter;          // The shell eject emitter
var()           name            ShellEjectBoneName;         // name of the shell eject bone

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

	return super(WeaponFire).AllowFire();
}

simulated function InitEffects()
{
    super.InitEffects();

    // don't even spawn on server
    if ( (Level.NetMode == NM_DedicatedServer) || (AIController(Instigator.Controller) != None) )
		return;
    if ( (ShellEjectClass != None) && ((ShellEjectEmitter == None) || ShellEjectEmitter.bDeleteMe) )
    {
        ShellEjectEmitter = Weapon.Spawn(ShellEjectClass);
        Weapon.AttachToBone(ShellEjectEmitter, ShellEjectBoneName);
    }
    if ( FlashEmitter != None )
		Weapon.AttachToBone(FlashEmitter, 'Muzzle');
}

function DrawMuzzleFlash(Canvas Canvas)
{
    super.DrawMuzzleFlash(Canvas);
    // Draw shell ejects
    if (ShellEjectEmitter != None )
    {
        Canvas.DrawActor( ShellEjectEmitter, false, false, Weapon.DisplayFOV );
    }
}

function FlashMuzzleFlash()
{
    super.FlashMuzzleFlash();

    /*if (ShellEjectEmitter != None)
    {
        ShellEjectEmitter.Trigger(Weapon, Instigator);
    }*/
}

//this does a shell eject triggered by anim notify
simulated function Notify_EjectShell()
{
    if (ShellEjectEmitter != None)
    {
        ShellEjectEmitter.Trigger(Weapon, Instigator);
    }
}

simulated function DestroyEffects()
{
    super.DestroyEffects();

    if (ShellEjectEmitter != None)
        ShellEjectEmitter.Destroy();
}

defaultproperties
{
     ShellEjectClass=Class'KFDA2Weapons.da_ShellEjectShotty'
     ShellEjectBoneName="Shell_Ejector"
     ProjPerFire=10
     ProjSpawnOffset=(X=25.000000,Y=5.000000,Z=-6.000000)
     bWaitForRelease=False //True
     TransientSoundVolume=4.200000
     TransientSoundRadius=350.000000
     FireSound=Sound'DA2_WeaponSounds.Gunshots.GK2_Fire'
     StereoFireSoundRef="DA2_WeaponSounds.Gunshots.GK2_Fire"
     FireRate=0.857 //0.965000
     AmmoClass=Class'KFDA2Weapons.da_GK2Ammo'
     AmmoPerFire=1
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=400.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeRotTime=5.000000
     ShakeOffsetMag=(X=-8.000000,Y=2.000000,Z=10.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=3.000000
     ProjectileClass=Class'KFDA2Weapons.da_proj_Shotgun'
     BotRefireRate=0.980000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stKar'
     aimerror=1.000000
     Spread=1100.000000
     SpreadStyle=SS_Random

     FireAnim="Fire"
     FireAnimRate=1.0
     NoAmmoSound=Sound'KF_9MMSnd.9mm_DryFire'
     
     bRandomPitchFireSound=false
     FireAimedAnim="Fire"
     bPawnRapidFireAnim=True
     bAttachSmokeEmitter=True
     RecoilRate=0.12
     maxVerticalRecoilAngle=1500
     maxHorizontalRecoilAngle=900
     TweenTime=0.025
     bFiringDoesntAffectMovement=true
}