//-----------------------------------------------------------
//
//-----------------------------------------------------------
class da_LK2MedicFire extends KFShotgunFire;

var()           class<Emitter>  ShellEjectClass;            // class of the shell eject emitter
var()           Emitter         ShellEjectEmitter;          // The shell eject emitter
var()           name            ShellEjectBoneName;         // name of the shell eject bone

simulated function bool AllowFire()
{
                                                                             //changed to 1 -- PooSH
    if( KFWeapon(Weapon).bIsReloading && KFWeapon(Weapon).MagAmmoRemaining < 1)
        return false;

    if(KFPawn(Instigator).SecondaryItem!=none)
        return false;
    if( KFPawn(Instigator).bThrowingNade )
        return false;

    if( Level.TimeSeconds - LastClickTime>FireRate )
    {
        LastClickTime = Level.TimeSeconds;
    }

    if( KFMedicGun(Weapon).MagAmmoRemaining<1 )
    {
        return false;
    }

    // Let the weapon chamber if interrupting on a full reload
    if (KFWeapon(Weapon).bIsReloading && da_LK2MedicShotgun(Weapon).bChamberThisReload)
    {
        KFWeapon(Weapon).InterruptReload();
        NextFireTime = Level.TimeSeconds + (da_LK2MedicShotgun(Weapon).ChamberTime / da_LK2MedicShotgun(Weapon).GetReloadMultiplier());
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
     ProjPerFire=6
     ProjSpawnOffset=(X=25.000000,Y=5.000000,Z=-6.000000)
     bWaitForRelease=False
     TransientSoundVolume=2.650000
     TransientSoundRadius=350.000000
     FireSound=Sound'DA2_WeaponSounds.Gunshots.LK2_Fire'
     StereoFireSoundRef="DA2_WeaponSounds.Gunshots.LK2_Fire"
     FireRate=0.450000
     AmmoClass=Class'KFDA2Weapons.da_LK2Ammo'
     AmmoPerFire=1
     ShakeRotMag=(X=50.000000,Y=50.000000,Z=250.000000)
     ShakeRotRate=(X=12500.000000,Y=12500.000000,Z=12500.000000)
     ShakeRotTime=3.000000
     ShakeOffsetMag=(X=-16.000000,Y=2.000000,Z=6.000000)
     ShakeOffsetRate=(X=1000.000000,Y=1000.000000,Z=1000.000000)
     ShakeOffsetTime=1.250000
     ProjectileClass=Class'KFDA2Weapons.da_proj_Shotgun'
     BotRefireRate=0.980000
     FlashEmitterClass=Class'ROEffects.MuzzleFlash1stSTG'
     aimerror=1.000000
     Spread=900.000000
     SpreadStyle=SS_Random

     FireAnim="Fire"
     FireAnimRate=1.0
     NoAmmoSound=Sound'KF_9MMSnd.9mm_DryFire'
     
     bRandomPitchFireSound=false
     FireAimedAnim="Fire"
     bPawnRapidFireAnim=True
     bAttachSmokeEmitter=True
     RecoilRate=0.10
     maxVerticalRecoilAngle=600 //
     maxHorizontalRecoilAngle=500
     TweenTime=0.025
     bFiringDoesntAffectMovement=true
}